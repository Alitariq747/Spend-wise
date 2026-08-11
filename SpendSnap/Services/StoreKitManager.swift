//
//  StoreKitManager.swift
//  SpendSnap
//
//  Created by Codex on 13/02/2026.
//

import Foundation
import StoreKit

enum SpendWiseProductIDs {
    static let monthly = "sw1"
    static let yearly = "sw2"
    static let all = [monthly, yearly]
    static let subscriptionGroupID = "21928894"
}

enum StoreKitPurchaseOutcome {
    case success(productID: String)
    case pending
    case userCancelled
    case failed(message: String)
}

enum StoreKitRestoreOutcome {
    case restored
    /// The sync succeeded and this Apple Account simply owns nothing.
    case nothingToRestore
    /// The user backed out of the App Store sign-in prompt, or a restore was
    /// already running. Either way they made no request — say nothing.
    case cancelled
    case failed(message: String)
}

@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var activeProductIDs: Set<String> = []
    @Published private(set) var isEntitlementsLoaded = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published var lastErrorMessage: String?

    var hasActiveSubscription: Bool {
        !activeProductIDs.isEmpty
    }
    
    /// Prefer the live group ID from loaded products, with ASC value as safe fallback.
    var resolvedSubscriptionGroupID: String {
        products.compactMap { $0.subscription?.subscriptionGroupID }.first ?? SpendWiseProductIDs.subscriptionGroupID
    }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactionUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let fetched = try await Product.products(for: SpendWiseProductIDs.all)
            products = fetched.sorted { lhs, rhs in
                sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
            }
            if products.isEmpty {
                lastErrorMessage = "No subscription products were returned."
            } else {
                lastErrorMessage = nil
            }
        } catch {
            lastErrorMessage = "Failed to load subscription products."
        }
    }

    func refreshEntitlements() async {
        var active: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard let transaction = verified(from: result) else { continue }
            guard SpendWiseProductIDs.all.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            guard !transaction.isUpgraded else { continue }

            if let expirationDate = transaction.expirationDate {
                if expirationDate > Date() {
                    active.insert(transaction.productID)
                }
            } else {
                active.insert(transaction.productID)
            }
        }

        activeProductIDs = active
        isEntitlementsLoaded = true
    }

    func purchase(_ product: Product) async -> StoreKitPurchaseOutcome {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                guard let transaction = verified(from: verification) else {
                    return .failed(message: "Purchase verification failed.")
                }

                await transaction.finish()
                await refreshEntitlements()
                return .success(productID: transaction.productID)

            case .pending:
                return .pending

            case .userCancelled:
                return .userCancelled

            @unknown default:
                return .failed(message: "Unknown purchase result.")
            }
        } catch {
            return .failed(message: "Purchase request failed.")
        }
    }

    func restorePurchases() async -> StoreKitRestoreOutcome {
        // Both restore buttons disable themselves while this runs, so this guard
        // is belt-and-braces — but a second `AppStore.sync()` raises its own App
        // Store sign-in prompt, and stacked credential prompts read as a bug.
        guard !isRestoring else { return .cancelled }

        isRestoring = true
        defer { isRestoring = false }

        // StoreKit already holds a local record of what this Apple Account owns,
        // and a reinstall is handed it once the account attaches — often a moment
        // *after* the launch read, which is why the UI can still be showing the
        // restore button. Re-reading first settles the common case for free;
        // `AppStore.sync()` is a round trip that always demands a password, so it
        // is kept for the case that genuinely needs it.
        await refreshEntitlements()
        if hasActiveSubscription { return .restored }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return hasActiveSubscription ? .restored : .nothingToRestore
        } catch StoreKitError.userCancelled {
            // Dismissing the sign-in sheet is a decision, not a fault. Reporting
            // it as a failure invites the user to retry something that worked.
            return .cancelled
        } catch StoreKitError.networkError {
            return .failed(message: "Couldn't reach the App Store. Check your connection and try again.")
        } catch {
            return .failed(message: "Restore failed. Please try again.")
        }
    }

    static func hasAnyActiveSubscription() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SpendWiseProductIDs.all.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            guard !transaction.isUpgraded else { continue }

            if let expirationDate = transaction.expirationDate {
                if expirationDate > Date() {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = self.verified(from: result) else { continue }

                await transaction.finish()
                await self.refreshEntitlements()
            }
        }
    }

    private func sortIndex(for productID: String) -> Int {
        SpendWiseProductIDs.all.firstIndex(of: productID) ?? .max
    }

    private func verified<T>(from result: VerificationResult<T>) -> T? {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            return nil
        }
    }
}

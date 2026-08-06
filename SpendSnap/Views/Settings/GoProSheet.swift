//
//  GoProSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/10/2025.
//

import SwiftUI
import StoreKit

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case monthly
    case yearly
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var period: String {
        switch self {
        case .monthly: return "month"
        case .yearly: return "year"
        }
    }
    
    var productID: String {
        switch self {
        case .monthly:
            return SpendWiseProductIDs.monthly
        case .yearly:
            return SpendWiseProductIDs.yearly
        }
    }
}

enum PremiumFeature: String, CaseIterable, Identifiable {
    case expenses
    case budgets
    case categories
    case iCloudBackup
    case widgets
    case reminders
    case display
    case card
    case support

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .expenses: return "checkmark.seal.fill"
        case .budgets: return "checkmark.seal.fill"
        case .categories: return "checkmark.seal.fill"
        case .iCloudBackup: return "checkmark.seal.fill"
        case .widgets: return "checkmark.seal.fill"
        case .reminders: return "checkmark.seal.fill"
        case .display: return "checkmark.seal.fill"
        case .card: return "checkmark.seal.fill"
        case .support: return "heart.fill"
        }
    }

    var text: String {
        switch self {
        case .expenses: return "Add and track expenses"
        case .budgets: return "Monthly and category budgets"
        case .categories: return "Custom categories"
        case .iCloudBackup: return "iCloud sync across devices"
        case .widgets: return "Home Screen widgets"
        case .reminders: return "Expense reminders"
        case .display: return "Light and dark appearance"
        case .card: return "Credit card tracking"
        case .support: return "Support an indie developer"
        }
    }
}

struct GoProSheet: View {
    private enum TrialEligibilityState {
        case checking
        case unavailable
        case eligible
        case ineligible
        case noOffer
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var storeKit: StoreKitManager
    @State private var selectedTier: SubscriptionTier = .monthly
    @State private var paywallMessage: String?
    @State private var trialEligibilityState: TrialEligibilityState = .checking
    
    private enum PaywallLinks {
        static let privacy = URL(string: "https://ahmadtariq.co/apps/spendwise/privacy")!
        static let terms = URL(string: "https://ahmadtariq.co/apps/spendwise/terms")!
    }
    
    private func product(for tier: SubscriptionTier) -> Product? {
        storeKit.products.first(where: { $0.id == tier.productID })
    }
    
    /// A tier is purchasable only when StoreKit returned a product *and* its
    /// subscription terms, since a price may never be shown without them.
    private func isAvailable(_ tier: SubscriptionTier) -> Bool {
        product(for: tier)?.subscription != nil
    }

    /// The only source of a currency string in this view. Never falls back to a
    /// literal — an unavailable tier has no price to show.
    private func displayPrice(for tier: SubscriptionTier) -> String? {
        guard isAvailable(tier) else { return nil }
        return product(for: tier)?.displayPrice
    }

    private func pricePerPeriod(for tier: SubscriptionTier) -> String? {
        guard let price = displayPrice(for: tier) else { return nil }
        return "\(price)/\(tier.period)"
    }

    private var isUnavailable: Bool {
        trialEligibilityState == .unavailable
    }

    private var chargeDisclosureTitle: String {
        switch trialEligibilityState {
        case .checking, .unavailable:
            return "Final details shown by App Store"
        case .eligible:
            return "14-day free trial"
        case .ineligible, .noOffer:
            return "Subscribe anytime"
        }
    }

    private var paywallTitle: String {
        switch trialEligibilityState {
        case .eligible:
            return "Start your 14-day free trial"
        case .checking, .unavailable:
            return "Subscribe to SpendWise Pro"
        case .ineligible, .noOffer:
            return "Subscribe to SpendWise Pro"
        }
    }

    private var chargeDisclosureDetail: String {
        // No real price means no terms can be stated. The unavailable notice
        // replaces this banner entirely, so this is a belt-and-braces guard.
        guard let price = pricePerPeriod(for: selectedTier) else {
            return "Review the price and terms before confirming with the App Store."
        }

        switch trialEligibilityState {
        case .checking, .unavailable:
            return "Review the price and terms before confirming with the App Store."
        case .eligible:
            return "Nothing due today. After 14 days, you'll be charged \(price), auto-renewing unless canceled."
        case .ineligible, .noOffer:
            return "\(price), auto-renewing. Cancel anytime in App Store settings."
        }
    }

    private var chargeDisclosureAccent: Color {
        switch trialEligibilityState {
        case .checking, .unavailable:
            return .gray
        case .eligible:
            return .green
        case .ineligible, .noOffer:
            return .orange
        }
    }
    
    private var chargeDisclosureBanner: some View {
        let accent = chargeDisclosureAccent

        return HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(accent.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chargeDisclosureTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(chargeDisclosureDetail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accent.opacity(0.22), lineWidth: 1)
        )
    }

    private var productsUnavailableNotice: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.orange.opacity(0.9))

            VStack(alignment: .leading, spacing: 2) {
                Text("Plans couldn't be loaded")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Check your internet connection and try again. Prices and subscription terms appear once plans load.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.22), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var purchaseDisclosureSection: some View {
        if isUnavailable {
            productsUnavailableNotice
        } else {
            chargeDisclosureBanner
        }
    }

    private func refreshTrialEligibilityState() async {
        await MainActor.run {
            trialEligibilityState = .checking
        }

        guard let subscription = product(for: selectedTier)?.subscription else {
            await MainActor.run {
                trialEligibilityState = .unavailable
            }
            return
        }

        guard subscription.introductoryOffer != nil else {
            await MainActor.run {
                trialEligibilityState = .noOffer
            }
            return
        }
        
        let isEligible = await Product.SubscriptionInfo.isEligibleForIntroOffer(
            for: subscription.subscriptionGroupID
        )
        
        await MainActor.run {
            trialEligibilityState = isEligible ? .eligible : .ineligible
        }
    }
    
    private func handleRetryTap() {
        Task {
            paywallMessage = nil
            await storeKit.loadProducts()
            // Re-run explicitly: a repeated failure leaves `products` empty, so
            // the onChange(of:) observer would not fire on its own.
            await refreshTrialEligibilityState()
        }
    }

    private func handleSubscribeTap() {
        guard let selectedProduct = product(for: selectedTier) else {
            paywallMessage = "Plan is unavailable right now. Please try again."
            return
        }
        
        Task {
            let outcome = await storeKit.purchase(selectedProduct)
            switch outcome {
            case .success(_):
                paywallMessage = nil
                dismiss()
            case .pending:
                paywallMessage = "Purchase is pending approval."
            case .userCancelled:
                paywallMessage = nil
            case .failed(let message):
                paywallMessage = message
            }
        }
    }
    
    private var primaryButtonTitle: String {
        if storeKit.isPurchasing { return "Processing..." }
        if isUnavailable { return storeKit.isLoadingProducts ? "Loading..." : "Try Again" }
        return "Continue"
    }

    private var isPrimaryButtonDisabled: Bool {
        if storeKit.isPurchasing { return true }
        if isUnavailable { return storeKit.isLoadingProducts }
        return product(for: selectedTier) == nil
    }

    private var showsPrimaryButtonSpinner: Bool {
        storeKit.isPurchasing || (isUnavailable && storeKit.isLoadingProducts)
    }

    /// The unavailable notice already explains a failed product load, so the
    /// generic store error is suppressed there rather than stated twice.
    private var statusMessage: String? {
        if let paywallMessage { return paywallMessage }
        if isUnavailable { return nil }
        return storeKit.lastErrorMessage
    }

    private func handleRestoreTap() {
        Task {
            let restored = await storeKit.restorePurchases()
            paywallMessage = restored ? "Subscription restored successfully." : "No active subscription found to restore."
        }
    }
    
    var body: some View {
        ScrollView {
        VStack(spacing: 18) {
            // HStack for close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .disabled(storeKit.isPurchasing)
                .opacity(storeKit.isPurchasing ? 0.35 : 1)
            }
            Image(systemName: "crown.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.05), in: Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
            
            Text(paywallTitle)
                .font(.system(size: 18, weight: .semibold))
            Text("Adding and tracking expenses requires an active SpendWise Pro subscription. Here's everything included.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
            
            
            VStack(spacing: 8) {
                ForEach(PremiumFeature.allCases) { feature in
                    HStack(alignment: .center) {
                        Image(systemName: feature.emoji)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(feature != .support ? Color.green.opacity(0.6) : Color.pink.opacity(0.6))
                            .frame(width: 26, alignment: .leading)
                        Text(feature.text)
                            .font(.system(size: 14, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: 260, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            // VStack for monthly
            HStack(spacing: 8) {
                ForEach(SubscriptionTier.allCases) { sub in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: "\(sub.title) Subscription")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text(verbatim: displayPrice(for: sub).map { "\($0) / \(sub.period)" } ?? "—")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedTier == sub ? Color.gray : Color.gray.opacity(0.05), lineWidth: selectedTier == sub ? 2 : 1))
                    .onTapGesture {
                        guard !storeKit.isPurchasing else { return }
                        selectedTier = sub
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            purchaseDisclosureSection


            Button {
                if isUnavailable {
                    handleRetryTap()
                } else {
                    handleSubscribeTap()
                }
            } label: {
                HStack(spacing: 8) {
                    if showsPrimaryButtonSpinner {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(primaryButtonTitle)
                        .font(.system(size: 18, weight: .semibold))
                }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(colorScheme == .light ? Color.black : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                
                
            }
            .disabled(isPrimaryButtonDisabled)
            Button {
                handleRestoreTap()
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(storeKit.isPurchasing)
            
            if storeKit.isLoadingProducts && !isUnavailable {
                ProgressView("Loading plans...")
                    .font(.system(size: 12, weight: .regular))
            }

            if let message = statusMessage {
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            
            HStack(spacing: 6) {
                Button("Terms of Service") {
                    openURL(PaywallLinks.terms)
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                
                Text("•")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                
                Button("Privacy Policy") {
                    openURL(PaywallLinks.privacy)
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
        }
        .padding()
        .interactiveDismissDisabled(storeKit.isPurchasing)
        .task {
            if storeKit.products.isEmpty {
                await storeKit.loadProducts()
            }
            if !storeKit.isEntitlementsLoaded {
                await storeKit.refreshEntitlements()
            }
            await refreshTrialEligibilityState()
        }
        .onChange(of: selectedTier) {
            Task {
                await refreshTrialEligibilityState()
            }
        }
        .onChange(of: storeKit.products.map(\.id)) {
            Task {
                await refreshTrialEligibilityState()
            }
        }
        }
    }
}

#Preview {
    GoProSheet()
        .environmentObject(StoreKitManager())
}

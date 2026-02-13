//
//  SpendSnapApp.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

@MainActor
final class AppBootController: ObservableObject {
    enum State {
        case loading
        case ready(ModelContainer, cloudKitEnabled: Bool)
        case failed(primary: Error, fallbackError: Error?)
    }

    @Published private(set) var state: State = .loading
    private var didStart = false

    func start() {
        guard !didStart else { return }
        didStart = true
        loadContainer()
    }

    func retry() {
        state = .loading
        didStart = false
        start()
    }

    private func loadContainer() {
        let primary = Self.buildContainer(cloudKit: .automatic)
        switch primary {
        case .success(let container):
            state = .ready(container, cloudKitEnabled: true)
        case .failure(let error):
            logBootError(error, label: "primary")
            let fallback = Self.buildContainer(cloudKit: .none)
            switch fallback {
            case .success(let container):
                state = .ready(container, cloudKitEnabled: false)
            case .failure(let fallbackError):
                logBootError(fallbackError, label: "fallback")
                state = .failed(primary: error, fallbackError: fallbackError)
            }
        }
    }

    private static func buildContainer(cloudKit: ModelConfiguration.CloudKitDatabase) -> Result<ModelContainer, Error> {
        let schema = Schema([
            Expense.self,
            CategoryEntity.self,
            CategoryMonthlyBudget.self,
            Budget.self,
            CreditCard.self,
            Settings.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.ahmad.SpendWise"),
            cloudKitDatabase: cloudKit
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            return .success(container)
        } catch {
            return .failure(error)
        }
    }

    private func logBootError(_ error: Error, label: String) {
        UserDefaults.standard.set("ModelContainer \(label) failure: \(error)", forKey: "AppBoot.lastError")
        #if DEBUG
        print("⚠️ ModelContainer \(label) failure: \(error)")
        #endif
    }
}

@main
struct SpendSnapApp: App {
    @StateObject private var boot = AppBootController()
    @StateObject private var storeKit = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            AppBootView(boot: boot)
                .environmentObject(storeKit)
        }
    }
}

private struct AppBootView: View {
    @ObservedObject var boot: AppBootController
    @EnvironmentObject private var storeKit: StoreKitManager

    var body: some View {
        Group {
            switch boot.state {
            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Preparing your data…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            case .ready(let container, _):
                AppEntryView()
                    .modelContainer(container)
            case .failed(let primary, let fallback):
                BootErrorView(primary: primary, fallback: fallback, onRetry: boot.retry)
            }
        }
        .task {
            boot.start()
            if !storeKit.isEntitlementsLoaded {
                await storeKit.refreshEntitlements()
            }
            if storeKit.products.isEmpty {
                await storeKit.loadProducts()
            }
        }
    }
}

private struct BootErrorView: View {
    let primary: Error
    let fallback: Error?
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.orange)

            Text("We couldn’t open your data")
                .font(.headline)

            Text("Please try again. If this keeps happening, reinstall the app or contact support.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)

            #if DEBUG
            VStack(alignment: .leading, spacing: 6) {
                Text("Primary error: \(primary.localizedDescription)")
                if let fallback {
                    Text("Fallback error: \(fallback.localizedDescription)")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            #endif
        }
        .padding()
    }
}

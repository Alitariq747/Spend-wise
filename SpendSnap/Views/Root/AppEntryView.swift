//
//  AppEntryView.swift
//  SpendSnap
//
//  Created by Codex on 04/06/2025.
//

import SwiftUI
import SwiftData

struct AppEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKit: StoreKitManager
    @Query private var settingsRow: [Settings]
    @State private var showPostOnboardingPaywall = false
    
    var body: some View {
        Group {
            if let settings = settingsRow.first {
                if settings.onboardingComplete {
                    RootTabView(settings: settings)
                } else {
                    OnboardingView(settings: settings)
                }
            } else {
                ProgressView()
                    .task {
                        if settingsRow.isEmpty {
                            modelContext.insert(Settings())
                            try? modelContext.save()
                        }
                }
            }
        }
        .onChange(of: settingsRow.first?.onboardingComplete ?? false) { oldValue, newValue in
            guard oldValue == false, newValue == true else { return }
            Task {
                await presentPostOnboardingPaywallIfNeeded()
            }
        }
        .sheet(isPresented: $showPostOnboardingPaywall) {
            GoProSheet()
        }
    }

    @MainActor
    private func presentPostOnboardingPaywallIfNeeded() async {
        if !storeKit.isEntitlementsLoaded {
            await storeKit.refreshEntitlements()
        }
        if !storeKit.hasActiveSubscription {
            showPostOnboardingPaywall = true
        }
    }
}

#Preview {
    AppEntryView()
        .modelContainer(for: [
            Expense.self,
            CategoryEntity.self,
            CategoryMonthlyBudget.self,
            Budget.self,
            CreditCard.self,
            Settings.self
        ], inMemory: true)
        .environmentObject(StoreKitManager())
}

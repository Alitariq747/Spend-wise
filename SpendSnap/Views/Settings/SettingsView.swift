//
//  SettingsView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData
import StoreKit
import UIKit

enum LegalLinks {
    static let privacy = URL(string: "https://Alitariq747.github.io/spendwise-legal/privacy.html")!
    static let terms   = URL(string: "https://Alitariq747.github.io/spendwise-legal/terms.html")!
    static let contact = URL(string: "mailto:spendwise-app@outlook.com")!
}

struct SettingsView: View {
    @Environment(\.openURL) private var openUrl
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRow: [Settings]
    
    private var settings: Settings? {
        settingsRow.first
    }
  
    
    @State private var showCurrencySheet: Bool = false
    @State private var showRemindersSheet: Bool = false
    @State private var showGoProSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showWidgetInfoSheet: Bool = false
    @State private var isRestoringPurchases: Bool = false
    @State private var showRestoreAlert: Bool = false
    @State private var restoreAlertMessage: String = ""
    
    @StateObject private var iCloudVM = ICloudStatusViewModel()
    @EnvironmentObject private var storeKit: StoreKitManager
    @State private var showICloudToast = false
    
    private static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
    
    private var hasActiveSubscription: Bool {
        storeKit.hasActiveSubscription
    }
    
    private var subscriptionStatusText: String {
        guard storeKit.isEntitlementsLoaded else { return "Checking..." }
        return hasActiveSubscription ? "Subscription Active" : "No Subscription Active"
    }
    
    private var subscriptionBadgeText: String? {
        guard storeKit.isEntitlementsLoaded else { return nil }
        return hasActiveSubscription ? "Manage" : "Upgrade"
    }
    
    private func labelForStatus(_ status: ICloudStatus) -> String {
           switch status {
           case .unknown, .couldNotDetermine:
               return "Checking…"
           case .available:
               return "Enabled"
           case .noAccount:
               return "Sign in"
           case .restricted:
               return "Restricted"
           case .temporarilyUnavailable:
               return "Unavailable temporarily"
           }
       }

    
    var body: some View {
        
        
        let symbol = CurrencyUtil.symbol(for: settings?.currencyCode ?? "USD")
        
       
            
            ScrollView {
               
                Text("💸")
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                    .background(Color(.systemGray6), in: Circle())
                
             
                // Parent settings VStack
                VStack(alignment: .leading) {
                    Text("Subscription")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: storeKit.isEntitlementsLoaded ? (hasActiveSubscription ? "checkmark.seal.fill" : "crown.fill") : "clock")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(storeKit.isEntitlementsLoaded ? (hasActiveSubscription ? Color.green.opacity(0.8) : Color.orange.opacity(0.9)) : Color.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pro Plan")
                                .font(.system(size: 15, weight: .semibold))
                            Text(subscriptionStatusText)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let badgeText = subscriptionBadgeText {
                            Text(badgeText)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(hasActiveSubscription ? .primary : Color.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(hasActiveSubscription ? Color(.systemGray5) : Color.black, in: Capsule())
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleSubscriptionTap()
                    }
                    .allowsHitTesting(storeKit.isEntitlementsLoaded)
                    
                    if storeKit.isEntitlementsLoaded && !hasActiveSubscription {
                        Button {
                            Task {
                                await restorePurchasesFromSettings()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.primary)

                                Text("Restore Purchases")
                                    .font(.system(size: 15, weight: .semibold))
                                
                                Spacer()
                                
                                if isRestoringPurchases {
                                    ProgressView()
                                        .tint(.primary)
                                } else {
                                    Text("Restore")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.black, in: Capsule())
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            .contentShape(Rectangle())
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(isRestoringPurchases)
                    }
                    
                    // Currency Hstack
                   Text("App Settings")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .padding(.top, 12)

                    Currency(symbol: symbol) {
                        showCurrencySheet = true
                    }
 
                    // Appearance HStack
                  AppearanceRow(settings: settings)
                    
                    // Notifications HStack
                    Reminders(level: settings?.reminderLevel ?? .quiet) {
                     
                            showRemindersSheet = true
                   
                    }                  
                    
                    // HStack for widgets
                    WidgetRow(onTap: {
                        showWidgetInfoSheet = true
                    })
                    
                  
                    Text("iCloud")
                         .font(.system(size: 16, weight: .medium))
                         .foregroundStyle(.primary)
                         .padding(.top, 12)
                    // ICloud HStack
                    Button {
                               if iCloudVM.status != .available {
                                   withAnimation {
                                       showICloudToast = true
                                   }
                               }
                           } label: {
                               HStack {
                                   Text("iCloud Sync")
                                       .font(.system(size: 16, weight: .semibold))

                                   Spacer()

                                   Text(labelForStatus(iCloudVM.status))
                                       .font(.system(size: 14, weight: .light))
                                       .foregroundStyle(iCloudVM.status == .available ? .green : .secondary)
                               }
                               .padding(.horizontal)
                               .padding(.vertical, 18)
                               .contentShape(Rectangle())
                               .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                           }
                           .buttonStyle(.plain)
                    
                   
                   
                    
                    
                    Text("General")
                         .font(.system(size: 16, weight: .medium))
                         .foregroundStyle(.primary)
                         .padding(.top, 12)
                    
                  
                    Button {
                        openUrl(LegalLinks.privacy)
                    } label: {
                        PrivacyPolicyRow()
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        openUrl(LegalLinks.terms)
                    } label: {
                        TermsOfServiceRow()
                    }
                    .buttonStyle(.plain)
                    Button {
                        openUrl(LegalLinks.contact)
                    } label: {
                        ContactUsRow()
                    }
                    .buttonStyle(.plain)
                    
                   RateUsRow(onTap: {print("Tapped rate us")})
                    
                }
                .padding()
              
                
             // Delete Button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                }
                .padding(.horizontal)

            }
            .padding(.vertical)
           
            .task {
                        await iCloudVM.refresh()
                        if !storeKit.isEntitlementsLoaded {
                            await storeKit.refreshEntitlements()
                        }
                        if storeKit.products.isEmpty {
                            await storeKit.loadProducts()
                        }
                    }
            .overlay(alignment: .bottom) {
                        if showICloudToast {
                            Text("Sign in to iCloud in Settings to sync your SpendWise data across devices.")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(Color.black.opacity(0.85))
                                )
                                .padding(.bottom, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showICloudToast = false
                                        }
                                    }
                                }
                        }
                    }
        .sheet(isPresented: $showCurrencySheet) {
            CurrencyPickerSheet(allCurrencies: CurrencyOption.allCurrencies, selectedCode: settings?.currencyCode ?? "USD") {
                newCode in
                settings?.currencyCode = newCode
                try? modelContext.save()
            }
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showRemindersSheet) {
            RemindersSelectionView(selectedReminderLevel: settings?.reminderLevel ?? .quiet) {  newLevel in
                settings?.reminderLevel = newLevel
                try? modelContext.save()
                if newLevel == .quiet {
                           NotificationManager.shared.clearAll()
                       } else {
                           NotificationManager.shared.requestPermission()
                           NotificationManager.shared.schedule(times: newLevel.times)
                       }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showGoProSheet) {
            GoProSheet()
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showDeleteConfirmation) {
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 4)
                    .foregroundColor(Color(.systemGray4))
                    .padding(.top, 8)

                Text("Delete Everything!")
                    .font(.headline)

                Text("This will delete everything including expenses, categories,cards and your currency settings. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    Button("Delete") {
                        deleteAllData()
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showWidgetInfoSheet) {
            WidgetInfoSheet()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreAlertMessage)
        }
    }
    
    private func handleSubscriptionTap() {
        guard storeKit.isEntitlementsLoaded else { return }
        if hasActiveSubscription {
            Task {
                await openManageSubscriptions()
            }
        } else {
            showGoProSheet = true
        }
    }
    
    @MainActor
    private func openManageSubscriptions() async {
        if let windowScene = activeWindowScene() {
            do {
                if #available(iOS 17.0, *) {
                    try await AppStore.showManageSubscriptions(
                        in: windowScene,
                        subscriptionGroupID: storeKit.resolvedSubscriptionGroupID
                    )
                } else {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                }
                return
            } catch {
                openUrl(Self.manageSubscriptionsURL)
                return
            }
        }
        openUrl(Self.manageSubscriptionsURL)
    }
    
    private func activeWindowScene() -> UIWindowScene? {
        let connectedScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return connectedScenes.first(where: { $0.activationState == .foregroundActive }) ?? connectedScenes.first
    }
    
    @MainActor
    private func restorePurchasesFromSettings() async {
        guard !isRestoringPurchases else { return }
        
        isRestoringPurchases = true
        defer { isRestoringPurchases = false }
        
        let restored = await storeKit.restorePurchases()
        
        if restored {
            restoreAlertMessage = "Your subscription was restored successfully."
        } else if let errorMessage = storeKit.lastErrorMessage {
            restoreAlertMessage = errorMessage
        } else {
            restoreAlertMessage = "No active purchases were found to restore."
        }
        
        showRestoreAlert = true
    }

    private func deleteAllData() {
        do {
            try deleteAll(of: Expense.self)
            try deleteAll(of: CategoryMonthlyBudget.self)
            try deleteAll(of: CategoryEntity.self)
            try deleteAll(of: Budget.self)
            try deleteAll(of: CreditCard.self)
            try deleteAll(of: Settings.self)

            try modelContext.save()
            print("✅ Deleted all data")
        } catch {
            print("❌ Failed to delete all data: \(error)")
        }
    }

    private func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try modelContext.fetch(descriptor)
        for item in items {
            modelContext.delete(item)
        }
    }

}

#Preview {
    SettingsView()
        .environmentObject(StoreKitManager())
}

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

extension Notification.Name {
    /// Posted synchronously after `DataWipe.deleteAll(in:)` commits,
    /// so views holding manually-fetched model arrays in `@State` can drop them
    /// before SwiftUI re-evaluates a body against an invalidated object.
    static let spendWiseDidDeleteAllData = Notification.Name("spendWiseDidDeleteAllData")
}

struct SettingsView: View {
    @Environment(\.openURL) private var openUrl
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var modelContext
    @Query(sort: Settings.oldestFirst) private var settingsRow: [Settings]
    
    private var settings: Settings? {
        settingsRow.first
    }
  
    
    @State private var showCurrencySheet: Bool = false
    @State private var showRemindersSheet: Bool = false
    @State private var showGoProSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showWidgetInfoSheet: Bool = false
    @State private var showRestoreAlert: Bool = false
    @State private var restoreAlertMessage: String = ""
    @State private var showDeleteResultAlert: Bool = false
    @State private var deleteResultTitle: String = ""
    @State private var deleteResultMessage: String = ""
    
    @StateObject private var iCloudVM = ICloudStatusViewModel()
    @EnvironmentObject private var storeKit: StoreKitManager
    @State private var showICloudToast = false
    @State private var showNotificationToast = false
    
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
        
        
        let symbol = CurrencyUtil.symbol(for: settings?.currencyCode ?? Settings.defaultCurrencyCode)
        
       
            
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
                                
                                if storeKit.isRestoring {
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
                        .disabled(storeKit.isRestoring)
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
                        openUrl(AppInfo.privacyURL)
                    } label: {
                        PrivacyPolicyRow()
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        openUrl(AppInfo.termsURL)
                    } label: {
                        TermsOfServiceRow()
                    }
                    .buttonStyle(.plain)
                    Button {
                        openUrl(AppInfo.supportURL)
                    } label: {
                        ContactUsRow()
                    }
                    .buttonStyle(.plain)
                    
                   RateUsRow {
                       requestReview()
                   }
                    
                }
                .padding()
              
                
             // Delete Button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete All Data")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .confirmationDialog(
                    "Delete All Data?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) { deleteAllSyncedData() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This permanently removes your expenses, income, categories, budgets, cards, bills and savings goals from this device — and from your other devices once iCloud finishes syncing. Your currency, appearance, and reminder preferences are kept. This can't be undone.")
                }

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
                        if showICloudToast || showNotificationToast {
                            Text(showNotificationToast ? "Notifications are off. Enable them in iPhone Settings to receive reminders." : "Sign in to iCloud in Settings to sync your \(AppInfo.name) data across devices.")
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
                                            showNotificationToast = false
                                        }
                                    }
                                }
                        }
                    }
        .sheet(isPresented: $showCurrencySheet) {
            CurrencyPickerSheet(allCurrencies: CurrencyOption.allCurrencies, selectedCode: settings?.currencyCode ?? Settings.defaultCurrencyCode) {
                newCode in
                settings?.currencyCode = newCode
                try? modelContext.save()
                // Every widget renders this symbol; without this they keep the
                // old one until their next scheduled timeline refresh.
                WidgetRefresh.reloadAll()
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
                           NotificationManager.shared.schedule(times: newLevel.times) {
                               DispatchQueue.main.async {
                                   withAnimation {
                                       showNotificationToast = true
                                   }
                               }
                           }
                       }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showGoProSheet) {
            GoProSheet()
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showWidgetInfoSheet) {
            WidgetInfoSheet()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreAlertMessage)
        }
        .alert(deleteResultTitle, isPresented: $showDeleteResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteResultMessage)
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
        switch await storeKit.restorePurchases() {
        case .restored:
            restoreAlertMessage = "Your subscription was restored successfully."

        case .nothingToRestore:
            restoreAlertMessage = "No active purchases were found to restore."

        // The user closed the sign-in sheet themselves; an alert confirming that
        // would be a second dialog they also have to dismiss.
        case .cancelled:
            return

        case .failed(let message):
            restoreAlertMessage = message
        }

        showRestoreAlert = true
    }

  
    private func deleteAllSyncedData() {
        do {
            try DataWipe.deleteAll(in: modelContext)

            // Synchronous, still inside this call stack — the tab views drop
            // their cached model arrays before SwiftUI can re-evaluate any body
            // against an invalidated object.
            NotificationCenter.default.post(name: .spendWiseDidDeleteAllData, object: nil)

            WidgetRefresh.reloadAll()

            deleteResultTitle = "All Data Deleted"
            deleteResultMessage = String(localized: "Your expenses, income, categories, budgets, cards, bills and savings goals have been removed. If iCloud sync is on, your other devices will update the next time they sync.")
        } catch {
            // DataWipe has already rolled the context back.
            deleteResultTitle = "Couldn't Delete Your Data"
            deleteResultMessage = "Something went wrong and your data wasn't deleted. Please try again, or contact us from the General section if the problem continues."
            #if DEBUG
            print("❌ Failed to delete all data: \(error)")
            #endif
        }

        showDeleteResultAlert = true
    }

}

#Preview {
    SettingsView()
        .environmentObject(StoreKitManager())
}

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
    
    var fallbackPrice: String {
        switch self {
        case .monthly: return "$2.99"
        case .yearly: return "$29.99"
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
    case iCloudBackup
    case widgets
    case reminders
   case display
    case card
    case support
    
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .iCloudBackup: return "checkmark.seal.fill"
        case .widgets: return "checkmark.seal.fill"
        case .reminders: return "checkmark.seal.fill"
        case .display: return "checkmark.seal.fill"
        case .card:
            return "checkmark.seal.fill"
        case .support: return "heart.fill"
        
      
        }
    }
    
    var text: String {
        switch self {
            case .iCloudBackup: return "iCloud Backup"
        case .widgets: return "Premium Widgets"
        case .reminders: return "Gentle Reminders"
        case .display: return "Dark mode support"
        case .card:
            return "Credit Card Tracking "
        case .support: return "Support Indie Developer"
       
        }
    }
}

struct GoProSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var storeKit: StoreKitManager
    @State private var selectedTier: SubscriptionTier = .monthly
    @State private var paywallMessage: String?
    
    private enum PaywallLinks {
        static let privacy = URL(string: "https://Alitariq747.github.io/spendwise-legal/privacy.html")!
        static let terms = URL(string: "https://Alitariq747.github.io/spendwise-legal/terms.html")!
    }
    
    private func product(for tier: SubscriptionTier) -> Product? {
        storeKit.products.first(where: { $0.id == tier.productID })
    }
    
    private func displayPrice(for tier: SubscriptionTier) -> String {
        product(for: tier)?.displayPrice ?? tier.fallbackPrice
    }
    
    private var chargeDisclosureBanner: some View {
        let detail = "Nothing due today. After 2 weeks, you'll be charged \(displayPrice(for: selectedTier))/\(selectedTier.period), auto-renewing unless canceled."

        return HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.green.opacity(0.85))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("2-week free trial")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.22), lineWidth: 1)
        )
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
                        .foregroundStyle(.black)
                }
            }
            Image(systemName: "crown.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.black.opacity(1))
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.05), in: Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
            
            Text("Ready to take Control?")
                .font(.system(size: 18, weight: .semibold))
            Text("Unlock all features to never over-run your hard earned income. You won't regret it!")
                .font(.system(size: 12, weight: .light))
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
            .frame(maxWidth: 200, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            // VStack for monthly
            HStack(spacing: 8) {
                ForEach(SubscriptionTier.allCases) { sub in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(sub.title) Subscription")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("\(displayPrice(for: sub)) / \(sub.period)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedTier == sub ? Color.gray : Color.gray.opacity(0.05), lineWidth: selectedTier == sub ? 2 : 1))
                    .onTapGesture {
                        selectedTier = sub
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            chargeDisclosureBanner
            
            
            Button {
                handleSubscribeTap()
            } label: {
                Text(storeKit.isPurchasing ? "Processing..." : "Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(colorScheme == .light ? Color.black : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                
                
            }
            .disabled(storeKit.isPurchasing || product(for: selectedTier) == nil)
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
            
            if storeKit.isLoadingProducts {
                ProgressView("Loading plans...")
                    .font(.system(size: 12, weight: .regular))
            }
            
            if let message = paywallMessage ?? storeKit.lastErrorMessage {
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
        .task {
            if storeKit.products.isEmpty {
                await storeKit.loadProducts()
            }
            if !storeKit.isEntitlementsLoaded {
                await storeKit.refreshEntitlements()
            }
        }
        }
    }
}

#Preview {
    GoProSheet()
        .environmentObject(StoreKitManager())
}

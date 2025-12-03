//
//  GoProSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/10/2025.
//

import SwiftUI

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case monthly
    case yearly
    case lifetime
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "$9.99 / month"
        case .yearly: return "$99.99 / year"
        case .lifetime: return "$999.99"
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
    let selected: SubscriptionTier = .yearly
    let onSubscribe: () -> Void
    var body: some View {
        
       
        VStack(spacing: 24) {
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
            .padding(.vertical)
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
                .foregroundStyle(.black.opacity(0.7))
                .multilineTextAlignment(.center)
            
           
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
            .frame(maxWidth: 200, alignment: .leading)   // the block itself is 320 wide, left-aligned inside
            .frame(maxWidth: .infinity, alignment: .center)
            
            // VStack for monthly
            VStack(spacing: 8) {
                ForEach(SubscriptionTier.allCases) { sub in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(sub.title) Subscription")
                            .font(.system(size: 14, weight: .semibold))
                        Text("\(sub.price)")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected == sub ? Color.darker : Color.gray.opacity(0.05), lineWidth: selected == sub ? 2 : 1))
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
              onSubscribe()
                dismiss()
            } label: {
                Text("Subscribe")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 14))
                
                
            }
          Text("Cancel anytime")
                .font(.system(size: 12, weight: .light))


        }
        .padding()
    }
}

#Preview {
    GoProSheet(onSubscribe: { print ("subscribed")})
}

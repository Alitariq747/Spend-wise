//
//  CategorySpendingCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/10/2025.
//

import SwiftUI
import SwiftData

struct CategorySpendingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let category: CategoryEntity
    let spent: Decimal
    let budget: Decimal
    let action: () -> Void

    private var percent: Double {
          guard budget > 0 else { return 0 }
          let s = NSDecimalNumber(decimal: spent).doubleValue
          let b = NSDecimalNumber(decimal: budget).doubleValue
          return min(max(s / b, 0), 1)
      }
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
    
        Button(action: action) {
                    VStack(alignment: .leading, spacing: 10) {
                        // row 1
                        HStack(alignment: .top) {
                            ZStack {
                                Circle().fill(Color(hex: category.colorHex)).frame(width:44,height:44)
                                Text(category.emoji).font(.system(size:22))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.name)
                                    .font(.system(size:16, weight: .semibold))
                                Text("\(symbol)\(spent)") // adapt currency
                                    .font(.system(size:14, weight:.medium))
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.system(size:14, weight:.medium))
                        }

                        // row 2
                        HStack {
                            Text("Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if budget > 0 {
                                HStack(spacing:8) {
                                    Text("\(symbol)\(budget)")
                                        .font(.system(size:14, weight:.semibold))
                                    Text("\(Int(percent * 100))%")
                                        .font(.caption2)
                                        .padding(.vertical,4).padding(.horizontal,6)
                                        .background(percent >= 1 ? Color.red.opacity(0.15) : Color.green.opacity(0.2))
                                        .foregroundStyle(percent >= 1 ? .red : .green)
                                        .clipShape(Capsule())
                                }
                            } else {
                                Text("—")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        Color(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground)),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
                }
                .buttonStyle(.plain)
    }
}

#Preview {
    CategorySpendingCard(category: previewCategories.first ?? CategoryEntity(name: "Food", emoji: "😀"), spent: 1100, budget: 1000, action: {print("pressed")} )
}

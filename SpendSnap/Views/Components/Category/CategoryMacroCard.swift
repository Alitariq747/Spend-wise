//
//  CategoryMacroCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 15/10/2025.
//

import SwiftUI
import SwiftData

struct CategoryMacroCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let category: Category
    let count: Int
    let total: Decimal
    let spent: Decimal
    
    func ratio(spent: Decimal, total: Decimal) -> Double {
        guard total > 0 else { return 0 }
        let v = Double(truncating: spent as NSDecimalNumber)
        let t = Double(truncating: total as NSDecimalNumber)
        return min(1, v / t)
    }
    
  
    private func percent(spent: Decimal, total: Decimal) -> Int {
        let r = ratio(spent: spent, total: total)   // 0…1
        return Int((r * 100).rounded())
    }
    
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        // Vstack parent
        VStack(spacing: 12) {
            
            // HStack for catgeory icon and amount and no of transactions
            HStack {
                // icon
                Text(category.emoji)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(category.color)
                // VStack for name and transaction count
                VStack(spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text("Expenses - \(count)")
                        .font(.system(size: 12, weight: .light))
                }
                .padding(.horizontal, 8)
                 Spacer()
                //Amount
                Text("\(symbol) \(spent)")
                    .font(.system(size: 16, weight: .semibold))
                
            }
            
            // ProgressView
            ProgressView(value: min(1, ratio(spent: spent, total: total)))
                .progressViewStyle(.linear)
                .tint(category.color)

            // % of total Budget
            Text("\(percent(spent: spent, total: total)) % of budget")
                   .font(.system(size: 12, weight: .regular))
            
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

#Preview {
    CategoryMacroCard(category: .food, count: 4, total: 2450, spent: 250)
}

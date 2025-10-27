//
//  CategorySpendingCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/10/2025.
//

import SwiftUI
import SwiftData

struct CategorySpendingCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let category: Category
    let spent: Decimal
    let total: Decimal
    
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
        
        VStack(alignment: .leading, spacing: 8) {
            // HStack row for icon title and spent
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .background(category.color.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                
                Text(category.name)
                    .font(.system(size: 12, weight: .light))
                
                Spacer()
                
                Text("\(symbol) \(spent) / \(total)")
                    .font(.system(size: 10, weight: .light))
            }
            // Progress Bar -> depends on amount spent
            // value: 0…1
            ProgressView(value: min(1, ratio(spent: spent, total: total)))
                .progressViewStyle(.linear)
                .tint(category.color)
            
            Text("\(percent(spent: spent, total: total)) %")
                   .font(.system(size: 10, weight: .light))

        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(category.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(category.color.opacity(0.1), lineWidth: 1))
    }
}

#Preview {
    CategorySpendingCard(category: .bills, spent: 1100, total: 900)
}

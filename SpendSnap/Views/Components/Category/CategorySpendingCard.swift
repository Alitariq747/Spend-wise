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
    
    let category: CategoryEntity
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
        
    
        HStack(spacing: 8) {
                Text(category.emoji)
                .font(.subheadline)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 5)
                    .background(category.color.opacity(0.9), in: Circle())
                    .overlay(Circle().stroke(category.color.opacity(0.9), lineWidth: 1))
                
           
                    Text(category.name)
                        .font(.system(size: 14, weight: .regular))
                
                
                Spacer()
                // Budgeted
            HStack(spacing: 30) {
                Text("\(symbol)\(category.monthlyBudget)")
                    .font(.system(size: 14, weight: .regular))
                let left = category.monthlyBudget - spent
                Text("\(symbol)\(left)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(left >= 0 ? Color.green : Color.red)
                    .padding(4)
                    .background(left >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
            }
            }
        .padding(.horizontal, 6)
       
    }
}

#Preview {
    CategorySpendingCard(category: previewCategories.first ?? CategoryEntity(name: "Food", emoji: "😀"), spent: 1100)
}

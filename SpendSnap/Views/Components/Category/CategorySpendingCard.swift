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
                Text(category.emoji)
                .font(.system(size: 18, weight: .bold))
                    .padding(.vertical, 7)
                    .padding(.horizontal, 7)
                    .background(category.color.opacity(0.9), in: Circle())
                    .overlay(Circle().stroke(category.color.opacity(0.9), lineWidth: 1))
                
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.system(size: 14, weight: .regular))
                    Text("Spent: \(symbol)\(spent)")
                        .font(.system(size: 12, weight: .medium))
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color(.systemGray))
                
            }
            // Progress Bar -> depends on amount spent
            // value: 0…1
           
          
        }
      
        .padding(.horizontal, 12)
       
    }
}

#Preview {
    CategorySpendingCard(category: .bills, spent: 1100, total: 900)
}

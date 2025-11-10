//
//  ExpenseCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 09/10/2025.
//

import SwiftUI
import SwiftData

struct ExpenseCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    @State var expense: Expense
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        HStack {
            // Image from category
            Text(expense.category?.emoji ?? "🔥")
                .foregroundStyle(expense.category?.color  ?? Color(.systemGray6))
                .font(.system(size: 14, weight: .bold))
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .background(expense.category?.color.opacity(0.2) ?? Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(expense.merchant)
                    .font(.system(size: 14, weight: .semibold))

                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            VStack(spacing: 0) {
                // expense amount
                Text("\(symbol) \(NSDecimalNumber(decimal: expense.amount))")
                    .font(.system(size: 14, weight: .semibold))
                
                // expense method
                Image(systemName: expense.method.icon)
                    .font(.caption)
                    .foregroundStyle(expense.category?.color.opacity(0.7) ?? Color(.systemGray6))
            }
           
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
        
    }
}



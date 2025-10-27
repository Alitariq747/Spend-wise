//
//  BudgetAlertCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 26/10/2025.
//

import SwiftUI
import SwiftData

struct BudgetAlertCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }

    
    let spent: Decimal
    let budgetAmount: Decimal
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red.opacity(0.6))
                Text("Budget Alert!")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("Alert")
                    .font(.system(size: 10, weight: .light))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.red.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.5), lineWidth: 1))
            }
            Divider()
            HStack {
                VStack(spacing: 4) {
                   Text("Budget:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(budgetAmount)")
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("Expenses:")
                         .font(.system(size: 12, weight: .light))
                     Text("\(symbol) \(spent)")
                         .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.vertical, 6)
            
            HStack {
                Image(systemName: "bolt.trianglebadge.exclamationmark")
                    .foregroundStyle(Color.red.opacity(0.5))
                Text("\(symbol) \(spent - budgetAmount)")
                    .font(.system(size: 12, weight: .semibold))
            }
            Divider()
            
            Text("You have over-spent. Slow down and review your spending.")
                .font(.system(size: 12, weight: .light))
                .padding(.vertical, 6)
            Text("Needs attention")
                .font(.system(size: 12, weight: .light))
               
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3),  lineWidth: 1))
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    BudgetAlertCard(spent: 1000.00, budgetAmount: 800.00)
}

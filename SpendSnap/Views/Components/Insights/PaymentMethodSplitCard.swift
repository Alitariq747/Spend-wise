//
//  PaymentMethodSplitCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 23/10/2025.
//

import SwiftUI
import SwiftData

struct PaymentMethodSplitCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expenses: [Expense]
    
    func paidByCard(expenses: [Expense]) -> Decimal {
        expenses.filter { $0.method == .card }.reduce(0) { $0 + $1.amount }
    }
    
    func paidByCash(expenses: [Expense]) -> Decimal {
        expenses.filter { $0.method == .cash }.reduce(0) { $0 + $1.amount }
    }
    
    func methodPercents(_ expenses: [Expense]) -> (card: Int, cash: Int) {
        let total = expenses.reduce(0 as Decimal) {$0 + $1.amount}
        guard total > 0 else { return (0, 0) }
        let card = expenses.filter{ $0.method == .card }.reduce(0 as Decimal) { $0 + $1.amount }
        let cardPct = Double(truncating: card as NSDecimalNumber) / Double(truncating: total as NSDecimalNumber) * 100
        return (Int(cardPct.rounded()), Int(100 - cardPct.rounded()))
    }
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let cardAmount = paidByCard(expenses: expenses)
        let cashAmount = paidByCash(expenses: expenses)
        let (cardPct, cashPct) = methodPercents(expenses)
        
        VStack {
            HStack {
                Image(systemName: "wallet.bifold.fill")
                    .foregroundStyle(Color.light2)
                Text("Payment Method Split")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            Divider()
            HStack {
                VStack(spacing: 4) {
                    Image(systemName: "banknote")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color.light2)
                    Text("\(symbol) \(cashAmount)")
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(cashPct)%")
                        .font(.system(size: 12, weight: .semibold))
                    
                }
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color.light2)
                    Text("\(symbol) \(cardAmount)")
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(cardPct)%")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.vertical, 6)
            Divider()
            
            Text("On average you spent \(cardPct) % on your card and \(cashPct) % on cash")
                .font(.system(size: 12, weight: .light))
                .padding(.vertical, 6)
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PaymentMethodSplitCard(expenses: previewExpenses)
}

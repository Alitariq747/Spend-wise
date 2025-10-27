//
//  TopMerchantCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 23/10/2025.
//

import SwiftUI
import SwiftData

struct TopMerchantCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expenses: [Expense]
    
    func totalsByMerchant(_ expenses: [Expense]) -> [String: Decimal] {
        var totals: [String: Decimal] = [:]
        for e in expenses {
            let name = e.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }           // skip blank merchants
            totals[name, default: 0] += e.amount
        }
        return totals
    }
    
    func topMerchant(in expenses: [Expense]) -> (merchant: String, amount: Decimal, count: Int)? {
        let totals = totalsByMerchant(expenses)
        guard let (name, amt) = totals.max(by: { $0.value < $1.value }) else { return nil }
        let count = expenses.filter { $0.merchant == name }.count
        return (merchant: name, amount: amt, count: count)
    }


    
    var body: some View {
        let top = topMerchant(in: expenses)
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        VStack {
            HStack {
                Image(systemName: "storefront")
                    .foregroundStyle(Color.light2)
                Text("Top Merchant")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()

            }
            Divider()
            HStack {
                VStack(spacing: 4) {
                    Text("Merchant:")
                        .font(.system(size: 12, weight: .light))
                    Text(top?.merchant ?? "")
                        .font(.system(size: 12, weight: .semibold))

                }
                Spacer()
                VStack(spacing: 4) {
                    Text("Spent:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(top?.amount ?? 0)")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.vertical, 6)
            
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundStyle(Color.light2)
                Text("\(top?.count ?? 0)")
                    .font(.system(size: 12, weight: .semibold))
            }
            Divider()
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TopMerchantCard(expenses: previewExpenses)
}

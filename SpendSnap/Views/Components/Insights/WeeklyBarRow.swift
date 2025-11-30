//
//  WeeklyBarRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 15/10/2025.
//

import SwiftUI
import SwiftData 

struct WeekBarRow: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }

    
    let title: String
    let amount: Decimal
    let maxAmount: Decimal
    let budgetAmount: Decimal?

    private func barColor(for amount: Decimal, budgetAmount: Decimal?) -> Color {
        guard let B = budgetAmount, B > 0 else {
            return amount == 0 ? .gray.opacity(0.15) : .darker
        }
        if amount == 0 { return .gray.opacity(0.15) }

        let weeklyTarget = B / 4
        guard weeklyTarget > 0 else { return .darker }

        let r = Double(truncating: amount as NSDecimalNumber) /
                Double(truncating: weeklyTarget as NSDecimalNumber)

        let epsilon = 0.05
        if r < 1 - epsilon { return .green }
        if r <= 1 + epsilon { return .blue }
        return .red
    }

    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .regular))
                .frame(width: 64, alignment: .leading)   // "Week 1" label

            GeometryReader { geo in
                // proportional width (0…1) * available width
                let ratio = min(1,
                    Double(truncating: amount as NSDecimalNumber) /
                    max(1, Double(truncating: maxAmount as NSDecimalNumber))
                )

                ZStack(alignment: .leading) {
                    Capsule().fill(.gray.opacity(0.15))
                    Capsule().fill(barColor(for: amount, budgetAmount: budgetAmount).opacity(0.7)).frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 10) // bar thickness

            Text("\(symbol) \(amount)")
                .font(.caption).foregroundStyle(.secondary)
                .frame(width: 90, alignment: .trailing)
        }
        .frame(height: 24) // row height
    }
}

//
//  AverageSpendingCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 23/10/2025.
//

import SwiftUI
import SwiftData

struct AverageSpendingCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let month: Date
    let expenses: [Expense]
    let budget: Budget?
    
    func idealDailyAverage(budget: Decimal?, month: Date) -> Decimal {
        guard let b = budget, b > 0 else { return 0 }
        let days = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
        return round2(b / Decimal(days))
    }
    
    func totalThisMonth(_ expenses: [Expense]) -> Decimal {
        expenses.reduce(0 as Decimal) { $0 + $1.amount }
    }
    
    func actualAveragePerDay(expenses: [Expense], month: Date ) -> Decimal {
        let total = totalThisMonth(expenses)
        let days = daysElapsed(month)
        guard days > 0 else { return 0 }
        return round2(total / Decimal(days))
    }

    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let actual = actualAveragePerDay(expenses: expenses, month: month)
        let ideal = idealDailyAverage(budget: budget?.amount, month: month)
        let diff = ideal - actual
        let tone = diff < 0 ? Color.red.opacity(0.5) : Color.light2.opacity(0.3)
    
        VStack {
            HStack {
                Image(systemName: "gauge.with.needle")
                    .foregroundStyle(Color.light2)
                Text("Daily Average")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(diff < 0 ? "High!" :"Low")
                    .font(.system(size: 10, weight: .light))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(tone, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(tone, lineWidth: 1))
            }
            
            Divider()
            HStack {
                VStack(spacing: 4) {
                    Text("Ideal:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(ideal)")
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("Actual:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(actual)")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.vertical, 6)
            
            if diff < 0 {
                HStack {
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(Color.red.opacity(0.8))
                    Text("\(format2(diff * -1))")
                        .font(.system(size: 12, weight: .semibold))
                }
            } else {
                HStack {
                    Image(systemName: "arrow.down.right")
                        .foregroundStyle(Color.green.opacity(0.8))
                    Text("\(format2(diff))")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            Divider()
            if diff < 0 {
                Text("Burning faster than planned—ease up to stay on track.")
                    .font(.system(size: 12, weight: .light))
                    .padding(.vertical, 6)
                Text("Needs attention")
                    .font(.system(size: 12, weight: .light))
                   
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3),  lineWidth: 1))
            } else {
                Text("On track and under budget—keep this rhythm.")
                    .font(.system(size: 12, weight: .light))
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
}

#Preview {
    AverageSpendingCard(month: Calendar.current.date(
        from: DateComponents(year: 2025, month: 10, day: 1)
    )!, expenses: previewExpenses, budget: Budget(monthKey: "2025-10", amount: 50000))
}

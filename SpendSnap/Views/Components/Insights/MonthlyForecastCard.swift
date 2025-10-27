//
//  MonthlyForecastCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 18/10/2025.
//

import SwiftUI
import SwiftData

struct MonthlyForecastCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expenses: [Expense]
    let budget: Budget?
    let month: Date
    
    var body: some View {
        let actual = actualThisMonth(expenses)
        let ideal  = idealToDate(budget: budget?.amount, month: month)
        
        let diff = ideal - actual
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let tone = diff < 0 ? Color.red.opacity(0.5) : Color.light2.opacity(0.3)

        VStack {
            HStack {
                Image(systemName: "gauge.with.dots.needle.50percent")
                    .foregroundStyle(diff < 0 ? Color.red.opacity(0.5) : Color.light2)
                Text("Monthly Forecast")
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
                    Text("Forecast:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(format2(ideal))")
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("Spent:")
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
                Text("You are over shooting. Slow down...")
                    .font(.system(size: 12, weight: .light))
                    .padding(.vertical, 6)
                Text("Needs attention")
                    .font(.system(size: 12, weight: .light))
                   
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3),  lineWidth: 1))
            } else {
                Text("You're under the ideal pace. Keep it steady")
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
    MonthlyForecastCard(expenses: previewExpenses, budget: Budget(monthKey: "2025-10", amount: 50000), month: Calendar.current.date(
        from: DateComponents(year: 2025, month: 10, day: 1)
    )!)
}

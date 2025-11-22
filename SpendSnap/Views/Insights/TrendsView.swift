//
//  TrendsView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 15/10/2025.
//

import SwiftUI
import SwiftData

struct TrendsView: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    @Binding var selectedMonth: Date
    let expenses: [Expense]
    let budget: Budget?

    var body: some View {
        let weekly = fourWeekTotals(monthExpenses: expenses, month: selectedMonth)
        let maxAmt = weekly.map(\.amount).max() ?? 0
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        let highest = weekly.max(by: { $0.amount < $1.amount })
        let lowest  = weekly.min(by: { $0.amount < $1.amount })   

        
        // parent vStack
        ScrollView {
            // VStack for mothly overview
            VStack(alignment: .center) {
                
                // HStack for title
                
                HStack {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Weekly Trends")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                // HStack for weekly bars
                VStack(spacing: 16) {
                    ForEach(0..<weekly.count, id: \.self) { i in
                                   WeekBarRow(
                                       title: weekly[i].title,
                                       amount: weekly[i].amount,
                                       maxAmount: maxAmt,
                                       budgetAmount: budget?.amount ?? 0
                                   )
                               }
                }
                
                // HStack for highest and lowest weak
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Text("Highest: \(highest?.title ?? "-")")
                            .font(.system(size: 10, weight: .light))
                        Text("\(symbol) \(highest?.amount ?? 0)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    Spacer()
                    VStack(spacing: 6) {
                        Text("Lowest: \(lowest?.title ?? "-")")
                            .font(.system(size: 10, weight: .light))
                        Text("\(symbol) \(lowest?.amount ?? 0)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray6), lineWidth: 1))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 20)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 2))
            
            // Daily Burn
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Daily Burn")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                DailyBurn(expenses: expenses, month: selectedMonth, budgetAmount: budget?.amount ?? 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 30)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 2))
                
            let points = makePaceSeries(expenses: expenses, month: selectedMonth, budget: budget?.amount)
            let bands  = makeBands(from: points)
            PaceBandChart(bands: bands)


        }
    }
}

#Preview {
    TrendsView(selectedMonth: .constant(Calendar.current.date(from: .init(year: 2025, month: 10))!), expenses: previewExpenses, budget: Budget(monthKey: "2025-10", amount: 10000))
}

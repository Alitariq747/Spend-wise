//
//  DailyBurn.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 16/10/2025.
//

import SwiftUI

struct DailyBurn: View {
    
    let expenses: [Expense]
    let month: Date
    let budgetAmount: Decimal?
    
    private var totalsByDay: [(day: Int, amount: Decimal)] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: expenses, by: { cal.component(.day, from: $0.date) })
        return grouped.keys.sorted().map { d in
            let dayTotal = grouped[d]!.map(\.amount).reduce(0 as Decimal, +)
            return (d, dayTotal)
        }
    }
    
    private var dailyTotalsForAllDays: [(day: Int, amount: Decimal)] {
           let cal = Calendar.current
           guard let lastDay = cal.range(of: .day, in: .month, for: month)?.count, lastDay > 0 else {
               return []
           }
           let grouped = Dictionary(grouping: expenses, by: { cal.component(.day, from: $0.date) })
           return (1...lastDay).map { day in
               let total = grouped[day]?.reduce(0 as Decimal) { $0 + $1.amount } ?? 0
               return (day, total)
           }
       }

    private func toDouble(_ d: Decimal) -> Double {
        Double(truncating: d as NSDecimalNumber)
    }
    
    private func weekdayLetter(for day: Int) -> String {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: month)
        comps.day = day
        guard let date = cal.date(from: comps) else { return "" }

        
        let letters = cal.veryShortWeekdaySymbols
        let idx = cal.component(.weekday, from: date) - 1
        return letters[idx]
    }
    
    private var dailyTarget: Decimal {
        let days = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 0
        guard let b = budgetAmount, b > 0, days > 0 else { return 0 }
        return b / Decimal(days)
    }

    private func barColor(for amount: Decimal) -> Color {
        // no budget ⇒ keep existing look
        guard dailyTarget > 0 else { return .darker }

        let r = Double(truncating: amount as NSDecimalNumber) /
                Double(truncating: dailyTarget as NSDecimalNumber)

        let epsilon = 0.05   // ±5% counts as “at target”
        if r < 1 - epsilon { return .green }     // under target
        if r <= 1 + epsilon { return .blue }     // ~ at target
        return .red                               // over target
    }


    
    var body: some View {
                let data = dailyTotalsForAllDays
                let maxAmt = data.map(\.amount).max() ?? 0
                let maxD = max(1.0, toDouble(maxAmt))
                let trackH: CGFloat = 84

        HStack(alignment: .bottom, spacing: 3) {
            ForEach(data, id: \.day) { d in
                let ratioToTarget = (dailyTarget > 0)
                    ? min(1, toDouble(d.amount) / toDouble(dailyTarget))  // 0…1 of target
                    : (maxD > 0 ? toDouble(d.amount) / maxD : 0)
                
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(width: 7, height: trackH)
                        
                        if d.amount > 0 {
                            Capsule()
                                .fill(barColor(for: d.amount).opacity(0.7))
                                .frame(width: 7, height: max(6, trackH * ratioToTarget))
                        }
                    }

                    Text(weekdayLetter(for: d.day))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.primary)
                            .frame(width: 7)
                }
//                .frame(width: 10, height: trackH, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
    }

}

//#Preview {
//    DailyBurn(expenses: previewExpenses, month: .constant(Calendar.current.date(from: .init(year: 2025, month: 10))!))
//}

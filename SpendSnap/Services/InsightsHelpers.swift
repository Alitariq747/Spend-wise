//
//  InsightsHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 18/10/2025.
//

import Foundation

func daysInMonth(_ month: Date) -> Int {
    Calendar.current.range(of: .day, in: .month, for: month)!.count
}


func actualThisMonth(_ expenses: [Expense]) -> Decimal {
    expenses.reduce(0 as Decimal) { $0 + $1.amount }
}


func idealPerDay(budget: Decimal?, month: Date) -> Decimal {
    guard let b = budget, b > 0 else { return 0 }
    return b / Decimal(daysInMonth(month))
}

func daysElapsed(_ month: Date) -> Int {
    let cal = Calendar.current
    let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!
    let totalDays = daysInMonth(month)
    let today = Date()

    if cal.isDate(today, equalTo: month, toGranularity: .month) {           // current
        return cal.component(.day, from: today)
    } else if today < startOfMonth {                                        // future
        return 0
    } else {                                                                // past
        return totalDays
    }
}


func idealToDate(budget: Decimal?, month: Date) -> Decimal {
    idealPerDay(budget: budget, month: month) * Decimal(daysElapsed(month))
}

func format2(_ d: Decimal) -> String {
    let f = NumberFormatter()
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return f.string(from: d as NSDecimalNumber) ?? "\(d)"
}

//
//  ExpenseHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/10/2025.
//

import Foundation

func totalsByCategory(_expenses: [Expense]) -> [CategoryEntity: Decimal] {
    var dict: [CategoryEntity: Decimal] = [:]
    for e in _expenses {
        dict[e.category ?? CategoryEntity(name: "Other", emoji: "👆🏻", colorHex: "9CA3AF"), default: 0] += e.amount
    }
    return dict
}

struct WeekTotal {
    let title: String
    let amount: Decimal
}


func fourWeekTotals(monthExpenses: [Expense], month: Date) -> [WeekTotal] {
    var totals: [Decimal] = [0, 0, 0, 0]
    let cal = Calendar.current

  
    for e in monthExpenses {
        let day = cal.component(.day, from: e.date)
        let idx: Int =
            (1...7).contains(day)   ? 0 :
            (8...14).contains(day)  ? 1 :
            (15...21).contains(day) ? 2 : 3
        totals[idx] += e.amount
    }

    return [
        WeekTotal(title: "Week 1", amount: totals[0]),
        WeekTotal(title: "Week 2", amount: totals[1]),
        WeekTotal(title: "Week 3", amount: totals[2]),
        WeekTotal(title: "Week 4", amount: totals[3]),
    ]
}

func round2(_ x: Decimal) -> Decimal {
    var a = x, r = Decimal()
    NSDecimalRound(&r, &a, 2, .plain)   // .plain = standard rounding
    return r
}

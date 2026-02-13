//
//  TrendAnalysisHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 17/10/2025.
//

import Foundation
import Charts

struct PacePoint: Identifiable {
    let day: Int           // 1…lastDay
    let actual: Double     // cumulative actual
    let ideal: Double      // cumulative ideal (budget pace)
    var id: Int { day }
}

enum PaceState: String { case under = "Under", over = "Over" }

struct PaceBand: Identifiable {
    let id: Int     // use day
    let day: Int
    let yStart: Double
    let yEnd: Double
    let state: PaceState
}

func makeBands(from points: [PacePoint]) -> [PaceBand] {
    points.map { p in
        let low  = min(p.actual, p.ideal)
        let high = max(p.actual, p.ideal)
        let st: PaceState = (p.actual <= p.ideal) ? .under : .over
        return PaceBand(id: p.day, day: p.day, yStart: low, yEnd: high, state: st)
    }
}


func dailyTotals(expenses: [Expense], month: Date) -> [Decimal] {
    let cal = Calendar.current
    guard let lastDay = cal.range(of: .day, in: .month, for: month)?.count, lastDay > 0 else {
        return []
    }
    var perDay = Array(repeating: Decimal(0), count: lastDay)
    for e in expenses {
        let d = cal.component(.day, from: e.date)   // 1…lastDay
        perDay[d - 1] += e.amount
    }
    return perDay
}

func cumulativeActual(from perDay: [Decimal]) -> [Decimal] {
    var run: Decimal = 0
    return perDay.map { run += $0; return run }
}

func idealLine(budget: Decimal?, lastDay: Int) -> [Decimal] {
    let B = budget ?? 0
    guard B > 0, lastDay > 0 else { return Array(repeating: 0, count: lastDay) }
    return (1...lastDay).map { day in B * Decimal(day) / Decimal(lastDay) }
}

func makePaceSeries(expenses: [Expense], month: Date, budget: Decimal?) -> [PacePoint] {
    let perDay = dailyTotals(expenses: expenses, month: month)
    let actualCum = cumulativeActual(from: perDay)

    let lastDay = perDay.count
    let idealCum = idealLine(budget: budget, lastDay: lastDay)

    func d2(_ d: Decimal) -> Double { Double(truncating: d as NSDecimalNumber) }

    return (1...lastDay).map { day in
        PacePoint(day: day,
                  actual: d2(actualCum[day-1]),
                  ideal:  d2(idealCum[day-1]))
    }
}

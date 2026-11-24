//
//  Income.swift
//  SpendSnap
//
//  Money in. Its own model (D27), not a flag on `Expense`, so a device still
//  on 2.3 sharing the same iCloud data can never count it as spending.
//

import Foundation
import SwiftData

/// D32: a fixed list. Raw values are stored and permanent once deployed.
enum IncomeSource: String, CaseIterable, Identifiable {
    case salary, business, freelance, gift, other
    var id: String { rawValue }
}

@Model
final class Income {
    var amount: Decimal = 0
    var date: Date = Date()
    var monthKey: String = ""
    /// An `IncomeSource` raw value. Unknown values read as `.other`.
    var sourceRaw: String = IncomeSource.other.rawValue
    var note: String = ""
    /// Rule id plus occurrence date for income a recurring rule made; `""` otherwise.
    var recurrenceKey: String = ""

    init(amount: Decimal, date: Date = .now, source: IncomeSource = .other, note: String = "") {
        self.amount = amount
        self.date = date
        self.monthKey = MonthUtil.monthKey(date)
        self.sourceRaw = source.rawValue
        self.note = note
    }

    var source: IncomeSource {
        get { IncomeSource(rawValue: sourceRaw) ?? .other }
        set { sourceRaw = newValue.rawValue }
    }
}

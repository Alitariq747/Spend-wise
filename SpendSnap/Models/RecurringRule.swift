//
//  RecurringRule.swift
//  SpendSnap
//
//  A bill, subscription or regular income that creates entries on a schedule.
//  Raw values below are stored and permanent once deployed.
//

import Foundation
import SwiftData

enum RecurringKind: String, CaseIterable, Identifiable {
    case expense, income
    var id: String { rawValue }
}

enum RecurringFrequency: String, CaseIterable, Identifiable {
    case weekly, biweekly, monthly, yearly
    var id: String { rawValue }
}

@Model
final class RecurringRule {
    /// Identity across devices; recurrence keys are built from it. Optional on
    /// purpose: a shared default would give two rules the same keys, and the
    /// duplicate cleanup would delete each other's entries. A rule with no id
    /// generates nothing.
    var stableID: UUID? = nil
    var name: String = ""
    var amount: Decimal = 0
    var kindRaw: String = RecurringKind.expense.rawValue
    var frequencyRaw: String = RecurringFrequency.monthly.rawValue
    /// First occurrence. Its day of month is the rule's day (31 falls back to
    /// the last day of shorter months).
    var startDate: Date = Date()

    var category: CategoryEntity?
    var card: CreditCard?
    var paymentMethodRaw: String = PaymentMethod.cash.rawValue
    /// An `IncomeSource` raw value for income rules; `""` for expense rules.
    var incomeSourceRaw: String = ""

    var isSubscription: Bool = false
    /// `nil` = no reminder, `0` = on the day, `n` = n days before.
    var reminderDays: Int? = nil
    var isActive: Bool = true
    var createdAt: Date = Date()
    /// Entries exist up to this date. Generation only goes forward from it, so
    /// an entry the user deleted is never recreated, and resuming a paused
    /// rule (which sets it to today) skips the paused stretch.
    var generatedThrough: Date? = nil

    init(name: String, amount: Decimal, kind: RecurringKind = .expense,
         frequency: RecurringFrequency = .monthly, startDate: Date = .now) {
        self.stableID = UUID()
        self.name = name
        self.amount = amount
        self.kindRaw = kind.rawValue
        self.frequencyRaw = frequency.rawValue
        self.startDate = startDate
        self.createdAt = Date()
    }

    var kind: RecurringKind {
        get { RecurringKind(rawValue: kindRaw) ?? .expense }
        set { kindRaw = newValue.rawValue }
    }

    var frequency: RecurringFrequency {
        get { RecurringFrequency(rawValue: frequencyRaw) ?? .monthly }
        set { frequencyRaw = newValue.rawValue }
    }

    var paymentMethod: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethodRaw) ?? .cash }
        set { paymentMethodRaw = newValue.rawValue }
    }
}

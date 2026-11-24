//
//  SavingsGoal.swift
//  SpendSnap
//
//  A savings goal and the money put into it (D19). Contributions are never
//  spending: they live outside `Expense` and no total reads them.
//

import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var name: String = ""
    var emoji: String = ""
    var targetAmount: Decimal = 0
    /// `nil` = no deadline, so no "save X a month" figure.
    var targetDate: Date? = nil
    var createdAt: Date = Date()

    /// A contribution means nothing without its goal.
    @Relationship(deleteRule: .cascade, inverse: \GoalContribution.goal)
    var contributions: [GoalContribution]? = []

    init(name: String, emoji: String, targetAmount: Decimal, targetDate: Date? = nil) {
        self.name = name
        self.emoji = emoji
        self.targetAmount = targetAmount
        self.targetDate = targetDate
        self.createdAt = Date()
    }

    /// Sum of every contribution, withdrawals included.
    var savedAmount: Decimal {
        (contributions ?? []).reduce(0) { $0 + $1.amount }
    }
}

/// One deposit or withdrawal. Each is its own record, so money added on two
/// devices while offline merges instead of one total overwriting the other.
@Model
final class GoalContribution {
    /// Negative for a withdrawal.
    var amount: Decimal = 0
    var date: Date = Date()
    var goal: SavingsGoal?

    init(goal: SavingsGoal, amount: Decimal, date: Date = .now) {
        self.goal = goal
        self.amount = amount
        self.date = date
    }
}

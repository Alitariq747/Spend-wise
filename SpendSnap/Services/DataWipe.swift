//
//  DataWipe.swift
//  SpendSnap
//
//  "Delete all data": removes every synced row except `Settings`.
//

import Foundation
import SwiftData

enum DataWipe {

    /// Deletes every row of every data model and saves. `Settings` stays, so
    /// currency, appearance and onboarding survive.
    ///
    /// Leaf-first: every child is gone before its parent, so no `.cascade`
    /// rule fires against an object already marked for deletion.
    ///
    /// On failure the context is rolled back and the error rethrown. Without
    /// the rollback the context keeps the objects marked for deletion:
    /// `@Query` shows an empty app while the store still holds the rows, and
    /// the next unrelated `save()` commits the delete silently.
    @MainActor
    static func deleteAll(in context: ModelContext) throws {
        do {
            try delete(GoalContribution.self, in: context)
            try delete(SavingsGoal.self, in: context)
            try delete(StatementPayment.self, in: context)
            try delete(RecurringRule.self, in: context)
            try delete(Income.self, in: context)
            try delete(Expense.self, in: context)
            try delete(CategoryMonthlyBudget.self, in: context)
            try delete(CategoryEntity.self, in: context)
            try delete(Budget.self, in: context)
            try delete(CreditCard.self, in: context)
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    @MainActor
    private static func delete<T: PersistentModel>(_ type: T.Type, in context: ModelContext) throws {
        for item in try context.fetch(FetchDescriptor<T>()) {
            context.delete(item)
        }
    }
}

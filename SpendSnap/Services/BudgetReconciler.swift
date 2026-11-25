//
//  BudgetReconciler.swift
//  SpendSnap
//

import Foundation
import SwiftData

/// Leaves one `Budget` row per month (2.5a).
///
/// CloudKit can't enforce uniqueness, so two devices that save the same month
/// before syncing leave two rows. Those arrive through sync at any time, so this
/// runs at launch and on every foreground. It keeps `Budget.preferred` (the last
/// edit) and deletes the rest. The rule is the same on every device, so two
/// devices cleaning up at once keep the same row.
enum BudgetReconciler {

    @MainActor
    static func reconcile(in context: ModelContext) {
        guard let all = try? context.fetch(FetchDescriptor<Budget>()) else { return }
        var deleted = 0
        for rows in Dictionary(grouping: all, by: \.monthKey).values where rows.count > 1 {
            guard let keep = Budget.preferred(rows) else { continue }
            for row in rows where row !== keep {
                context.delete(row)
                deleted += 1
            }
        }
        guard deleted > 0 else { return }
        do {
            try context.save()
            WidgetRefresh.reloadAll()
        } catch {
            #if DEBUG
            print("BudgetReconciler save failed: \(error)")
            #endif
        }
    }
}

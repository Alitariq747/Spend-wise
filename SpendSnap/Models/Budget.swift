//
//  Budget.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation
import SwiftData

@Model
final class Budget {
  var id: UUID = UUID()
  var monthKey: String = ""
  var amount: Decimal = 0
  /// Set on create and on every edit; picks the row to keep when a month has
  /// more than one (2.5a). `nil` on rows from 2.3, which never set it.
  var updatedAt: Date? = nil


  init(monthKey: String, amount: Decimal) {
    self.id = UUID()
    self.monthKey = monthKey
    self.amount = amount
    self.updatedAt = Date()
  }
}

extension Budget {
  /// The budget for a month (D26): the month's own row, else the "every month"
  /// default from the settings row every process agrees on, else 0.
  /// Home, Insights and the widgets all read the budget through this.
  static func amount(for monthKey: String, in context: ModelContext) -> Decimal {
    if let row = preferred(rows(for: monthKey, in: context)) { return row.amount }

    var settings = FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)
    settings.fetchLimit = 1
    return (try? context.fetch(settings))?.first?.defaultMonthlyBudget ?? 0
  }

  /// A month's own rows. Normally one; CloudKit can't enforce that, so sync can leave more.
  static func rows(for monthKey: String, in context: ModelContext) -> [Budget] {
    (try? context.fetch(FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == monthKey }))) ?? []
  }

  /// The row a month uses when it has several (2.5a): newest `updatedAt`, rows
  /// without one last, then the higher amount, then `id`. Every process and
  /// device picks the same row, so the app, the widgets and the cleanup agree.
  static func preferred(_ rows: [Budget]) -> Budget? {
    rows.min { a, b in
      let ta = a.updatedAt ?? .distantPast, tb = b.updatedAt ?? .distantPast
      if ta != tb { return ta > tb }
      if a.amount != b.amount { return a.amount > b.amount }
      return a.id.uuidString < b.id.uuidString
    }
  }

  /// On upgrade from 2.3, where every budget was per month: if no "every month"
  /// budget is set, the latest month's budget up to the current month becomes it.
  /// Cheap and idempotent, so it runs at every launch; once set it does nothing.
  @MainActor
  static func carryOverLatest(in context: ModelContext) {
    var settings = FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)
    settings.fetchLimit = 1
    guard let row = (try? context.fetch(settings))?.first, row.defaultMonthlyBudget == 0 else { return }

    let current = MonthUtil.monthKey(Date())
    let latest = FetchDescriptor<Budget>(
      predicate: #Predicate { $0.monthKey <= current },
      sortBy: [SortDescriptor(\.monthKey, order: .reverse)]
    )
    guard let budget = ((try? context.fetch(latest)) ?? []).first(where: { $0.amount > 0 }) else { return }
    row.defaultMonthlyBudget = budget.amount
    try? context.save()
  }
}

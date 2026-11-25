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


  init(monthKey: String, amount: Decimal) {
    self.id = UUID()
    self.monthKey = monthKey
    self.amount = amount
   
  }
}

extension Budget {
  /// The budget for a month (D26): the month's own row, else the "every month"
  /// default from the settings row every process agrees on, else 0.
  /// Home, Insights and the widgets all read the budget through this.
  static func amount(for monthKey: String, in context: ModelContext) -> Decimal {
    var own = FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == monthKey })
    own.fetchLimit = 1
    if let row = (try? context.fetch(own))?.first { return row.amount }

    var settings = FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)
    settings.fetchLimit = 1
    return (try? context.fetch(settings))?.first?.defaultMonthlyBudget ?? 0
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

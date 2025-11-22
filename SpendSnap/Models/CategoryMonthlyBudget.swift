//
//  CategoryMonthlyBudget.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 17/11/2025.
//

import Foundation

import SwiftData

@Model
final class CategoryMonthlyBudget {
    // e.g. "2025-11" (YYYY-MM)
    var monthKey: String
    var amount: Decimal

    @Relationship(inverse: \CategoryEntity.monthlyBudgets)
    var category: CategoryEntity

    init(category: CategoryEntity, monthKey: String, amount: Decimal) {
        self.category = category
        self.monthKey = monthKey
        self.amount = amount
    }
}


enum BudgetScope: String, CaseIterable, Identifiable {
    case thisMonth = "This month"
    case everyMonth = "Every month"  
    var id: Self { self }
}

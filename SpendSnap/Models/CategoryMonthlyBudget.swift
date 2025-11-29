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
   
    var monthKey: String = ""
    var amount: Decimal = 0


    var category: CategoryEntity?

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

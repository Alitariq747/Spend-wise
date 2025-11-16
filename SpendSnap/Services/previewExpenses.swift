//
//  previewExpenses.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/10/2025.
//

import Foundation

import SwiftData

// One CategoryEntity per enum case, for previews
let previewCategoriesByEnum: [Category: CategoryEntity] = {
    var dict: [Category: CategoryEntity] = [:]
    for cat in Category.allCases {
        dict[cat] = CategoryEntity(
            name: cat.name,
            emoji: cat.emoji,
            monthlyBudget: .zero,
            colorHex: cat.colorHex
        )
    }
    return dict
}()

let previewExpenses: [Expense] = {
    let cal = Calendar.current
    let now = Date()
    func day(_ daysAgo: Int) -> Date { cal.date(byAdding: .day, value: -daysAgo, to: now)! }

    let cat = previewCategoriesByEnum

    // newest → oldest
    return [
        Expense(amount: 1_599, date: day(0), merchant: "Daraz",
                category: cat[.food], method: .card),

        Expense(amount:   800, date: day(1), merchant: "Careem",
                category: cat[.bills], method: .card),

        Expense(amount: 2_300, date: day(2), merchant: "Cafe Bloom",
                category: cat[.entertainment], method: .cash),

        Expense(amount:   499, date: day(6), merchant: "App Store",
                category: cat[.groceries], method: .card),

        Expense(amount:   950, date: day(7), merchant: "Foodpanda",
                category: cat[.food], method: .card),

        Expense(amount: 4_499, date: day(8), merchant: "Amazon",
                category: cat[.health], method: .cash),

        Expense(amount:   320, date: day(9), merchant: "Bykea",
                category: cat[.entertainment], method: .cash),

        Expense(amount: 1_199, date: day(10), merchant: "Spotify",
                category: cat[.education], method: .cash),

        Expense(amount: 2_799, date: day(11), merchant: "GulAhmed",
                category: cat[.groceries], method: .cash),

        Expense(amount:   270, date: day(12), merchant: "Tea Stall",
                category: cat[.health], method: .cash),

        Expense(amount: 5_600, date: day(14), merchant: "PSO Fuel",
                category: cat[.transport], method: .cash),

        Expense(amount:   680, date: day(15), merchant: "Bakery",
                category: cat[.utilities], method: .cash),

        Expense(amount: 1_050, date: day(17), merchant: "Pharmacy",
                category: cat[.health], method: .cash),

        Expense(amount: 3_999, date: day(19), merchant: "IKEA",
                category: cat[.shopping], method: .cash),
    ]
}()

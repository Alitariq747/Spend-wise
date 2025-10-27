//
//  previewExpenses.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/10/2025.
//

import Foundation

let previewExpenses: [Expense] = {
    let cal = Calendar.current
    let now = Date()
    func day(_ daysAgo: Int) -> Date { cal.date(byAdding: .day, value: -daysAgo, to: now)! }

    // newest → oldest
    return [
        Expense(amount: 1_599, date: day(0), merchant: "Daraz",       category: .other, method: .card),
        Expense(amount:   800, date: day(1), merchant: "Careem",      category: .bills, method: .card),
        Expense(amount: 2_300, date: day(2), merchant: "Cafe Bloom",  category: .entertainment, method: .cash),
        Expense(amount: 3_200, date: day(4), merchant: "K-Electric",  category: .creditCard, method: .cash),
        Expense(amount:   499, date: day(6), merchant: "App Store",   category: .groceries, method: .card),
        Expense(amount:   950, date: day(7),  merchant: "Foodpanda",     category: .food, method: .card),
        Expense(amount: 4_499, date: day(8),  merchant: "Amazon",        category: .health, method: .cash),
         Expense(amount:   320, date: day(9),  merchant: "Bykea",         category: .other, method: .cash),
         Expense(amount: 1_199, date: day(10), merchant: "Spotify",       category: .other, method: .cash),
         Expense(amount: 2_799, date: day(11), merchant: "GulAhmed",      category: .other, method: .cash),
         Expense(amount:   270, date: day(12), merchant: "Tea Stall",     category: .other, method: .cash),
         Expense(amount: 5_600, date: day(14), merchant: "PSO Fuel",      category: .other, method: .cash),
         Expense(amount:   680, date: day(15), merchant: "Bakery",        category: .other, method: .cash),
         Expense(amount: 1_050, date: day(17), merchant: "Pharmacy",      category: .other, method: .cash),
         Expense(amount: 3_999, date: day(19), merchant: "IKEA",          category: .other, method: .cash),
    ]
}()

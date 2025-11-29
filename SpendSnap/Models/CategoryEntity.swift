//
//  CategoryEntity.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/11/2025.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class CategoryEntity {
    var name: String = ""
    var emoji: String = "📁"
    var monthlyBudget: Decimal = 0
    var isSystemOther: Bool = false

    var colorHex: String = "CCCCCC"
    
    init(name: String, emoji: String, monthlyBudget: Decimal = .zero, colorHex: String = "CCCCCC", isSystemOther: Bool = false) {
        self.name = name
        self.emoji = emoji
        self.monthlyBudget = monthlyBudget
        self.colorHex = colorHex
        self.isSystemOther = isSystemOther
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    @Relationship(deleteRule: .cascade, inverse: \CategoryMonthlyBudget.category)
    var monthlyBudgets: [CategoryMonthlyBudget]? = []
    
    @Relationship(deleteRule: .cascade , inverse: \Expense.category)
    var expenses: [Expense]? = []

}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                          .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255

        self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}




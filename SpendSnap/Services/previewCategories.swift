//
//  previewCategories.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 10/11/2025.
//

import Foundation

import SwiftData

let previewCategories: [CategoryEntity] = {
    Category.allCases.map { cat in
        CategoryEntity(
            name: cat.name,
            emoji: cat.emoji,
            monthlyBudget: .zero,
            colorHex: cat.colorHex
        )
    }
}()

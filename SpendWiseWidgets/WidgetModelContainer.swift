//
//  WidgetModelContainer.swift
//  SpendWiseWidgetsExtension
//
//  Created by Ahmad Ali Tariq on 27/11/2025.
//

import Foundation

import SwiftData

enum WidgetModelContainer {
    static let shared: ModelContainer? = {
        let schema = Schema([
            Expense.self,
            CategoryEntity.self,
            CategoryMonthlyBudget.self,
            Budget.self,
            CreditCard.self,
            Settings.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.ahmad.SpendWise"),
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("⚠️ Failed to create widget ModelContainer: \(error)")
                        return nil
        }
    }()
}

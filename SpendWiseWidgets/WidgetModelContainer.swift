//
//  WidgetModelContainer.swift
//  SpendWiseWidgetsExtension
//
//  Created by Ahmad Ali Tariq on 27/11/2025.
//

import Foundation

import SwiftData

enum WidgetModelContainer {
    private static let appGroupID = "group.ahmad.SpendWise"
    private static let errorKey = "WidgetModelContainer.lastError"

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
            groupContainer: .identifier(appGroupID),
            // Widgets should not attempt CloudKit sync; read the shared store only.
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            logContainerError(error, context: "shared-store")

            // Fallback: keep widget alive with an in-memory store.
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                logContainerError(error, context: "in-memory")
                return nil
            }
        }
    }()

    private static func logContainerError(_ error: Error, context: String) {
        #if DEBUG
        print("⚠️ Widget ModelContainer failed (\(context)): \(error)")
        #endif
        if let defaults = UserDefaults(suiteName: appGroupID) {
            defaults.set("Widget ModelContainer failed (\(context)): \(error)", forKey: errorKey)
        }
    }
}

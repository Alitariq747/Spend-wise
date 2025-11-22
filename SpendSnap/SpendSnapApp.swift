//
//  SpendSnapApp.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

@main
struct SpendSnapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Expense.self, Budget.self, Settings.self, CategoryEntity.self, CategoryMonthlyBudget.self, CreditCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

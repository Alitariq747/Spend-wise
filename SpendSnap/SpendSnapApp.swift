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
    private static let sharedModelContainer: ModelContainer = {
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
                return try ModelContainer(
                    for: schema,
                    configurations: [configuration]
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(Self.sharedModelContainer)
    }
}

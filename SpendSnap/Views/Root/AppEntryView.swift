//
//  AppEntryView.swift
//  SpendSnap
//
//  Created by Codex on 04/06/2025.
//

import SwiftUI
import SwiftData

struct AppEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRow: [Settings]
    
    var body: some View {
        Group {
            if let settings = settingsRow.first {
                if settings.onboardingComplete {
                    RootTabView(settings: settings)
                } else {
                    OnboardingView(settings: settings)
                }
            } else {
                ProgressView()
                    .task {
                        if settingsRow.isEmpty {
                            modelContext.insert(Settings())
                            try? modelContext.save()
                        }
                    }
            }
        }
    }
}

#Preview {
    AppEntryView()
        .modelContainer(for: [
            Expense.self,
            CategoryEntity.self,
            CategoryMonthlyBudget.self,
            Budget.self,
            CreditCard.self,
            Settings.self
        ], inMemory: true)
}

//
//  InsightsView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    
    @Environment(\.modelContext) private var ctx
    
    @State private var selectedMonth: Date = Date()
    
    @State private var budgetForMonth: Decimal = 0
    @State private var monthExpenses: [Expense] = []
 
    var body: some View {
        VStack {
            MonthPicker(month: $selectedMonth)

            ScrollView {
                VStack(spacing: 16) {
                    // 1) Pie overview
                    OverviewView(
                        selectedMonth: $selectedMonth,
                        budgetForMonth: budgetForMonth,
                        monthExpenses: monthExpenses
                    )

                    // 2) Trends sections
                    TrendsView(
                        selectedMonth: $selectedMonth,
                        expenses: monthExpenses,
                        budget: budgetForMonth
                    )
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .onAppear {
            fetchBudget()
            fetchExpenses()
        }
        // These caches hold objects fetched by hand, so they survive a delete
        // that `@Query` would have swept. Drop them before a body can read one.
        .onReceive(NotificationCenter.default.publisher(for: .spendWiseDidDeleteAllData)) { _ in
            monthExpenses = []
            budgetForMonth = 0
        }
        .onChange(of: selectedMonth) {
            fetchBudget()
            fetchExpenses()
        }
    }

    
    private func fetchBudget() {
       
            budgetForMonth = Budget.amount(for: MonthUtil.monthKey(selectedMonth), in: ctx)
       
    }
    
    private func fetchExpenses() {
        let key = MonthUtil.monthKey(selectedMonth)
        var desc = FetchDescriptor<Expense>(predicate: #Predicate { $0.monthKey == key })
        desc.sortBy = [.init(\.date, order: .reverse)]
        monthExpenses = (try? ctx.fetch(desc)) ?? []
    }
}

#Preview {
    InsightsView()
}

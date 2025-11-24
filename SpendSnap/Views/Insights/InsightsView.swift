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
    
    @State private var budgetForMonth: Budget? = nil
    @State private var monthExpenses: [Expense] = []
 
    @State private var tab: InsightsTab = .overview
    
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
        .onChange(of: selectedMonth) {
            fetchBudget()
            fetchExpenses()
        }
    }

    
    private func fetchBudget() {
       
            let key = MonthUtil.monthKey(selectedMonth)
             var desc = FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == key })
             desc.fetchLimit = 1
             budgetForMonth = (try? ctx.fetch(desc))?.first
       
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

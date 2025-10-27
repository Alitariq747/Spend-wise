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
        ZStack {
            Color(.gray).opacity(0.09)
                .ignoresSafeArea()
            
            VStack {
                MonthPicker(month: $selectedMonth)
                
                HStack(spacing: 8) {
                      TabPill("Overview", .overview,  selection: $tab)
                      TabPill("Trends",   .trends,    selection: $tab)
                      TabPill("Insights", .insights,  selection: $tab)
                  }

                  Group {
                      switch tab {
                      case .overview:
                          OverviewView(selectedMonth: $selectedMonth, budgetForMonth: budgetForMonth, monthExpenses: monthExpenses)  
                      case .trends:
                        
                          TrendsView(selectedMonth: $selectedMonth, expenses: monthExpenses, budget: budgetForMonth)
                      case .insights:
                          IntelligentInsightsView(selectedMonth: $selectedMonth, expenses: monthExpenses, budget: budgetForMonth)
                      }
                  }
            }
            .padding()
        }
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

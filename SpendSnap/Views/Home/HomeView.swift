//
//  HomeView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @Environment(\.modelContext) private var ctx
    @State private var selectedMonth = Date()
    @State private var showAddBudget: Bool = false
  
    @State private var budgetForMonth: Budget? = nil
    @State private var monthExpenses: [Expense] = []
    
    private var categoryTotals:[Category: Decimal] {
        totalsByCategory(_expenses: monthExpenses)
    }
    
    private var spentThisMonth: Decimal {
        monthExpenses.reduce(0 as Decimal) { $0 + $1.amount }
    }
    
    var monthKey: String {
        MonthUtil.monthKey(selectedMonth)
    }

    
    private var isViewingCurrentMonth: Bool {
        MonthUtil.monthKey(selectedMonth) == MonthUtil.monthKey(Date())
    }

    private var todayTotal: Decimal {
        guard isViewingCurrentMonth else { return 0 }
        return monthExpenses
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0 as Decimal) { $0 + $1.amount }
    }

    private var weekToDateTotal: Decimal {
        guard isViewingCurrentMonth,
              let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
        else { return 0 }
        return monthExpenses
            .filter { interval.contains($0.date) }
            .reduce(0 as Decimal) { $0 + $1.amount }
    }


    var body: some View {
        
        ZStack {
            Color(.gray).opacity(0.09)
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    MonthPicker(month: $selectedMonth, limitToCurrentMonth: true)
                    MonthlyOverview(onTapped: {
                        showAddBudget = true
                    }, budget: budgetForMonth, spent: spentThisMonth, todaySpent: todayTotal, weekSpent: weekToDateTotal, currentMonth: isViewingCurrentMonth)
                    
                    Text("Category highlights \(MonthUtil.fmt.string(from: selectedMonth)) ")
                        .font(.headline)
                        .foregroundStyle(.darker)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, -1)
                        .padding(.top, 30)
                    
                    
                    ForEach(Category.allCases, id: \.id) { cat in
                        let spent = categoryTotals[cat] ?? 0
                        CategorySpendingCard(category: cat, spent:spent , total: spentThisMonth)
                    }
                }
                .padding()
            }
           
        }
        .onChange(of: selectedMonth) {
            fetchBudget()
            fetchExpenses()
        }
        .sheet(isPresented: $showAddBudget, onDismiss: { fetchBudget() }) {
            AddBudgetSheet(month: $selectedMonth, existingBudget: budgetForMonth, onSave: {
                fetchBudget()
            })
            .presentationDetents([ .medium])
        }
        .onAppear {
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
    HomeView()
}


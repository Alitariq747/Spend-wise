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
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    @State private var selectedMonth = Date()
    @State private var showAddBudget: Bool = false
  
    @State private var budgetForMonth: Budget? = nil
    @State private var monthExpenses: [Expense] = []
    
    @State private var chosenCategory: CategoryEntity? = nil
    
    private var categoryTotals:[CategoryEntity: Decimal] {
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
    
    private func filteredExpenses(for category: CategoryEntity) -> [Expense] {
        monthExpenses.filter { $0.category?.persistentModelID == category.persistentModelID }
    }


    var body: some View {
        
      
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("💸")
                            .font(.system(size: 20, weight: .bold))
                      Spacer()
                        MonthPicker(month: $selectedMonth, limitToCurrentMonth: true)
                        Spacer()
                        Button {
                          showAddBudget = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                                .tint(Color(.systemGray))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                    }
                    
                    MonthlyOverview(onTapped: {
                        showAddBudget = true
                    }, budget: budgetForMonth, spent: spentThisMonth, todaySpent: todayTotal, weekSpent: weekToDateTotal, currentMonth: isViewingCurrentMonth, daysRemaining: daysRemaining(in: selectedMonth), idealPerDay: idealPerDay(budget: budgetForMonth?.amount ?? 0, month: selectedMonth))
                    
                 
                      
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                            VStack(spacing: 0) {
                                Button {
                                    chosenCategory = category
                                } label: {
                                    let spent = categoryTotals[category]
                                    CategorySpendingCard(category: category, spent: spent ?? 0)
                                        .padding(.vertical, 8)
                                } 
                                .buttonStyle(.plain)
                            }
                        }
                    }

                }
                .padding()
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
        .sheet(item: $chosenCategory, content: { cat in
            let spent = categoryTotals[cat] ?? 0
            CategoryDetailSheet(category: cat, spent: spent, expenses: filteredExpenses(for: cat))
        })
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


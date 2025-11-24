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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedMonth = Date()
    @State private var showAddBudget: Bool = false
    @State private var showAddCategorySheet: Bool = false
    @State private var showAddExpenseSheet = false

  
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
    
    private func resolveBudget(for category: CategoryEntity) -> Decimal {
        if let override = category.monthlyBudgets.first(where: {$0.monthKey == monthKey}) {
            return override.amount
        } else {
            return category.monthlyBudget
        }
    }
    
    @State private var showCategoryDetailSheet: Bool = false


    var body: some View {
        
        ZStack {
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
                
                
                LazyVStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        let spent = categoryTotals[cat] ?? 0
                        let budget = resolveBudget(for: cat)
                        CategorySpendingCard(category: cat, spent: spent, budget: budget) {
                            // open detail sheet
                            chosenCategory = cat
                            showCategoryDetailSheet = true
                        }
                    }
                }
                Button {
                    showAddCategorySheet = true
                } label: {
                    Text( "Add new category")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(.systemGray2))
                        .frame(maxWidth:.infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5)))
                }
                .padding(.top, categories.count == 0 ? -18 : -6)
                .padding(.horizontal, 2)
            }
            .padding()
        }
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        showAddExpenseSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .black : .white)   // icon color
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color.white : Color.black) // bg color
                            )
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    }
                    
                }
                .padding(.trailing, 25)
                .padding(.bottom, 20)
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
        .sheet(item: $chosenCategory, content: { cat in
            let spent = categoryTotals[cat] ?? 0
            CategoryDetailSheet(category: cat, spent: spent, expenses: filteredExpenses(for: cat), onDataChanged: { fetchExpenses() }, activeMonth: selectedMonth)
        })
        .sheet(isPresented: $showAddCategorySheet, content: {
            AddCategorySheet(activeMonth: selectedMonth)
        })
        .presentationDetents([.large])
        .navigationTitle("")
        .navigationDestination(isPresented: $showAddExpenseSheet, destination: {
            AddExpenseSheet(month: $selectedMonth)
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


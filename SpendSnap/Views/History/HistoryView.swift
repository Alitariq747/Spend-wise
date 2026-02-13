//
//  HistoryView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var storeKit: StoreKitManager
    @Environment(\.colorScheme) private var colorScheme
    @Query private var settingsRow: [Settings]
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    @State private var selectedMonth = Date()
    @State private var showAddExpenseView: Bool = false
    @State private var showAddCategorySheet: Bool = false
    @State private var showAddCategoryPrompt = false
    @State private var pendingCategoryFromPrompt = false
    @State private var showGoProSheet = false
    
    @State private var monthExpenses: [Expense] = []
    @State private var selectedExpense: Expense? = nil
    @State private var showExpenseDetailSheet: Bool = false
    
    // for url link from wiget
    @Binding var deepLinkMonth: Date?
    
    init(deepLinkMonth: Binding<Date?> = .constant(nil)) {
           _deepLinkMonth = deepLinkMonth
       
           _selectedMonth = State(initialValue: deepLinkMonth.wrappedValue ?? Date())
       }

    private func presentAddExpense() {
        if categories.isEmpty {
            showAddCategoryPrompt = true
        } else {
            showAddExpenseView = true
        }
    }

    @MainActor
    private func handleAddExpenseTap() async {
        if !storeKit.isEntitlementsLoaded {
            await storeKit.refreshEntitlements()
        }

        guard storeKit.hasActiveSubscription else {
            showGoProSheet = true
            return
        }

        presentAddExpense()
    }
    
    var body: some View {
        let symbol = CurrencyUtil.symbol(for: currencyCode)
            
        ZStack {
            VStack {
                
                
                MonthPicker(month: $selectedMonth, limitToCurrentMonth: true)
                // List of expenses
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(monthExpenses, id: \.id) { exp in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(exp.date, style: .date)
                                        .font(.system(size: 14, weight: .light))
                                    Spacer()
                                    Button {
                                        selectedExpense = exp
                                        
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 12, weight: .light))
                                            .tint(Color(.systemGray4))
                                    }
                                    .buttonStyle(.plain)
                                    
                                }
                                HStack {
                                    Circle().fill(exp.category?.color ?? Color(.systemGray5))
                                        .frame(width: 12, height: 12)
                                    Text(exp.merchant)
                                        .font(.system(size: 16, weight: .regular))
                                    Spacer()
                                    Text("\(symbol)\(exp.amount)")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    
                }
                .padding(.horizontal)
            }
            
            
            
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await handleAddExpenseTap()
                        }
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
            .sheet(item: $selectedExpense, content: { expense in
                ExpenseDetailSheet(expense: expense, onDeleteExpense: { fetchExpenses() })
            })

        
        .onChange(of: selectedMonth, {
            fetchExpenses()
        })
        .onAppear(perform: {
            fetchExpenses()
            handleDeepLinkIfNeeded()
        })
        .onChange(of: deepLinkMonth) {
            handleDeepLinkIfNeeded()
               }
        .navigationTitle("")
        .navigationDestination(isPresented: $showAddExpenseView) {
            AddExpenseSheet(month: $selectedMonth)
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheet(activeMonth: selectedMonth)
        }
        .sheet(isPresented: $showGoProSheet) {
            GoProSheet()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showAddCategoryPrompt, onDismiss: {
            if pendingCategoryFromPrompt {
                pendingCategoryFromPrompt = false
                showAddCategorySheet = true
            }
        }) {
            AddCategoryPromptSheet(
                onAddCategory: {
                    pendingCategoryFromPrompt = true
                    showAddCategoryPrompt = false
                },
                onDismiss: { showAddCategoryPrompt = false }
            )
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    private func fetchExpenses() {
        let key = MonthUtil.monthKey(selectedMonth)
        var desc = FetchDescriptor<Expense>(predicate: #Predicate { $0.monthKey == key })
        desc.sortBy = [.init(\.date, order: .reverse)]
        monthExpenses = (try? ctx.fetch(desc)) ?? []
    }
    
    private func handleDeepLinkIfNeeded() {
        guard let month = deepLinkMonth else { return }
        selectedMonth = month
        Task {
            await handleAddExpenseTap()
        }
        deepLinkMonth = nil    // consume the trigger so it doesn’t re-open
    }
}

#Preview {
    HistoryView()
        .environmentObject(StoreKitManager())
}

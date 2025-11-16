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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedMonth = Date()
    @State private var showAddExpenseView: Bool = false
    
    @State private var monthExpenses: [Expense] = []
    
    var body: some View {
        ZStack {
            Color(.gray).opacity(0.09)
                .ignoresSafeArea()
            
            VStack {
            
                
                MonthPicker(month: $selectedMonth, limitToCurrentMonth: true)
                // List of expenses
                List(monthExpenses, id: \.id) { e in
                    ExpenseCard(expense: e)
                        .padding(.vertical, 6)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(e)
                            } label: {
                               Image(systemName: "trash")
                                    .symbolRenderingMode(.monochrome)
                                    .font(.caption2)
                            }
                        
                            .tint(Color.red.opacity(0.5))
                              }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .padding()
    
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        showAddExpenseView = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .black : .white)   // icon color
                            .padding(8)
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
        .onChange(of: selectedMonth, {
            fetchExpenses()
        })
        .onAppear(perform: {
            fetchExpenses()
        })
        .navigationTitle("")
        .navigationDestination(isPresented: $showAddExpenseView) {
            AddExpenseSheet(month: $selectedMonth)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    private func fetchExpenses() {
        let key = MonthUtil.monthKey(selectedMonth)
        var desc = FetchDescriptor<Expense>(predicate: #Predicate { $0.monthKey == key })
        desc.sortBy = [.init(\.date, order: .reverse)]
        monthExpenses = (try? ctx.fetch(desc)) ?? []
    }
    private func delete(_ e: Expense) {
        withAnimation {
            ctx.delete(e)
            try? ctx.save()
            monthExpenses.removeAll { $0.id == e.id }
        }
    }

}

#Preview {
    HistoryView()
}

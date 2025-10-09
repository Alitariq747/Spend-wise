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
    
    var monthKey: String {
        MonthUtil.monthKey(selectedMonth)
    }

    @State private var showManualSheet = false

    var body: some View {
        
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                MonthPicker(month: $selectedMonth, limitToCurrentMonth: true)
                MonthlyOverview(onTapped: {
                    showAddBudget = true
                }, budget: budgetForMonth)
                
                // CTA button
                Button {
                  showManualSheet = true
                } label: {
                  HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill").font(.title2)
                    Text("Add Expense")
                      .font(.system(size: 18, weight: .semibold))
                  }
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 16)
                  .background(Color.light, in: RoundedRectangle(cornerRadius: 14))
                  .foregroundStyle(.white)
                  .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                }
              
            }
            .padding()
            .onChange(of: selectedMonth) { 
                fetchBudget()
            }
            .sheet(isPresented: $showAddBudget, onDismiss: { fetchBudget() }) {
                AddBudgetSheet(month: $selectedMonth, existingBudget: budgetForMonth, onSave: {
                    fetchBudget()
                })
                .presentationDetents([ .medium])
            }
            .onAppear {
                fetchBudget()
            }
            .navigationTitle("")
            .navigationDestination(isPresented: $showManualSheet) {
                AddExpenseSheet(month: $selectedMonth)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func fetchBudget() {
       
            let key = MonthUtil.monthKey(selectedMonth)
             var desc = FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == key })
             desc.fetchLimit = 1
             budgetForMonth = (try? ctx.fetch(desc))?.first
       
    }
}

#Preview {
    HomeView()
}

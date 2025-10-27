//
//  IntelligentInsightsView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 18/10/2025.
//

import SwiftUI

struct IntelligentInsightsView: View {
    
    @Binding var selectedMonth: Date
    let expenses: [Expense]
    let budget: Budget?
    
  

    
    var body: some View {
        let spent = actualThisMonth(expenses)
        let budgetAmount = budget?.amount ?? 0
        let difference = budgetAmount - spent
        

        ScrollView {
           // Budget Forecast Card
            difference < 0 ? BudgetAlertCard(spent: spent, budgetAmount: budgetAmount) : nil
            MonthlyForecastCard(expenses: expenses, budget: budget, month: selectedMonth)
            TopCategoryCard(expenses: expenses)
            AverageSpendingCard(month: selectedMonth, expenses: expenses, budget: budget)
            PaymentMethodSplitCard(expenses: expenses)
            TopMerchantCard(expenses: expenses)
        }
       
    }
}

#Preview {
    IntelligentInsightsView(selectedMonth: .constant(Calendar.current.date(from: .init(year: 2025, month: 10))!), expenses: previewExpenses, budget: Budget(monthKey: "2025-10", amount: 10000))
}

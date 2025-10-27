//
//  CategoryAnalytics.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 14/10/2025.
//

import SwiftUI

struct CategoryAnalytics: View {
    
    let expenses: [Expense]
    let budgetAmount: Decimal?
    
    @State private var selectedCategory: Category = .food
    
    private var filtered: [Expense] {
        expenses.filter { $0.category == selectedCategory }
    }
    
    private var categoryTotal: Decimal {
        filtered.reduce(0 as Decimal) { $0 + $1.amount }
    }
    
    private var count: Int { filtered.count }
    
    private var totalForPercent: Decimal {
        let spentAll = expenses.reduce(0 as Decimal) { $0 + $1.amount }
           let b = budgetAmount ?? 0
           return b > 0 ? b : spentAll
       }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 18, weight: .semibold))
                Text("Category Analytics")
                    .font(.system(size: 15, weight: .semibold))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Category.allCases) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            HStack {
                                Image(systemName: cat.icon)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(cat.color)
                                Text(cat.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.black.opacity(0.7))

                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(selectedCategory == cat ?  cat.color.opacity(0.3) : Color.gray.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedCategory == cat ? cat.color.opacity(0.3) : Color.gray.opacity(0.09), lineWidth: 1))
                        }
                        
                     
                      
                      
                    }
                  
                }
            }
            .padding(.bottom, 12)
            CategoryMacroCard(
                       category: selectedCategory,
                       count: count,
                       total: totalForPercent,
                       spent: categoryTotal
                   )
            
            // List of filtered expense
            filtered.count > 0 ?
            VStack {
                ForEach(filtered, id: \.id) { expense in
                        ExpenseCard(expense: expense)
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
            .background(Color.gray.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.09),  lineWidth: 1))
            : nil
            
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
    }
}

#Preview {
    CategoryAnalytics(expenses: previewExpenses, budgetAmount: 10000)
}

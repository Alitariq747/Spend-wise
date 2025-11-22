//
//  CategoryDetailSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 11/11/2025.
//

import SwiftUI
import SwiftData

struct CategoryDetailSheet: View {
    let category: CategoryEntity
    let spent: Decimal
    let expenses: [Expense]
    var onDataChanged: (() -> Void)? = nil
    let activeMonth: Date
    
    private var activeMonthKey: String {
        MonthUtil.monthKey(activeMonth)
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsRow: [Settings]
    
    @State private var selectedExpense: Expense? = nil
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    @State private var showCategoryEditSheet: Bool = false
    
    private var budget: Decimal {
        if let override = category.monthlyBudgets.first(where: { $0.monthKey == activeMonthKey}) {
            return override.amount
        } else {
            return category.monthlyBudget
        }
    }
    private var progress: Double {
        guard budget > 0 else { return 0 }
        let spentD  = NSDecimalNumber(decimal: spent).doubleValue
        let budgetD = NSDecimalNumber(decimal: budget).doubleValue
        return min(max(spentD / budgetD, 0), 1)
    }
    
    private var tintColor: Color {
        // use a tiny epsilon to avoid float equality issues
        let eps = 0.000_1
        if progress <= eps {                  // 0 → gray
            return Color(.systemGray5)
        } else if progress >= 1 - eps {       // 1+ → red
            return .red
        } else {                              // (0,1) → category color
            return category.color
        }
    }

    
    var body: some View {
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        VStack(alignment: .leading, spacing: 12) {
            
            // HStack for category emoji, title and buttons to edit and close the sheet
            HStack {
                Text(category.emoji)
                    .font(.system(size: 32, weight: .bold, design: .default))
                Text(category.name)
                    .font(.system(size: 20, weight: .medium, design: .default))
                Spacer()
                
                Button {
                    showCategoryEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .tint(Color(.systemGray))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                }
                .background(Color(.secondarySystemBackground), in: Circle())
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .tint(Color(.systemGray))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                }
                .background(Color(.secondarySystemBackground), in: Circle())
            }
            HStack {
               
                Gauge(value: progress, in: 0...1) {
                    // label (optional)
                } currentValueLabel: {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .gaugeStyle(.accessoryCircular)        
                .tint(tintColor)
                .frame(width: 64, height: 64)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budgeted: \(symbol)\(budget)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.primary)
                    Text("Spent: \(symbol)\(spent)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.primary)
                }
            }
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(expenses, id: \.id) { exp in
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
        }
        .padding()
        .sheet(item: $selectedExpense, content: { expense in
            ExpenseDetailSheet(expense: expense, onDeleteExpense: { onDataChanged?() })
        })
        .presentationDetents([.large])
        .sheet(isPresented: $showCategoryEditSheet) {
            CategoryEditSheet(category: category, activeMonth: activeMonth, onSaved: { onDataChanged?()
            dismiss()
            })
        }
        }
}

#Preview {
    CategoryDetailSheet(category: previewCategories.first!, spent: 50.00, expenses: previewExpenses, activeMonth: .now)
}

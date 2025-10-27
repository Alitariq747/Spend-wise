//
//  TopCategoryCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 20/10/2025.
//

import SwiftUI
import SwiftData

struct TopCategoryCard: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expenses: [Expense]
    
 
    func expenses(for category: Category, in all: [Expense]) -> [Expense] {
        all.filter { $0.category == category }
    }

    func total(for category: Category, in all: [Expense]) -> Decimal {
        expenses(for: category, in: all).reduce(0 as Decimal) { $0 + $1.amount }
    }

    func highestSpendingCategory(in all: [Expense])
    -> (category: Category, total: Decimal, percent: Double, percentInt: Int)? {

        let totalSpent = all.reduce(0 as Decimal) { $0 + $1.amount }
        guard totalSpent > 0 else { return nil }

        let top = Category.allCases
            .map { cat in (cat, total(for: cat, in: all)) }
            .max(by: { $0.1 < $1.1 })!

        let pct = (Double(truncating: top.1 as NSDecimalNumber) /
                   Double(truncating: totalSpent as NSDecimalNumber)) * 100.0
        let pctInt = Int(pct.rounded())

        return (category: top.0, total: top.1, percent: pct, percentInt: pctInt)
    }


    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let top = highestSpendingCategory(in: expenses)
        
        VStack {
            HStack {
                Image(systemName: "clock.circle")
                    .foregroundStyle(Color.light2)
                
                Text("Top Spending Category")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("Normal")
                    .font(.system(size: 10, weight: .light))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.light2.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.light2.opacity(0.3), lineWidth: 1))
            }
            Divider()
            
            HStack {
                VStack(spacing: 4) {
                    Text("Category: ")
                        .font(.system(size: 12, weight: .light))
                    
                    HStack {
                        Image(systemName: top?.category.icon ?? "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(top?.category.color ?? Color.light2)
                        Text(top?.category.name ?? "None")
                            .font(.system(size: 12, weight: .semibold))
                    }
                  
                }
           
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Spent:")
                        .font(.system(size: 12, weight: .light))
                    Text("\(symbol) \(top?.total ?? 0)")
                        .font(.system(size: 12, weight: .semibold))
                }
                
            }
            .padding(.vertical, 6)
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.light2)
                Text("\(top?.percentInt ?? 0)%")
                    .font(.system(size: 12, weight: .semibold))
            }
            
            Divider()
            
            Text("On average \(top?.category.name ?? "None") accounts for \(top?.percentInt ?? 0)% of your spending")
                .font(.system(size: 12, weight: .light))
                .padding(.vertical, 6)
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white,  lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        
    }
}

#Preview {
    TopCategoryCard(expenses: previewExpenses)
}

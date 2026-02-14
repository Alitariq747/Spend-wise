//
//  OverviewView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 12/10/2025.
//

import SwiftUI
import SwiftData

struct OverviewView: View {
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    @Binding var selectedMonth: Date
    
    let budgetForMonth: Budget?
    let monthExpenses: [Expense]
    
    private var categoryTotals:[CategoryEntity: Decimal] {
        totalsByCategory(_expenses: monthExpenses)
    }
    
    var body: some View {
        let segs = pieSegments(
            monthExpenses: monthExpenses,
            budgetAmount: budgetForMonth?.amount
        )

        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(categories, id: \.id) { c in
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(c.color)
                            .font(.caption)
                        Text(c.name)
                            .font(.caption2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PieChart(segments: segs)
                .frame(width: 180, height: 180)
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 2)
        )
    }

    
  
    
    private func pieSegments(monthExpenses: [Expense], budgetAmount: Decimal?) -> [PieChart.Segment] {
        let byCat = totalsByCategory(_expenses: monthExpenses)
        let totalSpent: Decimal = byCat.values.reduce(0 as Decimal, +)
        let denom: Decimal = (budgetAmount ?? 0) > 0 ? (budgetAmount ?? 0) : totalSpent

        func ratio(_ num: Decimal, _ den: Decimal) -> Double {
            guard den > 0 else { return 0 }
            let n = Double(truncating: num as NSDecimalNumber)
            let d = Double(truncating: den as NSDecimalNumber)
            guard n.isFinite, d.isFinite, d > 0 else { return 0 }
            let raw = n / d
            guard raw.isFinite else { return 0 }
            return max(0, min(1, raw))
        }

        return categories.compactMap { cat in
            let spent = byCat[cat] ?? 0
            let f = ratio(spent, denom)
            return f > 0 ? .init(fraction: f, color: cat.color) : nil
        }
    }
}

//#Preview {
//    OverviewView(selectedMonth: .constant(Calendar.current.date(from: .init(year: 2025, month: 10))!))
//}

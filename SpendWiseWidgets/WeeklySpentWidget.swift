//
//  WeeklySpentWidget.swift
//  SpendWiseWidgetsExtension
//
//  Created by Ahmad Ali Tariq on 27/11/2025.
//

import Foundation
import WidgetKit
import SwiftUI
import SwiftData



struct WeekSpentWigetView: View {
    
    let entry: MonthOverviewEntry
    
    private func weeklyBudget(monthBudget: Decimal, divisor: Decimal = 4.25) -> Int {
        guard monthBudget > 0, divisor > 0 else { return 0 }
        
        let monthlyNS = monthBudget as NSDecimalNumber
        let divisorNS = divisor as NSDecimalNumber
        
        let raw = monthlyNS.dividing(by: divisorNS).doubleValue
        let int = raw.rounded(.toNearestOrAwayFromZero)
        
        return Int(int)
    }
    
    func safeProgress(spent: Decimal, budget: Decimal) -> Double {
        guard budget > 0 else {
            return 0
        }
        let ratio = (spent as NSDecimalNumber).doubleValue / (budget as NSDecimalNumber).doubleValue
        
        return min(max(ratio, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            let weeklyBudget = weeklyBudget(monthBudget: entry.budgetAmount)
            let progress = safeProgress(spent: entry.weekSpent, budget: Decimal(weeklyBudget))
           
            
            HStack {
                Text("\(entry.currencyCode)\(entry.weekSpent)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                Spacer()
                
                Text("💸")
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                Text("of \(entry.currencyCode)\(weeklyBudget)")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(.white)
                Text("spent this week")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(.white)
            }
           
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(progress >= 1 ? .red : .green)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
           
        }
    
        .containerBackground(for: .widget) {
            Color.mint.opacity(2.5)
                    }
    }
}

struct WeeklySpentWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WeeklySpentWidget", provider: MonthOverviewProvider()) { entry in
            WeekSpentWigetView(entry: entry)
        }
        .configurationDisplayName("Weekly Spending")
        .description("Shows how much you spent this week")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WeeklySpentWidget()
} timeline: {
    MonthOverviewEntry(
        date: Date(),
        currencyCode: "$",
        budgetAmount: 80000,
        spent: 52300,
        todaySpent: 2300,
        weekSpent: 12000,

        daysRemaining: 9
    )
}


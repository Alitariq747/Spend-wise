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
    @Environment(\.colorScheme) private var colorScheme
    
    let entry: MonthOverviewEntry
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondary: Color {
        textColor.opacity(0.78)
    }
    
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    color(hex: 0x0B1020),
                    color(hex: 0x121A30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    color(hex: 0xDFF5EF),
                    color(hex: 0xB9E6D6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
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
        let spentValue = (spent as NSDecimalNumber).doubleValue
        let budgetValue = (budget as NSDecimalNumber).doubleValue
        guard spentValue.isFinite, budgetValue.isFinite, budgetValue > 0 else { return 0 }
        let ratio = spentValue / budgetValue
        guard ratio.isFinite else { return 0 }
        return min(max(ratio, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            let weeklyBudget = weeklyBudget(monthBudget: entry.budgetAmount)
            let progress = safeProgress(spent: entry.weekSpent, budget: Decimal(weeklyBudget))
           
            
            HStack {
                Text("\(entry.currencyCode)\(entry.weekSpent)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(textColor)
                    .padding(.bottom, 8)
                Spacer()
                
                Text("💸")
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                Text("of \(entry.currencyCode)\(weeklyBudget)")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(secondary)
                Text("spent this week")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(secondary)
            }
           
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(progress >= 1 ? .red : (colorScheme == .dark ? .green.opacity(0.8) : .green))
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
           
        }
    
        .containerBackground(for: .widget) {
            backgroundGradient
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14), lineWidth: 1)
                )
        }
    }
}

private func color(hex: UInt32) -> Color {
    let r = Double((hex >> 16) & 0xFF) / 255
    let g = Double((hex >> 8) & 0xFF) / 255
    let b = Double(hex & 0xFF) / 255
    return Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
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

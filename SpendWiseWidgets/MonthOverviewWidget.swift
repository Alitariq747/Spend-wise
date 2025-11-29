//
//  MonthOverviewWidget.swift
//  SpendWiseWidgetsExtension
//
//  Created by Ahmad Ali Tariq on 26/11/2025.
//

import Foundation

import WidgetKit
import SwiftUI
import SwiftData

struct MonthOverviewEntry: TimelineEntry {
    let date: Date

    // What MonthlyOverview needs
    let currencyCode: String
    let budgetAmount: Decimal
    let spent: Decimal
    let todaySpent: Decimal
    let weekSpent: Decimal
 
    let daysRemaining: Int
}


struct MonthOverviewWidgetView: View {
    let entry: MonthOverviewEntry

    func safeProgress(spent: Decimal, budget: Decimal) -> Double {
        guard budget > 0 else {
            return 0
        }
        let ratio = (spent as NSDecimalNumber).doubleValue / (budget as NSDecimalNumber).doubleValue
        
        return min(max(ratio, 0), 1)
    }
    
    var body: some View {
       
        let progress = safeProgress(spent: entry.spent, budget: entry.budgetAmount)

        VStack(alignment: .leading, spacing: 8) {
       
            HStack {
                Text("\(entry.currencyCode)\(entry.spent)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                
                
                Link(destination: URL(string: "SpendWise://addExpense")!) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.green.opacity(0.6), in: Circle())
                }
            

            }
            
            VStack(alignment: .leading) {
                Text("of \(entry.currencyCode)\(entry.budgetAmount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                Text("spent this month")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
            }
           
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(progress >= 1 ? .red : .green)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
        }
        .padding(.vertical)
        .padding(.horizontal, 6)
        .containerBackground(for: .widget) {
                Image("WidgetBackgroundimage")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                
        }
        .widgetURL(URL(string: "SpendWise://addExpense")!)
    }
}

struct MonthOverviewProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthOverviewEntry {
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

    func getSnapshot(in context: Context,
                        completion: @escaping (MonthOverviewEntry) -> Void) {
           // For now, just reuse real data or placeholder
           let entry = loadEntryForCurrentMonth() ?? placeholder(in: context)
           completion(entry)
       }

       func getTimeline(in context: Context,
                        completion: @escaping (Timeline<MonthOverviewEntry>) -> Void) {
           let entry = loadEntryForCurrentMonth() ?? placeholder(in: context)

           // Refresh e.g. every 30 minutes
           let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)

           let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
           completion(timeline)
       }
    
    private func loadEntryForCurrentMonth() -> MonthOverviewEntry? {
        
       guard let container = WidgetModelContainer.shared else { return nil }
         
        let context = ModelContext(container)
        
        let now = Date()
        let monthKey = MonthUtil.monthKey(now)
        
        // Settings for currency
        let settingsFetch = FetchDescriptor<Settings>()
        let settings = (try? context.fetch(settingsFetch))?.first
        let code = settings?.currencyCode ?? "$"
        
        // Fetch Budget for current Month
        let budgetFetch = FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == monthKey})
        let budget = (try? context.fetch(budgetFetch))?.first
        let budgetAmount = budget?.amount ?? 0
        
        // Expenses fetch
        let expensesFetch = FetchDescriptor<Expense>(predicate: #Predicate { $0.monthKey == monthKey})
        let expenses = (try? context.fetch(expensesFetch)) ?? []
        
        let totalSpent = expenses.reduce(0) { $0 + $1.amount }
        
        let cal = Calendar.current
        
        let todaySpent = expenses
                    .filter { cal.isDateInToday($0.date) }
                    .reduce(Decimal.zero) { $0 + $1.amount }

        let weekSpent = expenses
                    .filter { cal.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
                    .reduce(Decimal.zero) { $0 + $1.amount }
        
        let daysRemaining = daysRemaining(in: now)
        
        let symbol = CurrencyUtil.symbol(for: code)
        
        return MonthOverviewEntry(date: now, currencyCode: symbol, budgetAmount: budgetAmount, spent: totalSpent, todaySpent: todaySpent, weekSpent: weekSpent, daysRemaining: daysRemaining)
    }
}

#Preview(as: .systemMedium) {
   MonthOverviewWidget()
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

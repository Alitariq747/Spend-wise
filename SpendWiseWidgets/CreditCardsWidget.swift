//
//  CreditCardsWidget.swift
//  SpendWiseWidgetsExtension
//
//  Created by Codex on 04/06/2025.
//

import Foundation
import WidgetKit
import SwiftUI
import SwiftData

struct CardSummary: Identifiable {
    let id = UUID()
    let name: String
    let color: CardColor
    let spent: Decimal
    let limit: Decimal
    let cycleStart: Date
    let cycleEnd: Date
    let dueDate: Date
}

struct CreditCardsEntry: TimelineEntry {
    let date: Date
    let currencySymbol: String
    let cards: [CardSummary]
}

private struct CreditCardsWidgetView: View {
    let entry: CreditCardsEntry
    
    private func progress(for summary: CardSummary) -> Double {
        let spentD = (summary.spent as NSDecimalNumber).doubleValue
        let limitD = (summary.limit as NSDecimalNumber).doubleValue
        guard limitD > 0 else { return 0 }
        return min(max(spentD / limitD, 0), 1)
    }
    
    private func availableText(for summary: CardSummary) -> String {
        let available = summary.limit - summary.spent
        if available < 0 {
            return "Over by \(entry.currencySymbol)\((available * -1) as NSDecimalNumber)"
        }
        return "Avail \(entry.currencySymbol)\(available as NSDecimalNumber)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cards")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Soonest due")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            ForEach(entry.cards.prefix(3)) { summary in
                let fg = summary.color.onCardText
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(summary.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(fg)
                            
                            Text("\(dueLabel(for: summary.cycleStart)) – \(dueLabel(for: summary.cycleEnd))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(fg.opacity(0.9))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(entry.currencySymbol)\(summary.spent)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(fg)
                            
                            Text("of \(entry.currencySymbol)\(summary.limit)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(fg.opacity(0.9))
                        }
                    }
                    
                    ProgressView(value: progress(for: summary))
                        .progressViewStyle(.linear)
                        .tint(progress(for: summary) >= 1 ? .red : .green)
                        .scaleEffect(x: 1, y: 1.3, anchor: .center)
                    
                    HStack {
                        Text(availableText(for: summary))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(fg.opacity(0.9))
                        Spacer()
                        Text("Due \(dueLabel(for: summary.dueDate))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(fg)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(fg == .white ? Color.white.opacity(0.16) : Color.black.opacity(0.08))
                            )
                    }
                }
                .padding()
                .background(summary.color.gradient, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color.black.opacity(0.85), Color.black.opacity(0.65)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct CreditCardsProvider: TimelineProvider {
    func placeholder(in context: Context) -> CreditCardsEntry {
        CreditCardsEntry(
            date: Date(),
            currencySymbol: "$",
            cards: [
                CardSummary(name: "Alfalah", color: .royalBlue, spent: 23000, limit: 40000, cycleStart: Date(), cycleEnd: Date().addingTimeInterval(86400 * 30), dueDate: Date().addingTimeInterval(86400 * 20)),
                CardSummary(name: "HBL", color: .roseGold, spent: 12000, limit: 30000, cycleStart: Date(), cycleEnd: Date().addingTimeInterval(86400 * 30), dueDate: Date().addingTimeInterval(86400 * 22)),
                CardSummary(name: "Silk", color: .graphite, spent: 8000, limit: 25000, cycleStart: Date(), cycleEnd: Date().addingTimeInterval(86400 * 30), dueDate: Date().addingTimeInterval(86400 * 18))
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CreditCardsEntry) -> Void) {
        let entry = loadEntry() ?? placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CreditCardsEntry>) -> Void) {
        let entry = loadEntry() ?? placeholder(in: context)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
    
    private func loadEntry() -> CreditCardsEntry? {
        guard let container = WidgetModelContainer.shared else { return nil }
        let context = ModelContext(container)
        
        let now = Date()
        
        // currency
        let settingsFetch = FetchDescriptor<Settings>()
        let settings = (try? context.fetch(settingsFetch))?.first
        let currencyCode = settings?.currencyCode ?? "$"
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        // fetch cards
        let cardFetch = FetchDescriptor<CreditCard>(sortBy: [SortDescriptor(\.name)])
        guard let cards = try? context.fetch(cardFetch), !cards.isEmpty else {
            return CreditCardsEntry(date: now, currencySymbol: symbol, cards: [])
        }
        
        var summaries: [CardSummary] = []
        for card in cards {
            let cycle = cardCycleAndDue(statementDay: card.statementDay, dueDay: card.dueDay, reference: now)
            let start = cycle.start
            let end = cycle.end
            let cardID = card.persistentModelID
            
            let expensesFetch = FetchDescriptor<Expense>(
                predicate: #Predicate {
                    $0.card?.persistentModelID == cardID &&
                    $0.date >= start &&
                    $0.date < end
                }
            )
            
            let expenses = (try? context.fetch(expensesFetch)) ?? []
            let spent = expenses.reduce(Decimal.zero) { $0 + $1.amount }
            
            summaries.append(
                CardSummary(
                    name: card.name,
                    color: card.color,
                    spent: spent,
                    limit: card.cycleLimit,
                    cycleStart: cycle.start,
                    cycleEnd: cycle.end,
                    dueDate: cycle.due
                )
            )
        }
        
        let sorted = summaries.sorted { lhs, rhs in
            if lhs.dueDate == rhs.dueDate {
                return (lhs.spent as NSDecimalNumber).doubleValue > (rhs.spent as NSDecimalNumber).doubleValue
            }
            return lhs.dueDate < rhs.dueDate
        }
        
        return CreditCardsEntry(date: now, currencySymbol: symbol, cards: Array(sorted.prefix(2)))
    }
}

struct CreditCardsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CreditCardsWidget", provider: CreditCardsProvider()) { entry in
            CreditCardsWidgetView(entry: entry)
        }
        .configurationDisplayName("Credit Cards")
        .description("See your top cards with spend, limits, cycles, and due dates.")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemLarge) {
    CreditCardsWidget()
} timeline: {
    CreditCardsEntry(
        date: Date(),
        currencySymbol: "$",
        cards: [
            CardSummary(name: "Alfalah", color: .royalBlue, spent: 23000, limit: 40000, cycleStart: Date(), cycleEnd: Date().addingTimeInterval(86400 * 30), dueDate: Date().addingTimeInterval(86400 * 20)),
            CardSummary(name: "HBL", color: .roseGold, spent: 12000, limit: 30000, cycleStart: Date(), cycleEnd: Date().addingTimeInterval(86400 * 30), dueDate: Date().addingTimeInterval(86400 * 22)),
          
        ]
    )
}

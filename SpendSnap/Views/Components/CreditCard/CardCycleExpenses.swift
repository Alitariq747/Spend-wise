//
//  CardCycleExpenses.swift
//  SpendSnap
//

import SwiftUI
import SwiftData

/// Live-fetches one card's expenses for one cycle, `[cycle.start, cycle.end)`, newest
/// first, and hands them to `content`. Card views use this instead of querying every
/// expense in the store.
struct CardCycleExpenses<Content: View>: View {
    @Query private var fetched: [Expense]
    private let content: ([Expense]) -> Content

    init(card: CreditCard, cycle: CardCycle, @ViewBuilder content: @escaping ([Expense]) -> Content) {
        let cardID = card.persistentModelID
        let start = cycle.start
        let end = cycle.end
        _fetched = Query(
            filter: #Predicate<Expense> {
                $0.card?.persistentModelID == cardID && $0.date >= start && $0.date < end
            },
            sort: \Expense.date,
            order: .reverse
        )
        self.content = content
    }

    var body: some View {
        content(fetched.filter { $0.method == .card })
    }
}

//
//  CreditCardView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 02/11/2025.
//

import SwiftUI
import SwiftData

struct CardSnapShot: Identifiable {
    let id = UUID()
    let card: CreditCard
    let cycle: CardCycle
    let expensesThisCycle: [Expense]
    let spentThisCycle: Decimal
}

struct CreditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKit: StoreKitManager
    
    @Query(sort: \CreditCard.name) private var cards: [CreditCard]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    
    @State private var showAddCardSheet = false
    @State private var showGoProSheet = false
    @State private var selectedCard: CreditCard? = nil
    @State private var selected: CardSnapShot? = nil
    
    private func makeSnapshot(for card: CreditCard) -> CardSnapShot {
        let cycle = cardCycleAndDue(statementDay: card.statementDay, dueDay: card.dueDay)
        let expensesThisCycle = allExpenses.filter {
            $0.method == .card &&
            $0.card == card &&
            $0.date >= cycle.start && $0.date < cycle.end
        }
        let spent = expensesThisCycle.reduce(.zero) { $0 + $1.amount}
        return CardSnapShot(card: card, cycle: cycle, expensesThisCycle: expensesThisCycle, spentThisCycle: spent)
    }

    @MainActor
    private func handleAddCardTap() async {
        if !storeKit.isEntitlementsLoaded {
            await storeKit.refreshEntitlements()
        }

        guard storeKit.hasActiveSubscription else {
            showGoProSheet = true
            return
        }

        showAddCardSheet = true
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground).ignoresSafeArea()
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Cards")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    // Button to open add card sheet
                    Button {
                        Task {
                            await handleAddCardTap()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .symbolRenderingMode(.monochrome)
                            .font(.system(size: 12, weight: .semibold))
                            .tint(Color(.systemGray))
                            .padding(8)
                            .background(Color(.secondarySystemBackground), in: Circle())
                    }

                }
                
                if cards.count == 0 {
                    NoCardView()
                } else {
                    CreditCardList(creditCards: cards) { card in
                        selected = makeSnapshot(for: card)
                    }
                }
                    
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet()
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showGoProSheet) {
            GoProSheet()
        }
        .presentationDetents([.large])
        .sheet(item: $selected) { snap in
            CardDetailSheet(snapshot: snap, onClose: { selected = nil })
        }
        .presentationDetents([.large])
    }
}

#Preview {
    CreditCardView()
        .environmentObject(StoreKitManager())
}

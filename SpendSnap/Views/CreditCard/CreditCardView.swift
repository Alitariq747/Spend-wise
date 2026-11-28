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
    /// The statement the tile shows (D25); the detail sheet opens on it.
    let cycle: CardCycle
}

struct CreditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKit: StoreKitManager
    
    @Query(sort: \CreditCard.name) private var cards: [CreditCard]
    
    @State private var showAddCardSheet = false
    @State private var showGoProSheet = false
    @State private var selectedCard: CreditCard? = nil
    @State private var selected: CardSnapShot? = nil
    
    private func makeSnapshot(for card: CreditCard) -> CardSnapShot {
        CardSnapShot(card: card, cycle: cardStatementToShow(statementDay: card.statementDay, dueDay: card.dueDay).cycle)
    }

    @MainActor
    private func handleAddCardTap() async {
        await storeKit.requirePro({ showAddCardSheet = true }, otherwise: { showGoProSheet = true })
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
                    .accessibilityLabel("Add card")

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
        // `CardSnapShot` retains a CreditCard, so drop it
        // before a body can read one of them back after a delete.
        .onReceive(NotificationCenter.default.publisher(for: .spendWiseDidDeleteAllData)) { _ in
            selected = nil
            selectedCard = nil
        }
    }
}

#Preview {
    CreditCardView()
        .environmentObject(StoreKitManager())
}

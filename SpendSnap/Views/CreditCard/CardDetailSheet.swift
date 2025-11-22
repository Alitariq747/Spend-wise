//
//  CardDetailSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 06/11/2025.
//

import SwiftUI
import SwiftData

struct CardDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsRow: [Settings]
    @State private var showEditSheet = false
    
    let snapshot: CardSnapShot
  
    var onClose: (() -> Void)? = nil
    var onExpensesChanged: (() -> Void)? = nil
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    @State private var selectedExpense: Expense? = nil
    
    
    var body: some View {
       
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        // parent view
        VStack {
            // HStack for card icon name and cycle limit plus button to edit / delete card
            HStack {
                // Inner HStack for icon and name + limit
                HStack {
                    Image(systemName: "creditcard")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(snapshot.card.color.gradient, in: RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading) {
                        Text(snapshot.card.name)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("\(symbol) \(snapshot.card.cycleLimit)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                
                Button {
                   showEditSheet = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }

            }
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(snapshot.expensesThisCycle, id: \.id) { exp in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(exp.date, style: .date)
                                    .font(.system(size: 14, weight: .light))
                                Spacer()
                              
                              
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
        .sheet(isPresented: $showEditSheet) {
            CardEditSheet(card: snapshot.card, onDelete: {
                onClose?()
            })
        }
        .presentationDetents([.large])
        .sheet(item: $selectedExpense, content: { expense in
            ExpenseDetailSheet(expense: expense, onDeleteExpense: { onExpensesChanged?() })
        })
    }
}

#Preview {
    CardDetailSheet(snapshot: CardSnapShot(card: CreditCard(name: "Alfalah", cycleLimit: 20000, statementDay: 5, dueDay: 25), cycle: cardCycleAndDue(statementDay: 5, dueDay: 25), expensesThisCycle: previewExpenses, spentThisCycle: 23000))
}

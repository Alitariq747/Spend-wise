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
    
    @Query(sort: Settings.oldestFirst) private var settingsRow: [Settings]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @State private var showEditSheet = false
    @State private var cycleReference = Date()
    
    let snapshot: CardSnapShot
  
    var onClose: (() -> Void)? = nil
    var onExpensesChanged: (() -> Void)? = nil
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? Settings.defaultCurrencyCode
    }
    @State private var selectedExpense: Expense? = nil

    private var selectedCycle: CardCycle {
        cardCycleAndDue(
            statementDay: snapshot.card.statementDay,
            dueDay: snapshot.card.dueDay,
            reference: cycleReference
        )
    }

    private var currentCycle: CardCycle {
        cardCycleAndDue(
            statementDay: snapshot.card.statementDay,
            dueDay: snapshot.card.dueDay
        )
    }

    private var canMoveToNextCycle: Bool {
        selectedCycle.start < currentCycle.start
    }

    private var displayedExpenses: [Expense] {
        allExpenses.filter {
            $0.method == .card &&
            $0.card == snapshot.card &&
            $0.date >= selectedCycle.start &&
            $0.date < selectedCycle.end
        }
    }

    private var displayedSpent: Decimal {
        displayedExpenses.reduce(.zero) { $0 + $1.amount }
    }
    
    
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
                        
                        Text(verbatim: "\(symbol) \(snapshot.card.cycleLimit)")
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
            HStack {
                Button {
                    cycleReference = cardCycleReference(from: selectedCycle, offsetByMonths: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
                .buttonStyle(.plain)

                VStack(spacing: 3) {
                    Text("Billing Cycle")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(verbatim: "\(selectedCycle.start.formatted(date: .abbreviated, time: .omitted)) - \(selectedCycle.end.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 13, weight: .medium))
                    Text(verbatim: "\(symbol) \(displayedSpent) • \(displayedExpenses.count) expenses")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Button {
                    cycleReference = cardCycleReference(from: selectedCycle, offsetByMonths: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(!canMoveToNextCycle)
                .opacity(canMoveToNextCycle ? 1 : 0.3)
            }
            .padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    if displayedExpenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("No expenses in this cycle")
                                .font(.system(size: 14, weight: .medium))
                            Text("Card purchases linked to this billing cycle will appear here.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(displayedExpenses, id: \.id) { exp in
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
                                Text(verbatim: "\(symbol)\(exp.amount)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExpense = exp
                        }
                        }
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

//
//  CCView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 03/11/2025.
//

import SwiftUI
import SwiftData

struct CCView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: Settings.oldestFirst) private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? Settings.defaultCurrencyCode
    }
    
    let card: CreditCard
    
    /// The statement this tile shows (D25): the last closed one until its due date passes.
    private var cycle: CardCycle {
        cardStatementToShow(statementDay: card.statementDay, dueDay: card.dueDay).cycle
    }

    private func progress(_ spent: Decimal) -> Double {
        let spentD = (spent as NSDecimalNumber).doubleValue
        let limitD = (card.cycleLimit as NSDecimalNumber).doubleValue
        guard spentD.isFinite, limitD.isFinite, limitD > 0 else { return 0 }
        let ratio = spentD / limitD
        guard ratio.isFinite else { return 0 }
        return min(max(ratio, 0), 1)
    }

    private func progressColor(_ progress: Double) -> Color {
        switch progress {
        case ..<0.6:  return .green
        case ..<0.85: return .orange
        default:      return .red
        }
    }
    
    var onSelect: (() -> Void)? = nil
    
    var body: some View {
        let cc = cycle
        CardCycleExpenses(card: card, cycle: cc) { expenses in
            tile(cc, spent: expenses.reduce(Decimal.zero) { $0 + $1.amount })
        }
    }

    @ViewBuilder
    private func tile(_ cc: CardCycle, spent spentThisCycle: Decimal) -> some View {
        let fg = card.color.onCardText
        let ratio = progress(spentThisCycle)
        let remaining = card.cycleLimit - spentThisCycle
        // Parent VStack
        
        VStack(alignment: .leading, spacing: 18) {
            // HStack for Name, limit, payment due
            HStack {
                // VStack for name and cycleLimt
                VStack(spacing: 4) {
                    Text(card.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(fg)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                }
                
                Spacer()
                // VStack for Payment Due
                Button {
                    onSelect?()
                } label: {
                    Image(systemName: "ellipsis")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(fg)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                }

               
            }
            MoneyText(spentThisCycle, code: currencyCode)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(fg)
                .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
            // Progress View -> b/w limit and spent on this card
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: ratio)
                    .progressViewStyle(.linear)
                    .tint(progressColor(ratio))
                    .background(
                        Capsule().fill(Color(.tertiarySystemFill))
                    )
                    .clipShape(Capsule())
                    .scaleEffect(y: 1.2, anchor: .center)
                
                HStack {
                    Text("of \(Money.format(card.cycleLimit, code: currencyCode))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(card.color.onCardText)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                    Spacer()
                    remaining < 0 ? Text(verbatim: "💥 \(remaining * -1)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(card.color.onCardText)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                    : nil
                }
                    
            }
           
            
            // HStack for edit button , percent, cycle
            HStack {
                Text(verbatim: "\(dueLabel(for: cc.start)) - \(dueLabel(for: cc.end))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(card.color.onCardText)
                    .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                Spacer()
                
                Text(verbatim: dueLabel(for: cc.due))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.red.opacity(0.9)))
               
            }
          
        }
        .padding(.horizontal)
        .padding(.vertical, 18)
        .background(card.color.gradient, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CCView(card: CreditCard(name: "Alfalah", cycleLimit: 20000.00, statementDay: 6, dueDay: 10, color: .midnightBlue))
}

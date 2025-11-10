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
    
    @Query private var settingsRow: [Settings]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let card: CreditCard
    
    private var cycle: CardCycle {
        cardCycleAndDue(
            statementDay: card.statementDay,
            dueDay: card.dueDay
        )
    }

    private var expensesThisCycle: [Expense] {
        allExpenses.filter { exp in
            exp.method == .card &&
            exp.card == card &&
            exp.date >= cycle.start && exp.date < cycle.end
            
        }
    }
    
    private var spentThisCycle: Decimal {
        expensesThisCycle.reduce(.zero) { $0 + $1.amount }
    }
    
    private var spentD: Double {
        (spentThisCycle as NSDecimalNumber).doubleValue
    }
    private var limitD: Double {
        (card.cycleLimit as NSDecimalNumber).doubleValue
    }

   
    private var progress: Double {
        guard limitD > 0 else { return 0 }
        return min(max(spentD / limitD, 0), 1)
    }


    private var remaining: Decimal {
        let rem = card.cycleLimit - spentThisCycle
        return rem
    }

 
    private var progressColor: Color {
        switch progress {
        case ..<0.6:  return .green
        case ..<0.85: return .orange
        default:      return .red
        }
    }
    
    var onSelect: (() -> Void)? = nil
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        let cc = cardCycleAndDue(statementDay: card.statementDay, dueDay: card.dueDay)
        
        let fg = card.color.onCardText
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
            Text("\(symbol) \(spentThisCycle)")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(fg)
                .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
            // Progress View -> b/w limit and spent on this card
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(progressColor)
                    .background(
                        Capsule().fill(Color(.tertiarySystemFill))
                    )
                    .clipShape(Capsule())
                    .scaleEffect(y: 1.2, anchor: .center)
                
                HStack {
                    Text("of \(symbol) \(card.cycleLimit)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(card.color.onCardText)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                    Spacer()
                    remaining < 0 ? Text("💥 \(remaining * -1)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(card.color.onCardText)
                        .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                    : nil
                }
                    
            }
           
            
            // HStack for edit button , percent, cycle
            HStack {
                Text("\(dueLabel(for: cc.start)) - \(dueLabel(for: cc.end))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(card.color.onCardText)
                    .shadow(color: .black.opacity(fg == .white ? 0.25 : 0), radius: 2, y: 1)
                Spacer()
                
                Text("\(dueLabel(for: cc.due))")
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

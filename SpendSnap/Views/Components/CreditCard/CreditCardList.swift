//
//  CreditCardList.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 03/11/2025.
//

import SwiftUI

struct CreditCardList: View {
    
    let creditCards: [CreditCard]
    var onSelect: ((CreditCard) -> Void)? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(creditCards, id: \.name) { card in
                    CCView(card: card, onSelect: { onSelect?(card)})
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect?(card)
                        }
                }
            }
        }
    }
}

#Preview {
    CreditCardList(creditCards: [CreditCard(name: "Alfalah", cycleLimit: 1000, statementDay: 6, dueDay: 16)])
}

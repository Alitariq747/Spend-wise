//
//  MoneyText.swift
//  SpendSnap
//

import SwiftUI

/// An amount on screen, formatted by `Money.format` for the user's locale.
struct MoneyText: View {
    let amount: Decimal
    let code: String

    init(_ amount: Decimal, code: String) {
        self.amount = amount
        self.code = code
    }

    var body: some View {
        Text(verbatim: Money.format(amount, code: code))
    }
}

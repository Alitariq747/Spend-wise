//
//  StatementPayment.swift
//  SpendSnap
//
//  A card statement marked as paid, in full or in part. One per card per
//  statement; the reconciler in 5.3 merges duplicates from two devices.
//

import Foundation
import SwiftData

@Model
final class StatementPayment {
    var card: CreditCard?
    /// The statement's closing date as POSIX Gregorian `yyyy-MM-dd`, so every
    /// device and time zone groups payments the same way.
    var statementKey: String = ""
    var amountPaid: Decimal = 0
    var paidInFull: Bool = false
    var paidAt: Date = Date()

    init(card: CreditCard, statementKey: String, amountPaid: Decimal, paidInFull: Bool) {
        self.card = card
        self.statementKey = statementKey
        self.amountPaid = amountPaid
        self.paidInFull = paidInFull
        self.paidAt = Date()
    }
}

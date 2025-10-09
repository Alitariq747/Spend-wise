//
//  Budget.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation
import SwiftData

@Model
final class Budget {
  @Attribute(.unique) var id: UUID
  var monthKey: String      
  var amount: Decimal       
  var note: String?

  init(monthKey: String, amount: Decimal, note: String? = nil) {
    self.id = UUID()
    self.monthKey = monthKey
    self.amount = amount
    self.note = note
  }
}

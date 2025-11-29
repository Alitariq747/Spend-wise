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
  var id: UUID = UUID()
  var monthKey: String = ""
  var amount: Decimal = 0


  init(monthKey: String, amount: Decimal) {
    self.id = UUID()
    self.monthKey = monthKey
    self.amount = amount
   
  }
}

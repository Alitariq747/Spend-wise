//
//  Expenses.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation
import SwiftData



@Model
final class Expense {
    @Attribute(.unique) var id: UUID
        var amount: Decimal
        var date: Date
        var merchant: String
        var category: Category
        var method: PaymentMethod
        var monthKey: String

        init(amount: Decimal,
             date: Date = .now,
             merchant: String = "",
             category: Category = .other ,
             method: PaymentMethod = .cash,
           )
        {
            self.id = UUID()
            self.amount = amount
            self.date = date
            self.merchant = merchant
            self.category = category
            self.method = method
          

            let f = DateFormatter(); f.dateFormat = "yyyy-MM"
            self.monthKey = f.string(from: date)
        }
    
    @Relationship var card: CreditCard?
}

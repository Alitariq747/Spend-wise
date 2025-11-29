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
        var id: UUID = UUID()
        var amount: Decimal = 0
        var date: Date = Date()
        var merchant: String = ""
     
        var method: PaymentMethod = PaymentMethod.cash
        var monthKey: String = ""

        var category: CategoryEntity?
        var card: CreditCard?
   
    
        init(amount: Decimal,
             date: Date = .now,
             merchant: String = "",
             category: CategoryEntity? = nil ,
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
    
 
}

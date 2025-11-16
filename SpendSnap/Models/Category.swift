//
//  Category.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import Foundation

import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable {
  case food, groceries, transport, health, bills, shopping, entertainment, education, utilities

  var id: String { rawValue }

  var name: String {
    switch self {
      case .food: "Dine out"
      case .groceries: "Groceries"
      case .transport: "Transport"
      case .health: "Health"
      case .bills: "Bills"
      case .shopping: "Shopping"
      case .entertainment: "Entertainment"
      case .education: "Education"
      case .utilities: "Utilities"
    
    }
  }

  
  var color: Color {
      switch self {
      case .food: .orange
      case .groceries: .green
      case .transport: .blue
      case .health: .red
      case .bills: .indigo
      case .shopping: .pink
      case .entertainment: .purple
      case .education: .cyan
      case .utilities: .yellow

    }
  }
    
    var colorHex: String {
         switch self {
         case .food:          return "F97316" // orange
         case .groceries:     return "22C55E" // green
         case .transport:     return "3B82F6" // blue
         case .health:        return "EF4444" // red
         case .bills:         return "4F46E5" // indigo
         case .shopping:      return "EC4899" // pink
         case .entertainment: return "8B5CF6" // purple
         case .education:     return "06B6D4" // cyan
         case .utilities:     return "EAB308" // yellow
         }
     }
    
    var emoji: String {
        switch self {
        case .food:          "🍽️"      // meals, dine-out
        case .groceries:     "🛒"      // supermarket
        case .transport:     "🚗"      // car, ride, fuel       
        case .health:        "🩺"      // medical / pharmacy
        case .bills:         "🧾"      // invoices / subscriptions
        case .shopping:      "🛍️"      // clothes / random buys
        case .entertainment: "🎬"      // movies / fun
        case .education:     "🎓"      // courses / books
        case .utilities:     "💡"      // electricity / gas / internet
        }
    }

}

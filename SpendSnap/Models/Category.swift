//
//  Category.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import Foundation

import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable {
  case food, groceries, transport, travel, health, bills, shopping, home, entertainment, education, utilities, creditCard, other

  var id: String { rawValue }

  var name: String {
    switch self {
      case .food: "Food"
      case .groceries: "Groceries"
      case .transport: "Transport"
      case .travel: "Travel"
      case .health: "Health"
      case .bills: "Bills"
      case .shopping: "Shopping"
      case .home: "Home"
      case .entertainment: "Entertainment"
      case .education: "Education"
      case .utilities: "Utilities"
      case .creditCard: "Credit Card"
      case .other: "Other"
    }
  }

  var icon: String {
      switch self {
      case .food: "fork.knife"
      case .groceries: "cart"
      case .transport: "car.fill"
      case .travel: "airplane"
      case .health: "cross.case.fill"
      case .bills: "doc.text.fill"
      case .shopping: "bag.fill"
      case .home: "house.fill"
      case .entertainment: "film.fill"
      case .education: "book.fill"
      case .utilities: "bolt.fill"
      case .creditCard: "creditcard.fill"
      case .other: "ellipsis.circle.fill"
    }
  }

  var color: Color {
      switch self {
      case .food: .orange
      case .groceries: .green
      case .transport: .blue
      case .travel: .teal
      case .health: .red
      case .bills: .indigo
      case .shopping: .pink
      case .home: .brown
      case .entertainment: .purple
      case .education: .cyan
      case .utilities: .yellow
      case .creditCard: .mint
      case .other: .gray
    }
  }
    
    var emoji: String {
        switch self {
        case .food:          "🍽️"      // meals, dine-out
        case .groceries:     "🛒"      // supermarket
        case .transport:     "🚗"      // car, ride, fuel
        case .travel:        "✈️"      // trips / flights
        case .health:        "🩺"      // medical / pharmacy
        case .bills:         "🧾"      // invoices / subscriptions
        case .shopping:      "🛍️"      // clothes / random buys
        case .home:          "🏡"      // rent / house
        case .entertainment: "🎬"      // movies / fun
        case .education:     "🎓"      // courses / books
        case .utilities:     "💡"      // electricity / gas / internet
        case .creditCard:    "💳"      // card payments
        case .other:         "✨"      // misc
        }
    }

}

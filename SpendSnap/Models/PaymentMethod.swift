//
//  PaymentMethod.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 09/10/2025.
//

import Foundation
import SwiftUI

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case cash, card
    var id: String { rawValue }
    var title: String { self == .cash ? "Cash" : "Card" }
    var icon: String { self == .cash ? "banknote" : "creditcard" }
}


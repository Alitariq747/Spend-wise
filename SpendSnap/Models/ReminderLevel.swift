//
//  ReminderLevel.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/10/2025.
//

import Foundation

import Foundation

enum ReminderLevel: String, Codable, CaseIterable, Identifiable {
    case quiet
    case subtle
    case aggressive

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .quiet:      return "😌"
        case .subtle:     return "🔔"
        case .aggressive: return "⏰"
        }
    }

    var title: String {
        switch self {
        case .quiet:      return "Quiet"
        case .subtle:     return "Subtle & gentle"
        case .aggressive: return "Aggressive"
        }
    }

    // optional: short description you can show in the sheet
    var description: String {
        switch self {
        case .quiet:      return "No reminders"
        case .subtle:     return "1–2 reminders per day"
        case .aggressive: return "3–5 reminders per day"
        }
    }
    
    var times: [DateComponents] {
        switch self {
        case .quiet:
            return []
        case .subtle:
          
            return [
                DateComponents(hour: 16, minute: 30),
                DateComponents(hour: 20, minute: 0)
            ]
        case .aggressive:
          
            return [
                DateComponents(hour: 9,  minute: 0),
                DateComponents(hour: 12, minute: 30),
                DateComponents(hour: 17, minute: 0),
                DateComponents(hour: 21, minute: 0)
            ]
        }
    }

}



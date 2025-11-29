//
//  CreditCard.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 02/11/2025.
//

import Foundation
import SwiftData
import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension LinearGradient {
    static func linear(colors: [Color],
                       startPoint: UnitPoint,
                       endPoint: UnitPoint) -> LinearGradient {
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: startPoint, endPoint: endPoint)
    }
}


enum CardColor: String, CaseIterable, Identifiable {
    case silver, gold, graphite, royalBlue, deepPurple, midnightBlue, roseGold, platinum
    var id: String { rawValue }

   
    var accent: Color {
        switch self {
        case .silver:    return Color(hex: 0xB8C0CC)
        case .gold:      return Color(hex: 0xC89B3C)
        case .graphite:  return Color(hex: 0x1C212B)
        case .royalBlue: return Color(hex: 0x3C56D6)
        case .deepPurple:return Color(hex: 0x5B45C6)
        case .midnightBlue: return Color(hex: 0x0E1A3A) // deep navy
        case .roseGold:     return Color(hex: 0xC58C7B) // warm rosy metal
        case .platinum:     return Color(hex: 0xDCE1E7)
        }
    }

    
    var gradient: LinearGradient {
        switch self {
        case .silver:
            return .linear(colors: [Color(hex: 0xE7EBF2), Color(hex: 0xC6CCD6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold:
            return .linear(colors: [Color(hex: 0xFFE6A7), Color(hex: 0xD6A74F)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .graphite:
            return .linear(colors: [Color(hex: 0x2B2F3A), Color(hex: 0x101319)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .royalBlue:
            return .linear(colors: [Color(hex: 0x4D6BFF), Color(hex: 0x2F47C2)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .deepPurple:
            return .linear(colors: [Color(hex: 0x7E66FF), Color(hex: 0x4B37C6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .midnightBlue:
            return .linear(
                colors: [Color(hex: 0x14264F), Color(hex: 0x0C1834)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

        case .roseGold:
            return .linear(
                colors: [Color(hex: 0xF2C1B3), Color(hex: 0xC88F7E)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

        case .platinum:
            return .linear(
                colors: [Color(hex: 0xF4F6F9), Color(hex: 0xC9D0D9)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

        }
    }
}

extension CardColor {
    /// The “accent” hex you already use for this palette
    var accentHex: UInt32 {
        switch self {
        case .silver:       return 0xB8C0CC
        case .gold:         return 0xC89B3C
        case .graphite:     return 0x1C212B
        case .royalBlue:    return 0x3C56D6
        case .deepPurple:   return 0x5B45C6
        case .midnightBlue: return 0x0E1A3A
        case .roseGold:     return 0xC58C7B
        case .platinum:     return 0xDCE1E7
        }
    }

    /// Smart text color for this card background (white on dark, black on light)
    var onCardText: Color {
        let hex = accentHex
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0

        // sRGB → linear
        func linear(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055)/1.055, 2.4)
        }
        let L = 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)

        // threshold ~0.53 works well for these palettes
        return L < 0.53 ? .white : .black
    }

    /// Softer secondary text (e.g., captions) that still contrasts
    var onCardSecondaryText: Color {
        onCardText.opacity(0.85)
    }
}


@Model
final class CreditCard {
    var name: String = ""
    var cycleLimit: Decimal = 0
    var statementDay: Int = 1
    var dueDay: Int = 20
    
    var colorRaw: String = CardColor.royalBlue.rawValue
        var color: CardColor {
            get { CardColor(rawValue: colorRaw) ?? .royalBlue }
            set { colorRaw = newValue.rawValue }
        }
    
    init(name: String, cycleLimit: Decimal = 0, statementDay: Int = 1, dueDay: Int = 15, color: CardColor = .royalBlue) {
        self.name = name
        self.cycleLimit = cycleLimit
        self.statementDay = statementDay
        self.dueDay = dueDay
        self.colorRaw = color.rawValue
    }
    
    @Relationship(deleteRule: .cascade , inverse: \Expense.card)
    var expenses: [Expense]? = []
}

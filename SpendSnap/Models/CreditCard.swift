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


    /// The two ends of the card's gradient, top-leading then bottom-trailing.
    var gradientHexes: (UInt32, UInt32) {
        switch self {
        case .silver:       return (0xE7EBF2, 0xC6CCD6)
        case .gold:         return (0xFFE6A7, 0xD6A74F)
        case .graphite:     return (0x2B2F3A, 0x101319)
        case .royalBlue:    return (0x4D6BFF, 0x2F47C2)
        case .deepPurple:   return (0x7E66FF, 0x4B37C6)
        case .midnightBlue: return (0x14264F, 0x0C1834)
        case .roseGold:     return (0xF2C1B3, 0xC88F7E)
        case .platinum:     return (0xF4F6F9, 0xC9D0D9)
        }
    }

    var gradient: LinearGradient {
        let (top, bottom) = gradientHexes
        return .linear(colors: [Color(hex: top), Color(hex: bottom)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension CardColor {
    /// Text colour for this card: black or white, whichever contrasts better
    /// with *both* ends of the gradient (WCAG contrast ratio). Light metals
    /// (silver, gold, rose gold, platinum) get black, the rest white.
    var onCardText: Color {
        func luminance(_ hex: UInt32) -> Double {
            func linear(_ v: UInt32) -> Double {
                let c = Double(v & 0xFF) / 255
                return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(hex >> 16) + 0.7152 * linear(hex >> 8) + 0.0722 * linear(hex)
        }
        let (top, bottom) = gradientHexes
        let lighter = max(luminance(top), luminance(bottom))
        let darker = min(luminance(top), luminance(bottom))
        let whiteContrast = 1.05 / (lighter + 0.05)   // worst case is the lighter end
        let blackContrast = (darker + 0.05) / 0.05    // worst case is the darker end
        return whiteContrast >= blackContrast ? .white : .black
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
    
    /// Stable identity that survives sync (Siri entities, the default card).
    /// Optional on purpose: rows migrated from 2.3, or synced from a 2.3
    /// device, arrive as `nil` and `IdentityBackfill` fills them. Not named
    /// `id`, so SwiftData's own identity keeps driving `ForEach`.
    var stableID: UUID? = nil
    /// Last four digits only, for "the card ending 4421". Never the full number.
    var last4: String = ""
    /// Payoff plan. `yearlyRate` 0 is a real value (Islamic and 0% cards).
    var amountOwed: Decimal = 0
    var yearlyRate: Decimal = 0
    var plannedPayment: Decimal = 0

    var colorRaw: String = CardColor.royalBlue.rawValue
        var color: CardColor {
            get { CardColor(rawValue: colorRaw) ?? .royalBlue }
            set { colorRaw = newValue.rawValue }
        }
    
    init(name: String, cycleLimit: Decimal = 0, statementDay: Int = 1, dueDay: Int = 15, color: CardColor = .royalBlue) {
        self.stableID = UUID()
        self.name = name
        self.cycleLimit = cycleLimit
        self.statementDay = statementDay
        self.dueDay = dueDay
        self.colorRaw = color.rawValue
    }
    
    @Relationship(deleteRule: .cascade , inverse: \Expense.card)
    var expenses: [Expense]? = []

    /// Deleting the card clears the link on its rules; the rules stay.
    @Relationship(deleteRule: .nullify, inverse: \RecurringRule.card)
    var recurringRules: [RecurringRule]? = []

    /// A payment means nothing without its card.
    @Relationship(deleteRule: .cascade, inverse: \StatementPayment.card)
    var statementPayments: [StatementPayment]? = []
}

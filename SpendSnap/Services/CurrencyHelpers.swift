//
//  CurrencyHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 11/10/2025.
//

import Foundation

enum CurrencyUtil {
    private static var cache: [String:String] = [:]

    /// Returns a currency symbol (e.g., "$", "€", "₨") for a given ISO code ("USD","EUR","PKR"...).
   
    static func symbol(for code: String) -> String {
           // pick a locale that actually uses this currency
           let localeID = Locale.availableIdentifiers.first {
               Locale(identifier: $0).currency?.identifier == code
           } ?? Locale.current.identifier

           let f = NumberFormatter()
           f.numberStyle = .currency
           f.currencyCode = code
           f.locale = Locale(identifier: localeID)
           return f.currencySymbol ?? code
       }

    /// Optional: full formatted money string using the chosen currency
    static func format(_ amount: Decimal, code: String, locale: Locale = .current) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        f.locale = locale
        return f.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

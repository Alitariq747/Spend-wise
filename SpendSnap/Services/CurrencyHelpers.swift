//
//  CurrencyHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 11/10/2025.
//

import Foundation

struct CurrencyOption: Identifiable {
    let id = UUID()
    let code: String
    let symbol: String
    let name: String
}


enum CurrencyUtil {
    private static var cache: [String:String] = [:]

 
    static func symbol(for code: String) -> String {
        // 1) Check cache first
        if let cached = cache[code.uppercased()] {
            return cached
        }

        // 2) Look up in your CurrencyOption list
        if let option = CurrencyOption.allCurrencies.first(where: {
            $0.code.caseInsensitiveCompare(code) == .orderedSame
        }) {
            cache[code.uppercased()] = option.symbol
            return option.symbol
        }

        // 3) Fallback: if we don't know this code yet, just show the code itself
        //    (or you could hard-code a generic "¤" symbol here if you prefer)
        cache[code.uppercased()] = code
        return code
    }


    /// Optional: full formatted money string using the chosen currency
    static func format(_ amount: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}



extension CurrencyOption {
    static let allCurrencies: [CurrencyOption] = [
        // 🇵🇰 South Asia / local relevance first
        CurrencyOption(code: "PKR", symbol: "₨",     name: "Pakistani Rupee"),
        CurrencyOption(code: "INR", symbol: "₹",      name: "Indian Rupee"),
        CurrencyOption(code: "BDT", symbol: "৳",      name: "Bangladeshi Taka"),
        CurrencyOption(code: "LKR", symbol: "Rs",     name: "Sri Lankan Rupee"),
        CurrencyOption(code: "NPR", symbol: "Rs",     name: "Nepalese Rupee"),

        // 🌍 Gulf / Middle East (a lot of cross-border payments/remittance)
        CurrencyOption(code: "AED", symbol: "د.إ",    name: "UAE Dirham"),
        CurrencyOption(code: "SAR", symbol: "﷼",     name: "Saudi Riyal"),
        CurrencyOption(code: "QAR", symbol: "﷼",     name: "Qatari Riyal"),
        CurrencyOption(code: "KWD", symbol: "د.ك",    name: "Kuwaiti Dinar"),
        CurrencyOption(code: "OMR", symbol: "ر.ع.",   name: "Omani Rial"),
        CurrencyOption(code: "BHD", symbol: "ب.د",    name: "Bahraini Dinar"),

        // 🌍 North America
        CurrencyOption(code: "USD", symbol: "$",      name: "US Dollar"),
        CurrencyOption(code: "CAD", symbol: "CA$",    name: "Canadian Dollar"),
        CurrencyOption(code: "MXN", symbol: "$",      name: "Mexican Peso"),

        // 🌍 Europe (major + central/east)
        CurrencyOption(code: "EUR", symbol: "€",      name: "Euro"),
        CurrencyOption(code: "GBP", symbol: "£",      name: "British Pound"),
        CurrencyOption(code: "CHF", symbol: "CHF",    name: "Swiss Franc"),
        CurrencyOption(code: "TRY", symbol: "₺",      name: "Turkish Lira"),
        CurrencyOption(code: "PLN", symbol: "zł",     name: "Polish Złoty"),
        CurrencyOption(code: "CZK", symbol: "Kč",     name: "Czech Koruna"),
        CurrencyOption(code: "HUF", symbol: "Ft",     name: "Hungarian Forint"),
        CurrencyOption(code: "RON", symbol: "lei",    name: "Romanian Leu"),
        CurrencyOption(code: "SEK", symbol: "kr",     name: "Swedish Krona"),
        CurrencyOption(code: "NOK", symbol: "kr",     name: "Norwegian Krone"),
        CurrencyOption(code: "DKK", symbol: "kr",     name: "Danish Krone"),
        CurrencyOption(code: "RUB", symbol: "₽",      name: "Russian Ruble"),

        // 🌍 East / Southeast Asia
        CurrencyOption(code: "CNY", symbol: "¥",      name: "Chinese Yuan"),
        CurrencyOption(code: "JPY", symbol: "¥",      name: "Japanese Yen"),
        CurrencyOption(code: "KRW", symbol: "₩",      name: "South Korean Won"),
        CurrencyOption(code: "HKD", symbol: "HK$",    name: "Hong Kong Dollar"),
        CurrencyOption(code: "TWD", symbol: "NT$",    name: "New Taiwan Dollar"),
        CurrencyOption(code: "SGD", symbol: "S$",     name: "Singapore Dollar"),
        CurrencyOption(code: "THB", symbol: "฿",      name: "Thai Baht"),
        CurrencyOption(code: "MYR", symbol: "RM",     name: "Malaysian Ringgit"),
        CurrencyOption(code: "IDR", symbol: "Rp",     name: "Indonesian Rupiah"),
        CurrencyOption(code: "PHP", symbol: "₱",      name: "Philippine Peso"),
        CurrencyOption(code: "VND", symbol: "₫",      name: "Vietnamese Đồng"),

        // 🌍 Middle East / Israel
        CurrencyOption(code: "ILS", symbol: "₪",      name: "Israeli New Shekel"),

        // 🌍 Africa
        CurrencyOption(code: "ZAR", symbol: "R",      name: "South African Rand"),
        CurrencyOption(code: "EGP", symbol: "E£",     name: "Egyptian Pound"),
        CurrencyOption(code: "KES", symbol: "KSh",    name: "Kenyan Shilling"),
        CurrencyOption(code: "NGN", symbol: "₦",      name: "Nigerian Naira"),

        // 🌍 South America
        CurrencyOption(code: "BRL", symbol: "R$",     name: "Brazilian Real"),
        CurrencyOption(code: "ARS", symbol: "$",      name: "Argentine Peso"),
        CurrencyOption(code: "CLP", symbol: "$",      name: "Chilean Peso"),
        CurrencyOption(code: "COP", symbol: "$",      name: "Colombian Peso"),
        CurrencyOption(code: "PEN", symbol: "S/.",    name: "Peruvian Sol"),

        // 🌍 Oceania
        CurrencyOption(code: "AUD", symbol: "A$",     name: "Australian Dollar"),
        CurrencyOption(code: "NZD", symbol: "NZ$",    name: "New Zealand Dollar")
    ]
}


func parseAmount(_ raw: String, locale: Locale = .current) -> Decimal? {
    let decSep = locale.decimalSeparator ?? "."
    // Normalize: remove spaces (incl. non-breaking), remove commas, keep decimal sep
    var s = raw.replacingOccurrences(of: "\u{00A0}", with: "") // NBSP
    s = s.replacingOccurrences(of: " ", with: "")
         .replacingOccurrences(of: ",", with: "")
         .replacingOccurrences(of: "’", with: "") // some locales
    // If user used comma as decimal, normalize to current sep
    if decSep == "," { s = s.replacingOccurrences(of: ".", with: ",") }
    return Decimal(string: s)
}


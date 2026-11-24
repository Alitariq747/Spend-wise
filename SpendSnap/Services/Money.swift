//
//  Money.swift
//  SpendSnap
//
//  The one way an amount becomes display text. Foundation only, so the
//  widgets can share it and a scratch harness can compile it on its own.
//

import Foundation

enum Money {

    /// An amount as the user's locale writes money, with the app's own symbol
    /// for `code` (`Rs`, not `PKR`): grouping, decimal mark, numerals and the
    /// symbol's position all follow the locale. Whole amounts drop the
    /// decimals (`₨1,250`); others show at least two (`$12.50`, `₨0.50`,
    /// `¥1,250.50`), or three for three-decimal currencies (`KD 1.250`).
    static func format(_ amount: Decimal, code: String, locale: Locale = .current) -> String {
        let formatter = formatter(code: code, locale: locale, whole: isWhole(amount))
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    private static func isWhole(_ amount: Decimal) -> Bool {
        var value = amount
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return rounded == amount
    }

    private static var cache: [String: NumberFormatter] = [:]
    private static let lock = NSLock()

    /// Formatters are costly to build, so one is kept per currency, locale
    /// and whole/fractional. Each is configured once and never changed after,
    /// so a cached one is safe to use from any thread.
    private static func formatter(code: String, locale: Locale, whole: Bool) -> NumberFormatter {
        let key = "\(code)|\(locale.identifier)|\(whole)"
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[key] { return cached }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = CurrencyUtil.symbol(for: code)
        formatter.roundingMode = .halfUp
        // At least 2 decimals for a fractional amount, even for currencies
        // the system writes without (PKR, JPY): a typed 12.5 must not show
        // as 13. Three-decimal currencies (KWD) keep their 3.
        let digits = whole ? 0 : max(formatter.maximumFractionDigits, 2)
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        cache[key] = formatter
        return formatter
    }
}

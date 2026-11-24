//
//  AmountParser.swift
//  SpendSnap
//
//  The one way typed text becomes an amount, for every amount field.
//  Foundation only, so a scratch harness can compile it on its own.
//

import Foundation

enum AmountParser {

    /// Reads an amount the way the user wrote it, whatever their keyboard:
    /// `12.50`, `12,50`, `1,250.00`, `1.250,00`, `Rs 1,250`, Arabic-Indic and
    /// Persian digits. Returns `nil` when there is no number to read.
    ///
    /// Which mark is the decimal point:
    /// - both `.` and `,` present: the last one (`1.250,00`, `1,250.00`)
    /// - one mark, repeated: thousands separators (`1,250,000`)
    /// - one mark, once: the decimal point if it is the locale's own;
    ///   otherwise a thousands separator only when exactly three digits
    ///   follow it (`1,500` on a US phone), else the decimal point
    ///   (`12,50` on a US phone, `12.5` on a German one)
    static func parse(_ raw: String, locale: Locale = .current) -> Decimal? {
        let text = normalize(raw)
        guard text.contains(where: \.isNumber) else { return nil }
        let localeMark = normalize(locale.decimalSeparator ?? ".").first ?? "."

        let marks = text.filter { $0 == "." || $0 == "," }
        var decimalMark: Character?
        if marks.contains(".") && marks.contains(",") {
            decimalMark = marks.last
            guard marks.filter({ $0 == decimalMark }).count == 1 else { return nil }
        } else if marks.count == 1, let mark = marks.first, let i = text.firstIndex(of: mark) {
            let before = text[..<i].count
            let after = text[text.index(after: i)...].count
            let looksLikeThousands = after == 3 && (1...3).contains(before)
            decimalMark = (mark == localeMark || !looksLikeThousands) ? mark : nil
        }

        var posix = ""
        for ch in text {
            if ch.isNumber { posix.append(ch) } else if ch == decimalMark { posix.append(".") }
        }
        return Decimal(string: posix, locale: Locale(identifier: "en_US_POSIX"))
    }

    /// An amount as an edit field should show it: the locale's decimal mark
    /// and digits, no thousands separators, so `parse` reads it back exactly.
    /// Zero is `""`, an empty field.
    static func editString(_ amount: Decimal, locale: Locale = .current) -> String {
        guard amount != 0 else { return "" }
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 6
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    /// ASCII digits plus `.` and `,` only. Arabic-Indic and Persian digits
    /// become ASCII, the Arabic decimal mark becomes `.`, the Arabic comma
    /// becomes `,`. Thousands marks that can't be a decimal point (Arabic
    /// `٬`, apostrophes), spaces, symbols and letters are dropped.
    private static func normalize(_ s: String) -> String {
        var out = ""
        for scalar in s.unicodeScalars {
            switch scalar.value {
            case 0x30...0x39: out.unicodeScalars.append(scalar)
            case 0x660...0x669: out.unicodeScalars.append(Unicode.Scalar(scalar.value - 0x660 + 0x30)!)
            case 0x6F0...0x6F9: out.unicodeScalars.append(Unicode.Scalar(scalar.value - 0x6F0 + 0x30)!)
            case 0x2E, 0x66B: out.append(".")
            case 0x2C, 0x60C: out.append(",")
            default: break
            }
        }
        return out
    }
}

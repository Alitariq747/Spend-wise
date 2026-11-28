//
//  MoneyText.swift
//  SpendSnap
//

import SwiftUI

/// An amount on screen, formatted by `Money.format` for the user's locale.
///
/// `.inline` (the default) takes the surrounding font. `.title` and `.hero`
/// are the large D38 amounts: SF Pro Rounded, and the currency symbol at half
/// size in ink tertiary, wherever the locale puts it (`Rs12`, `12 €`).
struct MoneyText: View {
    enum Style { case inline, title, hero }

    let amount: Decimal
    let code: String
    let style: Style

    init(_ amount: Decimal, code: String, style: Style = .inline) {
        self.amount = amount
        self.code = code
        self.style = style
    }

    var body: some View {
        switch style {
        case .inline: Text(verbatim: Money.format(amount, code: code))
        case .title: LargeAmount(amount: amount, code: code, size: 28, relativeTo: .title)
        case .hero: LargeAmount(amount: amount, code: code, size: 60, relativeTo: .largeTitle)
        }
    }
}

private struct LargeAmount: View {
    let amount: Decimal
    let code: String
    @ScaledMetric private var size: CGFloat

    init(amount: Decimal, code: String, size: CGFloat, relativeTo style: Font.TextStyle) {
        self.amount = amount
        self.code = code
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
    }

    var body: some View {
        let text = Money.format(amount, code: code)
        let digits = Font.system(size: size, weight: .semibold, design: .rounded).monospacedDigit()
        let symbolFont = Font.system(size: size / 2, weight: .medium, design: .rounded)
        Group {
            if let range = text.range(of: CurrencyUtil.symbol(for: code)) {
                Text(verbatim: String(text[..<range.lowerBound])).font(digits)
                    + Text(verbatim: String(text[range])).font(symbolFont).foregroundStyle(Color.inkTertiary)
                    + Text(verbatim: String(text[range.upperBound...])).font(digits)
            } else {
                Text(verbatim: text).font(digits)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.4)
    }
}

import SwiftUI

// Design tokens for D38, "a quiet ledger". Values: MASTER_PLAN Appendix D.
// Colours live in Assets.xcassets/Tokens and are used through the generated
// symbols (`Color.canvas`, `.foregroundStyle(.inkSecondary)`…).

// MARK: - Shape

enum Radius {
    /// Fields, buttons, pills that aren't capsules, symbol tiles.
    static let control: CGFloat = 14
    /// Grouped lists, tiles, cards, sheets.
    static let surface: CGFloat = 22
}

extension Shape where Self == RoundedRectangle {
    static var controlRect: RoundedRectangle { RoundedRectangle(cornerRadius: Radius.control, style: .continuous) }
    static var surfaceRect: RoundedRectangle { RoundedRectangle(cornerRadius: Radius.surface, style: .continuous) }
}

// MARK: - Space

enum Space {
    // Steps of 4.
    static let s4: CGFloat = 4, s8: CGFloat = 8, s12: CGFloat = 12, s16: CGFloat = 16
    static let s20: CGFloat = 20, s24: CGFloat = 24, s32: CGFloat = 32, s40: CGFloat = 40
    /// Leading and trailing screen margin.
    static let margin: CGFloat = 20
    /// Smallest tappable size.
    static let touchTarget: CGFloat = 44
}

// MARK: - Shadow

private struct SurfaceShadow: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    // Dark mode separates surfaces with hairlines instead.
    func body(content: Content) -> some View {
        let on = scheme != .dark
        content
            .shadow(color: on ? Color.ink.opacity(0.04) : .clear, radius: 1, y: 1)
            .shadow(color: on ? Color.ink.opacity(0.05) : .clear, radius: 12, y: 8)
    }
}

extension View {
    /// The one shadow: light mode only.
    func surfaceShadow() -> some View { modifier(SurfaceShadow()) }
}

// MARK: - Type

extension Font {
    static let screenTitle = Font.largeTitle.weight(.semibold)
    static let statusSentence = Font.title2.weight(.medium)
    static let sectionHeader = Font.title3.weight(.semibold)
    /// Small labels, sentence case, never all caps.
    static let smallLabel = Font.footnote.weight(.semibold)

    /// An amount on a system text style: SF Pro Rounded, semibold, even-width digits.
    static func amount(_ style: Font.TextStyle) -> Font {
        .system(style, design: .rounded, weight: .semibold).monospacedDigit()
    }
}

/// An amount at a custom size (the ~60 pt hero) that still follows the user's text size.
private struct ScaledAmountFont: ViewModifier {
    @ScaledMetric private var size: CGFloat

    init(size: CGFloat, relativeTo style: Font.TextStyle) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: .semibold, design: .rounded).monospacedDigit())
    }
}

extension View {
    func amountFont(size: CGFloat, relativeTo style: Font.TextStyle = .largeTitle) -> some View {
        modifier(ScaledAmountFont(size: size, relativeTo: style))
    }
}

// MARK: - Category tones

/// A category tone's colours: `tint` behind the symbol, `ink` for the symbol.
/// The `CategoryTone` model enum (3.4a) maps onto these.
struct TonePair {
    let tint: Color
    let ink: Color

    static let sand = TonePair(tint: .toneSandTint, ink: .toneSandInk)
    static let sage = TonePair(tint: .toneSageTint, ink: .toneSageInk)
    static let cocoa = TonePair(tint: .toneCocoaTint, ink: .toneCocoaInk)
    static let mist = TonePair(tint: .toneMistTint, ink: .toneMistInk)
    static let lilac = TonePair(tint: .toneLilacTint, ink: .toneLilacInk)
    static let butter = TonePair(tint: .toneButterTint, ink: .toneButterInk)
    static let rose = TonePair(tint: .toneRoseTint, ink: .toneRoseInk)
    static let stone = TonePair(tint: .toneStoneTint, ink: .toneStoneInk)
}

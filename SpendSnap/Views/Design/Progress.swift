import SwiftUI

// MARK: - Status

/// How much of a budget is used. On track below 85%, close from 85% to
/// 100% (nothing left still counts as close), over above 100%.
enum BudgetStatus {
    case onTrack, close, over

    static let closeFrom = 0.85

    init(fraction: Double) {
        if fraction > 1 {
            self = .over
        } else if fraction >= Self.closeFrom {
            self = .close
        } else {
            self = .onTrack
        }
    }

    /// The bar or ring colour. On track has no colour of its own (D38).
    func fill(onTrack: Color) -> Color {
        switch self {
        case .onTrack: onTrack
        case .close: .amberFill
        case .over: .coralFill
        }
    }

    /// The spoken value, with words: the colour says nothing to VoiceOver.
    /// `nil` means the category has no budget.
    static func accessibilityValue(_ fraction: Double?) -> Text {
        guard let fraction, fraction.isFinite else { return Text("No budget") }
        let percent = FloatingPointFormatStyle<Double>.Percent().precision(.fractionLength(0))
        switch BudgetStatus(fraction: fraction) {
        case .onTrack: return Text(fraction, format: percent)
        case .close: return Text("\(fraction, format: percent), close to the limit")
        case .over: return Text("\(fraction, format: percent), over budget")
        }
    }
}

/// 0…1 for drawing; an over budget is drawn full.
private func drawn(_ fraction: Double) -> Double {
    fraction.isFinite ? min(max(fraction, 0), 1) : 0
}

/// A short spring with little bounce; under Reduce Motion the value just sets.
private func growth(_ reduceMotion: Bool) -> Animation? {
    reduceMotion ? nil : .spring(duration: 0.35, bounce: 0.1)
}

// MARK: - Bar

/// A budget bar with an optional even-pace mark. It fills from the leading
/// side, so from the right in Arabic. The screen gives the label
/// (`.accessibilityLabel`); the bar gives the value.
struct ProgressBar: View {
    enum Size {
        case hero, row
        var height: CGFloat { self == .hero ? 6 : 4 }
    }

    let fraction: Double
    /// Where an even pace would be today, 0…1.
    var pace: Double? = nil
    var size: Size = .hero
    /// Tracks inside a surface use the lighter inset hairline.
    var insideSurface = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let markHeight: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(insideSurface ? Color.hairlineInset : .hairline)
                    .frame(height: size.height)
                Capsule()
                    .fill(BudgetStatus(fraction: fraction).fill(onTrack: .ink))
                    .frame(width: width * drawn(fraction), height: size.height)
                if let pace {
                    Capsule()
                        .fill(Color.inkTertiary)
                        .frame(width: 2, height: markHeight)
                        .padding(.leading, min(max(width * drawn(pace) - 1, 0), width - 2))
                }
            }
            .frame(width: width, height: geo.size.height, alignment: .leading)
        }
        .frame(height: pace == nil ? size.height : markHeight)
        .animation(growth(reduceMotion), value: fraction)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(BudgetStatus.accessibilityValue(fraction))
    }
}

// MARK: - Ring

/// A budget ring around a category symbol: 56 across, stroke 4, around a
/// 40 circle in the tone's tint. It starts at the top and fills clockwise,
/// counter-clockwise in Arabic (the HIG flips progress controls); the symbol
/// is not flipped. A fixed size at every text size: the text beside it scales.
struct ProgressRing: View {
    /// `nil`: no budget, so only the track shows.
    let fraction: Double?
    let tone: TonePair
    let systemImage: String

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .inset(by: 3)
                .stroke(scheme == .dark ? Color.hairline : tone.tint, lineWidth: 4)
            if let fraction {
                // Kept at 0 (hidden, or the round cap draws a dot) so it can grow from there.
                Circle()
                    .inset(by: 3)
                    .trim(from: 0, to: drawn(fraction))
                    .stroke(BudgetStatus(fraction: fraction).fill(onTrack: tone.ink),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .flipsForRightToLeftLayoutDirection(true)
                    .opacity(drawn(fraction) > 0 ? 1 : 0)
            }
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(tone.ink)
                .frame(width: 40, height: 40)
                .background(tone.tint, in: Circle())
        }
        .frame(width: 56, height: 56)
        .animation(growth(reduceMotion), value: fraction)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(BudgetStatus.accessibilityValue(fraction))
    }
}

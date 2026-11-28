#if DEBUG
import SwiftUI

// Not shipped: a board of every D38 token, for checking against MASTER_PLAN Appendix D.
// Strings are verbatim so they stay out of the String Catalog.

private struct TokensBoard: View {
    private let colours: [(String, Color)] = [
        ("canvas", .canvas), ("surface", .surface), ("sunken", .sunken),
        ("hairline", .hairline), ("hairlineInset", .hairlineInset),
        ("ink", .ink), ("inkSecondary", .inkSecondary), ("inkTertiary", .inkTertiary),
        ("juniper", .juniper), ("amberText", .amberText), ("amberFill", .amberFill),
        ("coralText", .coralText), ("coralFill", .coralFill),
    ]
    private let tones: [(String, TonePair)] = [
        ("Sand", .sand), ("Sage", .sage), ("Cocoa", .cocoa), ("Mist", .mist),
        ("Lilac", .lilac), ("Butter", .butter), ("Rose", .rose), ("Stone", .stone),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s24) {
                Text(verbatim: "Tokens").font(.screenTitle)

                Text(verbatim: "Colours").font(.sectionHeader)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Space.s12)], spacing: Space.s12) {
                    ForEach(colours, id: \.0) { name, colour in
                        VStack(spacing: Space.s4) {
                            RoundedRectangle.controlRect.fill(colour).frame(height: 44)
                                .overlay(RoundedRectangle.controlRect.stroke(Color.hairline))
                            Text(verbatim: name).font(.caption2).foregroundStyle(.inkSecondary)
                        }
                    }
                }

                Text(verbatim: "Category tones").font(.sectionHeader)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: Space.s12)], spacing: Space.s12) {
                    ForEach(tones, id: \.0) { name, tone in
                        VStack(spacing: Space.s4) {
                            Image(systemName: "cart")
                                .font(.title3.weight(.medium)).foregroundStyle(tone.ink)
                                .frame(width: 58, height: 58).background(tone.tint, in: .controlRect)
                            Text(verbatim: name).font(.caption2).foregroundStyle(.inkSecondary)
                        }
                    }
                }

                Text(verbatim: "Type").font(.sectionHeader)
                VStack(alignment: .leading, spacing: Space.s8) {
                    Text(verbatim: "Rs800 left this month").font(.statusSentence)
                    Text(verbatim: "Section header").font(.sectionHeader)
                    Text(verbatim: "Small label").font(.smallLabel).foregroundStyle(.inkSecondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(verbatim: "Rs").amountFont(size: 30).foregroundStyle(.inkTertiary)
                        Text(verbatim: "12,450").amountFont(size: 60)
                    }
                    Text(verbatim: "Rs1,280").font(.amount(.title3))
                    HStack(spacing: Space.s12) {
                        Text(verbatim: "Paid").foregroundStyle(.juniper)
                        Text(verbatim: "Due in 2 days").foregroundStyle(.amberText)
                        Text(verbatim: "Rs400 over").foregroundStyle(.coralText)
                    }.font(.smallLabel)
                }

                Text(verbatim: "Shape and shadow").font(.sectionHeader)
                HStack(spacing: Space.s16) {
                    RoundedRectangle.controlRect.fill(Color.sunken).frame(width: 88, height: 56)
                        .overlay(Text(verbatim: "14").font(.smallLabel))
                    RoundedRectangle.surfaceRect.fill(Color.surface).frame(width: 140, height: 88)
                        .surfaceShadow()
                        .overlay(Text(verbatim: "22").font(.smallLabel))
                }
            }
            .foregroundStyle(.ink)
            .padding(.horizontal, Space.margin)
            .padding(.vertical, Space.s24)
        }
        .background(Color.canvas)
    }
}

#Preview("Light") { TokensBoard() }
#Preview("Dark") { TokensBoard().preferredColorScheme(.dark) }
#Preview("Light, largest text") { TokensBoard().dynamicTypeSize(.accessibility5) }
#Preview("Dark, largest text") { TokensBoard().preferredColorScheme(.dark).dynamicTypeSize(.accessibility5) }
#endif

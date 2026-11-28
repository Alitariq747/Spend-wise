import SwiftUI

// MARK: - Surface

/// A white card on the canvas (graphite in dark mode): radius 22, the one
/// shadow in light mode, a hairline in dark mode.
private struct SurfaceStyle: ViewModifier {
    let padding: CGFloat
    @Environment(\.colorScheme) private var scheme

    // The shadow goes on the background shape only: on the whole view it
    // would also shadow every piece of text inside.
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: Radius.surface, style: .continuous)
                    .fill(Color.surface)
                    .strokeBorder(scheme == .dark ? Color.hairline : .clear, lineWidth: 1)
                    .surfaceShadow()
            }
    }
}

extension View {
    func surfaceStyle(padding: CGFloat = Space.s16) -> some View {
        modifier(SurfaceStyle(padding: padding))
    }
}

// MARK: - Section header

/// A section title in sentence case, never all caps. `.small` is the quiet
/// footnote label over a list; `.large` heads a whole block. An optional
/// action ("See all") sits on the trailing side in Juniper.
struct SectionHeader: View {
    enum Size { case small, large }

    let title: LocalizedStringKey
    var size: Size = .small
    var actionTitle: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.s8) {
            Text(title)
                .font(size == .large ? .sectionHeader : .smallLabel)
                .foregroundStyle(size == .large ? Color.ink : Color.inkSecondary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.juniper)
                    .buttonStyle(.pressable)
            }
        }
    }
}

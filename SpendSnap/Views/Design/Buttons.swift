import SwiftUI

// Buttons for D38. Everything pressable shrinks to 97% while held
// (Appendix D, motion); Reduce Motion swaps the shrink for a slight fade.

private struct PressEffect: ViewModifier {
    let isPressed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(isPressed && reduceMotion ? 0.7 : 1)
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.35, bounce: 0.15),
                       value: isPressed)
    }
}

/// Rows, cards and tiles: no chrome, just the press.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.modifier(PressEffect(isPressed: configuration.isPressed))
    }
}

/// A full-width filled button. `.primary` is the main action on a screen
/// (ink fill); `.secondary` is a quieter one beside or below it (sunken fill).
struct FilledButtonStyle: ButtonStyle {
    let fill: Color
    let text: Color
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(text)
            .padding(.horizontal, Space.s16)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(fill, in: .controlRect)
            .opacity(isEnabled ? 1 : 0.4)
            .modifier(PressEffect(isPressed: configuration.isPressed))
    }
}

extension ButtonStyle where Self == FilledButtonStyle {
    static var primary: FilledButtonStyle { .init(fill: .ink, text: .canvas) }
    static var secondary: FilledButtonStyle { .init(fill: .sunken, text: .ink) }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { .init() }
}

/// A round icon-only button. The title is required: VoiceOver speaks it, and
/// the large content viewer shows it, so no icon button goes unlabelled.
struct IconButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    init(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.ink)
                .frame(width: Space.touchTarget, height: Space.touchTarget)
                .background(Color.sunken, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.pressable)
        .accessibilityShowsLargeContentViewer()
    }
}

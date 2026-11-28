#if DEBUG
import SwiftUI

// Not shipped: a board of the 3.2 components. Strings go through `key(_:)`
// or `verbatim:` so they stay out of the String Catalog.

private func key(_ s: String) -> LocalizedStringKey { LocalizedStringKey(s) }

struct ComponentsBoard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.s24) {
            SheetHeader(onClose: {})
            SheetHeader(key("Edit card"), onClose: {})
            SheetHeader(key("New expense"), onClose: {}) {
                Button { } label: { Text(verbatim: "Save").font(.headline) }
                    .foregroundStyle(Color.juniper)
                    .buttonStyle(.pressable)
            }

            HStack(spacing: Space.s12) {
                IconButton(key("Settings"), systemImage: "gearshape", action: {})
                IconButton(key("Add"), systemImage: "plus", action: {})
                IconButton(key("More"), systemImage: "ellipsis", action: {})
            }

            VStack(spacing: Space.s12) {
                Button { } label: { Text(verbatim: "Add expense") }.buttonStyle(.primary)
                Button { } label: { Text(verbatim: "Cancel") }.buttonStyle(.secondary)
                Button { } label: { Text(verbatim: "Add expense") }.buttonStyle(.primary).disabled(true)
            }

            Button { } label: {
                HStack {
                    Text(verbatim: "Pressable row")
                    Spacer()
                    Image(systemName: "chevron.forward").foregroundStyle(Color.inkTertiary)
                }
                .padding(Space.s16)
                .background(Color.sunken, in: .controlRect)
            }
            .buttonStyle(.pressable)

            // 3.2b
            SectionHeader(title: key("This month"), size: .large, actionTitle: key("See all"), action: {})
            VStack(alignment: .leading, spacing: Space.s12) {
                SectionHeader(title: key("Coming up"))
                ForEach(["Rent", "Internet"], id: \.self) { name in
                    HStack {
                        Text(verbatim: name)
                        Spacer()
                        MoneyText(12_500, code: "PKR").foregroundStyle(Color.inkSecondary)
                    }
                }
            }
            .surfaceStyle()

            VStack(alignment: .leading, spacing: Space.s8) {
                MoneyText(12_450, code: "PKR", style: .hero)
                MoneyText(1_280.5, code: "EUR", style: .hero)
                MoneyText(12_345_678, code: "PKR", style: .hero)
                MoneyText(8_000, code: "PKR", style: .title)
                MoneyText(42.5, code: "EUR", style: .title)
            }

            // 3.3a: hero bars on the canvas, row bars and rings inside a surface.
            VStack(spacing: Space.s16) {
                ProgressBar(fraction: 0, pace: 0)
                ProgressBar(fraction: 0.5, pace: 0.6)
                ProgressBar(fraction: 0.9, pace: 1)
                ProgressBar(fraction: 1)
                ProgressBar(fraction: 1.3, pace: 0.8)
            }
            VStack(spacing: Space.s16) {
                ProgressBar(fraction: 0.4, size: .row, insideSurface: true)
                ProgressBar(fraction: 0.95, size: .row, insideSurface: true)
                ProgressBar(fraction: 1.2, size: .row, insideSurface: true)
                HStack(spacing: Space.s12) {
                    ProgressRing(fraction: 0.73, tone: .sand, systemImage: "fork.knife")
                    ProgressRing(fraction: 0.97, tone: .sage, systemImage: "cart")
                    ProgressRing(fraction: 1.1, tone: .mist, systemImage: "fuelpump")
                    ProgressRing(fraction: nil, tone: .lilac, systemImage: "bag")
                }
                HStack(spacing: Space.s12) {
                    ProgressRing(fraction: 0, tone: .cocoa, systemImage: "cup.and.saucer")
                    ProgressRing(fraction: 0.25, tone: .rose, systemImage: "heart")
                    ProgressRing(fraction: 1, tone: .butter, systemImage: "bolt")
                    ProgressRing(fraction: 0.5, tone: .stone, systemImage: "tag")
                }
            }
            .surfaceStyle()
        }
        .foregroundStyle(Color.ink)
        .padding(.horizontal, Space.margin)
        .padding(.vertical, Space.s24)
        .background(Color.canvas)
    }
}

#Preview("Light") { ScrollView { ComponentsBoard() } }
#Preview("Dark") { ScrollView { ComponentsBoard() }.preferredColorScheme(.dark) }
#Preview("Largest text") { ScrollView { ComponentsBoard() }.dynamicTypeSize(.accessibility5) }
#Preview("Arabic") {
    ScrollView { ComponentsBoard() }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
#endif

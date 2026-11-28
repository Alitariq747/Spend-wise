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
#endif

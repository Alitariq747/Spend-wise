import SwiftUI

/// The top of a sheet: a labelled close button on the leading side, an
/// optional title in the middle, and an optional trailing action (Save…).
struct SheetHeader<Trailing: View>: View {
    let title: LocalizedStringKey?
    let onClose: () -> Void
    let trailing: Trailing

    init(_ title: LocalizedStringKey? = nil, onClose: @escaping () -> Void,
         @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.onClose = onClose
        self.trailing = trailing()
    }

    // The two sides share the leftover width equally, so the title stays
    // centred; it truncates rather than run into the trailing action.
    var body: some View {
        HStack(spacing: Space.s12) {
            IconButton("Close", systemImage: "xmark", action: onClose)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .layoutPriority(1)
                    .accessibilityAddTraits(.isHeader)
            }
            HStack(spacing: 0) { // a Spacer, so the side exists with no action too
                Spacer(minLength: 0)
                trailing.fixedSize()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minHeight: Space.touchTarget)
    }
}

extension SheetHeader where Trailing == EmptyView {
    init(_ title: LocalizedStringKey? = nil, onClose: @escaping () -> Void) {
        self.init(title, onClose: onClose) { EmptyView() }
    }
}

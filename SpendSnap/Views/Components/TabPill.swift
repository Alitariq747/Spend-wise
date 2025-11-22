//
//  TabPill.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 12/10/2025.
//

import SwiftUI

enum InsightsTab { case overview, trends }

struct TabPill: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let tab: InsightsTab
    @Binding var selection: InsightsTab

    init(_ title: String, _ tab: InsightsTab, selection: Binding<InsightsTab>) {
        self.title = title; self.tab = tab; self._selection = selection
    }

    var body: some View {
        Button {
            selection = tab
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selection == tab ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selection == tab ? Color.indigo : Color(.systemGray5))
                )
                .foregroundStyle(.black)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TabPill("Overview", .overview, selection: .constant(.overview))
}

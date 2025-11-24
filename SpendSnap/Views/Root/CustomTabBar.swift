//
//  CustomTabBar.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 24/11/2025.
//

import SwiftUI

enum MainTab: Hashable {
    case home, history, cards, insights, settings
}

struct CustomTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        VStack(spacing: 0) {
            // subtle top border
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)

            HStack {
                tabItem(.home,    systemName: "house.fill",                title: "Home")
                tabItem(.history, systemName: "clock.arrow.circlepath",    title: "History")
                tabItem(.cards,   systemName: "creditcard.fill",           title: "Cards")
                tabItem(.insights,systemName: "chart.bar.fill",            title: "Insights")
                tabItem(.settings,  systemName: "gearshape", title: "Settings")
            }
            .padding(.top, 18)   // ⬅️ controls vertical centering
            .padding(.horizontal, 20)
            .background(Color(.systemGray6).opacity(0.4))
        }
    }

    @ViewBuilder
    private func tabItem(_ tab: MainTab,
                         systemName: String,
                         title: String) -> some View {
        let isSelected = (selection == tab)

        Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
            .foregroundStyle(isSelected ? Color.indigo : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    CustomTabBar(selection: .constant(.home))
}

//
//  EmojiPickerSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 17/11/2025.
//

import SwiftUI


struct EmojiPickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    private struct EmojiGroup: Identifiable {
        let id = UUID()
        let title: String
        let emojis: [String]
    }

    private let groups: [EmojiGroup] = [
        .init(title: "Groceries & Food", emojis: ["🍎","🥑","🥦","🍞","🍕","🍔","🌮","🥗","🍜","🍣","☕️","🍺"]),
        .init(title: "Bills & Utilities", emojis: ["💡","💧","🔥","📶","🧾","🏠","🔌","🛏️","🛁"]),
        .init(title: "Transport & Fuel", emojis: ["🚗","⛽️","🚌","🚕","🚆","✈️","🚲","🛵"]),
        .init(title: "Shopping & Retail", emojis: ["🛍️","🛒","👕","👗","👟","👜","🎒"]),
        .init(title: "Health & Fitness", emojis: ["💊","🏥","🏃‍♂️","🧘‍♀️","🚴‍♂️","🩺"]),
        .init(title: "Subscriptions & Media", emojis: ["📺","🎧","📱","💻","🎮","🎬"]),
        .init(title: "Income & Savings", emojis: ["💰","💵","💳","🏦","📈","🪙"]),
        .init(title: "Travel & Leisure", emojis: ["🧳","🏖️","🏨","🗺️","🏔️","🎡"]),
        .init(title: "Gifts & Events", emojis: ["🎁","🎂","🎉","🥳","💐"]),
        .init(title: "Kids & Pets", emojis: ["👶","🍼","🧸","🐾","🐶","🐱"]),
        .init(title: "Education & Work", emojis: ["📚","📝","💼","🗂️"]),
        .init(title: "Charity & Giving", emojis: ["🤝","❤️"]),
        .init(title: "General & Other", emojis: ["✨","📌","🔖","🧠"])
    ]

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pick a category emoji")
                        .font(.headline)
                    Text("Choose one that best matches this category.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .font(.subheadline.weight(.semibold))
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(group.emojis, id: \.self) { e in
                                    Button {
                                        selection = e
                                        dismiss()
                                    } label: {
                                        Text(e)
                                            .font(.system(size: 26))
                                            .frame(width: 52, height: 52)
                                            .background(
                                                Circle()
                                                    .fill(e == selection ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(e == selection ? Color.accentColor : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}


#Preview {
    EmojiPickerSheet(selection: .constant("🚗"))
}

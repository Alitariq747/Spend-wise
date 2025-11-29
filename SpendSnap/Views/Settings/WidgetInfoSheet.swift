//
//  WidgetInfoSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/11/2025.
//

import SwiftUI

struct WidgetInfoSheet: View {

    @Environment(\.dismiss) private var dismiss

    private struct WidgetPreview: Identifiable {
        let id = UUID()
        let name: String
        let subtitle: String
        let sizeLabel: String
        let colors: [Color]
        let emoji: String
    }

    private let previews: [WidgetPreview] = [
        .init(
            name: "Weekly Spending",
            subtitle: "Track weekly budget / spent",
            sizeLabel: "Small",
            colors: [Color(hex: 0x0B1020), Color(hex: 0x121A30)],
            emoji: "📅"
        ),
        .init(
            name: "Monthly Overview",
            subtitle: "Monthly overview",
            sizeLabel: "Medium",
            colors: [Color(hex: 0x4D6BFF), Color(hex: 0x2F47C2)],
            emoji: "📊"
        ),
        .init(
            name: "Credit Cards",
            subtitle: "Next dues, spend, limits",
            sizeLabel: "Large",
            colors: [Color(hex: 0x5B45C6), Color(hex: 0x0E1A3A)],
            emoji: "💳"
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    previewCarousel
                    steps
                    tips
                }
                .padding()
            }
            .navigationTitle("Widgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle")
                              .font(.system(size: 16, weight: .semibold))
                              .foregroundStyle(.black)
                    }

                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stay on track at a glance")
                .font(.title2).bold()
            Text("Add SpendSnap widgets to quickly see budgets, weekly spend, and card due dates.")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }

    private var previewCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(previews) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(item.emoji).font(.title3)
                            Spacer()
                            Text(item.sizeLabel)
                                .font(.caption).bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding()
                    .frame(width: 220, height: 150)
                    .background(
                        LinearGradient(colors: item.colors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8, y: 4)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var steps: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to add").font(.headline)
            ForEach(Array(["Touch & hold on Home/Lock Screen", "Tap +, search “SpendSnap”", "Pick a size, tap Add Widget"].enumerated()), id: \.offset) { idx, text in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(idx + 1).").bold()
                    Text(text)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }

    private var tips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tips").font(.headline)
            Text("Widgets auto-refresh, but you can tap a card to refresh inside the app after changes.")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
    
}

#Preview {
    WidgetInfoSheet()
}

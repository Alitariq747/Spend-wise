//
//  AddCategoryPromptSheet.swift
//  SpendSnap
//
//  Created by Codex on 11/02/2026.
//

import SwiftUI

struct AddCategoryPromptSheet: View {
    let onAddCategory: () -> Void
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var cardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.black.opacity(0.04), Color.black.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var primaryButtonBackground: Color {
        colorScheme == .dark ? .white : .black
    }

    private var primaryButtonForeground: Color {
        colorScheme == .dark ? .black : .white
    }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(cardBackground)
                    .frame(width: 86, height: 86)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }

            VStack(spacing: 8) {
                Text("Add a category first")
                    .font(.system(size: 20, weight: .semibold))

                Text("Expenses must belong to a category so your totals and insights stay organized.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button {
                    onDismiss()
                } label: {
                    Text("Not now")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.1), lineWidth: 1))

                Button {
                    onAddCategory()
                } label: {
                    Text("Add Category")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryButtonForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .background(primaryButtonBackground, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(primaryButtonBackground, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    AddCategoryPromptSheet(onAddCategory: {}, onDismiss: {})
}

//
//  DayPickerRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 03/11/2025.
//

import SwiftUI

struct DayPickerRow: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let days: [Int]
    let systemImage: String
    
    @Binding var selection: Int?
    
    var body: some View {
            Menu {
                ForEach(days, id: \.self) { day in
                    Button {
                        selection = day
                    } label: {
                        HStack {
                            Text("\(day)")
                            if day == selection { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.primary)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)

                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 0)

                    Text(selection.map(String.init) ?? "Select")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.down")        // 👈 trailing chevron
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator).opacity(0.25), lineWidth: 0.5)
                )
                .contentShape(Rectangle()) // full-row hit area (nice on iPad)
            }
            .buttonStyle(.plain) // avoid blue tinting
        }}

#Preview {
    DayPickerRow(title: "Due Day", days: Array(1...31), systemImage: "star.fill", selection: .constant(5))
}

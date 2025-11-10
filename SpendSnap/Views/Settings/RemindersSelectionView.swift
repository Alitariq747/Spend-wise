//
//  RemindersSelectionView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/10/2025.
//

import SwiftUI

struct RemindersSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedReminderLevel: ReminderLevel
    let onReminderLevelSelected: (ReminderLevel) -> Void
    
    var body: some View {
        VStack {
            HStack {
                
                Spacer()
                Button {
                    dismiss()
                } label: {
                  Image(systemName: "x.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.black)
                }

            }
            .padding(.vertical)
            Text("Never over-spend!")
                .font(.system(size: 24, weight: .semibold))
            Text("Pick how chatty your expense coach should be — stay quiet, get gentle nudges, or let us really keep you on track.")
                .font(.system(size: 11, weight: .light))
                .multilineTextAlignment(.center)
                .padding(.vertical, 0.1)
                .foregroundStyle(.black.opacity(0.8))
            
            ForEach(ReminderLevel.allCases) { level in
                HStack {
                    Text(level.emoji)
                        .font(.system(size: 24, weight: .semibold))
                        .padding(12)
                        .background(selectedReminderLevel == level ? Color.light.opacity(0.3) : Color.gray.opacity(0.2), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.title)
                            .font(.system(size: 15, weight: .medium))
                        Text(level.description)
                            .font(.system(size: 11, weight: .light))
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedReminderLevel == level ? Color.light : Color.gray.opacity(0.09), lineWidth: selectedReminderLevel == level ? 2 : 1))
                .contentShape(Rectangle())
                .onTapGesture {
                    onReminderLevelSelected(level)
                    dismiss()
                }
            }
        }
        .padding()
    }
}

#Preview {
    RemindersSelectionView(selectedReminderLevel: .quiet, onReminderLevelSelected: {_ in print("Hello")})
}

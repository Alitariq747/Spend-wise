//
//  Reminders.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/10/2025.
//

import SwiftUI

struct Reminders: View {
    let level: ReminderLevel
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundStyle(Color.blue.opacity(0.9))
                .font(.system(size: 18, weight: .semibold))
            Text("Gentle Reminders")
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            Text(level.emoji)
                .font(.system(size: 14))
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.top, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    Reminders(level: .quiet, onTap: {print("reminders tapped")})
}

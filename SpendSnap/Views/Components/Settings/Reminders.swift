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
            
            Text("Gentle Reminders")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Text(level.emoji)
                .font(.system(size: 14))
           
        }
        .padding(.horizontal)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    Reminders(level: .quiet, onTap: {print("reminders tapped")})
}

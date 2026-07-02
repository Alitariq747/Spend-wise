//
//  RateUsRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/11/2025.
//

import SwiftUI

struct RateUsRow: View {
    
    let onTap: () -> Void
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text("Rate us 🖤")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .light))
            }
            .padding(.horizontal)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RateUsRow(onTap: { print("tapped")})
}

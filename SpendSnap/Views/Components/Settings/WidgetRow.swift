//
//  WidgetRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/11/2025.
//

import SwiftUI

struct WidgetRow: View {
    let onTap: () -> Void
    var body: some View {
        HStack {
           
            Text("Widgets")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .light))
         
        }
        .padding(.horizontal)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))    }
}

#Preview {
    WidgetRow(onTap: {print("Tapped")})
}

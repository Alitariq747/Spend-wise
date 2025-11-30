//
//  ContactUsRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/11/2025.
//

import SwiftUI

struct ContactUsRow: View {
    
    let onTap: () -> Void
    
    var body: some View {
        HStack {
           
            Text("Contact Us")
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
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

    }
}

#Preview {
    ContactUsRow(onTap: { print("Tapped")})
}

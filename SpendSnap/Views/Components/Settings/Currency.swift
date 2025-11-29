//
//  Currency.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/10/2025.
//

import SwiftUI

struct Currency: View {
    let symbol: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
           
            Text("Currency")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Text("\(symbol)")
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
    Currency(symbol: "$", onTap: { print("Tapped") })
}

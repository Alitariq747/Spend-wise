//
//  UpgradeToPro.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 28/10/2025.
//

import SwiftUI

struct UpgradeToPro: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow.opacity(0.7))
                    .font(.system(size: 18, weight: .semibold))
                Text("Pro Unlocked")
                    .font(.system(size: 18, weight: .semibold))
            }
           Text("Enjoy all the benefits of your pro subscription")
                .font(.system(size: 12, weight: .light))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.1), lineWidth: 1))
        
    }
}

#Preview {
    UpgradeToPro()
}

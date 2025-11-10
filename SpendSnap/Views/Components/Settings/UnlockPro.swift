//
//  UnlockPro.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 28/10/2025.
//

import SwiftUI

struct UnlockPro: View {
    
    let onTap: () -> Void

    var body: some View {
        
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "arrow.up.square.fill")
                    .foregroundStyle(.green.opacity(0.7))
                    .font(.system(size: 18, weight: .semibold))
                Text("Go PRO")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.darker)
            }
           Text("You are missing out on some amazing features!")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.darker)
            
            Button(action: {
               onTap()
            }, label: {
                Text("Upgrade")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.dark, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.dark, lineWidth: 1))
            })
        }
      
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.1), lineWidth: 1))
        .contentShape(Rectangle())
        
    }
}

//#Preview {
//    UnlockPro()
//}

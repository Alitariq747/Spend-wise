//
//  NoCardView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 02/11/2025.
//

import SwiftUI

struct NoCardView: View {
    var body: some View {
        VStack(spacing: 8) {
            // Image
            Image(.blueCard)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .clipped()
                .shadow(radius: 6)
                .padding(.bottom, -58)
            // No Cards yet
            Text("No Cards Yet")
                .font(.system(size: 20, weight: .semibold))
            
            // Description
            Text("Add your credit cards here to track cycles, stay under your limit, and never miss a payment.")
                .font(.system(size: 12, weight: .light))
                .multilineTextAlignment(.center)
                .padding(.top, 1)
                .padding(.horizontal)
        }
    }
}

#Preview {
    NoCardView()
}

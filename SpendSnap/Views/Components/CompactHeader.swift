//
//  CompactHeader.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 09/10/2025.
//

import SwiftUI

struct CompactHeader: View {
 
    var body: some View {
        VStack {
            Text("No expenses for this month...")
                .font(.subheadline.weight(.semibold))
     
            Text("Consider Adding Some 👆🏻")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
    }
}


#Preview {
    CompactHeader()
}

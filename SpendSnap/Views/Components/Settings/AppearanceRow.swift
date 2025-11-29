//
//  AppearanceRow.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 24/11/2025.
//

import SwiftUI

struct AppearanceRow: View {
    @Environment(\.modelContext) private var ctx
    
    let settings: Settings?
    
    private var currentAppearance: AppAppearance {
        settings?.appearance ?? .system
    }
    
    var body: some View {
        HStack(spacing: 12) {
                Text("Appearance")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Menu {
                    ForEach(AppAppearance.allCases, id: \.self) { option in
                        Button {
                            if let s = settings {
                                s.appearance = option
                                try? ctx.save()
                            }
                        } label: {
                            HStack {
                                Text(option.label)
                                if option == currentAppearance {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
            
                        Text(currentAppearance.label)
                            .font(.system(size: 14, weight: .light))
                       
                    
                  
                }
                .buttonStyle(.plain)
            }
        .padding(.horizontal)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

    }
}



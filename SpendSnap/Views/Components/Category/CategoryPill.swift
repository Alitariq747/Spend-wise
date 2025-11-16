//
//  CategoryPill.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import SwiftUI

struct CategoryPill: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let category: CategoryEntity
    let selected: Bool
    
    var bgColor: Color { selected ? category.color.opacity(0.12) : Color(.white)}
    var borderColor: Color {selected ? category.color : Color(.systemGray4)}
    
    private static let pillWidth: CGFloat = 96
    private static let iconSize: CGFloat = 34
    
    var body: some View {
        HStack(spacing: 20) {
            Text(category.emoji)
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(colorScheme == .dark ? category.color.opacity(0.8) : category.color.opacity(0.7), in: Circle())
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(category.color)
                    .font(.system(size: 20, weight: .medium))
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(.systemGray4))
            }
          
            
              
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
       
    }
}

#Preview {
    CategoryPill(category: previewCategories.first ?? CategoryEntity(name: "Food", emoji: "😀", monthlyBudget: .zero), selected: false)
}

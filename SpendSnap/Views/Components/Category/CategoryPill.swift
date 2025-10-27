//
//  CategoryPill.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import SwiftUI

struct CategoryPill: View {
    
    let category: Category
    let selected: Bool
    
    var bgColor: Color { selected ? category.color.opacity(0.12) : Color(.white)}
    var borderColor: Color {selected ? category.color : Color(.systemGray4)}
    
    private static let pillWidth: CGFloat = 96
    private static let iconSize: CGFloat = 34
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: category.icon)
                .font(.system(size: Self.iconSize * 0.55, weight: .semibold))
                .frame(width: Self.iconSize, height: Self.iconSize)
                .foregroundColor(category.color)
                .background(bgColor, in: RoundedRectangle(cornerRadius: 12))
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .frame(width: Self.pillWidth - 16)
            
        }
        .padding(.vertical, 12)
   
        .frame(width: Self.pillWidth)
        .background(bgColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(borderColor, lineWidth: selected ? 2 : 1))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: selected)
    }
}

#Preview {
    CategoryPill(category: Category.food, selected: true)
}

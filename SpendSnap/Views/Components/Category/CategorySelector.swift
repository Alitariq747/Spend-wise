//
//  CategorySelector.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import SwiftUI

struct CategorySelector: View {
    @Binding var selected: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Category.allCases) { cat in
                    Button{
                        selected = cat
                    } label: {
                        CategoryPill(category: cat, selected: selected == cat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}



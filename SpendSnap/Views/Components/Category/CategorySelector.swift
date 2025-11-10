//
//  CategorySelector.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import SwiftUI
import SwiftData

struct CategorySelector: View {
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    @Binding var selected: CategoryEntity?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { cat in
                    Button{
                        selected = cat
                    } label: {
                        CategoryPill(category: cat, selected: selected?.persistentModelID == cat.persistentModelID)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}



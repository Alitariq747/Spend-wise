//
//  CategorySelector.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 08/10/2025.
//

import SwiftUI
import SwiftData

struct CategorySelector: View {
    let categories: [CategoryEntity]
    @Binding var selected: CategoryEntity?
    
    var body: some View {

            VStack(spacing: 4) {
                ForEach(categories) { cat in
                    Button{
                        selected = cat
                    } label: {
                        CategoryPill(category: cat, selected: selected?.persistentModelID == cat.persistentModelID)
                    }
                    .buttonStyle(.plain)
                }
            }
         
    }
}


#Preview {
    CategorySelector(categories: previewCategories, selected: .constant(previewCategories[0]))
}

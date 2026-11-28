//
//  CategoryEditSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 18/11/2025.
//

import SwiftUI
import SwiftData


struct CategoryEditSheet: View {
    
    let category: CategoryEntity
  
    let onSaved: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: Settings.oldestFirst) private var settingsRows: [Settings]
    
    private var currency: String {
        settingsRows.first?.currencyCode ?? Settings.defaultCurrencyCode
    }
    @State private var emoji: String
    @State private var showEmojiPicker = false
    @State private var categoryName: String
    @State private var categoryBudget: String
    
   
    @State private var selectedColorHex: String = "#6366F1"
    private let colorOptions: [String] = [
        "#EF4444","#F97316","#F59E0B","#84CC16","#22C55E",
        "#10B981","#14B8A6","#06B6D4","#0EA5E9","#3B82F6",
        "#6366F1","#8B5CF6","#A855F7","#D946EF","#EC4899",
        "#F43F5E","#9CA3AF","#6B7280","#2DD4BF","#FDE047"
    ]
    private let colorColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    @State private var budgetScope: BudgetScope
    @State private var showDeleteConfirm: Bool = false
    
    let activeMonth: Date
    
    private var activeMonthKey: String {MonthUtil.monthKey(activeMonth)}
    
    init(category: CategoryEntity,
         activeMonth: Date,
         onSaved: (() -> Void)? = nil) {
        self.category = category
        self.activeMonth = activeMonth
        self.onSaved = onSaved

        // 1) basic fields straight from category
        _emoji = State(initialValue: category.emoji)
        _categoryName = State(initialValue: category.name)
        _selectedColorHex = State(initialValue: category.colorHex)

        // 2) figure out month-specific vs default budget
        let key = MonthUtil.monthKey(activeMonth)
        if let override = category.monthlyBudgets?.first(where: { $0.monthKey == key }) {
            // this month has its own override
            _categoryBudget = State(initialValue: AmountParser.editString(override.amount))
            _budgetScope = State(initialValue: .thisMonth)
        } else {
            // fall back to default monthlyBudget
            _categoryBudget = State(initialValue: AmountParser.editString(category.monthlyBudget))
            _budgetScope = State(initialValue: .everyMonth)
        }
    }


    var body: some View {
        let symbol = CurrencyUtil.symbol(for: currency)
        ScrollView {
            LazyVStack(spacing: 18) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(.systemGray))
                            .padding(8)
                            .background(Color(.secondarySystemBackground), in: Circle())
                    }
                    .accessibilityLabel("Close")
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if canSave {
                            Button {
                                saveCategory()
                            } label: {
                                Text("Edit")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.indigo)
                            }
                        } else {
                            EmptyView()
                        }
                        Button {
                          showDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12, weight:.semibold))
                                .foregroundStyle(Color(.systemGray))
                                .padding(6)
                                .background(Color(.secondarySystemBackground), in: Circle())
                        }
                        .accessibilityLabel("Delete category")
                        .buttonStyle(.plain)
                    }
                }
                ZStack {
                    Text(emoji)
                        .font(.system(size: 44, weight: .bold))
                        .padding(24)
                        .background(Color(hex: selectedColorHex).opacity(0.9), in: Circle())
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showEmojiPicker = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(.systemGray))
                            .padding(8)
                            .background(Color(.systemGray6), in: Circle())
                    }
                    .accessibilityLabel("Choose emoji")
                    .offset(x: 4, y: 13)
                    .buttonStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category name")
                        .font(.system(size: 16, weight: .regular))
                    TextField("Category name", text: $categoryName)
                        .font(.subheadline)
                        .keyboardType(.default)
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget (optional)")
                        .font(.system(size: 16, weight: .regular))
                    HStack {
                        Text(verbatim: symbol)
                            .font(.subheadline)
                        TextField("200", text: $categoryBudget)
                            .font(.subheadline)
                            .keyboardType(.decimalPad)
                           
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Applies")
                        .font(.system(size: 16, weight: .regular))
                    HStack {
                        Button {
                            budgetScope = .thisMonth
                        } label: {
                            Text("This month")
                                .font(budgetScope == .thisMonth ? .headline : .subheadline)
                                .foregroundStyle(budgetScope == .thisMonth ? Color.indigo : Color(.systemGray2))
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                      
                        Button {
                            budgetScope = .everyMonth
                        } label: {
                            Text("All months")
                                .font(budgetScope == .everyMonth ? .headline : .subheadline)
                                .foregroundStyle(budgetScope == .everyMonth ? Color.indigo : Color(.systemGray2))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        
                    }
                   
                   
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                
                VStack(alignment: .leading, spacing: 8) {
                Text("Pick a color")
                    .font(.system(size: 16, weight: .regular))
                LazyVGrid(columns: colorColumns, spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColorHex == hex ? Color(hex: selectedColorHex) : .clear, lineWidth: 2)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white)
                                            .opacity(selectedColorHex == hex ? 1 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Color \((colorOptions.firstIndex(of: hex) ?? 0) + 1)")
                            .accessibilityAddTraits(selectedColorHex == hex ? .isSelected : [])
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerSheet(selection: $emoji)
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showDeleteConfirm) {
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 4)
                    .foregroundColor(Color(.systemGray4))
                    .padding(.top, 8)

                Text("Delete this category?")
                    .font(.headline)

                Text("This will delete this category and all expenses assigned to it. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        showDeleteConfirm = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    Button("Delete") {
                        deleteCategory()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.hidden)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    /// The budget field's value: 0 when left empty (no budget), nil when it isn't a valid amount.
    private var enteredBudget: Decimal? {
        let text = categoryBudget.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return 0 }
        guard let amount = AmountParser.parse(text), amount >= 0 else { return nil }
        return amount
    }

    private var canSave: Bool {
        let hasName = !categoryName.trimmingCharacters(in: .whitespaces).isEmpty
        return enteredBudget != nil && hasName
    }
    
    private func saveCategory() {
        // An empty budget is 0: "no budget" every month, or for this month only.
        guard let newBudget = enteredBudget,
              !categoryName.trimmingCharacters(in: .whitespaces).isEmpty,
              categoryName.count <= 20 else {
            return
        }

     
        category.name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        category.emoji = emoji
        category.colorHex = selectedColorHex

        // 2) month-aware budget
        switch budgetScope {
        case .everyMonth:
            // behave like AddCategorySheet: this value becomes the default
            category.monthlyBudget = newBudget

            // for the active month, we want that same default,
            // so remove any specific override for this month if it exists
            if let override = category.monthlyBudgets?.first(where: { $0.monthKey == activeMonthKey }) {
                modelContext.delete(override)
            }

        case .thisMonth:
           
            if let override = category.monthlyBudgets?.first(where: { $0.monthKey == activeMonthKey }) {
                override.amount = newBudget
                override.updatedAt = Date()
            } else {
                let override = CategoryMonthlyBudget(
                    category: category,
                    monthKey: activeMonthKey,
                    amount: newBudget
                )
                modelContext.insert(override)
            }
        }

        try? modelContext.save()
        WidgetRefresh.reloadAll()
        onSaved?()
        dismiss()
    }

    private func deleteCategory() {
        let descriptor = FetchDescriptor<Expense>()
        if let expenses = try? modelContext.fetch(descriptor) {
            for exp in expenses {
                if exp.category === category {
                    modelContext.delete(exp)
                }
            }
        }
          
        
        modelContext.delete(category)
        try? modelContext.save()
        // Deleting a category deletes its expenses, so the month and week
        // totals move even though no expense screen was involved.
        WidgetRefresh.reloadAll()
        onSaved?()
        dismiss()
    }

}

#Preview {
    CategoryEditSheet(category: previewCategories[0], activeMonth: .now)
}

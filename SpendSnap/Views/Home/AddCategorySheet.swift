//
//  AddCategorySheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 17/11/2025.
//

import SwiftUI
import SwiftData

struct AddCategorySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var settingsRows: [Settings]
    
    private var currency: String {
        settingsRows.first?.currencyCode ?? "USD"
    }
    @State private var emoji: String = "🍎"
    @State private var showEmojiPicker = false
    @State private var categoryName: String = ""
    @State private var categoryBudget: String = ""
    
   
    @State private var selectedColorHex: String = "#6366F1"
    private let colorOptions: [String] = [
        "#EF4444","#F97316","#F59E0B","#84CC16","#22C55E",
        "#10B981","#14B8A6","#06B6D4","#0EA5E9","#3B82F6",
        "#6366F1","#8B5CF6","#A855F7","#D946EF","#EC4899",
        "#F43F5E","#9CA3AF","#6B7280","#2DD4BF","#FDE047"
    ]
    private let colorColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    @State private var budgetScope: BudgetScope = .thisMonth
    let activeMonth: Date
    
    private var activeMonthKey: String {MonthUtil.monthKey(activeMonth)}
    
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
                    Spacer()
                    
                    if canSave {
                        Button {
                            saveCat()
                        } label: {
                            Text("Create")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.indigo)
                        }
                    } else {
                        EmptyView()
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
                    .offset(x: 4, y: 13)
                    .buttonStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category name")
                        .font(.system(size: 16, weight: .regular))
                    TextField("Category name", text: $categoryName)
                        .font(.subheadline)
                        .keyboardType(.alphabet)
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Allocated Budget")
                        .font(.system(size: 16, weight: .regular))
                    HStack {
                        Text("\(symbol)")
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
        .scrollDismissesKeyboard(.automatic)
    }
    
    private var canSave: Bool {
        let isAmountOk = Decimal(string: categoryBudget) != nil && !categoryBudget.isEmpty
        let hasName = !categoryName.trimmingCharacters(in: .whitespaces).isEmpty
        return isAmountOk && hasName
    }
    
    private func saveCat() {
        guard let budget = Decimal(string: categoryBudget), budget > 0, !categoryName.trimmingCharacters(in: .whitespaces).isEmpty, categoryName.count <= 20 else {
            return
        }
        let category = CategoryEntity(name: categoryName, emoji: emoji, monthlyBudget: budgetScope == .everyMonth ? budget : .zero, colorHex: selectedColorHex)
        modelContext.insert(category)
        
        if budgetScope == .thisMonth {
            let override = CategoryMonthlyBudget(category: category, monthKey: activeMonthKey, amount: budget)
            modelContext.insert(override)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddCategorySheet(activeMonth: .now)
}

//
//  ExpenseDetailSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 15/11/2025.
//

import SwiftUI
import SwiftData

struct ExpenseDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRow: [Settings]
    @Query(sort: \CreditCard.name) private var cards: [CreditCard]
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expense: Expense
    var onDeleteExpense: (() -> Void)?
 
    
    @State private var amountText: String
    @State private var merchant: String
    @State private var date: Date
    @State private var allowedRange: ClosedRange<Date>
    @State private var showCalendar: Bool = false
    @State private var method: PaymentMethod
    @State private var selectedCard: CreditCard?
    @State private var selectedCategory: CategoryEntity?
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showDeleteConfirm = false
    
    init(expense: Expense, onDeleteExpense: (() -> Void)? = nil) {
        self.expense = expense
        self.onDeleteExpense = onDeleteExpense
     
        _amountText = State(initialValue: Self.string(from: expense.amount))
        _merchant = State(initialValue: expense.merchant)
        let initialDate = expense.date
        _date = State(initialValue: initialDate)
        _allowedRange = State(initialValue: monthRange(for: initialDate))
        _method = State(initialValue: expense.method)
        _selectedCard = State(initialValue: expense.card)
        _selectedCategory = State(initialValue: expense.category)
    }
    
    private var canSave: Bool {
        let hasAmount = Decimal(string: amountText) != nil && !amountText.isEmpty
        let hasMerchant = !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let methodOK = (method == .cash) || (method == .card && selectedCard != nil)
        let hasCategory = selectedCategory != nil
        return hasAmount && hasMerchant && methodOK && hasCategory
    }
    
    private static func string(from dec: Decimal) -> String {
    
        if dec == 0 { return "" }

        var value = dec
     
        return NSDecimalString(&value, Locale(identifier: "en_US_POSIX"))
    }
 
    private func confirmEdit() {
        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let amount = Decimal(string: amountText),
            amount > 0,
            !trimmedMerchant.isEmpty,
            trimmedMerchant.count <= 40,
            (method == .cash) || (selectedCard != nil)
        else { return }
        expense.amount = amount
        expense.merchant = trimmedMerchant
        expense.category = selectedCategory
        expense.method = method
        expense.card = (method == .card) ? selectedCard : nil
        
        try? modelContext.save()
  
        dismiss()
        
    }
    
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let labelW: CGFloat = 92
        
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("X")
                        .font(.system(size: 12, weight:.semibold))
                        .foregroundStyle(Color(.systemGray))
                        .padding(8)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
                .buttonStyle(.plain)
                Spacer()
                
                HStack(spacing: 8) {
                    if canSave {
                        Button {
                           confirmEdit()
                        } label: {
                            Text("Save")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.indigo)
                                .padding(.trailing, 4)
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
                    .buttonStyle(.plain)
                }

                
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Amount")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: labelW, alignment: .leading)
                    TextField("\(symbol) 0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding(.horizontal)
                Divider()
                
                HStack {
                                        Text("Merchant")
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: labelW, alignment: .leading)
                                        TextField("Walmart", text: $merchant)
                                            .keyboardType(.alphabet)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal)
                                    Divider()
                
                HStack {
                    Text("Date")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: labelW, alignment: .leading)
                    Button {
                        showCalendar = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                     
                     
                        .background(.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showCalendar) {
                        DatePicker(
                            "",
                            selection: $date,
                            in: allowedRange,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .presentationDetents([.medium])
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                
                // Method logic
                HStack {
                    
                Text("Method:")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: labelW, alignment: .leading)
                // HStack to choose b/w cash and card
                    HStack(spacing: 27) {
                    Button {
                        method = .cash
                        selectedCard = nil
                    } label: {
                        HStack {
                            Image(systemName: "banknote.fill")
                                .font(.body)
                                .foregroundStyle(method == .cash ? .primary : Color(.systemGray3))
                            Text("Cash")
                                .font(.body)
                                .foregroundStyle(method == .cash ? .primary : Color(.systemGray3))
                        }
                    
                        .padding(.vertical, 8)
                      
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if cards.isEmpty {
                            toastMessage = "No cards yet. Add one in cards tab"
                            withAnimation(.spring()) {showToast = true}
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.spring()) {showToast = false}
                            }
                            
                        } else {
                            method = .card
                        }
                    } label: {
                        HStack {
                            Image(systemName: "creditcard")
                                .font(.body)
                                .foregroundStyle(method == .card ? .primary : Color(.systemGray3))
                            Text("Card")
                                .font(.body)
                            .foregroundStyle(method == .card ? .primary : Color(.systemGray3))                                }
                    
                        .padding(.vertical, 8)
                    
                    }
                    .buttonStyle(.plain)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .padding(.horizontal)
                
                if method == .card {
                    HStack {
                        Label("Pay with", systemImage: "creditcard")
                        Spacer()
                        Menu {
                            ForEach(cards) { card in
                                Button {
                                    selectedCard = card
                                } label: {
                                    HStack {
                                        Text(card.name)
                                        if selectedCard?.persistentModelID == card.persistentModelID { Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedCard?.name ?? "Select card")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }

            }
            // Category ScrollView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text("CATEGORIES")
                        .tracking(2)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                    
                   CategorySelector(categories: categories, selected: $selectedCategory)
                }
            }
            .scrollDismissesKeyboard(.automatic)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            if showToast {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(toastMessage)
                        .font(.footnote)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: Capsule())
                .shadow(radius: 8)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .alert("Confirm Delete", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(expense)
                try? modelContext.save()
                onDeleteExpense?()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
            
        } message: {
            Text("This can not be undone.!")
        }
    }
}

#Preview {
    ExpenseDetailSheet(expense: previewExpenses[3])
}

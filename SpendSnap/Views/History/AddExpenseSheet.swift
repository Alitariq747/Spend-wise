//
//  AddExpenseSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddExpenseSheet: View {
    
    @Query(sort: \CategoryEntity.name) private var categories: [CategoryEntity]
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CreditCard.name) private var cards: [CreditCard]
    @State private var selectedCard: CreditCard? = nil
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    @State private var selectedCategory: CategoryEntity?
    @State private var amountText = ""
    @State private var merchant = ""
    @State private var date = Date()
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var method: PaymentMethod = .cash
    @State private var showCalendar = false
    
    @Binding var month: Date
    private let cal = Calendar.current
    
    private var monthInterval: DateInterval {
        if let interval = cal.dateInterval(of: .month, for: month) {
            return interval
        }
        let start = cal.startOfDay(for: month)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
        return DateInterval(start: start, end: end)
    }
    private var monthStart: Date { monthInterval.start }
    private var monthEnd: Date {
        let excl = monthInterval.end
        return cal.date(byAdding: .second, value: -1, to: excl) ?? excl
    }
    private var upperBound: Date { max(monthStart, min(Date(), monthEnd)) }
    private var allowedRange: ClosedRange<Date> { monthStart...upperBound }
    
    // Validations
    private var isDateOK: Bool { allowedRange.contains(date) }

    private var canSave: Bool {
        let hasAmount = Decimal(string: amountText) != nil && !amountText.isEmpty
        let hasMerchant = !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let methodOK = (method == .cash) || (method == .card && selectedCard != nil)
        let hasCategory = selectedCategory != nil
        return hasAmount && hasMerchant && isDateOK && methodOK && hasCategory
    }
    

    
    var body: some View {
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        let labelW: CGFloat = 92
                ScrollView {
                    
                    // Vstack parent
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // HStack for amount
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
                                .keyboardType(.default)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        Divider()
                        
                        // HStack for Date
                        
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
                             
                             
                                .background(.clear) // no gray background
                                .contentShape(Rectangle()) // easy tap
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
                                    .padding(.horizontal, 10).padding(.vertical, 8)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }
                        
                        // VStack with scrolling categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORIES")
                                .tracking(2)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                            
                           CategorySelector(categories: categories, selected: $selectedCategory)

                        }
                        .padding(.horizontal, 8)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("\(amountText)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            saveExpense()
                        }
                        .disabled(!canSave)
                    }
                }
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
     
    

     
    }
    private func saveExpense() {
        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let amt = Decimal(string: amountText),
            amt > 0,
            !trimmedMerchant.isEmpty,
            trimmedMerchant.count <= 40,
            (method == .cash) || (selectedCard != nil)
        else { return }
        
        let exp = Expense(amount: amt, date: date, merchant: trimmedMerchant, category: selectedCategory, method: method)
        if method == .card { exp.card = selectedCard }
        ctx.insert(exp)
        do {
            try ctx.save()
            WidgetCenter.shared.reloadTimelines(ofKind: "MonthOverviewWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "WeeklySpentWidget")
            dismiss()
        } catch {
            print("Error saving expense: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddExpenseSheet(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!))
}

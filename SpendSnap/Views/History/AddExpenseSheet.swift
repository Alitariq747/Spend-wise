//
//  AddExpenseSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct AddExpenseSheet: View {
    
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CreditCard.name) private var cards: [CreditCard]
    @State private var selectedCard: CreditCard? = nil
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    @State private var selectedCategory: Category? = .other
    @State private var amountText = ""
    @State private var merchant = ""
    @State private var date = Date()
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var method: PaymentMethod = .cash
    
    @Binding var month: Date
    private let cal = Calendar.current
    
    private var monthStart: Date { cal.dateInterval(of: .month, for: month)!.start }
    private var monthEnd: Date {
        let excl = cal.dateInterval(of: .month, for: month)!.end
        return cal.date(byAdding: .second, value: -1, to: excl)!
    }
    private var upperBound: Date { min(Date(), monthEnd) }
    private var allowedRange: ClosedRange<Date> { monthStart...upperBound }
    
    // Validations
    private var isDateOK: Bool { allowedRange.contains(date) }

    private var canSave: Bool {
        let hasAmount = Decimal(string: amountText) != nil && !amountText.isEmpty
        let hasMerchant = !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let methodOK = (method == .cash) || (method == .card && selectedCard != nil)
        return hasAmount && hasMerchant && isDateOK && methodOK
    }
    
    // Focus State
    enum Field: Hashable { case amount, merchant }
    @FocusState private var focused: Field?
    @State private var dateActive = false
    
    var body: some View {
        let symbol = CurrencyUtil.symbol(for: currencyCode)
       
        ZStack {
            Color(.gray).opacity(0.09)
                .ignoresSafeArea()
            GeometryReader { geo in
                
                
                ScrollView {
                    
                    // Vstack parent
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "plus.rectangle.on.rectangle.fill").resizable().scaledToFit().frame(width: 45, height: 45).foregroundColor(.darker.opacity(0.8))
                                Text("“Every expense, accounted.”")
                                    .font(.subheadline)
                                    .padding(.top, -10)
                                    .padding(.bottom, 10)
                                    .foregroundStyle(.darker)
                            }
                          
                            Spacer()
                        }
                        
                        
                        // Horizontal Scrolling list of categories
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Pick a category:")
                                .font(.subheadline)
                                .padding(.horizontal)
                                .foregroundStyle(.darker)
                            CategorySelector(selected: $selectedCategory)
                            
                        }
                        
                        // Add Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter amount:")
                                .font(.subheadline)
                                .foregroundStyle(.darker)
                            
                            TextField("\(symbol)", text: $amountText)
                                .keyboardType(.decimalPad)
                                .focused($focused, equals: .amount)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(focused == .amount ? Color.darker : Color.gray.opacity(0.2), lineWidth: focused == .amount ? 2 : 1))
                                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                        }
                        .padding(.horizontal)
                        
                        // Add merchant
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter merchant:")
                                .font(.subheadline)
                                .foregroundStyle(.darker)
                            
                            TextField("Walmart", text: $merchant)
                                .keyboardType(.alphabet)
                                .focused($focused, equals: .merchant)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke( focused == .merchant ? Color.darker : Color.gray.opacity(0.2), lineWidth: focused == .merchant ? 2 : 1))
                                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                                .onChange(of: merchant) {
                                    merchant = String(merchant.replacingOccurrences(of: "\n", with: " ").prefix(40))
                                }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pick date:")
                                .font(.subheadline)
                                .foregroundStyle(.darker)
                            
                            // Styled tappable row
                            HStack {
                                DatePicker("Date:", selection: $date, in: allowedRange, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(dateActive ? Color.darker : Color.gray.opacity(0.2),
                                            lineWidth: dateActive ? 2 : 1)
                            )
                            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    dateActive = true
                                    focused = nil
                                }
                            )
                            .onChange(of: focused) { if focused != nil { dateActive = false } }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        
                        
                        // Picker for method
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pick Method:")
                                .font(.subheadline)
                                .foregroundStyle(.darker)
                            // HStack to choose b/w cash and card
                            HStack {
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
                                        Text("Card")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.dark.opacity(method == .card ? 1 : 0.2), in: RoundedRectangle(cornerRadius: 14))
                                    .contentShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                                
                                Button {
                                    method = .cash
                                    selectedCard = nil
                                } label: {
                                    HStack {
                                        Image(systemName: "banknote.fill")
                                        Text("Cash")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.dark.opacity(method == .cash ? 1 : 0.2), in: RoundedRectangle(cornerRadius: 14))
                                    .contentShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
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
                                                if selectedCard?.id == card.id { Image(systemName: "checkmark") }
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

                        
                        // CTA Button to add expense
                        Button {
                            saveExpense()
                        } label: {
                            Text("Confirm")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canSave ? Color.darker : Color.darker.opacity(0.2), in:  RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal)
                        .disabled(!canSave)
                        .animation(.easeInOut(duration: 0.2), value: canSave)
                    }
                    .frame(minHeight: geo.size.height, alignment: .center)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Add Expense")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.visible, for: .navigationBar)
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
        
        let exp = Expense(amount: amt, date: date, merchant: trimmedMerchant, category: selectedCategory ?? .other, method: method)
        if method == .card { exp.card = selectedCard }
        ctx.insert(exp)
        do {
            try ctx.save()
            dismiss()
        } catch {
            print("Error saving expense: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddExpenseSheet(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!))
}

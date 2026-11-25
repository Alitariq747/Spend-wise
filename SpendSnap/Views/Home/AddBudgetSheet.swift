//
//  AddBudgetSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct AddBudgetSheet: View {

    /// Where a saved budget applies (D26).
    enum Scope: Hashable { case thisMonth, everyMonth }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: Settings.oldestFirst) private var settingsRows: [Settings]
    
    private var currency: String {
        settingsRows.first?.currencyCode ?? Settings.defaultCurrencyCode
    }
    
    @State private var amountText: String = ""
    @State private var scope: Scope = .everyMonth
    /// True when the month already has its own budget or an "every month" one is set.
    @State private var hasBudget = false
    
   
    @FocusState private var focused: Bool
   
    
    @Binding var month: Date
    var monthKey: String {
        MonthUtil.monthKey(month)
    }

    var onSave: (() -> Void)? = nil
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currency)
        
        VStack(alignment: .center, spacing: 16) {
            
            Image(systemName: "dollarsign.ring.dashed")
                .symbolRenderingMode(.monochrome)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 65, height: 65)
                .background(Circle().fill(colorScheme == .dark ? Color.blue.opacity(0.8) : Color.blue.opacity(0.7)))
                
                VStack(spacing: 6) {
                    Text(hasBudget ? "Update Budget" : "Enter Budget")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Text(hasBudget ? "Update your budget for \(MonthUtil.fmt.string(from: month))" : "Enter a budget for \(MonthUtil.fmt.string(from: month)) to start tracking.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.primary)
                }

                VStack(spacing: 6) {
                    Picker("Applies to", selection: $scope) {
                        Text("This month").tag(Scope.thisMonth)
                        Text("Every month").tag(Scope.everyMonth)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Text(scope == .thisMonth ? "Only for \(MonthUtil.fmt.string(from: month))." : "For every month that doesn't have its own budget.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text(verbatim: "\(symbol):")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundStyle(.dark)
                    
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16, weight: .semibold))
                        .focused($focused)
                        .foregroundStyle(.primary)
                      


                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)

                // HStack for two buttons
            
            amountText != "" ?
            VStack(spacing: 4) {
                Text("Target Budget")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.white)
                Text(verbatim: amountText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(colorScheme == .light ? Color(.blue.opacity(0.7)) : Color(.blue.opacity(0.8)), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .light ? Color(.blue.opacity(0.7)) : Color(.blue.opacity(0.8)), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .frame(maxWidth: .infinity) : nil
            
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal, 34)
                                .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        Button {
                          
                            DispatchQueue.main.async {
                                focused = false
                                saveBudget()
                            }
                        } label: {
                            Text("Save Budget")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 34)
                                .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colorScheme == .light ? Color(.blue.opacity(0.7)) : Color(.blue.opacity(0.8)), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(colorScheme == .light ? Color.blue.opacity(0.7) : Color.blue.opacity(0.8), lineWidth: 1))
                        
                    }
                    .frame(maxWidth: .infinity)
                 }
            .padding(.horizontal)
            .onAppear {
                   // Open on the month's own budget if it has one, else on "every month".
                   let everyMonth = settingsRows.first?.defaultMonthlyBudget ?? 0
                   if let own = ownRows().first {
                       scope = .thisMonth
                       amountText = AmountParser.editString(own.amount)
                   } else {
                       scope = .everyMonth
                       amountText = everyMonth > 0 ? AmountParser.editString(everyMonth) : ""
                   }
                   hasBudget = !amountText.isEmpty
                   DispatchQueue.main.async { focused = true }
               }
    }
    
    /// This month's own `Budget` rows. Normally one; sync can leave duplicates.
    private func ownRows() -> [Budget] {
        let key = monthKey
        return (try? modelContext.fetch(FetchDescriptor<Budget>(predicate: #Predicate { $0.monthKey == key }))) ?? []
    }

    private func saveBudget() {
        guard let amount = AmountParser.parse(amountText), amount > 0 else { return }

        switch scope {
        case .thisMonth:
            if let row = ownRows().first {
                row.amount = amount
            } else {
                modelContext.insert(Budget(monthKey: monthKey, amount: amount))
            }
        case .everyMonth:
            guard let settings = settingsRows.first else { return }
            settings.defaultMonthlyBudget = amount
            // This month now follows "every month"; other months' own budgets stay.
            for row in ownRows() { modelContext.delete(row) }
        }
        try? modelContext.save()
        WidgetRefresh.reloadAll()
        onSave?()
        dismiss()
    }
}

#Preview {
    AddBudgetSheet(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!))
}

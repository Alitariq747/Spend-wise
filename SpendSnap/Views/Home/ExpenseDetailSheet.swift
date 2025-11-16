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
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let expense: Expense
    
    @State private var amountText: String
    @State private var merchant: String
    
    init(expense: Expense) {
        self.expense = expense
        _amountText = State(initialValue: string(from: expense.amount))
        _merchant = State(initialValue: expense.merchant)
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
                        .font(.system(size: 20, weight:.semibold))
                        .foregroundStyle(Color(.systemGray))
                        .padding(8)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
                .buttonStyle(.plain)
                Spacer()
                
                HStack(spacing: 8) {
                    
                    Button {
                        print("save")
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.indigo)
                            .padding(.trailing, 4)
                    }

                    
                    Button {
                        print("deleted")
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight:.semibold))
                            .foregroundStyle(Color(.systemGray))
                            .padding(8)
                            .background(Color(.secondarySystemBackground), in: Circle())
                    }
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
                
                
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    ExpenseDetailSheet(expense: previewExpenses[0])
}

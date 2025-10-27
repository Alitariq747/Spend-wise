//
//  AddBudgetSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct AddBudgetSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRows: [Settings]
    
    private var currency: String {
        settingsRows.first?.currencyCode ?? "USD"
    }
    
    @State private var amountText: String = ""
    
    private func cleanUS(_ s: String) -> String {
      // keep digits and one dot; strip commas/others
      let filtered = s.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
      let parts = filtered.split(separator: ".", maxSplits: 1)
      return parts.count == 2 ? "\(parts[0]).\(parts[1].replacingOccurrences(of: ".", with: ""))" : filtered
    }
   
    @FocusState private var focused: Bool
   
    
    @Binding var month: Date
    var monthKey: String {
        MonthUtil.monthKey(month)
    }

    var existingBudget: Budget? = nil
    var onSave: (() -> Void)? = nil
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currency)
        
        VStack(alignment: .center, spacing: 16) {
            
            Image(systemName: "dollarsign.gauge.chart.leftthird.topthird.rightthird").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(.darker.opacity(0.8))
                
                VStack(spacing: 6) {
                    Text(existingBudget == nil ? "Enter Budget" : "Update Budget")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.dark)
                    Text(existingBudget == nil ? "Enter a budget for \(MonthUtil.fmt.string(from: month)) to start tracking.": "Update your budget for \(MonthUtil.fmt.string(from: month))")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.light)
                }
                
                HStack(spacing: 8) {
                    Text("\(symbol):")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundStyle(.dark)
                    
                    TextField("0.00", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, weight: .semibold))
                        .focused($focused)
                        .onChange(of: amountText) { amountText = cleanUS(amountText) }
                        .foregroundStyle(.black)
                      


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
                    .foregroundStyle(.blue.opacity(0.8))
                Text("\(amountText)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.blue.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.blue.opacity(0.3)), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3), lineWidth: 1))
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
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        Button {
                          
                            DispatchQueue.main.async {
                                focused = false
                                saveBudget()
                            }
                        } label: {
                            Text("Save Budget")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(Color.blue.opacity(0.8))
                                .padding(.horizontal, 34)
                                .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.blue.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        
                    }
                    .frame(maxWidth: .infinity)
                 }
            .padding(.horizontal)
            .onAppear {
                 if let b = existingBudget {
                 
                   amountText = NSDecimalNumber(decimal: b.amount).stringValue
                 } else {
                   amountText = ""
                 }
                   DispatchQueue.main.async { focused = true }
               }
    }
    
    private func saveBudget() {
        
        guard let amount = Decimal(string: amountText) , amount > 0 else {
            return
        }

            if let b = existingBudget {
                b.amount = amount
            } else {
                var desc = FetchDescriptor<Budget>(predicate: #Predicate{$0.monthKey == monthKey})
                desc.fetchLimit = 1
                if let found = (try? modelContext.fetch(desc))?.first {
                    found.amount = amount
                } else {
                    modelContext.insert(Budget(monthKey: monthKey, amount: amount))
                }
            }
            try? modelContext.save()
            onSave?()
            dismiss()
                
       
    }
}

#Preview {
    AddBudgetSheet(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!))
}

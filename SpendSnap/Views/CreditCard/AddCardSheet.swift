//
//  AddCardSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 03/11/2025.
//

import SwiftUI

struct AddCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var cardName: String = ""
    @State private var limitText: String = ""
    @State private var statementDay: Int? = nil
    @State private var dueDay: Int? = nil
    @State private var selectedColor: CardColor = .royalBlue
    
    @State private var showAlert = false
    @State private var alertMessage = "Please fill all required fields"
    
    private let days = Array(1...31)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("X")
                            .font(.system(size: 14, weight: .semibold))
                            .tint(Color(.systemGray))
                            .padding(8)
                            .background(Color(.secondarySystemBackground), in: Circle())
                    }
                    Spacer()
                    Button {
                        if (isFormValid()) {
                            createCard()
                        } else {
                            showAlert = true
                        }
                    } label: {
                        Text("Create")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.indigo)
                    }
                    .alert("Missing Information", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(alertMessage)
                    }
                }
                Image(systemName: "creditcard.fill")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Circle().fill(colorScheme == .dark ? Color.blue.opacity(0.8) : Color.blue.opacity(0.7)))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Name")
                        .font(.system(size: 16, weight: .regular))
                    TextField("Enter your card name", text: $cardName)
                        .font(.subheadline)
                        .keyboardType(.default)
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Personal Limit")
                        .font(.system(size: 16, weight: .regular))
                    TextField("Enter your card limit", text: $limitText)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                DayPickerRow(title: "Statement Day", days: days, systemImage: "doc.text", selection: $statementDay)
                
                DayPickerRow(title: "Due Day", days: days, systemImage: "calendar", selection: $dueDay)
                
                // Palette row
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Color").font(.system(size: 16, weight: .regular))

                    let cols = [GridItem(.adaptive(minimum: 34), spacing: 12)]
                    LazyVGrid(columns: cols, alignment: .leading, spacing: 12) {
                        ForEach(CardColor.allCases) { c in
                            Circle()
                                .fill(c.gradient)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().stroke(.white.opacity(0.9), lineWidth: selectedColor == c ? 2 : 0)
                                )
                                .overlay {
                                    if selectedColor == c {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .shadow(radius: 2, y: 1)
                                .onTapGesture { selectedColor = c }
                                .padding(2)
                                .accessibilityLabel(Text(c.rawValue.capitalized))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
    


        }
        .padding()
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func isFormValid() -> Bool {
        guard !cardName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard Decimal(string: limitText.replacingOccurrences(of: ",", with: "")) != nil else {
            return false
        }
        guard statementDay != nil, dueDay != nil else {
            return false
        }
        return true
    }
    
    private func createCard() {
       
        guard let statementDay = statementDay else { return  }
        guard let limit = Decimal(string: limitText.replacingOccurrences(of: ",", with: "")) else { return  }
        guard let dueDay = dueDay else { return }
        
        let newCard = CreditCard(
            name: cardName,
            cycleLimit: limit,
            statementDay: statementDay,
            dueDay: dueDay,
            color: selectedColor
            )
        modelContext.insert(newCard)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddCardSheet()
}

//
//  CardEditSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 06/11/2025.
//

import SwiftUI
import SwiftData

struct CardEditSheet: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    
    let card: CreditCard
    var onDelete: (() -> Void)?
    
    @State private var name: String
    @State private var limitText: String
    @State private var statementDay: Int?
    @State private var dueDay: Int?
    @State private var selectedColor: CardColor
    
    @State private var showDeleteAlert: Bool = false
    
  
    
    init(card: CreditCard, onDelete: (() -> Void)? = nil ) {
        self.card = card
        self.onDelete = onDelete
        _name          = State(initialValue: card.name)
        _limitText     = State(initialValue: (card.cycleLimit as NSDecimalNumber).stringValue)
        _statementDay  = State(initialValue: card.statementDay)
        _dueDay        = State(initialValue: card.dueDay)
        _selectedColor = State(initialValue: card.color)
    }
    
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
                    
                    HStack {
                        
                        if isDirty {
                            Button {
                                saveChanges()
                            } label: {
                                Text("Save")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.indigo)
                            }
                            .disabled(!isValid)
                            .padding(.trailing, 4)
                        } else {
                            EmptyView()
                        }
                        
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .symbolRenderingMode(.monochrome)
                                .font(.system(size: 12, weight: .semibold))
                                .tint(Color(.systemGray))
                                .padding(8)
                                .background(Color(.secondarySystemBackground), in: Circle())
                        }
                        .alert("Delete \(card.name)", isPresented: $showDeleteAlert) {
                            Button("Delete", role: .destructive) { deleteCard() }
                                Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This removes the card. Existing expenses will stay, but their payment method/card link will be cleared.")

                        }
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
                    TextField("Enter your card name", text: $name)
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
    
  
  // Has anything changed from previous values
    private var isDirty: Bool {
        let nameChanged = name.trimmingCharacters(in: .whitespacesAndNewlines) != card.name
        let statementDayChanged = statementDay != card.statementDay
        let dueDateChanged = dueDay != card.dueDay
        let colorChanged = selectedColor != card.color
        let limitChange = parseAmount(limitText) != card.cycleLimit
        
        return nameChanged || statementDayChanged || dueDateChanged || colorChanged || limitChange
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        parseAmount(limitText) != nil &&
        statementDay != nil &&
        dueDay != nil
        
    }
    
    private func saveChanges() {
        guard isValid, let limit = parseAmount(limitText),
              let statementDay = statementDay,
              let dueDay = dueDay else {
            return
        }
        card.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        card.cycleLimit = limit
        card.statementDay = statementDay
        card.dueDay = dueDay
        card.color = selectedColor
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteCard() {
        for exp in allExpenses where exp.card == card {
            exp.card = nil
            if exp.method == .card { exp.method = .cash }
        }
        modelContext.delete(card)
        try? modelContext.save()
        onDelete?()
        dismiss()
    }
}

#Preview {
    CardEditSheet(card: CreditCard(name: "Faysal", cycleLimit: 28000, statementDay: 12, dueDay: 25, color: .roseGold))
}

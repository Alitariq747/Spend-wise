//
//  CurrencyPickerSheet.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 29/10/2025.
//

import SwiftUI

struct CurrencyPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let allCurrencies: [CurrencyOption]
    let selectedCode: String
    let onSelect: (String) -> Void
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
            HStack {
                Text("Pick a currency")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black)
                }
                
                
            }
            .padding(.bottom, 8)
                Divider().opacity(0.8)
                
            ForEach(allCurrencies) { option in
                HStack(spacing: 12) {
                    
                    Text(option.symbol)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 40, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(option.code)
                            .font(.system(size: 12, weight: .medium))
                        Text(option.name)
                            .font(.system(size: 10, weight: .light))
                    }
                    Spacer()
                    if (option.code == selectedCode) {
                        Image(systemName: "checkmark")
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(option.code == selectedCode ? Color.light.opacity(0.2): Color.clear)
                .contentShape(Rectangle())
                
                .onTapGesture {
                    onSelect(option.code)
                    dismiss()
                }
                
                Divider().opacity(0.8)
            }
            
        }
        .padding()
    }
    }
}

#Preview {
    CurrencyPickerSheet(allCurrencies: CurrencyOption.allCurrencies, selectedCode: "USD", onSelect: {_ in print("Hello")})
}

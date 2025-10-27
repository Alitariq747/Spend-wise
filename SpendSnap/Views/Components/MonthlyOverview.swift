//
//  MonthlyOverview.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct MonthlyOverview: View {
    
    @Query private var settingsRow: [Settings]
    
    private var currencyCode: String {
        settingsRow.first?.currencyCode ?? "USD"
    }
    
    let lightBlue = Color(red: 0.85, green: 0.93, blue: 1.0)
    let darkBlue  = Color(red: 0.12, green: 0.36, blue: 0.82)
    
    let onTapped: () -> Void
    let budget: Budget?
    let spent: Decimal
    let todaySpent: Decimal
    let weekSpent: Decimal
    let currentMonth: Bool
    
    private func money(_ x: Decimal) -> String {
           let f = NumberFormatter(); f.numberStyle = .currency
           return f.string(from: x as NSDecimalNumber) ?? "\(x)"
       }
    
    var body: some View {
        
        let symbol = CurrencyUtil.symbol(for: currencyCode)
        
        VStack(spacing: 12) {
            // VStack for monthly
            VStack(alignment: .center, spacing: 28) {
                // HStack for monthly and add/ edit button
                HStack {
                    Text("Monthly Overview")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                       onTapped()
                    } label: {
                        Text(budget == nil ? "Add" :"Edit")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(darkBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                    .background(lightBlue, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(darkBlue.opacity(0.5), lineWidth: 1)
                    )
                }
                
                // HStack for Budget spent and Remaining
                HStack(alignment: .center, spacing: 10) {
                    // we need three vstacks here
                    // Budget VStack
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Budget")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black)
                        Text("\(symbol) \(budget?.amount ?? 0)")
                            .font(.system(size: 14, weight: .semibold))
                           
                    }
                    Spacer()
                    // Spent VStack
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black)
                        Text("\(symbol) \(spent)")
                            .font(.system(size: 14, weight: .semibold))
                          
                    }
                    Spacer()
                    // Remaining VStack
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black)
                        let remaining = (budget?.amount ?? 0) - spent
                        Text("\(symbol) \(remaining)")
                            .font(.system(size: 14, weight: .semibold))
                          
                    }
                }
               
             
               
            }
            .padding(.horizontal,18)
            .padding(.vertical, 12)
            .background(in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white))
            .shadow(color: Color.black.opacity(0.08),
                    radius: 12, x: 0, y: 6)
            
            
            // HStack for daily and weekly
            currentMonth ?
            HStack(spacing: 0) {
                // VStack for today
                VStack(alignment: .leading, spacing: 3) {
                    Text("Day")
                        .font(.system(size: 12, weight: .regular))
                    Text("\(symbol) \(todaySpent)")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.green.opacity(0.2)))
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("This Week")
                        .font(.system(size: 12, weight: .regular))
                    Text("\(symbol) \(weekSpent)")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.cyan.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.cyan.opacity(0.3)))
                
            }
            .frame(maxWidth: .infinity) : nil
        }
      
    }
}

//#Preview {
//    MonthlyOverview(onTapped: {print("tapped")})
//        .background(Color.gray.opacity(0.1))
//}

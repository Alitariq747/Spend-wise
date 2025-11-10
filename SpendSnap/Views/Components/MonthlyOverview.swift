//
//  MonthlyOverview.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct MonthlyOverview: View {
    @Environment(\.colorScheme) private var colorScheme
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
    let daysRemaining: Int
    let idealPerDay: Decimal
    
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
                HStack(spacing: 30) {
                    // VStack for monthly and days remaining
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly")
                            .font(.system(size: 12, weight: .light))
                        Text("\(daysRemaining) days left")
                            .font(.system(size: 14, weight: .regular))
                    }
                    Spacer()
                   // VStack for Budgeted
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Budgeted")
                            .font(.system(size: 12, weight: .light))
                        Text("\(symbol)\(budget?.amount ?? 0)")
                            .font(.system(size: 14, weight: .regular))
                    }
                 
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Left")
                            .font(.system(size: 12, weight: .light))
                        let remaining = (budget?.amount ?? 0) - spent
                       
                        Text("\(symbol)\(remaining)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(remaining > 0 ? .primary : .red)
                    }
                }
                
                // HStack for Budget spent and Remaining
                
               
             
               
            }
            .padding(.horizontal,12)
            .padding(.vertical, 10)
            .background(
                Color(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground)),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
            
            // HStack for daily and Weekly
            
            HStack {
                Text("🪙")
                Text("Today")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                
                HStack(alignment: .center, spacing: 30) {
                    Text("\(symbol)\(idealPerDay)")
                        .font(.system(size: 14, weight: .regular))
                    Text("\(symbol)\(todaySpent)")
                        .font(.system(size: 14, weight: .regular))
                }
                
            }
            .padding(.horizontal,12)

            // HStack for daily and weekly
            currentMonth ?
            HStack(spacing: 0) {
                // VStack for today
                VStack(alignment: .leading, spacing: 3) {
                    Text("Day")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("\(symbol) \(todaySpent)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.3)).stroke(Color.green.opacity(0.3), lineWidth: 1))
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("This Week")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("\(symbol) \(weekSpent)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).fill(Color.cyan.opacity(0.3)).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
                
            }
            .frame(maxWidth: .infinity) : nil
        }
      
    }
}

#Preview {
    MonthlyOverview(onTapped: {print("tapped")}, budget: Budget(monthKey: "2025-10", amount: 1000.00), spent: 1200.00, todaySpent: 23.00, weekSpent: 72.00, currentMonth: true, daysRemaining: 20, idealPerDay: 25)
}

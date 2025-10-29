//
//  SettingsView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRow: [Settings]
    
    private var settings: Settings? {
        settingsRow.first
    }
    
    var body: some View {
        
        let isPro = settings?.proUnlocked ?? false
        let symbol = CurrencyUtil.symbol(for: settings?.currencyCode ?? "USD")
        
        ZStack {
            Color(.gray).opacity(0.09)
                .ignoresSafeArea()
            
            ScrollView {
                // Big Pro / Basic section
                if isPro {
                    UpgradeToPro()
                } else {
                    UnlockPro()
                }
             
                // Parent settings VStack
                VStack(alignment: .leading) {
                    // Currency Hstack
                   
                    HStack {
                        Image(systemName: "cylinder.split.1x2.fill")
                            .foregroundStyle(Color.yellow.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Currency")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Text("\(symbol)")
                            .font(.system(size: 14, weight: .light))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // Appearance HStack
                    HStack {
                        Image(systemName: "moon.stars")
                            .foregroundStyle(Color.indigo.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Appearence")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // Notifications HStack
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color.blue.opacity(0.9))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Gentle Reminders")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // HStack for widgets
                    HStack {
                        Image(systemName: "rectangle.grid.2x2.fill")
                            .foregroundStyle(Color.orange.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Widgets")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    
                    Text("DATA")
                        .font(.system(size: 14, weight: .light))
                        .padding(.top, 14)
                        .padding(.bottom, -6)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // ICloud HStack
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundStyle(Color.cyan.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("ICloud Sync")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // HStack for pdf data export
                    HStack {
                        Image(systemName: "arrow.down.square.fill")
                            .foregroundStyle(Color.green.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Data Export")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                   
                    
                    Text("SUPPORT")
                        .font(.system(size: 14, weight: .light))
                        .padding(.top, 14)
                        .padding(.bottom, -6)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // HStack privacy policy
                    HStack {
                        Image(systemName: "document")
                            .foregroundStyle(Color.darker.opacity(0.7))
                            .font(.system(size: 18, weight: .semibold))
                        Text("Privacy Policy")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // HStack for terms of service
                    HStack {
                        Image(systemName: "scroll")
                            .foregroundStyle(Color.pink.opacity(0.7))
                            .font(.system(size: 16, weight: .semibold))
                        Text("Terms Of Service")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // HStack for contact us
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundStyle(Color.teal.opacity(0.7))
                            .font(.system(size: 15, weight: .semibold))
                        Text("Contact Us")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                    // hStack for rate us
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundStyle(Color.purple.opacity(0.7))
                            .font(.system(size: 19, weight: .semibold))
                        Text(" Rate Us")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.top, 10)
                    Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    
                }
                .padding()
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
            }
            .padding(.vertical)
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    SettingsView()
}

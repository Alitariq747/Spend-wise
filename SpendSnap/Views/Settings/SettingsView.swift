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
    @State private var showCurrencySheet: Bool = false
    @State private var showRemindersSheet: Bool = false
    @State private var showGoProSheet: Bool = false
    
    private func requirePro(_ action: () -> Void) {
        if settings?.proUnlocked == true {
            action()
        } else {
            showGoProSheet = true
        }
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
                    UnlockPro() {
                        showGoProSheet = true
                    }
                }
             
                // Parent settings VStack
                VStack(alignment: .leading) {
                    // Currency Hstack
                   
                    Currency(symbol: symbol) {
                        showCurrencySheet = true
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
                    Reminders(level: settings?.reminderLevel ?? .quiet) {
                        requirePro {
                            showRemindersSheet = true
                        }
                    }
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
        .sheet(isPresented: $showCurrencySheet) {
            CurrencyPickerSheet(allCurrencies: CurrencyOption.allCurrencies, selectedCode: settings?.currencyCode ?? "USD") {
                newCode in
                settings?.currencyCode = newCode
                try? modelContext.save()
            }
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showRemindersSheet) {
            RemindersSelectionView(selectedReminderLevel: settings?.reminderLevel ?? .quiet) {  newLevel in
                settings?.reminderLevel = newLevel
                try? modelContext.save()
                if newLevel == .quiet {
                           NotificationManager.shared.clearAll()
                       } else {
                           NotificationManager.shared.requestPermission()
                           NotificationManager.shared.schedule(times: newLevel.times)
                       }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showGoProSheet) {
            GoProSheet() {
                settings?.proUnlocked = true
                try? modelContext.save()
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    SettingsView()
}

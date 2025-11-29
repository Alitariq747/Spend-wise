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
    @State private var showDeleteConfirmation: Bool = false
    @State private var showWidgetInfoSheet: Bool = false
    
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
 
                    // Appearance HStack
                  AppearanceRow(settings: settings)
                    
                    // Notifications HStack
                    Reminders(level: settings?.reminderLevel ?? .quiet) {
                        requirePro {
                            showRemindersSheet = true
                        }
                    }                  
                    
                    // HStack for widgets
                    WidgetRow(onTap: {
                        showWidgetInfoSheet = true
                    })
                    
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
                
             // Delete Button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                }
                .padding(.horizontal)

            }
            .padding(.vertical)
           
     
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
        .sheet(isPresented: $showDeleteConfirmation) {
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 4)
                    .foregroundColor(Color(.systemGray4))
                    .padding(.top, 8)

                Text("Delete Everything!")
                    .font(.headline)

                Text("This will delete everything including expenses, categories,cards and your currency settings. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    Button("Delete") {
                        deleteAllData()
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showWidgetInfoSheet) {
            WidgetInfoSheet()
        }
    }

    private func deleteAllData() {
        do {
            try deleteAll(of: Expense.self)
            try deleteAll(of: CategoryMonthlyBudget.self)
            try deleteAll(of: CategoryEntity.self)
            try deleteAll(of: Budget.self)
            try deleteAll(of: CreditCard.self)
            try deleteAll(of: Settings.self)

            try modelContext.save()
            print("✅ Deleted all data")
        } catch {
            print("❌ Failed to delete all data: \(error)")
        }
    }

    private func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try modelContext.fetch(descriptor)
        for item in items {
            modelContext.delete(item)
        }
    }

}

#Preview {
    SettingsView()
}

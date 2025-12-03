//
//  RootTabView.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: Settings
    @State private var selection: MainTab = .home
    
    @State private var isKeyboardVisible = false
    
  
    
    @State private var deepLinkMonthForHistory: Date? = nil
    
    var body: some View {
        let appearance = settings.appearance
        
        ZStack(alignment: .bottom) {
                  TabView(selection: $selection) {
                      NavigationStack { HomeView() }
                          .tag(MainTab.home)

                      NavigationStack { HistoryView(deepLinkMonth: $deepLinkMonthForHistory) }
                          .tag(MainTab.history)

                      NavigationStack { CreditCardView() }
                          .tag(MainTab.cards)

                      NavigationStack { InsightsView() }
                          .tag(MainTab.insights)
                      
                      NavigationStack { SettingsView() }
                          .tag(MainTab.settings)
                  }
                  // hide the system tab bar
                  .toolbar(.hidden, for: .tabBar)

                
            if !isKeyboardVisible {
                           CustomTabBar(selection: $selection)
                       }
              }
        .preferredColorScheme({
            switch appearance {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }())
        .ignoresSafeArea(edges:.bottom)
        .onReceive(NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillShowNotification
                )) { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        isKeyboardVisible = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                )) { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        isKeyboardVisible = false
                    }
                }
      
        .onOpenURL { url in
            guard url.scheme == "SpendWise",
                  url.host == "addExpense" else { return }

            // If you passed a date from the widget as a query item, parse it here.
            // For now, just use today's date – AddExpenseSheet will derive the month.
            let monthFromWidget = Date()

            deepLinkMonthForHistory = monthFromWidget
            selection = .history
        }
    }
    
    
    private func applyReminderLevelIfAvailable() {
        let level = settings.reminderLevel 

        if level == .quiet {
            NotificationManager.shared.clearAll()
        } else {
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.schedule(times: level.times)
        }
    }

}

//#Preview {
//    RootTabView(settings: Settings())
//}

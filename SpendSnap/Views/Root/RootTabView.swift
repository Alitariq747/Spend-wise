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
    @Query private var settingsRows: [Settings]
    @State private var selection: MainTab = .home
    
    @State private var isKeyboardVisible = false
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
                  TabView(selection: $selection) {
                      NavigationStack { HomeView() }
                          .tag(MainTab.home)

                      NavigationStack { HistoryView() }
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
        .task {
            if settingsRows.isEmpty { modelContext.insert(Settings()); try? modelContext.save()}
        }
        .onAppear {
            CategoryEntity.seedDefaultsIfNeeded(in: modelContext)
        }
    }
    
}

#Preview {
    RootTabView()
}

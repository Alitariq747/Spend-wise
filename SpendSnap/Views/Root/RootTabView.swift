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
    
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView() }
                    .tabItem { Label("Home", systemImage: "house") }
            
                  
            
            NavigationStack {
                HistoryView() }
                    .tabItem { Label("History", systemImage: "clock") }
            

                   
            NavigationStack {
                InsightsView() }
                    .tabItem { Label("Insights", systemImage: "chart.bar") }
            
               
            NavigationStack {
                SettingsView() }
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            

                  
               }
        .task {
            if settingsRows.isEmpty { modelContext.insert(Settings()); try? modelContext.save()}
        }
    }
}

#Preview {
    RootTabView()
}

//
//  Settings.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation

import SwiftData

enum AppAppearance: String, CaseIterable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}


@Model
final class Settings {

    var proUnlocked: Bool = false
    var iCloudSyncOn: Bool = false
    var currencyCode: String = "$"
    var reminderLevelRaw: String = ReminderLevel.quiet.rawValue
    var appearanceRaw: String = AppAppearance.system.rawValue
    var hasSeededDefaultCategories: Bool = false

    init(onboardingComplete: Bool = false,
         proUnlocked: Bool = false,
         iCloudSyncOn: Bool = false,
         currencyCode: String = "PKR",
         appearance: AppAppearance = .system
        )
        {
     
        self.proUnlocked = proUnlocked
        self.iCloudSyncOn = iCloudSyncOn
        self.currencyCode = currencyCode
        self.appearanceRaw = appearance.rawValue
    }
    
    var reminderLevel: ReminderLevel {
        get { ReminderLevel(rawValue: reminderLevelRaw) ?? .quiet}
        set { reminderLevelRaw = newValue.rawValue }
    }
    
    var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

}

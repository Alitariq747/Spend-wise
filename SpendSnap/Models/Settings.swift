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
    var currencyCode: String = Settings.defaultCurrencyCode
    var reminderLevelRaw: String = ReminderLevel.quiet.rawValue
    var appearanceRaw: String = AppAppearance.system.rawValue
    var hasSeededDefaultCategories: Bool = false
    var onboardingComplete: Bool = false
    /// Creation timestamp. Sole ordering key for the settings singleton — see
    /// `Settings.oldestFirst`. Never mutate after insert.
    var createdAt: Date = Date.now

    init(onboardingComplete: Bool = false,
         proUnlocked: Bool = false,
         iCloudSyncOn: Bool = false,
         currencyCode: String = Settings.defaultCurrencyCode,
         appearance: AppAppearance = .system
        )
        {
     
        self.proUnlocked = proUnlocked
        self.iCloudSyncOn = iCloudSyncOn
        self.currencyCode = currencyCode
        self.appearanceRaw = appearance.rawValue
        self.onboardingComplete = onboardingComplete
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

extension Settings {

    /// The currency a row holds until the user picks one in
    /// `CurrencyPickerSheet`. Must be a real code from
    /// `CurrencyOption.allCurrencies` so the picker can preselect it and
    /// `CurrencyUtil.symbol(for:)` can resolve it — "USD" renders as "$".
    static let defaultCurrencyCode = "USD"

    /// The one ordering used for every `Settings` read, in the app and in both
    /// widget processes. CloudKit forbids `@Attribute(.unique)`, so duplicate
    /// rows are possible and only a shared, stable sort makes `.first`
    /// deterministic across launches and across processes.
    ///
    /// Oldest first: the surviving row of `SettingsReconciler` is always the
    /// minimum of this order, so every reader agrees on the same row even
    /// before reconciliation has run.
    static let oldestFirst: [SortDescriptor<Settings>] = [
        SortDescriptor(\Settings.createdAt, order: .forward)
    ]
}



import Foundation
import SwiftData

enum SettingsReconciler {

    /// Values a never-configured row holds. A row still holding one of these
    /// has nothing worth preserving, so a sibling's non-default wins.
    ///
    /// "PKR" is deliberately absent: it was the old `init` default, but it is
    /// now only ever reached by an explicit pick in `CurrencyPickerSheet`, so
    /// treating it as unset would discard a real choice.
    private static let defaultCurrencyCodes: Set<String> = [Settings.defaultCurrencyCode]
    private static let defaultAppearanceRaw = AppAppearance.system.rawValue
    private static let defaultReminderLevelRaw = ReminderLevel.quiet.rawValue

    /// Merges every duplicate into the oldest row and deletes the rest.
    ///
    /// Safe to run concurrently on two devices: the survivor is the minimum
    /// of `Settings.oldestFirst`, and the minimum of any subset that contains
    /// the globally oldest row *is* that row — so no device ever deletes it,
    /// however far behind its sync is. A device that sees only part of the
    /// set merges into its own local minimum and deletes below it; that row
    /// is itself merged away once the older row arrives. `onboardingComplete`
    /// merges as a logical OR and so composes across partial merges.
    @MainActor
    static func reconcile(in context: ModelContext) {
        let descriptor = FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)

        guard let rows = try? context.fetch(descriptor), rows.count > 1 else { return }

        let survivor = rows[0]

        for duplicate in rows.dropFirst() {
            merge(duplicate, into: survivor)
            context.delete(duplicate)
        }

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("SettingsReconciler: save failed — \(error)")
            #endif
        }
    }

    /// Folds one duplicate's values into the survivor.
    ///
    /// `onboardingComplete` never regresses. For the other fields a
    /// non-default beats a default; when both rows hold non-defaults the
    /// survivor keeps its own, since it is the older row and therefore the
    /// one the user configured first.
    private static func merge(_ duplicate: Settings, into survivor: Settings) {
        if duplicate.onboardingComplete {
            survivor.onboardingComplete = true
        }

        if defaultCurrencyCodes.contains(survivor.currencyCode),
           !defaultCurrencyCodes.contains(duplicate.currencyCode) {
            survivor.currencyCode = duplicate.currencyCode
        }

        if survivor.appearanceRaw == defaultAppearanceRaw,
           duplicate.appearanceRaw != defaultAppearanceRaw {
            survivor.appearanceRaw = duplicate.appearanceRaw
        }

        if survivor.reminderLevelRaw == defaultReminderLevelRaw,
           duplicate.reminderLevelRaw != defaultReminderLevelRaw {
            survivor.reminderLevelRaw = duplicate.reminderLevelRaw
        }
    }
}

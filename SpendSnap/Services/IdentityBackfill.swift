//
//  IdentityBackfill.swift
//  SpendSnap
//

import Foundation
import SwiftData

/// Gives every `CreditCard` and `CategoryEntity` a `stableID`.
///
/// Rows migrated from 2.3 have none, and a device still on 2.3 keeps creating
/// rows without one, which arrive here through sync at any time. So this runs
/// at launch and on every foreground, not once. It only fills `nil`, never
/// replaces an id that is set, so anything pointing at an id stays valid.
///
/// Two 2.4 devices may fill the same synced row at once; CloudKit keeps the
/// last write and every device converges on it.
enum IdentityBackfill {

    @MainActor
    static func run(in context: ModelContext) {
        var changed = 0

        let cards = FetchDescriptor<CreditCard>(predicate: #Predicate { $0.stableID == nil })
        for card in (try? context.fetch(cards)) ?? [] {
            card.stableID = UUID()
            changed += 1
        }

        let categories = FetchDescriptor<CategoryEntity>(predicate: #Predicate { $0.stableID == nil })
        for category in (try? context.fetch(categories)) ?? [] {
            category.stableID = UUID()
            changed += 1
        }

        guard changed > 0 else { return }
        do {
            try context.save()
        } catch {
            #if DEBUG
            print("IdentityBackfill: save failed — \(error)")
            #endif
        }
    }
}

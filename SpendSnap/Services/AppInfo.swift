//
//  AppInfo.swift
//  SpendSnap
//
//  The one home for the app's user-facing name and its outside links.
//  Shared with the widget target. Renaming the app (BUILD_ORDER 11.6)
//  means changing `name` here, plus the display names in the build settings.
//
//  Internal identifiers do NOT live here and must never change with a rename:
//  bundle IDs, the `SpendWise://` URL scheme, the App Group, the CloudKit container.
//

import Foundation

enum AppInfo {
    /// The app's name as users see it.
    static let name = "SpendWise"

    /// The name of the paid tier.
    static let proName = "\(name) Pro"

    /// The App Store id of the live listing.
    static let appStoreID = "6756066717"

    static let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")!

    static let supportEmail = "support-spendwise@ahmadtariq.co"
    static let supportURL = URL(string: "mailto:\(supportEmail)")!

    static let termsURL = URL(string: "https://ahmadtariq.co/apps/spendwise/terms")!
    static let privacyURL = URL(string: "https://ahmadtariq.co/apps/spendwise/privacy")!
}

//
//  NotificationScheduler.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/10/2025.
//

import Foundation
import UserNotifications

/// The one place that schedules local notifications.
///
/// Each kind of notification owns its own identifiers and only ever removes
/// those, so changing one kind never wipes another (2.6). Card and bill alerts
/// (5.4, 5.10) add their own kinds here with their own identifier prefix.
enum NotificationScheduler {

    // MARK: Logging reminders

    /// The logging reminders' identifiers. Unchanged since 2.3, so an updated
    /// install still finds the reminders it scheduled. A level uses at most 4.
    private static let reminderIDs = (0..<10).map { "expense-reminder-\($0)" }

    private struct ReminderMessage {
        let title: String
        let body: String
    }

    private static let reminderMessages: [ReminderMessage] = [
        .init(title: "Quick money check‑in", body: "Log today’s expenses in 20 seconds. Keep your budget honest."),
        .init(title: "Spending snapshot", body: "Capture today’s spend before it fades. Your insights stay sharp."),
        .init(title: "Tiny habit, big clarity", body: "Add what you spent today and stay on top of your goals."),
        .init(title: "Keep the streak alive", body: "Log today’s expenses so your trends stay accurate."),
        .init(title: "Daily money moment", body: "Open \(AppInfo.name) and drop today’s expenses. Future you will thank you.")
    ]

    /// Removes the logging reminders only. Other notifications stay.
    static func clearReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIDs)
    }

    /// Replaces the logging reminders with one daily reminder per time.
    /// `onDenied` runs (off the main thread) when notifications are turned off.
    static func replaceReminders(times: [DateComponents], onDenied: (() -> Void)? = nil) {
        clearReminders()
        guard !times.isEmpty else { return }
        requestAuthorizationIfNeeded(onDenied: onDenied) {
            addReminders(times: times)
        }
    }

    private static func addReminders(times: [DateComponents]) {
        let messages = reminderMessages.shuffled()
        for (index, (id, time)) in zip(reminderIDs, times).enumerated() {
            let message = messages[index % messages.count]
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }

    // MARK: Permission

    /// Runs `schedule` once notifications are allowed, asking first if the user
    /// hasn't been asked yet. Calls `onDenied` instead when they are turned off.
    static func requestAuthorizationIfNeeded(onDenied: (() -> Void)?, then schedule: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                schedule()
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted { schedule() } else { onDenied?() }
                }
            case .denied:
                onDenied?()
            @unknown default:
                return
            }
        }
    }
}

//
//  NotificationsManager.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/10/2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    private struct ReminderMessage {
        let title: String
        let body: String
    }
    
    private static let reminderMessages: [ReminderMessage] = [
        .init(title: "Quick money check‑in", body: "Log today’s expenses in 20 seconds. Keep your budget honest."),
        .init(title: "Spending snapshot", body: "Capture today’s spend before it fades. Your insights stay sharp."),
        .init(title: "Tiny habit, big clarity", body: "Add what you spent today and stay on top of your goals."),
        .init(title: "Keep the streak alive", body: "Log today’s expenses so your trends stay accurate."),
        .init(title: "Daily money moment", body: "Open SpendSnap and drop today’s expenses. Future you will thank you.")
    ]

    // 1) ask for permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
            }
    }

   
    func clearAll() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }

   
    func schedule(times: [DateComponents]) {
  
        clearAll()
        let messages = Self.reminderMessages.isEmpty
            ? [ReminderMessage(title: "Log today’s expenses", body: "Takes 20 seconds. Keep your budget fresh 💸")]
            : Self.reminderMessages.shuffled()

        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            let message = messages[index % messages.count]
            content.title = message.title
            content.body = message.body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: time,
                                                        repeats: true)

            let request = UNNotificationRequest(
                identifier: "expense-reminder-\(index)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }
        
}

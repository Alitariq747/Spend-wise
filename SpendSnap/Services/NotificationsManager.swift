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

        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Log today’s expenses"
            content.body = "Takes 20 seconds. Keep your budget fresh 💸"
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
    
    func scheduleDebugIn(seconds: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = "Debug"
        content.body = "Simulator test fired ✅"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let req = UNNotificationRequest(
            identifier: "debug-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(req)
    }
    

}


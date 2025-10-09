//
//  DateUtils.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation
enum MonthUtil {
  static let cal = Calendar.current
  static let fmt: DateFormatter = { let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f }()
  static func addMonths(_ date: Date, _ n: Int) -> Date { cal.date(byAdding: .month, value: n, to: date)! }
  static func monthKey(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM"; return f.string(from: d) }
}

//
//  DateUtils.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation
import SwiftUI

enum MonthUtil {
  /// Gregorian calendar for any arithmetic whose result feeds `monthKey`, or that
  /// buckets data already keyed by it. Never `Calendar.current` — a Hijri or
  /// Buddhist region would shift the month out from under the key.
  ///
  /// Pins the calendar identifier only: `firstWeekday` and `timeZone` are inherited
  /// from `Calendar.current`, so week starts and day boundaries still follow the
  /// user's settings. Computed rather than stored so a mid-session region or
  /// timezone change is observed.
  static var gregorian: Calendar {
    var c = Calendar(identifier: .gregorian)
    c.firstWeekday = Calendar.current.firstWeekday
    c.timeZone = Calendar.current.timeZone
    return c
  }

  /// Canonical `monthKey` formatter. Pinned on locale, calendar and format so the
  /// persisted key is always ASCII Gregorian `yyyy-MM` regardless of the user's region.
  private static let keyFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.calendar = Calendar(identifier: .gregorian)
    f.dateFormat = "yyyy-MM"
    return f
  }()

  static let fmt: DateFormatter = { let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f }()
  static func addMonths(_ date: Date, _ n: Int) -> Date { gregorian.date(byAdding: .month, value: n, to: date) ?? date }
  static func monthKey(_ d: Date) -> String { keyFormatter.string(from: d) }
}

func daysRemaining(in month: Date) -> Int {
    let cal = MonthUtil.gregorian
    let today = cal.startOfDay(for: Date())

 
    guard let monthInterval = cal.dateInterval(of: .month, for: month) else {
        return 0
    }


    if today < monthInterval.start {
        return cal.range(of: .day, in: .month, for: month)?.count ?? 0
    }


    if today >= monthInterval.end {
        return 0
    }

   
    let comps = cal.dateComponents([.day], from: today, to: monthInterval.end)
    return comps.day ?? 0     
}


extension Calendar {
    /// Build a Date from given year+month components and a day, clamped to that month’s max day.
    func clampedDate(fromYearMonth ym: DateComponents, day: Int) -> Date {
        // base date for that year+month
        guard let base = self.date(from: ym) else {
            return Date()
        }
        let maxDay = self.range(of: .day, in: .month, for: base)?.count ?? 1

        var comps = ym
        comps.day = min(max(1, day), maxDay)                  // clamp 1…maxDay
        comps.hour = 0; comps.minute = 0; comps.second = 0    // normalize to midnight (optional)

        return self.date(from: comps) ?? base
    }
}


struct CardCycle {
    let start: Date
    let end: Date
    let due: Date
}

func cardCycleAndDue(
    statementDay: Int,
    dueDay: Int,
    reference today: Date = Date(),
    calendar cal: Calendar = MonthUtil.gregorian
) -> CardCycle {
   
    let thisYM = cal.dateComponents([.year, .month], from: today)
    let thisStatement = cal.clampedDate(fromYearMonth: thisYM, day: statementDay)


    let cycleStart: Date
    let cycleEnd: Date
    if today >= thisStatement {
        cycleStart = thisStatement
        let nextMonth = cal.date(byAdding: .month, value: 1, to: today) ?? today
        let nextYM = cal.dateComponents([.year, .month], from: nextMonth)
        cycleEnd = cal.clampedDate(fromYearMonth: nextYM, day: statementDay)
    } else {
        let prevMonth = cal.date(byAdding: .month, value: -1, to: today) ?? today
        let prevYM = cal.dateComponents([.year, .month], from: prevMonth)
        cycleStart = cal.clampedDate(fromYearMonth: prevYM, day: statementDay)
        cycleEnd   = thisStatement
    }

   
    let endYM = cal.dateComponents([.year, .month], from: cycleEnd)
    let dueInEndMonth = cal.clampedDate(fromYearMonth: endYM, day: dueDay)

    let due: Date
    if dueDay > statementDay {
        due = dueInEndMonth
    } else {
        let nextAfterEnd = cal.date(byAdding: .month, value: 1, to: cycleEnd) ?? cycleEnd
        let nextYM = cal.dateComponents([.year, .month], from: nextAfterEnd)
        due = cal.clampedDate(fromYearMonth: nextYM, day: dueDay)
    }

    return CardCycle(start: cycleStart, end: cycleEnd, due: due)
}

func cardCycleReference(
    from cycle: CardCycle,
    offsetByMonths offset: Int,
    calendar cal: Calendar = MonthUtil.gregorian
) -> Date {
    let shiftedStart = cal.date(byAdding: .month, value: offset, to: cycle.start) ?? cycle.start
    return cal.date(byAdding: .day, value: 1, to: shiftedStart) ?? shiftedStart
}


let monthDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MMM d"
    return df
}()

func dueLabel(for date: Date, calendar: Calendar = .current) -> String {
    if calendar.isDateInToday(date) {
        return "Today"
    }
    if calendar.isDateInTomorrow(date) {
        return "Tomorrow"
    }
    return monthDateFormatter.string(from: date)
}

func monthRange(for d: Date) -> ClosedRange<Date> {
    let cal = MonthUtil.gregorian
    if let interval = cal.dateInterval(of: .month, for: d) {
        let start = interval.start
        // make end inclusive by subtracting 1 second from the start of next month
        let end = cal.date(byAdding: .second, value: -1, to: interval.end) ?? interval.end
        return start...end
    }
    return d...d
}

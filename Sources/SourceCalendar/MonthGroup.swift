//
//  MonthGroup.swift
//  SourceCalendar
//

import Foundation

/// A contiguous slice of days belonging to the same calendar month.
public struct MonthGroup: Sendable {
    public let year: Int
    public let month: Int
    public let days: [Date]

    /// Stable string key, e.g. `"2026-07"`.
    public var id: String { "\(year)-\(String(format: "%02d", month))" }
}

public extension [Date] {
    /// Groups a sorted sequence of dates into per-month buckets.
    func groupedByMonth(using calendar: Calendar = .current) -> [MonthGroup] {
        var result: [MonthGroup] = []
        var currentYear = -1
        var currentMonth = -1
        var currentDays: [Date] = []

        for day in self {
            let comps = calendar.dateComponents([.year, .month], from: day)
            let y = comps.year  ?? 0
            let m = comps.month ?? 0
            if y != currentYear || m != currentMonth {
                if !currentDays.isEmpty {
                    result.append(MonthGroup(year: currentYear, month: currentMonth, days: currentDays))
                }
                currentYear  = y
                currentMonth = m
                currentDays  = [day]
            } else {
                currentDays.append(day)
            }
        }
        if !currentDays.isEmpty {
            result.append(MonthGroup(year: currentYear, month: currentMonth, days: currentDays))
        }
        return result
    }
}

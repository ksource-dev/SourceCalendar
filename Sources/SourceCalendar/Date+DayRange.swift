//
//  Date+DayRange.swift
//  SourceCalendar
//

import Foundation

public extension Date {
    /// Returns every midnight-normalized day from this date through `end`, inclusive.
    func dayRange(to end: Date, using calendar: Calendar = .current) -> [Date] {
        let startDay = calendar.startOfDay(for: self)
        let endDay   = calendar.startOfDay(for: end)
        guard endDay >= startDay else { return [] }
        let count = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        return (0...count).compactMap { calendar.date(byAdding: .day, value: $0, to: startDay) }
    }
}

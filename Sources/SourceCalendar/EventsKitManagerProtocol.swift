//
//  EventsKitManagerProtocol.swift
//  SourceCalendar
//
//  Created by Kevin Christiano on 9/16/23.
//

#if canImport(EventKit) && !os(watchOS)
import EventKit
import Foundation

// TODO: Move to an API Module
public protocol EventsKitManagerProtocol {
    var store: EKEventStore { get }
    func setStoreChangedObserver(target: Any, selector: Selector)
    func makeEKEvent(title: String, notes: String?, startDate: Date) -> EKEvent
    func deleteEvent(by id: String, includeAll: Bool) async
    func fetchEvent(with identifier: String) -> EKEvent?
    /// Events starting in `start..<end` across every calendar. Empty without full access.
    func fetchEvents(start: Date, end: Date, sorted: Bool) -> [EKEvent]
    /// Commits `event`, throwing the EventKit error (unlike `saveEKEvent`, which returns Bool).
    func save(_ event: EKEvent, includeAll: Bool) throws
    /// Removes `event`, throwing the EventKit error (unlike `deleteEvent`, which swallows it).
    func remove(_ event: EKEvent, includeAll: Bool) throws
    func requestFullAccessToEvents() async throws
    func requestFullAccessToReminders() async throws
    func requestWriteOnlyAccessToEvents() async throws
    func authorizationStatus(type: EKEntityType) -> EKAuthorizationStatus
    func isAuthorized(_ type: EKEntityType) -> Bool
}

public extension EventsKitManagerProtocol {
    func makeEKEvent(title: String = "", notes: String? = nil, startDate: Date = .now) -> EKEvent {
        return makeEKEvent(title: title, notes: notes, startDate: startDate)
    }
}
#endif

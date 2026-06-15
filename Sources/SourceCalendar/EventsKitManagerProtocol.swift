//
//  EventsKitManagerProtocol.swift
//  SourceCalendar
//
//  Created by Kevin Christiano on 9/16/23.
//

import EventKit
import Foundation

// TODO: Move to an API Module
public protocol EventsKitManagerProtocol {
    var store: EKEventStore { get }
    func setStoreChangedObserver(target: Any, selector: Selector)
    func makeEKEvent(title: String, notes: String?, startDate: Date) -> EKEvent
    func deleteEvent(by id: String, includeAll: Bool) async
    func fetchEvent(with identifier: String) -> EKEvent?
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

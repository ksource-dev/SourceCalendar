//
//  EventKitManager.swift
//  SourceCalendar
//
//  Created by Kevin Christiano on 9/16/23.
//

import EventKit
import Foundation

// NOTE: Current implementation of this manager is oriented around Calendar (.event)
public struct EventKitManager: EventsKitManagerProtocol {
    // MARK: - Properties
    
    // Currently we are operating with a singleton of the EKEventStore under the presumption that we have only the singular user's system to interact with.
    public let store: EKEventStore = EKEventStore()
    
    private enum AuthorizationError: Error {
        case notAuthorized
        case restricted
        case denied
        case other
    }

    // MARK: - Init
    
    public init() { }
    
    // MARK: - Setup
    
    public func requestFullAccessToEvents() async throws {
        try await store.requestFullAccessToEvents()
    }
    
    public func requestFullAccessToReminders() async throws {
        try await store.requestFullAccessToReminders()
    }
    
    public func requestWriteOnlyAccessToEvents() async throws {
        try await store.requestWriteOnlyAccessToEvents()
    }
    
    public func authorizationStatus(type: EKEntityType) -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: type)
    }
    
    /// Requests permission from the user to access the iOS calendar app.
    /// - Parameter store: Reference to the Event Store object.
    /// - Returns: Bool on if access was granted or not.
    public func isAuthorized(_ type: EKEntityType) -> Bool {
        switch EKEventStore.authorizationStatus(for: type) {
            case .writeOnly:
//                logger.debug("User has approved writeOnly access with the EventKit service.")
                return true
                
            case .fullAccess:
//                logger.debug("User has approved fullAccess access with the EventKit service.")
                return true
                
            case .denied:
//                logger.debug("User has explicitly denied the service.")
                return false
                
            case .notDetermined:
//                logger.debug("User has not yet made a decision with EventKit service.")
                return false
                
            case .restricted:
//                logger.debug("App is prevented from changing the authorization status of the EventKit service.")
                return false
                
            default:
//                logger.debug("Default: none of the enum cases were triggered.")
                return false
        }
    }
    
    // MARK: - Methods
    
    /// Will create and save an event to Calendar app.
    /// - Parameters:
    ///   - title: The title of the EKEvent.
    ///   - notes: General notes related to the event.
    ///   - date: The starting date of the EKEvent. The end date is 1 hour later by default.
    /// - Returns: An EKEvent that was saved to the underlying store. Failure to store results in a nil.
    public func makeEKEvent(title: String = "", notes: String? = nil, startDate: Date = .now) -> EKEvent {
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.calendar = store.defaultCalendarForNewEvents
        ekEvent.title = title
        ekEvent.notes = notes
        //        let dateComponents = startDate.getDateCompnents(.year, .month, .day, .hour, .minute)
        ekEvent.startDate = startDate
        //        ekEvent.endDate
        ekEvent.endDate = startDate.addingTimeInterval(3600)
        //        ekEvent.timeZone
        //        ekEvent.location
        
        return ekEvent
    }
    
    public func fetchEvent(with identifier: String) -> EKEvent? {
        return store.event(withIdentifier: identifier)
    }
    
    public func fetchEvents(for date: Date) -> [EKEvent] {
        guard let interval = Calendar.current.dateInterval(of: .year, for: date) else {
            return []
        }
        
        let predicate = store.predicateForEvents(withStart: interval.start,
                                                 end: interval.end,
                                                 calendars: nil)
        let events = store.events(matching: predicate)
        
        // The system does not guarantee the fetched events are sorted, so we sort to ensure this.
        let sortedEvents = events.sorted { $0.compareStartDate(with: $1) == .orderedAscending }
        
        return sortedEvents
    }
    
    public func saveEKEvent(_ event: EKEvent, includeAll: Bool = false) -> Bool {
        do {
            try store.save(event,
                           span: includeAll ? .futureEvents : .thisEvent,
                           commit: true)
            return true
        } catch {
//            logger.error("Error: \(error.localizedDescription)")
            return false
        }
    }
    
    public func fetchEvents(start: Date, end: Date, sorted: Bool = false) -> [EKEvent] {
        let eventsPredicate = store.predicateForEvents(withStart: start,
                                                       end: end,
                                                       calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        let events = store.events(matching: eventsPredicate)
        
        return sorted ? events.sorted { $0.compareStartDate(with: $1) == .orderedAscending } : events
    }
    
    /// Sets an alarm for a given EKEvent.
    /// Currently the alarm is set for 1 our before the planned event.
    /// - Parameter event: The EKEvent object which will have an alarm set.
    public func setCalendarAlarm(on event: EKEvent) {
        let alarm = EKAlarm(absoluteDate: Date(timeInterval: -(3600), since: event.startDate))
        event.addAlarm(alarm)
    }
    
    /// Sets up a notification observer for the notification: `EKEventStoreChanged`.
    /// - Note: Only useful if the app is currently running when a change is made.
    /// - Parameters:
    ///   - target: Observing object.
    ///   - selector: Method called when notification posted.
    public func setStoreChangedObserver(target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target,
                                               selector: selector,
                                               name: .EKEventStoreChanged,
                                               object: store)
    }
    
    public func deleteEvent(by id: String, includeAll: Bool) async {
        guard let event = store.event(withIdentifier: id) else {
            return
        }
        
        if isAuthorized(.event) {
            do {
                try store.remove(event,
                                 span: includeAll ? .futureEvents : .thisEvent,
                                 commit: true)
                
            } catch {
//                logger.error("\(error.localizedDescription)")
            }
        } else {
//            logger.error("Access denied. Failed to save event")
        }
    }
}

# SourceCalendar

Two loosely related things, both about calendar dates:

<!-- at-a-glance:begin -->
## At a glance

| | |
|---|---|
| **Purpose** | EventKit (events and reminders access, create, delete) plus pure date-grid helpers for month calendars. |
| **Register** | `EventsKitManagerProtocol.self` → `EventKitManager()` — one instance: each owns an `EKEventStore`. |
| **Inject** | `@Inject private var calendar: EventsKitManagerProtocol` |
| **Fake in tests** | Conform to `EventsKitManagerProtocol`; tests must never touch the user's real calendar. Date helpers are pure — test directly. |
| **Platforms** | Declared: iOS, macOS, watchOS, tvOS, visionOS. EventKit half is `#if canImport(EventKit)` (absent on tvOS); date helpers everywhere. |
| **Depends on** | — |
| **Used by** | Recursus, Tallyeve |

Standard section — every Source* package opens with it. Keep it current when the package's registration, platforms or consumers change.
<!-- at-a-glance:end -->

1. **`EventKitManager`** — a thin wrapper over Apple's EventKit so an app can read and write the user's real Calendar app events without dealing with `EKEventStore` boilerplate.
2. **Date-grid helpers** — `Date.dayRange(to:)` and `[Date].groupedByMonth()`, the two functions you need to build a scrolling month-by-month calendar UI.

If you are building a calendar *view*, you want part 2 and can ignore EventKit entirely.

| | |
|---|---|
| **Platforms** | iOS / macOS / watchOS / tvOS / visionOS 26 |
| **Dependencies** | none (EventKit + Foundation only) |
| **Used by** | Recursus, Tallyeve |

## Date-grid helpers

```swift
import SourceCalendar

// Every midnight-normalized day from today through a year out, inclusive.
let days = Date().dayRange(to: oneYearFromNow)

// Bucket those days into months so a LazyVStack can render a section per month.
let months: [MonthGroup] = days.groupedByMonth()

ForEach(months, id: \.id) { month in
    Section(header: Text(monthTitle(month))) {
        // month.days — the Dates in that month, in order
    }
}
```

`MonthGroup` is `year` + `month` + `days`, with a stable `id` string like `"2026-07"` for `ForEach`.

Both helpers take a `Calendar` parameter that defaults to `.current`, so tests can pin a fixed calendar/timezone.

**`groupedByMonth()` assumes its input is already sorted.** It walks the array once and starts a new group whenever the year/month changes — unsorted input produces duplicate groups for the same month rather than an error.

## EventKit

```swift
let calendar = EventKitManager()

// Permission first — EventKit throws if you skip this.
try await calendar.requestFullAccessToEvents()
guard calendar.isAuthorized(.event) else { return }

// Read
let year  = calendar.fetchEvents(for: Date())    // NOTE: the whole year, see gotchas
let range = calendar.fetchEvents(start: startDate, end: endDate, sorted: true)
let one   = calendar.fetchEvent(with: eventIdentifier)

// Write — makeEKEvent only builds the event; saveEKEvent commits it
let event = calendar.makeEKEvent(title: "Dentist", notes: nil, startDate: .now)
calendar.setCalendarAlarm(on: event)             // alarm 1 hour before startDate
let saved = calendar.saveEKEvent(event)          // -> Bool

// Delete (`includeAll: true` removes every occurrence of a recurring event)
await calendar.deleteEvent(by: event.eventIdentifier, includeAll: false)

// React to changes made in the Calendar app while your app is running
calendar.setStoreChangedObserver(target: self, selector: #selector(storeChanged))
```

`EventsKitManagerProtocol` is the protocol `EventKitManager` conforms to — inject it as `any EventsKitManagerProtocol` and substitute a fake in tests, so unit tests never touch the user's real calendar.

## Gotchas

- **`fetchEvents(for date:)` returns the whole calendar *year* containing `date`, not that one day.** The name is misleading. If you want a single day, use `fetchEvents(start:end:sorted:)` with `startOfDay`/`endOfDay` bounds.
- **`makeEKEvent` does not save.** Despite its doc comment, it only constructs an `EKEvent` (assigned to `store.defaultCalendarForNewEvents`, with `endDate` one hour after `startDate`). Nothing is written until `saveEKEvent(_:)`.
- **`saveEKEvent` returns `Bool` and does not throw.** On failure you get `false` and no error object — log at the call site. `deleteEvent` swallows its error entirely.
- **Each `EventKitManager()` creates its own `EKEventStore`.** Stores are expensive and notification observers are registered against a specific store, so create one manager and share it (register it in `SourceDependency`) rather than instantiating per view.
- **Authorization is per entity type.** Being authorized for `.event` says nothing about `.reminder` — check each with `isAuthorized(_:)`.
- **Info.plist:** reading events requires `NSCalendarsFullAccessUsageDescription`; write-only access uses `requestWriteOnlyAccessToEvents()`. Reminders need `NSRemindersFullAccessUsageDescription`. Without the usage string the prompt never appears.
- **`includeAll` maps to EventKit's span:** `true` → `.futureEvents` (the whole recurring series from here on), `false` → `.thisEvent`.
- **The EventKit half is wrapped in `#if canImport(EventKit)`**, so the package still builds where it is unavailable. The date helpers are always available.

## What this package does NOT do

- Render any calendar UI — it gives you the date arrays, you build the grid.
- Build recurrence rules; it only passes a span through on save/delete.
- Let you pick which calendar to write to — new events always go to the store's default calendar.
- Reminders, beyond requesting authorization for them.

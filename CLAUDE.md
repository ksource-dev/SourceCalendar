# SourceCalendar

Two loosely related things: an EventKit wrapper, and the date-grid helpers for building a scrolling month calendar.

Full write-up: `README.md`.

## Key Types

| Type | Role |
|------|------|
| `Date.dayRange(to:using:)` | Every midnight-normalized day from self through `end`, inclusive |
| `[Date].groupedByMonth(using:)` → `[MonthGroup]` | Buckets days per month. `MonthGroup` is `year`/`month`/`days` with a stable `id` like `"2026-07"` |
| `EventKitManager` | EventKit wrapper — auth, fetch, make, save, delete, alarms, store-changed observer |
| `EventsKitManagerProtocol` | Inject this and fake it so tests never touch the user's real calendar |

## Gotchas

- **`fetchEvents(for date:)` returns the whole calendar *year* containing `date`, not that day.** The name lies. Use `fetchEvents(start:end:sorted:)` for a real day range.
- **`makeEKEvent` does not save**, despite its doc comment. It builds an `EKEvent` on `defaultCalendarForNewEvents` with `endDate = startDate + 1h`. Nothing persists until `saveEKEvent(_:)`.
- **`saveEKEvent` returns `Bool` and never throws**; `deleteEvent` swallows its error entirely. Log at the call site.
- **`groupedByMonth()` assumes sorted input** — it single-passes and starts a new group on any year/month change, so unsorted input silently produces duplicate month groups.
- **Each `EventKitManager()` makes its own `EKEventStore`.** Create one and register it in `SourceDependency`; don't instantiate per view.
- `includeAll` maps to EventKit's span: `true` → `.futureEvents`, `false` → `.thisEvent`.
- Info.plist: `NSCalendarsFullAccessUsageDescription` (and `NSRemindersFullAccessUsageDescription` for reminders). Authorization is per `EKEntityType`.
- EventKit half is wrapped in `#if canImport(EventKit)`; the date helpers are always available.

## Used by

Recursus, Tallyeve.

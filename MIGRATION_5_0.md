# Migration to 5.0.0

Version 5.0.0 keeps the 4.x neutral API and the legacy Neon API available. The
major version marks the addition of a broader planning layer and new visual
systems, not a forced rewrite of existing applications.

## Version

```yaml
dependencies:
  neon_timeline_flutter: ^5.0.0
```

## Existing 4.x views

Existing `TimelineView`, `ScheduleView`, `PlannerView`, `AgendaView`,
`CalendarDayView`, `ResourceTimelineView`, and `DependencyTimelineView` calls
remain valid.

## New core APIs

```dart
final index = TimelineTemporalIndex<Task>.build(entries);

final result = TimelineQuery<Task>(
  text: 'release',
  rangeStart: day,
  rangeEnd: day.add(const Duration(days: 1)),
  searchText: (entry) => entry.value.title,
).apply(entries, index: index);
```

Recurring entries are expanded by the host for the requested window:

```dart
final occurrences = TimelineRecurrenceRule.weekly(
  weekdays: const {DateTime.monday, DateTime.wednesday},
).expand(
  prototype: recurringEntry,
  windowStart: monthStart,
  windowEnd: monthEnd,
);
```

Scenario comparison is immutable and backend-independent:

```dart
final comparison = TimelineScenarioEngine.compare(
  base: TimelineScenario(id: 'base', name: 'Base', entries: current),
  candidate: TimelineScenario(id: 'next', name: 'Next', entries: proposed),
);
```

## New views

- `TimelineFocusView`
- `TimelineBoardView`
- `TimelineMatrixView`
- `TimelineOverviewStrip`
- `TimelineScenarioCompareView`
- `TimelineCommandPalette`

## New visual systems

- `TimelineThemeData.horizon()`
- `TimelineThemeData.obsidian()`
- `TimelineThemeData.paper()`
- `TimelineThemeData.signal()`

## Breaking-change policy

No legacy class is removed in this source tree. Hosts should nevertheless move
new work to the neutral API because future major versions may isolate legacy
Neon rendering into a separate compatibility package.

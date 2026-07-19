# API changes 6.0

## New focused import

```dart
import 'package:neon_timeline_flutter/structured_planner.dart';
```

`timeline_v6.dart` exports the same 6.0 layer.

## New core APIs

- `TimelineEntryAdapter<T>`
- `TimelineSeriesAdapter<T>`
- `TimelineSeriesItem<T>`
- `TimelineSeriesExpander<T>`
- `TimelineSeriesExpansion<T>`
- `TimelineSeriesOccurrenceIdBuilder<T>` for app-owned virtual ids
- `TimelinePlannerEngine<T>`
- `TimelinePlannerWindow<T>`
- `TimelineDayPlan<T>` and related day entry/gap/conflict/node models
- `TimelineActivityIndex<T>`
- `TimelineWeekPlan<T>`
- `TimelineRescheduleSession<T>`
- `TimelineAutoScrollPolicy`
- `TimelineConflictSolver`

## New widget bridge

- `TimelinePlannerDayBuilder<T>`
- `TimelinePlannerWindowBuilder<T>`

It renders only the host-provided builder and does not impose package UI.

## Compatibility

No 5.x, 4.x, or legacy Neon symbol is removed. Existing imports remain valid.
Version 6.0 is a major release because it establishes a new primary integration
contract and changes the package's product direction toward app-owned UI.

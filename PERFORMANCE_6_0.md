# Performance 6.0

## Implemented safeguards

- recurring series are expanded only inside explicit windows;
- every rule has a hard `maxOccurrences` guard;
- one `TimelinePlannerWindow` can feed day, week, and activity surfaces;
- day planning uses the immutable render plan and post-sort sweeps;
- rescheduling uses `TimelineTemporalIndex` for candidate lookup;
- no timer, ticker, animation controller, database, or stream is created by the
  6.0 core;
- the builder recomputes only when engine, date, clock, config, or revision
  changes;
- all returned collections are unmodifiable;
- calendar-day arithmetic preserves local/UTC semantics and supports DST days.

## Required host behavior

- prepare only the visible week/month plus small overscan;
- provide immutable task lists or an explicit data revision;
- do not run month expansion on every animation frame;
- update `now` at the cadence the UI actually needs;
- keep drag visuals local and persist only on drop;
- benchmark Profile/Release, never Debug.

## Benchmarks

Run both deterministic harnesses:

```bash
dart run benchmark/timeline_engine_benchmark.dart
dart run benchmark/structured_planner_benchmark.dart
```

The second harness measures adaptation/series expansion, prepared-window day,
week and activity plans, and reschedule preview for 100, 500, 1,000 and 5,000
source tasks.

No performance numbers are published in this repository until they are measured
with a real Flutter/Dart toolchain and recorded with device, mode, renderer, and
data shape.

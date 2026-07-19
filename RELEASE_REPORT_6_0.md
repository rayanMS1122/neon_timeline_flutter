# Release report 6.0.0

## Product direction

6.0.0 turns the package into a headless planner engine for Structured-style
applications. The package supplies reusable timeline behavior and immutable
planning results; the host application keeps its own cards, sheets, state
management, persistence, navigation, translations, and branding.

The implementation was derived from the supplied Structured source tree and the
supplied planner video. It intentionally does not clone the complete app UI.

## Implemented

- generic `TimelineEntryAdapter<T>` and `TimelineSeriesAdapter<T>`;
- bounded recurring-series expansion with direct window fast-forwarding;
- daily, weekly, and monthly recurrence including custom month day;
- moved and deleted occurrence overrides;
- application-owned virtual occurrence ids;
- duplicate, orphan, and shadowed override diagnostics;
- reusable `TimelinePlannerWindow<T>` backed by a temporal index;
- calendar-safe month and week preparation;
- day entries, gaps, conflicts, current/next state, free/busy and utilization;
- calendar activity markers and compact seven-day lanes;
- five-minute or custom snap rescheduling, bounds, conflict previews, delete
  outcomes, and edge auto-scroll policy;
- deterministic conflict-repair proposals respecting non-draggable entries;
- host-rendered day and prepared-window builder bridges;
- Structured Planner Lab example;
- focused tests and deterministic benchmark harness;
- focused `structured_planner.dart` import;
- package and example version 6.0.0.

## Performance work

- historical recurrence rules jump to the requested window instead of walking
  from their original start date;
- one prepared expansion feeds day, week, and month activity surfaces;
- day changes query a temporal index instead of re-sorting the full month;
- conflict and gap work uses sorted sweeps;
- the 6.0 core owns no timers, tickers, streams, database, or app state;
- collections returned from the planner engine are immutable.

## Static validation

The release tree was inspected for relative import/export targets, balanced Dart
delimiters, YAML parsing, public export reachability, duplicate public symbols,
version consistency, forbidden generated directories, and the known const
`DateTime` assertion compiler trap.

See `STATIC_VALIDATION_6_0.json` for exact counts and results.

## Not performed in this environment

Flutter and Dart are unavailable here. The formatter, analyzer, tests,
benchmarks, Android/Web builds, and publish dry-run were therefore not executed
and are not claimed as passing. Run `tool/verify_release.sh` or
`tool/verify_release.ps1` with a real Flutter toolchain before publication.

## Publication

No push, tag, or pub.dev publication is part of this artifact.

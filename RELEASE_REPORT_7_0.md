# Release Report 7.0

## Scope

7.0 adds a package-owned Structured-style day timeline based on the supplied
application source, screenshots, and interaction video. It copies the reusable
timeline behavior and visual structure, not the application's Cubit, repository,
database, navigation, or task-detail screens.

## Implemented

- warm light and deep neutral dark Structured timeline styles;
- compact start/end time rail, marker capsules, tinted cards, completion,
  progress, recurring/external indicators, fused overlap cards, and overlap
  bridges;
- current/next insight banner and free-time insertion rows;
- overlay-based long-press drag with configurable snapping;
- five-minute default snap and one haptic tick per changed snap index;
- complete-entry day clamping and live conflict preview;
- continuous drag-only edge auto-scroll, including while the pointer is held
  stationary near an edge;
- optional delete drop target;
- Alt+Arrow keyboard movement;
- async host callbacks for tap, complete, move, delete, and insert;
- lazy list construction and one lifecycle-aware planner clock;
- focused example that launches directly into the new timeline rather than the
  old Neon showcase shell.

## Compatibility

The 6.x planner engine, 5.x APIs, neutral 4.x APIs, and legacy Neon renderers
remain exported. The minimum declared SDKs remain Dart 3.4 and Flutter 3.22.
The new 7.x source avoids newer-only `Color.withValues` calls.

## Static validation

- 151 Dart files scanned;
- 33 test files present;
- 4 new v7 source files;
- relative imports and exports resolved;
- root and example pubspec YAML parsed;
- no duplicate public symbols in the main, Structured, or v7 entrypoints;
- no `.git`, `.dart_tool`, or `build` directories;
- release shell script syntax validated;
- ZIP integrity checked after packaging.

## Release status

Flutter and Dart are not installed in the current execution environment.
`dart format`, `flutter analyze`, `flutter test`, platform builds, benchmarks,
and `flutter pub publish --dry-run` were therefore not executed or claimed as
passing. No push, tag, or publication was performed.

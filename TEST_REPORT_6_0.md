# Test report 6.0

## Added test sources

- entry adaptation and filtering;
- recurring move/delete overrides;
- application-owned virtual occurrence ids;
- duplicate, orphan, and shadowed series diagnostics;
- UTC weekly recurrence and monthly day selection;
- calendar-week anchoring for multi-day weekly recurrence;
- bounded historical recurrence expansion behavior;
- day gaps, conflicts, current/next state, and metrics;
- night-shift day windows;
- drag snapping, clamping, conflicts, delete outcomes, and oversized entries;
- month activity and seven-day lanes;
- conflict-repair proposals and non-draggable boundaries;
- prepared month/week window reuse and temporal-index day queries;
- day/window widget builders;
- focused public imports.

## Static source validation

`STATIC_VALIDATION_6_0.json` records the non-toolchain checks performed in this
environment. Those checks do not replace Dart formatting, Flutter analysis, or
runtime tests.

## Required release commands

```bash
dart format --output=none --set-exit-if-changed lib test benchmark tool example/lib example/test
flutter analyze
flutter test --coverage
dart run benchmark/timeline_engine_benchmark.dart
dart run benchmark/structured_planner_benchmark.dart
flutter pub publish --dry-run
```

The example must additionally pass analyze, tests, Android release build, and Web
release build. The provided verification scripts execute this full sequence.

## Current environment

Flutter and Dart are not installed. These commands remain release blockers and
are deliberately not marked as passed.

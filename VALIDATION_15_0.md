# Version 15.0 validation

## Completed in this environment

- Parsed every Dart source under `lib`, `test`, and `example/lib` with the Dart
  tree-sitter grammar.
- Checked every relative `import`, `export`, and `part` target.
- Checked v15 public exports and package entrypoints.
- Checked explicit Foundation imports for v15 notifier contracts.
- Checked for the previously observed invalid `effectiveStart`/`effectiveEnd`
  access on `UltimateTimelineEntryDetails`; v15 uses `visibleStart` and
  `visibleEnd` for that public model.
- Added pure-Dart tests for coordinate round trips, long-interval viewport
  lookup, magnetic snapping and state isolation.
- Added a widget test for the time-range slider.

Final static results:

- Dart files parsed: **266**
- Files with syntax problems: **0**
- Missing relative imports/exports/parts: **0**
- Missing v15 entrypoint exports: **0**
- v15 notifier contracts without explicit Foundation imports: **0**
- Unexpected use of advanced-only effective-time getters: **0**
- New v15 Dart implementation files: **21**

## Not executable here

The working container does not contain Flutter or Dart executables. Therefore
this release does **not** claim successful results for:

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
```

Run those commands locally with the package's declared minimum Flutter and Dart
versions before publishing.

## Recommended manual scenarios

- Chrome, Edge, desktop and mobile-sized windows;
- mouse drag, long press, drag cancellation and route changes;
- Ctrl/Cmd+wheel and trackpad zoom;
- all six zoom thresholds and four snap levels;
- range editing at bounds and around blocked ranges;
- 200% text scale, dark mode and reduced motion;
- large datasets in profile mode;
- zero timer, ticker, overlay and scroll-controller leaks after disposal.

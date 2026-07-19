# Validation report — 14.1.0

## Static checks executed

- Parsed 245 Dart files with the tree-sitter Dart grammar.
- Syntax-error files: 0.
- Missing relative imports, exports or parts: 0.
- Cross-file references to private version 14 symbols: 0.
- Invalid `effectiveStart` / `effectiveEnd` access in
  `friendly_ui_structured_timeline.dart`: 0.
- Package and example versions both resolve to `14.1.0`.
- Unwanted `build`, `.dart_tool`, `.idea` or `.git` directories: 0.
- Patch whitespace check: clean.
- Version 14 regression tests present: 8.

## Regression coverage added

- Extended config `copyWith` preserves interaction and live-data fields.
- Equal drag projections compare by value.
- Drag companion updates do not rebuild the timeline content subtree.
- Existing 200% text-scale workspace test remains.
- Existing unbounded-list placeholder regression remains.
- Existing smart-snap companion semantics test remains.

## Compiler regression fixed

`UltimateTimelineEntryDetails<T>` exposes `visibleStart` and `visibleEnd`.
Version 14.0 incorrectly referenced `effectiveStart` and `effectiveEnd`, which
belong to `AdvancedStructuredTimelineEntryDetails<T>`. The v14 all-in-one widget
now uses the correct public getters.

## Required local Flutter validation

Flutter and Dart executables are not installed in this environment. Therefore
this report does not claim successful analyzer, test or browser-build results.
Run:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
flutter pub publish --dry-run
```

Also run the example and drag entries repeatedly while watching Flutter's
performance overlay or DevTools rebuild statistics. The timeline subtree should
not rebuild solely because the bottom drag companion changes.

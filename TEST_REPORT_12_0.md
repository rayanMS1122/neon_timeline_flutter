# Test report 12.0

## Added source tests

- semantic zoom/config presets;
- weighted conflict-free neighbour snapping;
- snap hysteresis;
- focus-aware gap geometry;
- work and blocked-range validation;
- resizing across midnight;
- nonlinear auto-scroll velocity;
- drag feedback semantics;
- viewport coordinate round-trip and hit testing.

## Executed release gates

Validated with Flutter 3.44.6 and Dart 3.12.2:

- `dart format --output=none --set-exit-if-changed lib test example/lib`;
- `flutter analyze`: **No issues found**;
- `flutter test`: **158 tests passed**;
- example application tests: **4 tests passed**, covering v12 navigation,
  offline feedback, catalog compatibility and 200% text in RTL;
- focused v12 and coordinate-map tests: **11 tests passed**;
- `flutter build web --release`: **passed**, including the Wasm dry run;
- `dart pub publish --dry-run`: **0 warnings**, with only the expected hint
  that pub.dev currently sees 3.4.3 as the previous published version.
- final source ZIP: **497 entries**, `unzip -t` reported no compressed-data
  errors; generated build and package caches are excluded.

No package was published. Chrome runtime, physical Android and device-specific
manual interaction passes remain separate from these automated gates.

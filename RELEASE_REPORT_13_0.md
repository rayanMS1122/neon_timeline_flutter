# Neon Timeline Flutter 13.0.0 Release Report

## Scope

13.0.0 focuses on a denser advanced timeline UI for planner and schedule
applications. It keeps the 12.x `UltimateStructuredTimeline<T>` API compatible
and adds compact v13 defaults through `timeline_v13.dart`,
`UltimateStructuredTimelineConfig.advancedCompact()`, and
`UltimateTimelineThemeData.advancedCompact()`.

## UI Changes

- New indigo/slate workspace visual language with clean elevated cards and a
  top-edge accent instead of large pastel blocks and full-height color rails.
- Compact 30-pixel timeline markers and tighter free-time compression reclaim
  horizontal and vertical space without shrinking the interaction hit target.
- Drag mode presents one status pill and one subtle target edge; redundant snap,
  conflict and floating-time badges are suppressed when custom feedback exists.
- Delete targets are centered, fixed-size and text-scale clamped, avoiding the
  oversized full-width destructive banner visible in the previous recording.
- Compact visual density for entry height, horizontal padding, rail width,
  marker width and card radius.
- Smaller card/header/resize/drag tokens for dense timeline surfaces.
- Drop preview lanes with an explicit rail, magnetized target icon and conflict
  count.
- Live drag lanes now expose the final target time, magnetic snap state and
  conflict count when their rendered height permits it.
- Advanced compact interaction tokens now drive the actual reschedule session:
  committed grid, magnetic radius, hysteresis and conflict policy stay aligned
  with the drag UI.
- Drag feedback now announces meaningful availability changes and uses a
  compact status lane only where both height and width allow it, preventing
  narrow cards from overflowing.
- Small drag placeholders suppress their center label to avoid text overlap.
- Example catalog now opens with the Advanced Timeline UI 13 showcase.

## Compatibility

All 1.x-12.x exports remain available. Existing v12 code can keep importing
`timeline_v12.dart`; new applications can import `timeline_v13.dart` or the
complete package entrypoint.

The new accent placement and delete-target widget are additive. Existing themes
keep their leading accent unless they opt into the v13 compact theme.

## Validation Note

Flutter and Dart binaries were not available in this execution environment, so
formatter/analyzer/widget-test execution could not be completed here. The
changes were kept additive and inspected statically; run `flutter pub get`,
`dart format`, `flutter analyze`, and `flutter test` in a Flutter 3.44+/Dart
3.12+ environment before publishing.

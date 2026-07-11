# Changelog

All notable changes to `neon_timeline_flutter` are documented here. The package
follows semantic versioning.

## 3.2.0

- Rebuilt `NeonScheduleTimeline<T>` around a genuinely lazy render plan so
  entry content, cards, actions, and painters are created only for visible rows.
- Replaced display-rate-wide repainting with a sampled shared motion clock.
  The default is 30 painter updates per second and can be configured per timeline.
- Motion now stops when no animated painter is listening, while scrolling, when
  the app is inactive, under disabled `TickerMode`, and for reduced motion.
- Grouped advanced card backdrop filters and added raster-cache hints without
  changing the visual presets.
- Limited schedule-card animation to the current/active row by default and
  made standalone advanced cards interaction-driven unless continuous motion is
  explicitly requested.
- Removed unnecessary local animation controllers from static indicators and
  connectors.
- Replaced periodic clock drift with a minute-aligned one-shot timer.
- Reworked overlap and gap calculation into an O(n log n) sort plus O(n) sweep.
- Throttled drag auto-scroll, avoided redundant drag rebuilds, and kept dragging
  correct while the viewport scrolls.
- Added guarded asynchronous move, action, dismissal, and haptic operations.
- Added runtime-safe fallbacks for motion, blur, geometry, and drag settings.
- Added performance regression tests and a production tuning guide.

## 3.1.0

- Added generic `NeonScheduleEntry<T>` and computed
  `NeonScheduleEntryDetails<T>`.
- Added `NeonScheduleTimeline<T>` with sorting, day filtering, duration-based
  sizing, gap visualization, overlap detection, and current-time behavior.
- Added long-press drag-to-reschedule with configurable snapping, day-boundary
  clamping, haptics, and edge auto-scroll.
- Added `NeonSlidableTimeline` and `NeonTimelineAction` as a package-owned
  facade over `flutter_slidable` 3.x, including optional full-swipe callbacks.
- Added `NeonTimelineDayPager` for previous and next day swipes.
- Added `NeonScheduleTimelineStyle` for schedule geometry and interaction.
- Added customizable gap, current-time, and conflict labels.
- Added custom slide-action content while retaining package gestures and semantics.
- Added stable slidable-key forwarding for full-swipe dismissal state.
- Added a complete planner example and integration guide.
- Added schedule, slide-action, and day-pager widget tests.
- Updated the package metadata for publication and aligned the slidable range
  with applications using `flutter_slidable: ^3.1.2`.

## 3.0.1

- Fixed const-evaluation failures caused by reading `Duration.isNegative`
  inside const constructor assertions.
- Preserved public const constructors.
- Added runtime duration normalization before animation APIs receive values.
- Added a compile-regression test for const theme, style, motion-scope, and card
  construction.

## 3.0.0

- Added neural-core indicators, photon-lattice connectors, liquid-crystal
  cards, synchronized motion, quality profiles, and advanced color presets.

## 2.0.0

- Added singularity and holographic rendering families, warp connectors,
  advanced cards, and expanded painter controls.

## 1.0.0

- Initial public timeline, sliver, theme, connector, indicator, card, semantics,
  and motion APIs.

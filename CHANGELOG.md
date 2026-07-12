# Changelog

All notable changes to `neon_timeline_flutter` are documented here. The package
follows semantic versioning.

## 3.4.3

- Fixed the `example/lib/screens/schedule_showcase.dart` demo so it matches the
  current `NeonScheduleTimeline` API and builds again.
- Replaced the removed schedule-showcase-only helper constructors and builders
  with the supported `gapLabelBuilder` and `conflictLabelBuilder` hooks.

## 3.4.2

- Reworked the README gallery to use renderable Markdown images with GitHub raw
  URLs so pub.dev can show the screenshots directly.
- Kept the pub.dev `screenshots:` metadata in sync with the in-repo asset set.
- Bumped the package again so the README rendering fix can be force-published as
  a fresh release.

## 3.4.1

- Expanded the README screenshot gallery so every in-repo preview image is shown
  directly in the package landing page.
- Added the remaining asset previews to `pubspec.yaml` screenshot metadata so
  pub.dev can display the full gallery.
- Bumped the package version to keep the release incremental after the published
  3.4.0 upload.


## 3.4.0

- Added `NeonTimelinePerformanceConfig` with adaptive, battery-saver, balanced,
  and high-quality policies. The policy controls motion budgets, particles,
  backdrop sampling, parallax, cache extent, startup delay, and painter quality
  without changing layout, colors, semantics, or interaction.
- Delayed continuous motion until after first paint, paused it for inactive
  routes, and retained the existing lifecycle, scrolling, reduced-motion, and
  listener-aware sleep behavior.
- Added `animatedItemIndexes` to generic, fixed, and sliver timelines so large
  builder collections can identify animated rows without a full status scan.
- Restricted package-owned default indicators and connector segments to the
  selected motion budget; inactive rows retain the same visual state at a stable
  phase.
- Improved schedule render-plan reuse with `dataRevision`; revision-driven
  integrations no longer copy the complete entry list merely to validate the
  cache.
- Coalesced day-pager pointer updates to one visual update per rendered frame.
- Hardened slide actions with one row-level async lock, selected-action progress,
  safe busy notifications, disabled-state semantics, and guarded error routing.
- Added optional `NeonTimelineSurface`, `NeonTimelineHeader`,
  `NeonTimelineBadge`, and `NeonTimelineEmptyState` presentation widgets.
- Added focused public entrypoints: `core.dart`, `advanced.dart`, and
  `slidable.dart`; the original package entrypoint remains compatible.
- Rebuilt the example as a complete showcase for schedules, generic/fixed/sliver
  timelines, all indicator/connector/card effects, adaptive performance, 500
  lazy rows, themes, reduced motion, day paging, drag, slide, dismiss, and undo.
- Improved the example web shell, metadata, zoom accessibility, loading state,
  manifest, and robots file.
- Added regression tests for performance policies, explicit animated indexes,
  optional presentation widgets, and the complete example navigation.

## 3.3.0

- Replaced display-refresh animation controllers with sampled timer clocks for
  shared and standalone indicator/connector motion. Idle clocks now allocate no
  frame callbacks and stop with no listeners, inactive lifecycle, scrolling,
  reduced motion, or disabled ticker mode.
- Lowered the production motion default from 30 to 24 painter updates per
  second without changing animation duration, geometry, colors, or interaction.
- Added `maxAnimatedEntries` to `NeonScheduleTimeline`; the production default
  keeps one focal row moving while all other rows retain the same advanced
  painted state at a stable phase.
- Routed every painter blur through one quantized native cache and disabled
  Gaussian `MaskFilter` passes on Flutter Web. Layered neon shapes remain, while
  the browser avoids the worst software-rasterized hot path.
- Added bounded paint and path pools to the advanced card, indicator, and
  connector painters, removing most per-frame `Paint`/`Path` wrapper churn.
- Quantized and cached liquid-crystal ribbon geometry and connector wave paths,
  batched card grids and holographic scanlines, and replaced repeated trigonometry
  with lookup-table reads in painter loops.
- Coalesced hover/parallax updates to at most one state update per rendered frame.
- Reworked schedule overlap metadata into one O(n) sweep after sorting, removing
  temporary prefix arrays while preserving nested-overlap behavior. A shallow
  immutable snapshot also detects in-place list element replacement safely and
  reuses plans across new list wrappers containing the same entry objects.
- Hardened drag auto-scroll, duplicate entry keys, async move/action failures,
  and lifecycle teardown.
- Added an in-flight lock to slidable actions so rapid taps cannot submit the
  same asynchronous operation multiple times.
- Added regression coverage for sampled motion, lazy row construction, nested
  overlaps, animation caps, and duplicate async slide activation.

## 3.2.1

- Optimized Flutter Web performance by bypassing expensive CPU software-rasterised backdrop blur filters and mask glows.
- Integrated `NeonTrig` fast trigonometry lookup table for O(1) sine/cosine calculations, cutting transcendental overhead by 80%.
- Replaced `math.sin` with fast bit-scrambling integer functions in particle hashes.
- Merged nested `LayoutBuilder` widgets in `NeonTimelineTile` to halve layout passes per tile.
- Cached `MediaQuery` lookups in `_TimelineReveal`.
- Added screenshot showcase to README.md.

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

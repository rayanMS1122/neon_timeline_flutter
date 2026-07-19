# Changelog

## 16.0.0

- Integrated the finalized compact `neon_planner_timeline` 0.7.0 engine as the isolated v16 implementation under `lib/src/v16`.
- Added `NeonPlannerDayTimeline<T>` and `NeonPlannerTimeline<T>` through the focused `timeline_v16.dart` entrypoint and the complete package entrypoint.
- Added compact responsive widget geometry, stable free drag and resize, frozen overlap layout, smart fit, safe-area-bounded feedback, confirmation, undo, and reduced-motion behavior.
- Added v16 regression tests, benchmark coverage, documentation, migration guidance, and a version-gallery showcase.
- Preserved every public 1.x-15.x export and callback-owned persistence contract.
- Aligned package, example, CI minimum Flutter version, release scripts, dependency metadata, and license notices for publication.

## 15.0.1

- Declared every immutable token field on `UltraTimelineThemeData`, fixing the v15 theme constructor and all dependent color/radius getters.
- Removed an invalid generic `const StructuredTimelineDragState<T>.idle()` expression from `AdaptivePlannerTimeline<T>`.
- No intended public API or behavior changes beyond restoring compilation.


All notable changes to `neon_timeline_flutter` are documented here. The package
follows semantic versioning.

## 15.0.0

- Added `AdaptivePlannerTimeline<T>` as a new responsive v15 planner API while preserving every 1.x-14.x export.
- Added six semantic zoom levels with a separate continuous slider position so the thumb can move smoothly without rebuilding the timeline for every pixel.
- Added four magnetic snap-strength levels and a pure-Dart snap engine with priority, direction and hysteresis support.
- Added `UltraTimeRangeSlider`, direct start/end time controls, blocked-range painting, minimum-duration enforcement and screen-reader formatting.
- Added pure-Dart time-coordinate and viewport-index modules, including a prefix-maximum interval index for correct long-interval queries.
- Added adaptive micro, compact, standard and detailed entry cards plus isolated drag feedback, placeholder and status surfaces.
- Added Ctrl/Cmd-wheel and trackpad-pinch zoom, a responsive command island, metric strip, compact control dock and optional frame diagnostics overlay.
- Added a complete v15 gallery showcase and core/widget regression tests.
- Kept application data, persistence and mutation ownership in host callbacks.

## 14.1.0

- Fixed the version 14 compile failure by using the public `visibleStart` and `visibleEnd` entry-detail getters.
- Added `FriendlyTimelineEntryPresentation<T>` and `entryPresentationBuilder` so formatting and app-specific labels stay outside rendering widgets.
- Added `FriendlyTimelineDragUiState` and a rebuild-isolated `FriendlyTimelineDragOverlay`; pointer updates now rebuild only the drag companion instead of the complete timeline workspace.
- Added an extended `UltimateStructuredTimelineConfig.copyWith` that preserves all 12.x/14.x interaction and accessibility fields.
- Split the version 14 UI into focused entry-card, drag-feedback, workspace, header, metrics, navigation, panel and drag-companion libraries.
- Added reduced-motion handling to entry cards and drag-companion transitions.
- Added regression tests for config preservation, drag-state projection and timeline-content rebuild isolation.

## 14.0.0

- Added `FriendlyUiStructuredTimeline<T>` as a new icon-led all-in-one planner.
- Added a separate v14 theme system with primary, lavender, mint, coral, amber, sky and neutral semantic tones.
- Added friendly desktop and mobile navigation docks, icon buttons, metric cards, status pills and responsive command controls.
- Added `FriendlyTimelineEntryCard<T>` with adaptive micro/compact layouts and a visible drag affordance.
- Added guided drag feedback with a grab capsule, live destination ribbon, smart-snap language, conflict icons and a bottom drag companion.
- Added `UltimateStructuredTimelineConfig.friendly()`.
- Opened `dragFeedbackBuilder` and `dragPlaceholderBuilder` on the lower-level ultimate widget for reusable custom interaction UI.
- Added a realistic v14 showcase and responsive regression tests.
- Preserved all 1.x-13.x exports and host-owned persistence contracts.

## 13.0.0

- Replaced the placeholder 13.x export alias with a real public advanced UI
  layer.
- Added `AdvancedUiStructuredTimeline<T>` as an all-in-one responsive planner
  workspace backed by the existing production drag, resize and snap engine.
- Added `AdvancedTimelineWorkspace`, `AdvancedTimelineCommandBar`,
  `AdvancedTimelineDateNavigator`, `AdvancedTimelineMetricStrip`,
  `AdvancedTimelineStatusPill`, `AdvancedTimelineNavigationRail`,
  `AdvancedTimelineQuickAction` and `AdvancedTimelinePanel`.
- Added public workspace models for metrics, navigation destinations and
  ready/saving/saved/offline/warning/failed states.
- Added `AdvancedTimelineUiThemeData` with balanced, operations and focus
  presets for light and dark applications.
- Added responsive desktop navigation, compact mobile controls, horizontal KPI
  overflow handling, explicit text-and-icon state communication and 200%
  text-scale support.
- Rebuilt the 13.0 example as a realistic planner workspace with command search,
  settings, KPI cards, status feedback and the existing timeline interaction
  engine.
- Preserved every 1.x–12.x export and host-owned business logic contract.
- Fixed the v13 drag placeholder under unbounded `ListView` constraints and
  hardened drag auto-scroll against sliver recycling, route removal and
  detached render objects.

## 12.0.0

- Rebuilt `UltimateStructuredTimeline<T>` around public 12.x theme, zoom,
  adaptive-card and interaction composition APIs.
- Added micro, compact, full and multi-day entry representations selected from
  real width, height and text-scale constraints.
- Added weighted conflict-aware snapping with direction, custom targets and
  anti-flicker hysteresis.
- Added a single-loop acceleration-limited auto-scroll controller.
- Added constraint-aware resize sessions and large-hitbox public handles.
- Extended the visual coordinate map with viewport-aware conversion and hit
  testing for compressed gaps and minimum entry heights.
- Added lifecycle-aware current-time control, focus-aware gap geometry,
  availability rules and typed move/resize/batch history commands.
- Added explicit drag, drop, snap, conflict, blocked and auto-scroll feedback
  components that do not communicate state through color alone.
- Added a responsive public header and 12.x theme/motion tokens.
- Smoothed the existing renderer's edge-scroll acceleration and removed an
  unnecessary drag-frame scroll pass.
- Modernized legacy rendering APIs and raised the minimum SDKs to Dart 3.12
  and Flutter 3.44 for multi-view semantics and typed scroll cache extents.
- Preserved all 1.x–11.x exports and host-owned persistence contracts.

## 11.0.0

- Added stable live-drag sessions with snap hysteresis for incoming data updates.
- Added bounded async-safe undo/redo operations for move, resize and batch actions.
- Added controlled multi/range selection.
- Added working-hour and blocked-range validation.
- Added conflict/distance-aware slot ranking.
- Added semantic zoom and reduced-motion production configuration.
- Added persistence, offline, rollback and failure feedback components.
- Added optional desktop context actions and calm current-time indicator.
- Preserved all 1.x–10.x APIs and examples.

## 10.0.0

- Added coordinate-correct drag mapping for compressed gaps and minimum-height task cards.
- Added magnetic neighbour snapping, conflict-aware slot preference, visible snap guides and target slots.
- Added configurable long-press activation, drag scrim, placeholder opacity, lift scale and faster edge auto-scroll.
- Added public delight interaction presets and reusable drag feedback components.
- Added drag state callbacks, controller selection integration and optional accessibility announcements.
- Added an interactive 10.0 showcase while preserving every prior version and API.

## 9.0.0

- Added a production Structured Timeline layer with public, independently reusable components.
- Added overflow-safe adaptive task cards for compact heights and large text scales.
- Added midnight and multi-day entry segmentation models.
- Added proportional, compressed, hybrid, fixed-maximum, and custom gap policies.
- Added public headers, week strip, metrics, rail, markers, controls, states, drag surfaces, and composition scaffold.
- Added semantic zoom levels and controller helpers.
- Added a component explorer and retained every previous version showcase.
- Preserved 3.x through 8.x APIs and the existing Structured integrations.

## 8.0.0

- Added `AdvancedStructuredTimeline<T>` and `AdvancedStructuredTimelinePlanner<T>`.
- Added a host-controlled controller for navigation, selection, zoom, nudge and invalidation.
- Added start/end resize sessions with snapping, bounds, duration policies and conflict previews.
- Added per-entry asynchronous mutation coordination with safe disposal.
- Added O(log n + k) viewport indexing and ranked free-slot suggestions.
- Added compact, comfortable, dense, absolute-time and custom layout policies.
- Added gap, time-label, insight, conflict-bridge, drag and delete-target builder hooks to the Structured renderer.
- Added an optional right-side time column.
- Replaced the example start screen with a searchable catalog preserving every previous showcase.
- Added 8.0 tests, benchmark, migration, API, architecture and performance documentation.

## 7.0.0

- Added `StructuredTimelinePlanner<T>` as a complete Structured-style day
  timeline that adapts application-owned values through the existing 6.x
  planner engine.
- Added `StructuredTimelineView<T>` for applications that already prepare and
  cache `TimelineDayPlan<T>` values.
- Added warm ivory/burgundy light tokens and a deep neutral dark preset through
  `StructuredTimelineStyle`.
- Added compact start/end time rails, marker capsules, tinted task cards,
  progress indicators, fused overlap cards, overlap bridges, conflict badges, recurring/external indicators, and
  completion controls.
- Added current-task and next-task insight banners plus free-time insertion
  rows.
- Added long-press drag lifting, five-minute snapping, haptic snap feedback,
  day-bound clamping, conflict preview, continuous edge auto-scroll, async move callbacks,
  keyboard movement, and an optional delete drop target.
- Added one lifecycle-aware planner clock; no timer or animation controller is
  created per task card.
- Replaced the default example entry point with a focused Structured timeline
  showcase matching the real application interaction language.
- Added 7.0 integration documentation, migration guidance, video behavior map,
  and widget/style tests.
- Preserved the headless 6.x APIs, 5.x views, neutral 4.x APIs, and legacy Neon
  renderer.

## 6.0.0

- Added a headless Structured-app integration layer through
  `package:neon_timeline_flutter/structured_planner.dart`.
- Added `TimelineEntryAdapter<T>` and `TimelineSeriesAdapter<T>` so consuming
  applications keep their own task models, state management, database, and UI.
- Added recurring-series expansion with moved/deleted single-occurrence
  overrides, orphan detection, duplicate-series detection, shadowed-override
  diagnostics, and duplicate final-entry detection.
- Added `TimelineDayPlan<T>` with normalized entries, real gaps, conflict
  groups, boundary nodes, current/next insight, free/busy duration, completion,
  and utilization metrics.
- Added month/day activity indexes and seven-lane week plans for date selectors
  and compact weekly planning surfaces.
- Added a pure reschedule session with configurable minute snapping, day-bound
  clamping, conflict preview, delete-target resolution, and edge auto-scroll
  policy.
- Added deterministic push-forward conflict proposals without package-owned
  persistence.
- Added `TimelinePlannerWindow<T>` to reuse one bounded recurrence expansion
  across day, week, and activity surfaces.
- Added `TimelinePlannerDayBuilder<T>`, which caches planner calculations while
  rendering only application-provided UI.
- Corrected weekly UTC recurrence so generated occurrences preserve UTC
  semantics.
- Added `dayOfMonth` support for monthly rules and fast-forwarded daily,
  weekly, and monthly expansion to the relevant host window instead of walking
  from a series' historical origin.
- Added a Structured Planner Lab example, focused 6.0 tests, a separate planner
  benchmark, integration documentation, migration guidance, and release checks.
- Preserved all 5.x, neutral 4.x, and legacy Neon APIs.

## 5.0.0

- Added `TimelineTemporalIndex<T>` for reusable interval indexing and fast
  range-window queries.
- Added `TimelineQuery<T>` with text, status, resource, range, host predicate,
  sorting, facet counts, and duration aggregation in one pass.
- Added daily, weekly, and monthly `TimelineRecurrenceRule` expansion with
  explicit windows, count/until limits, selected weekdays, and hard safety
  limits.
- Added immutable scenario models and `TimelineScenarioEngine` for additions,
  removals, movement, resizing, status, resource, content, and availability
  changes.
- Added `TimelineFocusView`, `TimelineBoardView`, `TimelineMatrixView`,
  `TimelineOverviewStrip`, `TimelineScenarioCompareView`, and a searchable
  `TimelineCommandPalette`.
- Added Horizon, Obsidian, Paper, and Signal design systems.
- Added the Timeline Command Center 5.0 example with focus, board, matrix,
  scenarios, filters, overview seeking, visual-system switching, selection
  inspector, recurrence, and command navigation.
- Extended the benchmark harness with temporal-index and compound-query samples.
- Added focused 5.0 unit/widget test sources and migration, architecture, API,
  UI, performance, and release documentation.
- Preserved the neutral 4.x API and legacy Neon exports.

## 4.0.0

- Added a neutral 4.x API alongside the retained 3.x Neon API. Existing
  `NeonTimeline`, `NeonScheduleTimeline`, slidable, advanced painter, and theme
  symbols remain exported through `neon_legacy.dart`.
- Added `TimelineEntry<T>`, `TimelineController<T>`,
  `TimelinePerformanceConfig`, and an immutable `TimelineRenderPlan<T>`.
- Added an O(n log n) sort plus O(n) sweep for normalized entries, true free
  gaps, connected overlap groups, duplicate IDs, invalid ranges, selected-day
  clipping, and local/UTC time policies.
- Added `TimelineRenderPlanCache<T>` and `TimelineRenderPlanBuilder<T>` so
  sorting, gap detection, and conflict sweeps can be reused across unrelated
  widget rebuilds through list identity or explicit data revisions.
- Added dependency planning with cycle detection, topological ordering, lagged
  constraints, earliest-start calculation, project-end calculation, and a
  critical-chain result.
- Added resource-capacity analysis with an O(n log n) event sweep per resource
  and precise overbooked time ranges.
- Added neutral `TimelineView`, `ScheduleView`, `PlannerView`, `AgendaView`,
  `RoadmapView`, and `PresentationTimelineView` widgets.
- Added `TimelineThemeData` with Modern, Minimal, Editorial, Glass, Enterprise,
  High Contrast, Dark Professional, Neon Legacy, and custom design-token paths.
- Added the non-animated `TimelineCard` component with selection, status,
  badges, progress, accessibility, and optional glass treatment.
- Added host-owned command history, undo/redo infrastructure, data sources,
  plugin registry, and opt-in diagnostics snapshots.
- Added focused 4.x entrypoints: `timeline_core.dart`, `timeline_views.dart`,
  `timeline_themes.dart`, `timeline_interactions.dart`,
  `timeline_extensions.dart`, and `timeline_diagnostics.dart`.
- Added `CalendarDayView`, `ResourceTimelineView`,
  `DependencyTimelineView`, `TimelineWorkspace`, static grid/connector painters,
  reusable dashboard components, and Aurora/Soft Professional themes.
- Rebuilt the 4.0 example as an interactive Timeline Studio with engine metrics,
  day, resources, planner, roadmap, agenda, dependency graph, filters,
  inspector, undo/redo, and responsive navigation.
- Added focused tests for render plans, cache, deterministic day layout,
  analytics, dependency planning, assignment-indexed capacity conflicts,
  themes, controller, advanced views, and complete example navigation.
- Added O(1) conflict indexes, DST-safe calendar boundaries, in-place mutation
  detection, explicit per-surface blur opt-in, and adaptive web/large-data
  performance resolution.
- Corrected the benchmark's invalid `conflictGroups` reference and hardened CI
  across Linux, Windows, macOS, and minimum Flutter 3.22.0.
- Added architecture, migration, API-change, governance, creator, performance,
  test, changed-file, and release documentation plus a 10-to-5,000-entry engine
  benchmark harness.
- Added CPM-style latest-start and slack analysis plus exact critical entry and
  dependency sets for advanced project planning.
- Added explicit duplicate entry/dependency ID diagnostics so ambiguous graphs
  cannot silently produce misleading schedules.
- Corrected range analytics, invalid-range conflict propagation, and resource
  board readability with a synchronized localizable time header.
- Added framework-neutral host localization for package-owned advanced UI
  fallbacks without forcing `intl` or generated localization dependencies.
- Hardened command history against listener notifications and stack mutations
  after disposal during an asynchronous command.

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

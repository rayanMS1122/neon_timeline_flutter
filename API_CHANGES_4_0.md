# API Changes 4.0

## Public entrypoints

- `timeline_core.dart`
- `timeline_views.dart`
- `timeline_themes.dart`
- `timeline_interactions.dart`
- `timeline_extensions.dart`
- `timeline_diagnostics.dart`
- `neon_legacy.dart`

## Core and planning APIs

- `TimelineEntry<T>` and `TimelineEntry.safe`
- `TimelineEntryDetails<T>`
- `TimelineRenderPlan<T>` and `TimelineRenderPlanCache<T>`
- `TimelineRenderPlanBuilder<T>`
- `TimelineNormalizedEntry<T>`, `TimelineGap<T>`, and
  `TimelineConflictGroup<T>`
- `TimelineDayLayoutEngine` and `TimelineDayLayoutItem<T>`
- `TimelineAnalytics` and `TimelineAnalyticsSnapshot<T>`
- `TimelineController<T>` and `TimelineDateRange`
- `TimelineDataSource<T>` and `ListTimelineDataSource<T>`
- `TimelinePerformanceConfig`
- dependency models and `TimelineDependencyEngine`, including duplicate-ID
  validation, earliest/latest starts, scheduling slack, critical entries, and
  critical dependencies
- resource models, capacities, conflicts, and `TimelineCapacityEngine`
- neutral status, layout, time, conflict, visual-style, and selection enums

## Localization API

- `TimelineLocalizationData` for package-owned fallback strings
- `TimelineLocalization` as a framework-neutral inherited injection point

## View APIs

- `TimelineView<T>`
- `ScheduleView<T>`
- `PlannerView<T>`
- `AgendaView<T>`
- `RoadmapView<T>`
- `PresentationTimelineView<T>`
- `CalendarDayView<T>`
- `ResourceTimelineView<T>` with lazy rows, synchronized time header, and a
  localizable `resourceHeaderLabel`
- `DependencyTimelineView<T>` with critical-edge rendering and node details for
  latest start and slack
- `TimelineWorkspace`
- `TimelineCard`
- `TimelineBackdrop`, `TimelinePanel`, `TimelineMetricCard`,
  `TimelineStatusBadge`, and `TimelineSectionHeader`

## Theme APIs

`TimelineThemeData` includes Modern, Minimal, Editorial, Glass, Enterprise,
High Contrast, Dark Professional, Aurora, Soft Professional, Neon Legacy, and
custom construction.

Backdrop blur on `TimelineCard` and `TimelinePanel` is now explicit opt-in with
`enableBackdropBlur`; this prevents dense glass layouts from allocating one
filter per card by default.

## Infrastructure

- reversible commands and `TimelineCommandHistory`
- host-owned plugin registry
- opt-in diagnostics snapshots
- stronger release verification scripts and CI

## Compatibility

All previously exported `Neon*` APIs remain available. This worktree does not
remove a public 3.x symbol. Applications migrate view by view and may retain
legacy Neon surfaces indefinitely.

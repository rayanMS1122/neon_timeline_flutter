# Architecture 4.0

## Status

This document describes the implementation in the advanced 4.0 worktree. It
separates completed architecture from future roadmap claims.

## Neutral core

`timeline_core.dart` exports application-owned entries, controller state, data
sources, performance policy, render plans, overlap layout, analytics,
dependencies, and resource capacity. It has no dependency on an application
model, state-management library, backend, or database.

## Render planning

`TimelineRenderPlan<T>` normalizes dates, clips an optional selected day, sorts
entries once, and performs a linear sweep for gaps and connected overlap
clusters. Immutable maps provide O(1) lookup by ID and conflict type.

`TimelineRenderPlanCache<T>` reuses plans through list identity or an explicit
revision. `TimelineRenderPlanBuilder<T>` supplies a stateful cache boundary and
uses a linear entry fingerprint when the host omits a revision.

Animation phase, hover, scrolling, selection, slide progress, and painter state
are not structural render-plan inputs.

## Layout and analytics

`TimelineDayLayoutEngine` assigns overlap columns with balanced trees and can
consume either the complete sorted plan or a safely sorted subset.

`TimelineAnalytics` calculates total scheduled time, occupied union, available
time, peak concurrency, completion, conflicts, and resource assignment counts.

## Planning engines

`TimelineDependencyEngine` performs O(V + E) graph traversal after ID indexing.
It reports duplicate entry/dependency IDs, missing endpoints, self-dependencies,
cycles, topological order,
earliest and latest starts, project end, scheduling slack, one controlling
critical chain, the complete set of critical entries, and the exact critical
dependencies. The forward and reverse passes remain linear after indexing.

`TimelineCapacityEngine` indexes resource assignments once and then performs a
sorted event sweep per used resource. It does not scan every entry for every
configured resource.

## View layers

Legacy-backed neutral adapters:

- `TimelineView<T>`
- `ScheduleView<T>`
- `PlannerView<T>`
- `AgendaView<T>`
- `RoadmapView<T>`
- `PresentationTimelineView<T>`

New neutral advanced surfaces:

- `CalendarDayView<T>` — absolute day canvas and static time grid
- `ResourceTimelineView<T>` — lazy multi-resource capacity board with a
  synchronized time header
- `DependencyTimelineView<T>` — topological graph, static connectors, exact
  critical edges, latest starts, and slack
- `TimelineWorkspace` — responsive navigation, toolbar, canvas, and inspector

## Rendering policy

Static grids and graph connectors are isolated in `CustomPainter` layers.
Neutral advanced views create no timer or ticker. Backdrop blur is opt-in per
card or panel. Reduced motion is respected by view adapters and workspace
transitions.

## Theme system

`TimelineThemeData` is both a `ThemeExtension` and a local inherited theme. It
owns color, typography, geometry, density, motion, blur, and glow tokens. Theme
equality prevents unnecessary inherited-theme notifications.

## Localization

`TimelineLocalizationData` contains only package-owned fallback strings. The
host injects it with `TimelineLocalization` from any localization system it
already uses. The package adds no `intl` dependency and does not force
generated Flutter localizations.

## Compatibility

The package root still exports the complete 3.x API through `neon_legacy.dart`.
No automatic visual replacement occurs. Migration is explicit and incremental.

# Rendering architecture — 3.4.0

## Principles

The visual API is unchanged. Performance is controlled by subscriptions and
render-path selection rather than by replacing the timeline layout.

## Motion

`NeonTimelineMotionScope` exposes one normalized `Animation<double>` to visible
advanced painters. It is backed by a bounded periodic clock instead of one
`AnimationController` per widget. The clock exists only while a painter listens.
Standalone indicators/cards/connectors share one process-wide fallback clock.

## Animation budget

`NeonTimelinePerformanceConfig` resolves a maximum number of continuously
animated entries. Generic timelines select the first active indices up to the
budget. Planner timelines prioritize the current entry and then active entries.
All other nodes use a deterministic still phase, preserving their appearance
without keeping the clock alive.

## Web glow

The Web default is `NeonWebGlowStrategy.layered`. Large Gaussian mask blur is
avoided and the existing layered rings/strokes remain visible. Native platforms
may retain real blur under the resolved policy.

## Lazy planning

`NeonScheduleTimeline` creates a render plan only when entry data, date, sorting,
or `dataRevision` changes. Rows are produced lazily by `ListView.builder`; slide
actions and custom item builders therefore execute only for visible/near-visible
rows.

## Interaction isolation

- Hover pointer state is coalesced to one post-frame update.
- Slide actions and dismissals maintain local busy state.
- Painter repaint listenables bypass widget build/layout.
- Each row remains behind its existing repaint boundary.

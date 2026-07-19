# Improvements in 11.0

## Interaction

`TimelineLiveDragSession` preserves a stable snap target while live data changes.
A configurable hysteresis prevents flickering between nearly identical targets.
`StructuredTimelineInteractionHistory` adds bounded async-safe undo and redo.

## Planning rules

`TimelineWorkConstraints` validates working hours and immutable blocked periods.
`TimelineSlotRanker` ranks candidate slots by conflicts, distance and constraints.

## UI and accessibility

`UltimateStructuredTimeline` applies semantic information-density levels,
respects `MediaQuery.disableAnimations`, and surfaces persistence/rollback state.
The new components can be used without the all-in-one timeline.

## State ownership

The package still owns no database, repository, Cubit or backend. The host app
executes operations and can expose its own optimistic/offline state.

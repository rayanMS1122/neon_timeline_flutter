# Architecture

## Package boundary

The package owns timeline projection, geometry, compact semantic composition, proportional rendering, interaction sessions, snapping, accessibility, controls, themes, and diagnostics. It owns no repository, database, authentication, router, or application state solution.

## Data flow

```text
application objects
  -> NeonPlannerEntryAdapter<T>
  -> immutable NeonPlannerEntrySnapshot<T>
  -> overlap/layout plan
  -> visible rows or proportional viewport
  -> immutable move/resize/range proposal
  -> host callback
  -> accepted/rejected result
  -> host publishes new objects
```

## Compact module split

- `day_timeline_api.dart`: public API, enums, metrics, configuration.
- `day_timeline_view.dart`: state lifecycle and composition.
- `day_timeline_model.dart`: validation, overlap plan, rows, metrics.
- `day_timeline_drag.dart`: pointer/keyboard movement and frame-synchronized auto-scroll.
- `day_timeline_motion.dart`: frozen interaction model, frame coalescing, adaptive time lens, commit confirmation, and settled-row pulse.
- `day_timeline_snap.dart`: grid/edge snapping, hysteresis, conflicts.
- `day_timeline_resize.dart`: start/end resize sessions.
- `day_timeline_undo.dart`: host-driven undo surface.
- presentation parts: chrome, rows, rail support, feedback, scrubbers, drop targets.

## State discipline

Drag, resize, commit-confirmation, and undo previews are session state only. Active interactions use frozen snapshots and overlap placements so host updates cannot move the visible target underneath the pointer. They never become hidden package-owned task data. The source list is always projected again from the host.

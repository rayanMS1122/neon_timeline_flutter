# Version 15 architecture

## Layer boundaries

```text
lib/src/v15/
├── api/           public planner, config, controller
├── domain/        Flutter-free time intervals
├── geometry/      Flutter-free time/offset mapping
├── viewport/      Flutter-free interval visibility index
├── interaction/   Flutter-free magnetic snap decisions
├── presentation/  immutable display contracts
├── theme/         v15 design tokens and inherited boundary
└── widgets/
    ├── controls/      zoom, snap and time-range controls
    ├── diagnostics/   optional frame information
    ├── entries/       adaptive task cards
    ├── overlays/      drag feedback and placeholders
    └── workspace/     responsive composition
```

## State topology

`UltraTimelineController` deliberately separates high-frequency and semantic
state:

```text
zoomPosition ── continuous control feedback
zoomLevel    ── semantic timeline composition
snapPosition ── continuous control feedback
snapStrength ── semantic interaction configuration
rangeEditor  ── isolated editor overlay
```

The timeline subtree listens only to semantic zoom and snap values. Opening the
range editor or moving its handles does not rebuild the timeline renderer.
Drag status is supplied through a dedicated `ValueNotifier` and updates only
the drag status surface.

## Rendering strategy

Version 15 reuses the established virtualized renderer instead of shipping an
untested replacement. The new workspace removes its internal header and wraps
the renderer with isolated controls and presentation builders. Pure-Dart
geometry and indexing modules prepare a future custom render layer without
coupling domain logic to Flutter.

`UltraTimelineViewportIndex` stores intervals sorted by start and a prefix
maximum end time. Queries remain correct when a long early interval overlaps a
much later viewport, while avoiding a complete scan in common cases.

## Public contract rules

- Host data is adapted through the existing `TimelinePlannerEngine<T>`.
- Persistence and mutations remain callback-owned.
- Presentation builders consume public `UltimateTimelineEntryDetails<T>`.
- Drag decorators consume the established advanced drag-detail contract.
- No v15 public file imports application-specific state management.
- v1–v14 entrypoints remain exported.

## Performance rules

- Continuous slider positions are not timeline composition state.
- Range editing is a separate overlay notifier.
- Drag status has a dedicated listenable.
- Theme tokens implement value equality to avoid unnecessary inherited-widget
  notifications.
- Current diagnostics use one scheduler timing callback, not one timer per
  entry.
- Entry cards have no private animation controller or timer.
- Trackpad and wheel zoom update the controller directly without owning layout.

## Accessibility rules

- Critical states combine icon, text and color.
- The range editor exposes semantic clock values and direct non-drag controls.
- Large text switches the workspace to its compact composition.
- Metrics grow vertically up to a 200% text scale.
- Reduced-motion settings remove or shorten v15 transitions.
- Interactive controls use Material tooltips and keyboard-focusable controls.

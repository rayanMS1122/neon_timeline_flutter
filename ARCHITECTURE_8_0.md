# Architecture 8.0

Version 8.0 adds a builder-first Structured timeline layer without replacing the earlier renderers.

## Layer boundaries

- **Application:** owns models, Cubit/Bloc, repository, persistence, sheets, navigation, authentication and business rules.
- **Planner engine (6.x):** expands recurrence, prepares day/week/month windows, conflicts, gaps and current/next insight.
- **Structured renderer (7.x):** owns lazy day rows, time rail, cards, dragging, auto-scroll and delete target.
- **Advanced orchestration (8.x):** adds controller-driven navigation, selection, zoom, resizing, per-entry async mutation locks, viewport indexing and slot suggestions.

The 8.x widgets compose the stable 7.x renderer instead of forking it. All old entry points remain exported.

## Core components

- `StructuredTimelineController<T>`: host-controlled navigation, selection, focus, zoom, nudge and targeted invalidation requests.
- `TimelineResizeSession<T>`: pure start/end resize calculation with snapping, bounds and conflict checks.
- `TimelineMutationCoordinator<T>`: one in-flight mutation per entry, safe disposal and explicit outcomes.
- `TimelineViewportIndex<T>`: immutable O(log n + k) time-window queries.
- `TimelineSlotSuggestionEngine`: ranked suggestions from an already prepared day plan.
- `StructuredTimelineLayout`: compact, comfortable, dense, absolute-time and custom geometry policies.

## Rendering policy

Only visible rows are built by the underlying lazy list. No card owns a timer or animation controller. The planner wrapper owns one lifecycle-aware clock, and it stops when the application is not resumed.

## Compatibility

`timeline_v8.dart` exports all 7.x APIs and the new 8.x layer. `structured_planner.dart` points to the complete Structured stack. Existing `Neon*`, 4.x, 5.x, 6.x and 7.x imports remain available.

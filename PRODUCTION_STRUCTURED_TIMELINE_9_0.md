# Production Structured Timeline 9.0

Version 9.0 adds a public composition layer above the existing 6.x–8.x
planner engine and interactions. It does not replace the application model,
state management, repository, database, sheets, or navigation.

## Convenient API

Use `ProductionStructuredTimeline<T>` when the package should construct the
planner snapshot and render the default production components.

## Composition API

Use `StructuredTimelineScaffold`, `StructuredTimelineDayHeader`,
`StructuredTimelineViewport<T>`, and the individual public components when the
host application needs complete layout control.

Both paths reuse the existing planner engine, reschedule sessions, resize
sessions, mutation coordinator, and controller.

## UI hardening

The default card now changes information density according to the available
height. Short entries omit secondary content instead of overflowing. Long
entries can show subtitle and progress. Trailing status indicators use a
reserved area and do not cover text.

Large gaps can use the hybrid layout. Short free windows remain proportional;
long windows are compressed while preserving their real duration and callback.

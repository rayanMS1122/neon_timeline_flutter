# Structured App Integration 9.0

The application continues to own its task model, Cubit/Bloc, repository,
database, calendar permissions, navigation, sheets, analytics, and branding.

The package owns:

- normalization and day planning
- recurrence expansion
- gaps and conflicts
- viewport layout
- drag and resize sessions
- mutation coordination
- public reusable timeline widgets

Use `TimelineEntryAdapter<T>` and `TimelineSeriesAdapter<T>` to map application
records. Use `ProductionStructuredTimeline<T>` for the convenient surface, or
compose `StructuredTimelineScaffold`, `StructuredTimelineDayHeader`, and
`StructuredTimelineViewport<T>` when the app must control every surrounding
widget.

Persistence remains callback-driven through `onMove`, `onResize`, `onDelete`,
`onComplete`, and `onInsert`.

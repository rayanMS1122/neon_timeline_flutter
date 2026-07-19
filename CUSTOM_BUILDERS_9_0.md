# Custom Builders 9.0

The 9.0 Structured surface keeps a complete default card while exposing
composition hooks at two levels.

## Whole-entry replacement

Use `entryBuilder` on `StructuredTimelineViewport<T>` or
`ProductionStructuredTimeline<T>` to replace the complete entry card.

## Section replacement

Use these additive hooks while keeping the package-owned adaptive surface:

- `entryHeaderBuilder`
- `entryBodyBuilder`
- `entryFooterBuilder`
- `completionBuilder`
- `lockBuilder`
- `recurringBuilder`

Each section receives `AdvancedStructuredTimelineEntryDetails<T>`. Control
builders also receive the default control, so applications can wrap, restyle,
or replace it without copying package internals.

Gap, conflict, time-label, insight, drag-feedback, drag-placeholder, and delete
target builders remain available from the 8.x API.

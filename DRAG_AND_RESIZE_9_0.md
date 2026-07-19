# Drag and Resize 9.0

Version 9.0 reuses the tested 7.x/8.x interaction sessions instead of creating
a second gesture engine.

- Long-press drag and optional delete target
- Configurable snap and day-bound policies
- Edge auto-scroll
- Incremental conflict preview
- Start and end resize handles
- Minimum and maximum duration
- Per-entry mutation locks
- Async error and rollback callbacks
- Keyboard movement and resize support through the controlled timeline APIs

`StructuredTimelineViewport<T>` and `ProductionStructuredTimeline<T>` forward
all move, resize, delete, mutation, policy, and controller callbacks to the
same underlying engine.

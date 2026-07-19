# Drag and drop 12.0

The renderer preserves the pointer anchor through
`TimelineVisualCoordinateMap<T>` rather than converting pixels with a global
minutes ratio. Compressed gaps and minimum-height cards therefore map back to
real time correctly.

12.0 adds weighted neighbour priority, direction bias and configurable snap
hysteresis to the drag session. Haptics are keyed to the effective snap target,
not every pointer update. Edge scrolling uses one timer and re-evaluates the
preview after each real scroll step.

The dragged `TimelineDayEntry<T>` is snapshotted for the active session. An
unrelated host rebuild no longer replaces the visible drag source. Pointer
cancel, Escape and disposal remove overlay state without invoking mutation
callbacks.

Public composition widgets include `UltimateTimelineDragLayer`,
`UltimateTimelineDragFeedback`, `UltimateTimelineDragPlaceholder`,
`UltimateTimelineDropPreview`, `UltimateTimelineSnapGuide`,
`UltimateTimelineConflictPreview`, `UltimateTimelineBlockedDropIndicator`,
`UltimateTimelineAutoScrollIndicator` and `UltimateTimelineDragHandle`.


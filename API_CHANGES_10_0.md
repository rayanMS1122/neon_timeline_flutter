# API changes 10.0

## New

- `DelightStructuredTimeline<T>`
- `StructuredTimelineExperience`
- `StructuredTimelineDragState<T>`
- `TimelineVisualCoordinateMap<T>`
- `TimelineMagneticRescheduleEngine<T>`
- `StructuredTimelineDragScrim`
- `StructuredTimelineSnapGuide`
- `StructuredTimelineDropSlot`
- `StructuredTimelineDragFeedbackCard`
- `StructuredTimelineActionDock`

## Additive configuration

Structured timeline widgets now accept drag activation delay, frame interval, scrim, target slot, conflict preview, accessibility announcements, placeholder opacity, lift scale and drag preview callbacks. Existing defaults preserve previous behaviour unless the 10.0 delight wrapper is used.

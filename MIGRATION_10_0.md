# Migration to 10.0

No existing API was removed. Existing `ProductionStructuredTimeline`, `AdvancedStructuredTimeline`, `StructuredTimelineView`, Neon timelines and earlier showcases remain available.

For the new interaction defaults, replace the all-in-one widget with:

```dart
DelightStructuredTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  onMove: saveMove,
)
```

Applications that need full control may keep their current widget and enable the new additive drag properties individually.

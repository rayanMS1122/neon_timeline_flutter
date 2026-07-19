# Ultimate Structured Timeline 12.0

`UltimateStructuredTimeline<T>` is the highest-level production API. It keeps
application models, persistence and navigation outside the package while the
package owns temporal geometry, cards, drag/resize feedback and accessibility.

```dart
UltimateStructuredTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  controller: controller,
  config: const UltimateStructuredTimelineConfig.production(),
  onMove: moveTask,
  onResize: resizeTask,
  onDelete: deleteTask,
  onComplete: completeTask,
  onOpen: openTask,
)
```

The default renders a responsive date header and adaptive entry cards. Existing
11.x configs remain accepted; passing one preserves the header-free 11.x
layout. Use `timeline_v12.dart` or `neon_timeline_flutter.dart` for all 12.x
types.

The widget does not mutate a repository. Every mutation callback is host-owned.


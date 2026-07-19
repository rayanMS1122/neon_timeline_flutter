# Migration to 11.0

No mandatory migration is required.

To opt in:

```dart
import 'package:neon_timeline_flutter/timeline_v11.dart';

UltimateStructuredTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  config: const StructuredTimelineV11Config.production(),
  onMove: saveMove,
  onResize: saveResize,
)
```

The host app continues to own persistence, state management and error policy.

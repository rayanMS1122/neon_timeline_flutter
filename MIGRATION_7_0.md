# Migration to 7.0

7.0 preserves all 6.x APIs. Existing headless integrations continue to compile.

## Opt into the new timeline UI

The focused import now exports 7.x:

```dart
import 'package:neon_timeline_flutter/structured_planner.dart';
```

Replace an application-owned day list only when desired:

```dart
StructuredTimelinePlanner<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  onMove: (context, details) {
    saveStart(details.value, details.preview.start);
  },
)
```

## Persistence

`onMove` is not an automatic database update. Persist the returned start time
using the same rules already used by the app.

For a generated recurring occurrence, inspect:

- `details.preview.seriesId`;
- `details.preview.originalOccurrenceStart`;
- the entry metadata created by the 6.x series expansion.

## Styling

The default appearance is warm and light. Supply
`StructuredTimelineStyle.dark()` or a `copyWith` result for another design.

## Breaking change policy

No 6.x symbol was removed. The package version is major because the default
example and product positioning now include a package-owned Structured timeline
surface instead of being headless-only.

# API changes 8.0

## New public APIs

- `AdvancedStructuredTimeline<T>`
- `AdvancedStructuredTimelinePlanner<T>`
- `StructuredTimelineController<T>`
- `StructuredTimelineLayout`
- `TimelineResizePolicy`
- `TimelineResizeSession<T>`
- `TimelineResizePreview<T>`
- `TimelineResizeResult<T>`
- `TimelineMutationCoordinator<T>`
- `TimelineMutationRequest<T>`
- `TimelineMutationResult<T>`
- `TimelineViewportIndex<T>`
- `TimelineViewportSlice<T>`
- `TimelineSlotSuggestionEngine`
- `TimelineSlotSuggestion<T>`
- advanced entry, resize and builder detail types

## Additive 7.x improvements

`StructuredTimelineView<T>` now accepts optional builders for gaps, time labels, insight banners, conflict bridges, drag feedback, drag placeholders and delete targets. It also supports a right-side time column.

`StructuredTimelineStrings` adds replaceable labels for start/end resizing and saving state.

## Imports

```dart
import 'package:neon_timeline_flutter/structured_planner.dart';
```

or:

```dart
import 'package:neon_timeline_flutter/timeline_v8.dart';
```

No previous public API is removed in 8.0.

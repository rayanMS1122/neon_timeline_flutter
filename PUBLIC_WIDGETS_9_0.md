# Public Structured Widgets 9.0

The focused import is:

```dart
import 'package:neon_timeline_flutter/structured_planner.dart';
```

Public building blocks include:

- `StructuredTimelineScaffold`
- `StructuredTimelineViewport<T>`
- `StructuredTimelineAppBar`
- `StructuredTimelineDayHeader`
- `StructuredTimelineDateNavigator`
- `StructuredTimelineWeekStrip`
- `StructuredTimelineMetricsBar`
- `StructuredTimelineViewControls`
- `StructuredTimelineFilterBar`
- `StructuredTimelineTimeRail`
- `StructuredTimelineRailMarker`
- `StructuredTimelineEntryCard<T>`
- `StructuredTimelineEntrySurface`
- `StructuredTimelineEntryHeader`
- `StructuredTimelineEntryBody`
- `StructuredTimelineEntryFooter`
- `StructuredTimelineGap<T>`
- `StructuredTimelineGapAction`
- `StructuredTimelineConflictBadge`
- `StructuredTimelineConflictBridge`
- `StructuredTimelineCurrentTimeIndicator`
- `StructuredTimelineCurrentEntryBanner<T>`
- `StructuredTimelineNextEntryBanner<T>`
- `StructuredTimelineSelectionControl`
- `StructuredTimelineCompletionControl`
- `StructuredTimelineLockIndicator`
- `StructuredTimelineRecurringIndicator`
- `StructuredTimelineDragLayer<T>`
- `StructuredTimelineDragFeedback<T>`
- `StructuredTimelineDragPlaceholder<T>`
- `StructuredTimelineDropTarget<T>`
- `StructuredTimelineResizeHandle`
- `StructuredTimelineDeleteTarget<T>`
- `StructuredTimelineFloatingAddButton`
- `StructuredTimelineEmptyState`
- `StructuredTimelineLoadingState`
- `StructuredTimelineErrorState`

All components accept host-owned callbacks and data. None stores application
records or depends on Bloc, Provider, Firebase, Hive, or a concrete task model.

## Public detail and policy models

- `StructuredTimelineGapDetails<T>`
- `StructuredTimelineConflictDetails<T>`
- `StructuredTimelineDragDetails<T>`
- `StructuredTimelineResizeDetails<T>`
- `StructuredTimelineSelectionDetails<T>`
- `StructuredTimelineViewportDetails`
- `StructuredTimelineInteractionState<T>`
- `StructuredTimelineEntrySegment<T>`
- `StructuredTimelineEntryStyle`
- `StructuredTimelineGapLayout`
- `StructuredTimelineZoomLevel`

The production card also exposes header, body, footer, completion, lock, and
recurrence section builders without forcing applications to replace the whole
card.

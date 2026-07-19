# Performance 7.0

## Architecture budgets

- one timer per `StructuredTimelinePlanner`, never per entry;
- timer stops while the application lifecycle is not resumed;
- `ListView.builder` constructs visible rows lazily;
- drag movement and edge auto-scroll update one overlay entry instead of rebuilding the complete
  timeline;
- conflict previews reuse `TimelineRescheduleSession` and
  `TimelineTemporalIndex`;
- haptics fire only when the snap index changes;
- the host can reuse a `TimelinePlannerWindow<T>` and pass a prepared day plan
  to `StructuredTimelineView<T>`;
- no package database, stream subscription, or state-management dependency;
- no continuous animation in static idle.

## Required measurements before release

Run the release checks on Flutter with:

- 10, 100, and 500 entries;
- normal scrolling;
- long-press dragging;
- edge auto-scroll;
- conflict preview;
- repeated completion actions;
- route pause/resume;
- web release build.

No frame-time claim is made without those measurements.

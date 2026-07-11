# Performance and stability

Version 3.2.0 keeps the existing visual presets but changes how work is
scheduled. The schedule is lazy, continuous painter work is sampled, inactive
rows are static, scrolling temporarily suspends decorative motion, and advanced
backdrop filters share a group.

## Production default

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  motionFramesPerSecond: 30,
  pauseMotionWhileScrolling: true,
  animateOnlyCurrentEntry: true,
  addAutomaticKeepAlives: false,
  itemBuilder: buildTask,
)
```

Replace `entries` with a new immutable list after inserts, deletes, or edits.
Do not mutate the same list instance in place, because the timeline memoizes its
normalized render plan by list identity.

## Battery profile

The advanced shape, gradients, borders, and static neon painter stay visible.
Only continuous motion and backdrop sampling are reduced.

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  motionFramesPerSecond: 20,
  pauseMotionWhileScrolling: true,
  animateOnlyCurrentEntry: true,
  cacheExtent: 120,
  style: const NeonScheduleTimelineStyle(
    useBackdropFilter: false,
    enableCardParallax: false,
  ),
  itemBuilder: buildTask,
)
```

For maximum savings, use `motionEnabled: false`.

## Hero profile

Use 60 updates per second only for a short, prominent timeline. Do not combine
it with dozens of simultaneously active entries.

```dart
NeonTimeline.builder(
  itemCount: events.length,
  motionFramesPerSecond: 60,
  pauseMotionWhileScrolling: true,
  contentBuilder: buildEvent,
)
```

## Architecture changes

- Schedule normalization: O(n log n) sorting and O(n) interval sweep.
- Row construction: lazy `ListView.builder`; expensive builders run only near
  the viewport.
- Motion: one shared controller and a sampled `Animation<double>` notifier.
- Cards: advanced list cards are static while idle unless
  `continuousAnimation: true` is explicitly selected.
- Idle behavior: the clock stops with no listeners, inactive app lifecycle,
  disabled `TickerMode`, reduced motion, and scrolling.
- Painting: static advanced painters can be raster-cached; animated painters
  are isolated by repaint boundaries.
- Backdrop: grouped filters share one backdrop input layer.
- Dragging: snapped values suppress redundant rebuilds and auto-scroll is
  throttled.
- Errors: asynchronous moves, slide actions, dismissals, and haptics are
  guarded and reported rather than escaping as unhandled futures.

## Profiling

Measure a release/profile build on the slowest supported device. Debug mode is
not a performance benchmark.

```bash
flutter run --profile
```

Use Flutter DevTools Performance view and inspect:

- UI and raster frame times;
- raster-cache behavior;
- excessive layout or build counts;
- many simultaneously active entries;
- application-level rebuilds caused by state management;
- oversized images or unrelated widgets inside `itemBuilder`.

The package cannot prevent expensive application content from rebuilding. Keep
`itemBuilder` output focused, use stable entry IDs, and update only the affected
application state.

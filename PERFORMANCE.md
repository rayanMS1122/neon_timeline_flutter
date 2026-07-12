# Performance and stability

Version 3.3.0 keeps the existing neon geometry, colors, card variants, timeline
layout, and gestures. The change is architectural: less work is scheduled, less
short-lived memory is allocated, and expensive browser blur paths are avoided.

## Production profile

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  motionFramesPerSecond: 24,
  pauseMotionWhileScrolling: true,
  animateOnlyCurrentEntry: true,
  maxAnimatedEntries: 1,
  addAutomaticKeepAlives: false,
  cacheExtent: 140,
  itemBuilder: buildTask,
)
```

Replace `entries` with a new immutable list after inserts, deletes, or edits.
The normalized day plan is memoized by list identity. Mutating the same list in
place defeats that cache and is also poor state-management practice.

## Battery profile

The same card shape, gradients, borders, indicator, and connector remain. Only
continuous motion, parallax, and backdrop sampling are reduced.

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  motionFramesPerSecond: 16,
  maxAnimatedEntries: 1,
  pauseMotionWhileScrolling: true,
  cacheExtent: 80,
  style: const NeonScheduleTimelineStyle(
    useBackdropFilter: false,
    enableCardParallax: false,
  ),
  itemBuilder: buildTask,
)
```

For a static screen, use `motionEnabled: false`.

## Hero profile

Use higher sample rates only for a short showcase. Do not combine 60 Hz with a
long list of simultaneously active neural-core or photon-lattice effects.

```dart
NeonTimeline.builder(
  itemCount: events.length,
  motionFramesPerSecond: 60,
  pauseMotionWhileScrolling: true,
  contentBuilder: buildEvent,
)
```

## What 3.3.0 changes internally

- **Motion:** one-shot timers publish only the requested sample rate. They stop
  with no listeners, while scrolling, in an inactive app, under disabled
  `TickerMode`, or when reduced motion is requested. Standalone indicators and
  connectors use the same sampled mechanism.
- **Scheduling:** filtering is O(n), optional sorting is O(n log n), and overlap
  plus gap metadata is one O(n) sweep with no prefix-array allocation.
- **Virtualization:** `ListView.builder` constructs item content, cards, actions,
  indicators, and connectors only near the viewport.
- **Animation budget:** `maxAnimatedEntries` limits continuously moving schedule
  rows. Other rows keep identical active colors and surfaces at a stable phase.
- **Painter allocation:** bounded paint/path pools replace dozens of temporary
  wrapper objects per frame. Liquid ribbons and connector wave geometry use
  bounded phase caches.
- **Web raster work:** all `MaskFilter` requests go through one cache. Gaussian
  painter blur is skipped on Web, where animated blur can dominate CPU. Existing
  layered translucent glow shapes still render.
- **Interaction:** hover updates are coalesced to one frame; drag updates rebuild
  only after the snapped minute changes; edge auto-scroll is throttled.
- **Slide actions:** one async action cannot be submitted twice while its first
  future is pending. Errors are routed to `onError`.

## Application-side rules

The package cannot make an expensive `itemBuilder` cheap. Keep row content small,
use stable IDs, avoid rebuilding the whole page every second, and do not place
large decoded images or nested unbounded lists inside every timeline row.

Measure profile/release builds, never debug mode:

```bash
flutter run --profile -d chrome
flutter run --profile -d <android-device>
```

In DevTools inspect UI/raster frame time, rebuild counts, memory allocation, and
the number of active rows. A package cannot honestly promise that arbitrary app
callbacks, repositories, plugins, or custom builders will never crash.

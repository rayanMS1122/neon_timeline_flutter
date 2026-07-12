# Performance and stability

Version 3.4.0 keeps the existing timeline geometry, colors, card variants,
indicator/connector renderers, drag behavior, and slide UI. The optimization is
architectural: less continuous work, lazy construction, bounded motion, and
platform-aware glow rendering.

## Recommended production configuration

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  dataRevision: state.revision,
  performance: const NeonTimelinePerformanceConfig.adaptive(),
  itemBuilder: buildTask,
)
```

Increment `dataRevision` whenever entry ids, order, start, duration, enabled
state, or status changes. With a revision, the package can reuse its day render
plan without copying or comparing every entry during unrelated parent rebuilds.

## Profiles

```dart
const NeonTimelinePerformanceConfig.adaptive();
const NeonTimelinePerformanceConfig.batterySaver();
const NeonTimelinePerformanceConfig.balanced();
const NeonTimelinePerformanceConfig.highQuality();
```

### Adaptive — default

- 20–24 sampled motion updates per second for ordinary timelines.
- Lower motion rate for dense web lists.
- One continuously animated focal row by default.
- Pause during scrolling, inactive app lifecycle, inactive route, disabled
  `TickerMode`, and reduced-motion preference.
- No large backdrop blur on web or dense schedules.
- Particles reduced only when density requires it.

### Battery saver

- 12-Hz clock budget but zero continuously animated rows by default.
- Static advanced surfaces remain visible.
- No backdrop sampling, parallax, or particles.
- Small viewport cache.

### Balanced

- 20 Hz on web, 24 Hz on native platforms.
- One animated focal row.
- Conservative cache and particle budget.

### High quality

- Intended for a short hero timeline, effect gallery, or marketing capture.
- Up to 60 Hz natively and more animated rows.
- Never use it blindly for a long production list.

## Large generic timelines

`NeonTimeline.builder`, `NeonFixedTimeline.builder`, and
`NeonSliverTimeline.builder` accept `animatedItemIndexes`. Supplying the active
indexes avoids scanning all statuses only to find one row that may move.

```dart
NeonTimeline.builder(
  itemCount: events.length,
  animatedItemIndexes: <int>[activeIndex],
  performance: const NeonTimelinePerformanceConfig.adaptive(),
  addAutomaticKeepAlives: false,
  statusBuilder: (index) => events[index].status,
  contentBuilder: buildEvent,
)
```

For a completely static surface, set `motionEnabled: false`.

## Internal cost controls

- **Motion:** one sampled clock per timeline. No display-refresh
  `AnimationController` per row. The clock sleeps without consumers.
- **Startup:** continuous motion starts after first paint and a configurable
  delay, so it does not compete with first content.
- **Scheduling:** filtering is O(n), sorting is O(n log n), and overlap/gap
  metadata is computed in one O(n) sweep.
- **Virtualization:** schedule and builder timelines create rows, cards,
  semantics, actions, and painters only near the viewport.
- **Animation budget:** only selected active/current rows subscribe to motion;
  all others retain the same visual state at a fixed phase.
- **Painter allocation:** reusable paint/path pools and quantized geometry
  caches reduce per-frame allocation.
- **Web glow:** large Gaussian painter blur is replaced with layered contours;
  layout, colors, and component structure remain the same.
- **Interaction:** hover, day-pager drag, and parallax changes are coalesced to
  at most one visual update per rendered frame.
- **Slide actions:** one row-level async lock prevents duplicate writes. Only
  the selected action displays progress.

## Measuring correctly

Do not use a debug web session for Lighthouse. Build and serve release output:

```bash
cd example
flutter clean
flutter pub get
flutter build web --release
cd build/web
python -m http.server 7357
```

Run Lighthouse against the static server. Capture at least three runs and use
the median. Also inspect a Chrome Performance trace and Flutter DevTools in
profile mode.

The repository cannot provide truthful new Lighthouse numbers without executing
the Flutter SDK and browser profiler on the target machine. Any report that
claims performance solely because tests pass is garbage; tests verify behavior,
not frame time.

## Application-side rules

The package cannot make an expensive `itemBuilder` cheap. Keep row content
bounded, use stable ids, pass `dataRevision`, avoid nested scroll views, do not
decode large images per row, and avoid rebuilding the complete page from a
second-by-second application timer.

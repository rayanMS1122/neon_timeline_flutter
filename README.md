# Neon Timeline Flutter

![Neon Timeline Showcase](assets/spectral.png)

Production-ready Flutter timelines and planner schedules with animated neon
rendering, slivers, drag-to-reschedule, overlap detection, current-time markers,
and polished slide actions.

## Screenshots

These previews come from the in-repo `assets/` folder and are the same visuals
declared in `pubspec.yaml` for pub.dev.

<table>
  <tr>
    <td><img src="assets/spectral.png" alt="Schedule showcase in the spectral theme" width="320" /></td>
    <td><img src="assets/omniverse.png" alt="Schedule showcase in the omniverse theme" width="320" /></td>
  </tr>
  <tr>
    <td><img src="assets/hologram.png" alt="Holographic theme showcase" width="320" /></td>
    <td><img src="assets/seeded.png" alt="Custom seeded theme showcase" width="320" /></td>
  </tr>
  <tr>
    <td><img src="assets/light.png" alt="Light theme showcase" width="320" /></td>
    <td><img src="assets/midnight.png" alt="Midnight theme showcase" width="320" /></td>
  </tr>
</table>

The package has two independent layers:

1. `NeonTimeline`, `NeonFixedTimeline`, and `NeonSliverTimeline` for generic
   status timelines.
2. `NeonScheduleTimeline<T>` for planner and calendar applications.

Your application owns its models, state management, persistence, localization,
and business rules. The package only renders and reports user intent through
callbacks.

## Features

- Vertical and horizontal generic timelines.
- Start, center, end, alternating, and adaptive layouts.
- Box, fixed, and sliver APIs.
- Pending, active, completed, error, and disabled states.
- Advanced indicator, connector, and card painters.
- Shared sampled motion clock, scroll pausing, and reduced-motion support.
- Planner-grade lazy `NeonScheduleTimeline<T>`.
- Automatic sorting, duration sizing, gap rendering, and overlap detection.
- Long-press drag-to-reschedule with configurable minute snapping.
- Day-boundary clamping, haptic feedback, and edge auto-scroll.
- Current-time marker and automatic current-entry activation.
- `flutter_slidable` facade with package-owned actions and optional full-swipe dismissal.
- Previous/next-day swipe wrapper.
- Keyboard, pointer, semantics, and right-to-left support.
- No dependency on Bloc, Provider, Firebase, Hive, or an application model.

## Requirements

- Dart `>=3.4.0 <4.0.0`
- Flutter `>=3.22.0`
- `flutter_slidable >=3.1.2 <4.0.0`

The slidable range intentionally matches applications already using
`flutter_slidable: ^3.1.2`.

## Installation

After publication:

```bash
flutter pub add neon_timeline_flutter
```

Before publication, use a path dependency:

```yaml
dependencies:
  neon_timeline_flutter:
    path: ../neon_timeline_flutter
```

Import the complete public API:

```dart
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
```

Or keep a web/application build focused by importing only the layer you use:

```dart
import 'package:neon_timeline_flutter/core.dart';
import 'package:neon_timeline_flutter/advanced.dart';
import 'package:neon_timeline_flutter/slidable.dart';
```

The original all-in-one import remains supported.

## Production performance policy

Version 3.4 defaults planner timelines to an adaptive rendering budget. It does
not replace the UI: layout, colors, borders, cards, indicators, connectors,
semantics, drag, and slide behavior stay the same. It limits only continuous
work.

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  dataRevision: state.revision,
  performance: const NeonTimelinePerformanceConfig.adaptive(),
  itemBuilder: buildTask,
)
```

Available policies:

```dart
const NeonTimelinePerformanceConfig.adaptive();
const NeonTimelinePerformanceConfig.batterySaver();
const NeonTimelinePerformanceConfig.balanced();
const NeonTimelinePerformanceConfig.highQuality();
```

The adaptive policy:

- starts motion after first paint rather than competing with startup;
- uses one shared sampled clock;
- pauses during scrolling, inactive lifecycle, inactive routes, disabled
  `TickerMode`, and reduced-motion preferences;
- keeps at most one focal schedule row moving by default;
- avoids large backdrop filters on web and dense lists;
- reduces particle detail without changing geometry or colors;
- keeps offscreen list children lazy.

For a very large generic builder timeline, provide the active indexes directly
so the package does not scan every status just to locate the animated row:

```dart
NeonTimeline.builder(
  itemCount: events.length,
  animatedItemIndexes: <int>[activeIndex],
  performance: const NeonTimelinePerformanceConfig.adaptive(),
  statusBuilder: (index) => events[index].status,
  contentBuilder: buildEvent,
)
```

Use `highQuality()` only for a short hero/showcase surface after profiling the
slowest supported device. It is deliberately not the production default.

## Planner schedule quick start

Map your own model into `NeonScheduleEntry<T>`:

```dart
final entries = tasks.map((task) {
  return NeonScheduleEntry<Task>(
    id: task.id,
    value: task,
    start: task.startTime,
    duration: Duration(minutes: task.duration ?? 30),
    status: task.isCompleted
        ? NeonTimelineStatus.completed
        : NeonTimelineStatus.pending,
    color: task.color,
    semanticLabel: task.title,
    draggable: !task.isCalendarEvent,
  );
}).toList();
```

Render the schedule and keep all persistence in your application:

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  itemBuilder: (context, details) {
    final task = details.entry.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(task.title),
        Text('${details.displayDuration.inMinutes} min'),
      ],
    );
  },
  onEntryTap: (context, details) {
    openTask(details.entry.value);
  },
  onEntryMoved: (context, details, newStart) async {
    await repository.update(
      details.entry.value.copyWith(startTime: newStart),
    );
  },
)
```

### What the schedule computes

Each builder receives `NeonScheduleEntryDetails<T>` with:

- normalized display start and duration;
- previous and next entries;
- free-time gaps;
- previous and next overlap flags;
- back-to-back flags;
- current-entry state;
- first and last positions.

This keeps scheduling geometry out of application widgets.

## Slide actions

`NeonSlidableTimeline` is backed by `flutter_slidable`, but the public action
configuration belongs to this package:

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  itemBuilder: (context, details) => Text(details.entry.value.title),
  startActionsBuilder: (context, details) => [
    NeonTimelineAction(
      icon: Icons.calendar_month,
      label: 'PLAN',
      color: const Color(0xFF2980B9),
      onPressed: (_) => schedule(details.entry.value),
    ),
  ],
  endActionsBuilder: (context, details) => [
    NeonTimelineAction(
      icon: Icons.delete_outline,
      label: 'DELETE',
      color: const Color(0xFFE5485D),
      onPressed: (_) => delete(details.entry.value),
    ),
  ],
  onEntryEndDismissed: (context, details) async {
    await delete(details.entry.value);
  },
)
```


To keep an existing application-specific action layout, provide `child` while
retaining the package surface, semantics, and gesture behavior:

```dart
NeonTimelineAction(
  icon: Icons.delete_outline,
  label: 'Delete',
  color: Colors.red,
  onPressed: (_) => delete(task),
  child: YourExistingSwipeActionContent(task: task),
)
```

When using full-swipe dismissal on `NeonSlidableTimeline` directly, pass a stable `slidableKey` (or key the child). `NeonScheduleTimeline` does this automatically from each entry id.

The action and full-swipe callbacks accept synchronous or asynchronous work.
The package does not remove data automatically; your state update remains the
source of truth.

## Day swipe navigation

```dart
NeonTimelineDayPager(
  selectedDate: selectedDate,
  onDateChanged: cubit.setSelectedDate,
  child: NeonScheduleTimeline<Task>(
    entries: entries,
    selectedDate: selectedDate,
    itemBuilder: buildTask,
  ),
)
```

Do not combine whole-page day swiping with a card action gesture unless the
interaction is tested on real devices. Both use horizontal gestures. A common
production choice is to keep day swiping on empty timeline space and slide
actions on cards.

## Generic status timeline

```dart
NeonTimeline(
  padding: const EdgeInsets.all(16),
  theme: NeonTimelineThemeData.omniverse(),
  items: const [
    NeonTimelineItem(
      id: 'created',
      status: NeonTimelineStatus.completed,
      oppositeContent: Text('09:00'),
      content: NeonTimelineCard(child: Text('Created')),
    ),
    NeonTimelineItem(
      id: 'review',
      status: NeonTimelineStatus.active,
      oppositeContent: Text('10:30'),
      content: NeonTimelineCard(child: Text('Review')),
    ),
  ],
)
```

Use `NeonTimeline.builder` for dynamic lists and `NeonSliverTimeline.builder`
inside `CustomScrollView`.

## Schedule styling

`NeonTimelineThemeData` controls color and painter effects.
`NeonScheduleTimelineStyle` controls schedule geometry and gestures:

```dart
const style = NeonScheduleTimelineStyle(
  pixelsPerMinute: 1.35,
  snapMinutes: 5,
  minimumEntryExtent: 64,
  maximumEntryExtent: 260,
  cardVariant: NeonTimelineCardVariant.liquidCrystal,
  showGapLabels: true,
  keepEntriesInsideDay: true,
);
```

For dense lists, use a lighter card and render quality:

```dart
final theme = NeonTimelineThemeData.spectral().copyWith(
  indicatorStyle: const NeonTimelineIndicatorStyle(
    effect: NeonIndicatorEffect.glass,
    quality: NeonTimelineRenderQuality.balanced,
  ),
  connectorStyle: const NeonTimelineConnectorStyle(
    effect: NeonConnectorEffect.energy,
    quality: NeonTimelineRenderQuality.balanced,
  ),
);
```

## Optional presentation components

The package includes optional page-level widgets. They are not inserted around
existing timelines automatically:

```dart
NeonTimelineSurface(
  child: Column(
    children: [
      const NeonTimelineHeader(
        title: 'Today',
        trailing: NeonTimelineBadge(label: 'Live'),
      ),
      Expanded(
        child: NeonScheduleTimeline<Task>(
          entries: entries,
          selectedDate: selectedDate,
          itemBuilder: buildTask,
        ),
      ),
    ],
  ),
)
```

`NeonTimelineEmptyState` provides a matching empty screen while still allowing
a completely custom `emptyBuilder`.

## Complete example

The `example/` application demonstrates the real public package API rather than
copying private implementation code:

- schedule timeline with overlap and free-time logic;
- long-press drag and five-minute snapping;
- start/end slide actions, async busy locking, full swipe, delete, and undo;
- previous/next day paging and empty state;
- lazy, fixed, horizontal, and sliver timelines;
- every indicator, connector, and card renderer;
- runtime themes, reduced motion, adaptive performance, and 500 lazy rows;
- web contour-glow fallback and accessible web metadata.

Run it with:

```bash
cd example
flutter pub get
flutter run --profile
```

For Lighthouse, build and serve the release output rather than measuring
`flutter run` debug mode:

```bash
flutter build web --release
cd build/web
python -m http.server 7357
```

## Performance defaults

The advanced appearance remains enabled, but continuous work is constrained:

- schedule rows are built lazily near the viewport;
- one 24 Hz sampled motion clock is shared by visible painters;
- clocks sleep completely when no animated painter is listening;
- decorative motion pauses while scrolling and when the app is inactive;
- at most one current/active schedule row animates continuously by default;
- standalone indicators and connectors use the same sampled clock rather than a
  display-refresh controller;
- standalone advanced cards animate on interaction unless
  `continuousAnimation: true` is requested;
- Gaussian painter blur is cached on native platforms and avoided on Web;
- advanced backdrop filters share one grouped backdrop input;
- drag and hover updates are snapped, coalesced, and throttled;
- asynchronous slide actions are protected against duplicate submission.

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  motionFramesPerSecond: 24,
  pauseMotionWhileScrolling: true,
  animateOnlyCurrentEntry: true,
  maxAnimatedEntries: 1,
  addAutomaticKeepAlives: false,
  itemBuilder: buildTask,
)
```

For constrained hardware, keep the same painted card design but disable the
backdrop sampling layer:

```dart
const NeonScheduleTimelineStyle(
  cardVariant: NeonTimelineCardVariant.liquidCrystal,
  useBackdropFilter: false,
  enableCardParallax: false,
)
```

See [PERFORMANCE.md](PERFORMANCE.md) for production, battery, and hero profiles.

## State-management integration

The package is intentionally state-management agnostic. It works with Bloc,
Cubit, Riverpod, Provider, ChangeNotifier, Redux, or local state because it
only needs immutable input and callbacks.

A callback should update the application state. The rebuilt entry list then
becomes the new visual state. The package never edits an entry object in place.

## Accessibility and motion

- Entry semantics can be supplied through `semanticLabel`.
- Disabled entries suppress interaction.
- Active animation respects `MediaQuery.disableAnimations`.
- Interactive indicators and cards support keyboard activation.
- Logical start and end actions follow text direction.
- Gap, conflict, current-time, and entry-time labels can be localized with builders.
- Set `motionEnabled: false` for golden tests or battery-sensitive surfaces.

## Publication

Read [PUBLISHING.md](PUBLISHING.md) before uploading. At minimum run:

```bash
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

Publishing is permanent. Verify the package name, license ownership,
repository metadata, the screenshot gallery, and the dry-run file list before
the final command.

## License

MIT. See [LICENSE](LICENSE).

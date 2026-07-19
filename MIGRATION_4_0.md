# Migration to 4.0

## Compatibility policy

Version 4.0 adds a neutral API generation. The existing `NeonTimeline`,
`NeonScheduleTimeline`, advanced painters, slidable facade, and public Neon theme
classes remain available.

A 3.x application can update the dependency first and migrate individual screens
later. Do not rewrite a working application in one uncontrolled change.

## Imports

Complete API:

```dart
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
```

Focused 4.x imports:

```dart
import 'package:neon_timeline_flutter/timeline_core.dart';
import 'package:neon_timeline_flutter/timeline_views.dart';
import 'package:neon_timeline_flutter/timeline_themes.dart';
```

Explicit legacy import:

```dart
import 'package:neon_timeline_flutter/neon_legacy.dart';
```

## Entry migration

Before:

```dart
NeonScheduleEntry<Task>(
  id: task.id,
  value: task,
  start: task.start,
  duration: task.duration,
  status: NeonTimelineStatus.pending,
)
```

After:

```dart
TimelineEntry<Task>(
  id: task.id,
  value: task,
  start: task.start,
  duration: task.duration,
  status: TimelineStatus.pending,
)
```

## View migration

Before:

```dart
NeonScheduleTimeline<Task>(
  entries: entries,
  selectedDate: selectedDate,
  itemBuilder: buildTask,
)
```

After:

```dart
TimelineTheme(
  data: TimelineThemeData.modern(),
  child: PlannerView<Task>(
    entries: entries,
    selectedDate: selectedDate,
    itemBuilder: buildTask,
  ),
)
```

## Important differences

- 4.x entry ranges may use either `end` or `duration`.
- Invalid ranges are normalized to a minimum visible duration and remain
  diagnosable in the render plan.
- `TimelineController` is optional and host-owned.
- Modern themes default to restrained, non-continuous rendering.
- The `neon_legacy.dart` entrypoint and `TimelineThemeData.neonLegacy()` remain
  opt-in and preserve the older visual language.
- Backends, state management, persistence, and business rules stay in the host
  application.

## Recommended migration order

1. Upgrade and run all existing 3.x tests without changing widgets.
2. Introduce `TimelineEntry<T>` adapters beside existing entry adapters.
3. Migrate one non-critical screen to `TimelineView` or `PlannerView`.
4. Add golden, keyboard, drag, and accessibility tests.
5. Migrate remaining screens only after visual and performance comparison.

## Advanced planning surfaces

Use `CalendarDayView<T>` when entries need an absolute time canvas with overlap
columns. Use `ResourceTimelineView<T>` for teams, rooms, or machines; its
`resourceHeaderLabel` should be supplied by the host localization layer when the
default English label is inappropriate. Use `DependencyTimelineView<T>` for
predecessor/successor graphs and expose `latestStart`, `slack`, and
`onCriticalPath` from `TimelineDependencyNodeDetails<T>` in custom nodes.

## Localization

Inject package-owned fallback strings from the application's existing
localization system:

```dart
TimelineLocalization(
  data: TimelineLocalizationData(
    resourcesLabel: appStrings.resources,
    noResourcesConfigured: appStrings.noResources,
    noEntriesInTimeRange: appStrings.noEntries,
  ),
  child: timeline,
)
```

No `intl` or generated-localizations dependency is required by the package.

## Glass and blur migration

Glass-capable themes no longer imply one backdrop filter per card. Enable blur
only on the small surfaces that need it:

```dart
TimelineCard(
  title: task.title,
  enableBackdropBlur: true,
)
```

Dense planners and resource boards should keep blur disabled unless profile
measurements on every target platform justify it.

## Validation before release

Run `./tool/verify_release.sh` or `tool/verify_release.ps1`. The gate includes
formatting, analyzer, package and example tests, benchmark execution, Android
and web release builds, and `flutter pub publish --dry-run`.

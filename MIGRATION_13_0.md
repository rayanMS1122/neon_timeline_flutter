# Migration 13.0.0

13.0.0 is additive for existing 12.x consumers.

## Use The New Compact UI

```dart
import 'package:neon_timeline_flutter/timeline_v13.dart';

UltimateStructuredTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  config: const UltimateStructuredTimelineConfig.advancedCompact(),
)
```

## Existing 12.x Code

No migration is required if you already import `timeline_v12.dart` and use
`UltimateStructuredTimelineConfig.production()`. The older production preset
keeps its comfortable density.

## Custom Themes

For a dense theme without using the full config preset:

```dart
final theme = UltimateTimelineThemeData.advancedCompact(
  Theme.of(context).colorScheme,
);
```

You can also use the new `copyWith` methods on entry, gap, drag, resize,
header and root theme token classes.

The compact theme uses `UltimateTimelineAccentPlacement.top`. Custom themes can
retain `leading`, switch to `top`, or choose `none` without replacing the card
widget. `UltimateTimelineDeleteTarget` is also public for custom overlays.

## Fine-Tune Drag And Drop

The 13.0 advanced preset already uses a 5-minute committed drop grid with a
15-minute magnetic neighbour search. If your app needs another balance, set
the fields on `UltimateTimelineInteractionConfig`:

```dart
interaction: UltimateTimelineInteractionConfig(
  dropSnapInterval: Duration(minutes: 10),
  snapDistance: Duration(minutes: 20),
  snapHysteresis: Duration(minutes: 2),
  preferConflictFreeDrop: true,
  allowConflictingDrops: false,
  showConflictPreview: true,
  announceDragChanges: true,
),
```

`dropSnapInterval` controls the final time grid, while `snapDistance` only
controls how far the timeline looks for adjacent-event magnetic targets.
The last two options keep visual and screen-reader feedback aligned with the
chosen drag behavior.

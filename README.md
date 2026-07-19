# Neon Timeline Flutter

[![pub package](https://img.shields.io/pub/v/neon_timeline_flutter.svg)](https://pub.dev/packages/neon_timeline_flutter)

A highly adaptive, responsive timeline and day planner platform for Flutter. It features stable coordinate-correct drag-and-drop, snapping grid, overlap handling, continuous zoom, frame diagnostics, and legacy migration APIs.

---

## Visual Showcase Gallery

Every generation is preserved in the example app. All image links below use
package-relative paths, so the complete gallery is also rendered on pub.dev.

| v16 Compact Mobile | v15 Ultra Planner | v14 Friendly UI |
| :---: | :---: | :---: |
| ![v16 compact mobile planner](assets/screenshots/v16/home.png) | ![v15 ultra planner](assets/screenshots/v15/home.png) | ![v14 friendly timeline UI](assets/screenshots/v14/home.png) |

| v13 Workspace Shell | v12 Neon Design System | v11 Accessible History |
| :---: | :---: | :---: |
| ![v13 multi-panel workspace](assets/screenshots/v13/home.png) | ![v12 neon design system](assets/screenshots/v12/home.png) | ![v11 accessible timeline with undo and redo](assets/screenshots/v11/home.png) |

| v10 Delight Snapping | v9 Zoom & Virtualization | v8 Drag & Resize |
| :---: | :---: | :---: |
| ![v10 magnetic snapping timeline](assets/screenshots/v10/home.png) | ![v9 zoomable virtualized timeline](assets/screenshots/v9/home.png) | ![v8 drag and resize timeline](assets/screenshots/v8/home.png) |

| v7 Structured UI | v6 Planning Engine | v5 Command Center |
| :---: | :---: | :---: |
| ![v7 structured timeline UI](assets/screenshots/v7/home.png) | ![v6 planning engine](assets/screenshots/v6/home.png) | ![v5 command center board](assets/screenshots/v5/board.png) |

### V4 Enterprise Views

| Agenda | Day | Planner |
| :---: | :---: | :---: |
| ![v4 agenda view](assets/screenshots/v4/agenda.png) | ![v4 day view](assets/screenshots/v4/day.png) | ![v4 planner view](assets/screenshots/v4/planner.png) |

| Resources | Roadmap | Studio |
| :---: | :---: | :---: |
| ![v4 resource view](assets/screenshots/v4/resources.png) | ![v4 roadmap view](assets/screenshots/v4/roadmap.png) | ![v4 studio view](assets/screenshots/v4/studio.png) |

### V5 Productivity Views

| Board | Focus | Matrix | Scenarios |
| :---: | :---: | :---: | :---: |
| ![v5 board view](assets/screenshots/v5/board.png) | ![v5 focus view](assets/screenshots/v5/focus.png) | ![v5 matrix view](assets/screenshots/v5/matrix.png) | ![v5 scenarios view](assets/screenshots/v5/scenarios.png) |

### Theme Gallery

| Aurora | Cryogenic | Ember | Hologram |
| :---: | :---: | :---: | :---: |
| ![Aurora theme](assets/screenshots/themes/aurora.png) | ![Cryogenic theme](assets/screenshots/themes/cryogenic.png) | ![Ember theme](assets/screenshots/themes/ember.png) | ![Hologram theme](assets/screenshots/themes/hologram.png) |

| Hyperion | Light | Midnight | Neon |
| :---: | :---: | :---: | :---: |
| ![Hyperion theme](assets/screenshots/themes/hyperion.png) | ![Light theme](assets/screenshots/themes/light.png) | ![Midnight theme](assets/screenshots/themes/midnight.png) | ![Neon theme](assets/screenshots/themes/neon.png) |

| Neural Aurora | Neural Ember | Omniverse |
| :---: | :---: | :---: |
| ![Neural Aurora theme](assets/screenshots/themes/neural_aurora.png) | ![Neural Ember theme](assets/screenshots/themes/neural_ember.png) | ![Omniverse theme](assets/screenshots/themes/omniverse.png) |

| Seeded | Solar Flare | Spectral |
| :---: | :---: | :---: |
| ![Seeded theme](assets/screenshots/themes/seeded.png) | ![Solar Flare theme](assets/screenshots/themes/solar_flare.png) | ![Spectral theme](assets/screenshots/themes/spectral.png) |

---

## Table of Contents
1. [Installation & Requirements](#installation--requirements)
2. [Quick Start (V16 Compact Planner)](#quick-start-v16-compact-planner)
3. [V16 Mapping with Entry Adapters](#v16-mapping-with-entry-adapters)
4. [V16 API Parameter Reference](#v16-api-parameter-reference)
5. [Snapping & Drag-and-Drop Interaction](#snapping--drag-and-drop-interaction)
6. [Theming & Color Customization](#theming--color-customization)
7. [Responsive Breakpoints & Density](#responsive-breakpoints--density)
8. [Virtualization & Performance Policy](#virtualization--performance-policy)
9. [Legacy API Catalog (V15 - V10)](#legacy-api-catalog-v15---v10)

---

## Installation & Requirements

### System Requirements
* **Dart SDK:** `>=3.12.0 <4.0.0`
* **Flutter SDK:** `>=3.44.0`
* **Dependencies:** `flutter_slidable: '>=3.1.2 <4.0.0'`

### Add to Project
Run this command in your package root:
```bash
flutter pub add neon_timeline_flutter
```

Or reference a local path dependency in `pubspec.yaml`:
```yaml
dependencies:
  neon_timeline_flutter:
    path: /path/to/neon_timeline_flutter
```

### Imports
Import the modern V16 unified namespace:
```dart
import 'package:neon_timeline_flutter/timeline_v16.dart';
```

Or keep imports focused on specific library layers:
```dart
import 'package:neon_timeline_flutter/timeline_core.dart';
import 'package:neon_timeline_flutter/timeline_views.dart';
import 'package:neon_timeline_flutter/timeline_themes.dart';
```

---

## Quick Start (V16 Compact Planner)

Initialize the timeline by projecting your local task models onto the timeline engine.

### 1. Define Your Model
```dart
class Task {
  final String id;
  final String title;
  final String? note;
  final DateTime start;
  final Duration duration;
  final IconData icon;
  final NeonPlannerEntryKind kind;

  Task({
    required this.id,
    required this.title,
    this.note,
    required this.start,
    required this.duration,
    required this.icon,
    required this.kind,
  });

  Task copyWith({DateTime? start, Duration? duration}) {
    return Task(
      id: id,
      title: title,
      note: note,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      icon: icon,
      kind: kind,
    );
  }
}
```

### 2. Implement the Widget
```dart
class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final _day = DateTime(2026, 7, 19);

  List<Task> _tasks = [
    Task(
      id: 'sleep',
      title: 'Nachtschlaf',
      note: 'Erholungsphase',
      start: DateTime(2026, 7, 19, 0, 0),
      duration: const Duration(hours: 7, minutes: 30),
      icon: Icons.brightness_3_rounded,
      kind: NeonPlannerEntryKind.sleep,
    ),
    Task(
      id: 'focus',
      title: 'Konzentriertes Arbeiten',
      note: 'Wichtigstes Projekt zuerst',
      start: DateTime(2026, 7, 19, 8, 30),
      duration: const Duration(minutes: 50),
      icon: Icons.center_focus_strong_rounded,
      kind: NeonPlannerEntryKind.focus,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Define the adapter to project models into presentation
    final adapter = NeonPlannerEntryAdapter<Task>(
      id: (task) => task.id,
      start: (task) => task.start,
      duration: (task) => task.duration,
      presentation: (task) => NeonPlannerEntryPresentation(
        title: task.title,
        subtitle: task.note,
        icon: task.icon,
        kind: task.kind,
      ),
    );

    // 2. Render the timeline widget
    return Scaffold(
      body: SafeArea(
        child: NeonPlannerDayTimeline<Task>(
          entries: _tasks,
          adapter: adapter,
          selectedDate: _day,
          fit: NeonPlannerDayFit.scroll,
          autoResponsiveDensity: true,
          dragMode: NeonPlannerDayDragMode.time,
          snapInterval: const Duration(minutes: 5),
          enableResize: true,
          onEntryMove: (proposal) {
            setState(() {
              _tasks = _tasks.map((t) => t.id == proposal.entry.data.id
                  ? t.copyWith(start: proposal.proposedStart)
                  : t).toList();
            });
            return const NeonPlannerMutationResult.accepted('Erfolgreich verschoben.');
          },
          onEntryResize: (proposal) {
            setState(() {
              _tasks = _tasks.map((t) => t.id == proposal.entry.data.id
                  ? t.copyWith(
                      start: proposal.proposedStart,
                      duration: proposal.proposedEnd.difference(proposal.proposedStart),
                    )
                  : t).toList();
            });
            return const NeonPlannerMutationResult.accepted('Zeitdauer angepasst.');
          },
        ),
      ),
    );
  }
}
```

---

## V16 Mapping with Entry Adapters

`NeonPlannerEntryAdapter<T>` adapts any data type `T` to the timeline presentation model without modifying your domain model.

```dart
NeonPlannerEntryAdapter<T>(
  id: (T item) => Object,        // Unique ID for delta updates
  start: (T item) => DateTime,   // Entry start boundary
  duration: (T item) => Duration,// Entry temporal length
  presentation: (T item) => NeonPlannerEntryPresentation, // Styling mapping
)
```

### Presentation Configs (`NeonPlannerEntryPresentation`)
* **`title`:** Primary header label.
* **`subtitle`:** Supporting info (displayed when height is sufficient).
* **`metadata`:** High-density details line.
* **`icon`:** Displayed inside the circular hub timeline markers.
* **`kind`:** Maps to standard category colors and default badges (Sleep, Travel, Focus, Break, etc.).
* **`accentColor`:** Explicit color override bypassing category theme palettes.
* **`completion`:** Fractional value (`0.0` - `1.0`) rendering a progress ring around the entry node.

---

## V16 API Parameter Reference

### `NeonPlannerDayTimeline<T>`

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `entries` | `List<T>` | *Required* | List of domain model items to project. |
| `adapter` | `NeonPlannerEntryAdapter<T>` | *Required* | Projector converting `T` into UI presentations. |
| `selectedDate` | `DateTime` | *Required* | Bounding date for the schedule. |
| `fit` | `NeonPlannerDayFit` | `smart` | Fits layout to `content`, `scroll` internally, or selects automatically (`smart`). |
| `density` | `double` | `1.0` | Vertical density scaler for timeline rows. |
| `autoResponsiveDensity`| `bool` | `false` | Automatically scales rows based on screen width. |
| `dragMode` | `NeonPlannerDayDragMode` | `disabled` | Allows pointer drag: `disabled`, `time` scaling, or `slot` suggestions. |
| `enableResize` | `bool` | `false` | Enables start/end bounds handle dragging. |
| `snapInterval` | `Duration` | `Duration(minutes: 5)`| Intervals to clamp start/end boundaries on drag. |
| `conflictPolicy` | `NeonPlannerConflictPolicy`| `allow` | Overlap behavior: `allow`, `block`, or `delegate`. |
| `showGrabber` | `bool` | `true` | Renders a sheet drawer notch at the container top. |
| `showHeader` | `bool` | `true` | Renders the timeline navigation header. |
| `showMetrics` | `bool` | `true` | Renders KPI summaries (Tasks count, focus hours, sleep tracker). |
| `borderRadius` | `double` | `42.0` | Outer card boundary border radius. Set to `0` for flat layouts. |
| `backgroundColor` | `Color?` | `null` | Widget base container color (defaults to theme surface). |
| `theme` | `NeonPlannerTimelineThemeData?`| `null` | Timeline visual styling values and override colors. |

### `NeonPlannerTimelineConfig` (Advanced Planner Configurations)
* **`zoomLevel`:** Standardized scale preset (e.g. `balanced`, `comfortable`).
* **`snapStrength`:** Magnetic pull radius towards adjacent entries (`soft`, `balanced`, `strong`).
* **`showTimeScrubber`:** Displays duration feedback tags while resizing.
* **`enableHaptics`:** Fires subtle vibration ticks on snap transitions.

---

## Snapping & Drag-and-Drop Interaction

The scheduling engine handles complex temporal mutations out-of-the-box.

```
       [Drag Handle] -> Lift entry
            |
            v
       [Magnetic Snap] -> Pulls boundaries to adjacent gaps/slots
            |
            v
   [Conflict Checking] -> Evaluates overlap policy
            |
            v
     [onEntryMove()] -> Dispatches proposal back to host app
```

### Mutation Callback Contracts
* **`onEntryMove`:** Fired when dragging is finalized. Returns a `NeonPlannerMutationResult`.
* **`onEntryResize`:** Fired when edge resizing completes. Returns a `NeonPlannerMutationResult`.

```dart
onEntryMove: (proposal) {
  if (proposal.hasConflict && _mustBlock) {
    return const NeonPlannerMutationResult.rejected('Kollision blockiert.');
  }
  // Persist model updates...
  return const NeonPlannerMutationResult.accepted('Änderung gespeichert.');
}
```

---

## Theming & Color Customization

### Preset Themes
The package exports visual styling configurations out-of-the-box:
* `NeonPlannerTimelineThemeData.light()` - Balanced, clean professional theme.
* `NeonPlannerTimelineThemeData.dark()` - Ambient, glow-accented dark mode.

### Custom Styling Override
To override colors, shadows, and fonts:
```dart
final customTheme = NeonPlannerTimelineThemeData.light().copyWith(
  accentColor: const Color(0xFF6C5CE7),
  surfaceColor: const Color(0xFFF9F9FB),
  gridColor: const Color(0xFFE2E8F0),
);
```

### Borderless Flat Layout
To integrate the planner seamlessly as a flat page widget (as shown in our Dashboard Showcase):
```dart
NeonPlannerDayTimeline<Task>(
  borderRadius: 0,
  showGrabber: false,
  showHeader: false,
  backgroundColor: Colors.transparent,
  theme: NeonPlannerTimelineTheme.of(context).copyWith(
    shadowColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
  ),
  // ...
)
```

---

## Responsive Breakpoints & Density

The planner dynamically shifts details density depending on available width constraints:

* **Micro Layout (`<360px`):** Drops text fields, merges timelines into single compact line, maps status indicator tags.
* **Compact Layout (`360px` - `480px`):** Renders compact labels and side-by-side gap metrics.
* **Regular Layout (`>480px`):** Full-bleed double track, semantic timelines, expanded task descriptions, and persistent metrics.

---

## Virtualization & Performance Policy

Timelines manage dense data using an adaptive virtualization layer:
* **Lazy Rendering:** Off-viewport entry cards are not instantiated, keeping list layout computations at a constant $O(N)$ with respect to screen size rather than task count.
* **Diagnostics Overlay:** Set `showDiagnostics: true` inside `NeonPlannerTimelineConfig` to audit frame times, layout cache misses, and overlaps during runtime.

---

## Legacy API Catalog (V15 - V10)

All original timeline paradigms are preserved for backwards compatibility.

### V15: Ultra Adaptive Planner
Semantic continuous zoom and magnetic snapping:
```dart
AdaptivePlannerTimeline<T>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  title: 'Ultra Planner v15',
  controller: ultraController,
  config: const UltraTimelineConfig.production(),
  onMove: moveTask,
  onResize: resizeTask,
)
```

### V14: Friendly UI Structured Timeline
Colorful, icon-led presentation with card abstraction:
```dart
FriendlyUiStructuredTimeline<T>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  title: 'Friendly Planner',
  onMove: moveTask,
  entryPresentationBuilder: (context, details) =>
      FriendlyTimelineEntryPresentation(
        details: details,
        title: details.value.toString(),
        icon: Icons.calendar_month,
        tone: FriendlyTimelineIconTone.mint,
      ),
)
```

### V13: Advanced Workspace Shell
Fully responsive workspace with built-in KPI banners, navigation rail, and commands:
```dart
AdvancedUiStructuredTimeline<T>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  title: 'Workspace Planner',
  metrics: const [
    AdvancedTimelineMetric(
      label: 'Completed',
      value: '3 / 5',
      icon: Icons.check_circle_rounded,
    )
  ],
  onMove: moveTask,
)
```

### V12: Ultimate Structured Timeline
Adaptive cards, auto-scroll bounds, and focus gaps:
```dart
UltimateStructuredTimeline<T>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  config: const UltimateStructuredTimelineConfig.production(),
  onMove: moveTask,
)
```

### V10: Delight Snapping Timeline
Coordinate-correct pixel-to-time mapping engine:
```dart
DelightStructuredTimeline<T>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  experience: const StructuredTimelineExperience.delight(),
  onMove: moveTask,
)
```

---

Created and maintained by **rayanMS1122**. Licensed under the MIT License.

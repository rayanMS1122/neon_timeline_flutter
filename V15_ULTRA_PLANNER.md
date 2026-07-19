# Neon Timeline Flutter 15.0 — Ultra Adaptive Planner

Version 15 is a new planner presentation and interaction layer built on the
proven virtualized timeline renderer. It does not replace host models,
repositories, persistence, or business rules.

## Main API

```dart
final uiController = UltraTimelineController();

AdaptivePlannerTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  title: 'Orbit Ultra Planner',
  controller: uiController,
  config: const UltraTimelineConfig.production(),
  onMove: persistMove,
  onResize: persistResize,
  onRangeCommit: persistTimeRange,
)
```

Import `package:neon_timeline_flutter/timeline_v15.dart` for the focused API.
`structured_planner.dart` and the main package entrypoint also export v15.
All earlier version entrypoints remain available.

## Continuous semantic zoom

`UltraTimelineController` exposes two separate listenables:

- `zoomPosition`: continuous 0–1 slider and gesture position;
- `zoomLevel`: one of six semantic density levels.

Moving the thumb updates `zoomPosition` continuously. The timeline composition
only changes when a semantic threshold is crossed. This keeps controls smooth
without rebuilding all timeline content for every pointer pixel.

Zoom inputs include the public slider, plus/minus controls, Ctrl/Cmd+wheel and
trackpad pan/zoom events. Host applications may use the controller directly.

## Magnetic snapping

`UltraTimelineSnapStrength` provides `off`, `soft`, `balanced`, and `strong`
levels. `UltraMagneticSnapEngine` is Flutter-free and supports ranked targets,
direction weighting, grid fallback and hysteresis against snap flicker.

The v15 wrapper projects the selected strength into the existing production
drag engine. Application mutations still occur only through host callbacks.

## Time-range editor

`UltraTimeRangeSlider` provides:

- two draggable handles;
- direct start and end time pickers;
- minimum-duration enforcement;
- discrete minute steps;
- blocked-range visualization;
- semantic clock labels for assistive technology;
- isolated `UltraTimeRangeEditorState` updates.

Opening and editing the range overlay does not notify zoom or snap listeners.

## Adaptive cards and drag surfaces

`UltraTimelineEntryCard` chooses micro, compact, standard, or detailed content
from the real entry height and semantic zoom level. Drag feedback, origin
placeholder and bottom status are separate widgets and separate repaint areas.

The `handleOnly` activation value presents a handle-oriented UI, but strict
handle hit-testing remains dependent on the underlying renderer. The compact
preset therefore uses the reliable long-press policy by default.

## Diagnostics

`UltraTimelineDiagnosticsOverlay` can show recent average build and raster
frame durations, entry count, zoom and snap state. It is intended for local
profile work and can be disabled in production with `showDiagnostics: false`.

## Host ownership

The package does not persist tasks and does not introduce repositories, Cubits,
or application state into widgets. The host remains responsible for move,
resize, completion, insertion, deletion and range-editor commits.

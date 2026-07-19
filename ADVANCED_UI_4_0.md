# Advanced UI 4.0

## Purpose

The 4.x UI is a neutral planning surface, not a recolored copy of the legacy
Neon renderer. Applications keep ownership of models, state, persistence,
localization, and authorization. The package provides deterministic layout,
interaction surfaces, and design tokens.

## Production surfaces

### `CalendarDayView<T>`

An absolute-positioned day canvas with hour and half-hour grid lines, overlap
columns, an optional current-time marker, selection semantics, and a static
painter layer. It creates no timer or ticker.

```dart
CalendarDayView<Task>(
  entries: entries,
  selectedDate: selectedDate,
  timelineController: controller,
  startHour: 7,
  endHour: 20,
  itemBuilder: (context, details) {
    return TimelineCard(
      title: details.entryDetails.entry.value.title,
      timeLabel: formatTime(details.entryDetails.displayStart),
      status: details.entryDetails.entry.status,
      selected: controller.isSelected(details.entryDetails.entry.id),
    );
  },
)
```

### `ResourceTimelineView<T>`

A horizontally scrollable, vertically lazy resource board for teams, people,
rooms, machines, and other capacity-limited resources. Entries are indexed by
resource once. Capacity conflicts are computed by an event sweep and exposed to
each entry builder. A synchronized time header makes the board readable, and
`resourceHeaderLabel` lets applications localize or replace the leading label.

```dart
ResourceTimelineView<Task>(
  resources: resources,
  entries: entries,
  selectedDate: selectedDate,
  itemBuilder: (context, details) {
    return TimelineCard(
      title: details.entryDetails.entry.value.title,
      status: details.isOverbooked
          ? TimelineStatus.error
          : details.entryDetails.entry.status,
    );
  },
)
```

### `DependencyTimelineView<T>`

A pan-and-zoom dependency map driven by `TimelineDependencyEngine`. Nodes are
placed in deterministic topological layers. One static painter renders
connectors, issue edges, and only the dependencies that are actually critical.
Node builders receive earliest and latest scheduling information, per-entry
slack, critical-state information, and graph issues.

### `TimelineWorkspace`

A responsive application shell with a navigation rail on wide layouts, bottom
navigation on compact layouts, an optional toolbar, and an optional inspector.
It respects the operating-system reduced-motion preference.

### Reusable product components

- `TimelineBackdrop`
- `TimelinePanel`
- `TimelineMetricCard`
- `TimelineStatusBadge`
- `TimelineSectionHeader`
- `TimelineCard`

Backdrop blur on cards and panels is deliberately disabled by default, even for
a glass-capable theme. Dense lists and dashboards must opt in per surface.

## Design systems

The implemented neutral presets are:

- Modern
- Minimal
- Editorial
- Glass
- Enterprise
- High Contrast
- Dark Professional
- Aurora
- Soft Professional
- Neon Legacy
- fully custom `TimelineThemeData`

The legacy Neon API remains available and is not silently replaced.

## Localization

Package-owned empty-state and resource-header strings are supplied through
`TimelineLocalizationData`. Applications can inject translations from their
existing localization layer without adding a package-mandated dependency.

## Example studio

`example/lib/screens/v4_platform_showcase.dart` is an interactive planning
studio rather than a single card demo. It contains:

- an operational dashboard using real engine analytics;
- a day canvas;
- a multi-resource capacity board;
- a planner with move commands and undo/redo;
- a roadmap;
- an agenda;
- a dependency map;
- live search and status filters;
- date navigation;
- selection inspector;
- runtime theme switching;
- mobile, tablet, and desktop workspace behavior.

Older Neon schedules, effects, generic timelines, and the 500-row performance
showcase remain reachable from the example app.

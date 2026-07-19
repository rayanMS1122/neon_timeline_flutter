# Advanced UI 13.0

Version 13 introduces a public workspace UI on top of the existing production
timeline engine. The old 13.x surface only re-exported 12.x and changed a few
compact tokens. The new surface adds actual reusable architecture.

## Main API

```dart
AdvancedUiStructuredTimeline<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  title: 'Orbit Planner',
  subtitle: 'A focused day without calendar noise',
  metrics: const [
    AdvancedTimelineMetric(
      label: 'Scheduled',
      value: '4h 45m',
      icon: Icons.schedule_rounded,
      emphasized: true,
    ),
  ],
  onMove: moveTask,
  onResize: resizeTask,
  onOpen: openTask,
)
```

`AdvancedUiStructuredTimeline<T>` composes the existing
`UltimateStructuredTimeline<T>` with a responsive shell. It does not own
repositories, state management, routes, persistence or application models.

## Public components

- `AdvancedTimelineWorkspace`
- `AdvancedTimelineCommandBar`
- `AdvancedTimelineDateNavigator`
- `AdvancedTimelineMetricStrip`
- `AdvancedTimelineMetricCard`
- `AdvancedTimelineStatusPill`
- `AdvancedTimelineQuickAction`
- `AdvancedTimelineNavigationRail`
- `AdvancedTimelineMobileNavigation`
- `AdvancedTimelinePanel`
- `AdvancedTimelineUiTheme`
- `AdvancedTimelineUiThemeData`

## Responsive behavior

Below the compact breakpoint the command bar stacks into two rows and the date
navigator expands to the available width. Metrics scroll horizontally instead
of wrapping into an overflow. The desktop navigation rail appears only above
the navigation breakpoint. All controls retain explicit tooltips, semantics and
large hit targets.

## State communication

The workspace status model distinguishes ready, saving, saved, offline,
warning and failed states. Every state has text and an icon; color is never the
only signal. The all-in-one widget maps existing persistence states onto this
model automatically, while allowing an explicit override.

## Theming

`AdvancedTimelineUiThemeData.fromColorScheme` provides balanced light and dark
palettes. `operations` is denser for desktop dashboards and `focus` is more
spacious for touch-first planner apps. All workspace geometry and colors are
public tokens.

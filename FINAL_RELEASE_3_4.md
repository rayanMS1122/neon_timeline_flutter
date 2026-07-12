# neon_timeline_flutter 3.4.0 — final integration candidate

This release is intended to be the stable base for application integration,
not another visual experiment.

## What remains visually compatible

- existing normal timeline widgets;
- all advanced neon indicator and connector effects;
- glass, prismatic, holographic, and liquid-crystal cards;
- schedule gaps, overlap/conflict UI, time rail, and current-time marker;
- slide, dismiss, drag, day pager, theme, builder, sliver, and accessibility APIs;
- the original all-in-one package import.

## What was added

- adaptive performance policy and explicit production profiles;
- central sampled motion with lifecycle/visibility/scroll sleep states;
- optional `NeonTimelineSurface`, `NeonTimelineHeader`,
  `NeonTimelineBadge`, and `NeonTimelineEmptyState`;
- split imports for core, advanced rendering, and slidable APIs;
- `dataRevision` and `animatedItemIndexes` optimization hooks;
- robust async slide-action state;
- complete multi-screen example and CI Web release build.

## Recommended app defaults

```dart
NeonScheduleTimeline<MyTask>(
  entries: entries,
  selectedDate: selectedDate,
  dataRevision: state.revision,
  performance: const NeonTimelinePerformanceConfig.adaptive(),
  addAutomaticKeepAlives: false,
  itemBuilder: (context, details) {
    return MyExistingTaskCard(task: details.entry.value);
  },
)
```

Use `highQuality()` only for short hero/showcase timelines. Long real-world
lists should use `adaptive()` or `balanced()`.

# Structured Timeline 7.0

Version 7.0 turns the reusable planning engine from 6.x into a package-owned
timeline surface designed around the real Structured planner interaction.

## What moved into the package

- compact start/end time rail;
- marker capsule;
- task card;
- current/next banner;
- free-time insertion rows;
- completion control;
- long-press drag and lifted preview;
- configurable snap grid;
- haptic feedback only when the snapped value changes;
- edge auto-scroll;
- day-bound clamping;
- conflict preview and overlap bridges;
- optional delete drop target;
- keyboard movement;
- light and dark design tokens;
- one lifecycle-aware planner clock.

## What stays in the application

- the application task model;
- Cubit, Bloc, Provider, Riverpod, or another state layer;
- persistence;
- recurring occurrence write rules;
- task sheets and edit screens;
- date selector and application navigation;
- backend and analytics.

## Recommended integration

Use `StructuredTimelinePlanner<T>` when the screen has a raw application-owned
task list. It uses `TimelinePlannerEngine<T>` and the existing adapters.

Use `StructuredTimelineView<T>` when the app already prepares a
`TimelineDayPlan<T>` from `TimelinePlannerWindow<T>`.

```dart
StructuredTimelinePlanner<Task>(
  values: state.tasks,
  engine: plannerEngine,
  selectedDate: state.selectedDate,
  dataRevision: state.revision,
  titleBuilder: (entry) => entry.value.title,
  subtitleBuilder: (entry) => entry.value.category,
  progressBuilder: (entry) => entry.value.progress,
  onEntryTap: (context, details) {
    showTaskDetailSheet(context, details.value);
  },
  onComplete: (context, details) {
    taskCubit.toggleTaskComplete(details.value.id);
  },
  onMove: (context, details) {
    taskCubit.moveTask(
      details.value.id,
      details.preview.start,
    );
  },
  onInsert: (context, gap) {
    openAddTask(startTime: gap.start);
  },
)
```

## Drag behavior

The default policy uses a five-minute snap. During a drag the package:

1. creates one reschedule session;
2. translates pointer movement into timeline minutes;
3. includes scroll movement in the calculated delta;
4. clamps the complete entry to the day bounds;
5. queries conflicts through the temporal index;
6. keeps edge auto-scroll running while the pointer remains near an edge;
7. emits haptics only when the snap index changes;
8. shows a lifted overlay and time badge;
9. returns a `TimelineDropResult<T>` to the host.

The package does not persist the move. The callback is the transaction boundary.

## Customization

`StructuredTimelineStyle` controls layout and visual tokens. Applications can
replace the card, marker, trailing content, strings, title, subtitle, progress,
time formatter, and duration formatter without replacing the drag engine or
timeline rail.

# Composition Guide 9.0

```dart
StructuredTimelineScaffold(
  appBar: const StructuredTimelineAppBar(
    title: 'My planner',
  ),
  header: StructuredTimelineDayHeader(
    date: selectedDate,
    style: style,
    metrics: StructuredTimelineMetrics.fromPlan(plan),
  ),
  body: StructuredTimelineViewport<Task>(
    plan: plan,
    controller: controller,
    entryStyle: const StructuredTimelineEntryStyle.comfortable(),
    gapLayout: const StructuredTimelineGapLayout.hybrid(),
    onMove: persistMove,
    onResize: persistResize,
    onInsert: openCreateTask,
  ),
  floatingAction: StructuredTimelineFloatingAddButton(
    onPressed: openCreateTask,
  ),
)
```

The application can replace any individual component without forking the
engine or copying private widgets.

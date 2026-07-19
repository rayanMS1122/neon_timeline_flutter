# Advanced Structured Timeline 8.0

## Basic integration

```dart
final controller = StructuredTimelineController<Task>();
final mutations = TimelineMutationCoordinator<Task>();

AdvancedStructuredTimelinePlanner<Task>(
  values: tasks,
  engine: plannerEngine,
  selectedDate: selectedDate,
  dataRevision: state.revision,
  controller: controller,
  mutationCoordinator: mutations,
  layout: const StructuredTimelineLayout.comfortable(),
  titleBuilder: (entry) => entry.value.title,
  subtitleBuilder: (entry) => entry.value.category,
  onMove: (context, details) async {
    await repository.move(
      details.value.id,
      details.preview.start,
    );
  },
  onResize: (context, details) async {
    await repository.updateRange(
      details.value.id,
      details.preview.start,
      details.preview.end,
    );
  },
  onInsert: (context, gap) {
    openCreateTask(initialStart: gap.start, initialEnd: gap.end);
  },
)
```

## Controller

The controller can select and focus entries, jump to now or a specific entry, keep an entry visible, zoom, request keyboard-style time nudges and publish targeted invalidations. It never writes app data.

## Resize

Start and end handles appear for selected or hovered movable entries. The pure resize session applies the configured snap, duration limits, day bounds and conflict policy before a request reaches the host application.

## Async mutations

Move, resize, completion and deletion callbacks are coordinated per entry. Duplicate submissions are rejected while the first operation is in flight. Errors are returned to `onMutationError`; app data remains host-owned.

## Builder-first rendering

Applications may replace cards, gaps, labels, insight, conflict bridges, drag feedback, placeholders and delete targets. Package defaults remain usable when builders are omitted.

## Version gallery

The example starts with a searchable catalog that keeps the 1.x–3.x APIs and every 4.0–8.0 showcase accessible. It no longer hides older work behind one overloaded popup menu.

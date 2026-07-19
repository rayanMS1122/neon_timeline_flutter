# Migration to 8.0

8.0 is additive. Existing 7.x code continues to compile.

To adopt the advanced layer:

1. Keep the same `TimelinePlannerEngine<T>` and adapters.
2. Replace `StructuredTimelinePlanner<T>` with `AdvancedStructuredTimelinePlanner<T>` when controller or resize support is needed.
3. Pass `onResize` to enable resize handles.
4. Optionally provide `StructuredTimelineController<T>` and `TimelineMutationCoordinator<T>` from application state.
5. Keep all repository writes in the callbacks.

```dart
AdvancedStructuredTimelinePlanner<Task>(
  values: tasks,
  engine: engine,
  selectedDate: selectedDate,
  controller: controller,
  onMove: saveMove,
  onResize: saveResize,
)
```

No model, Cubit, repository or database migration is required.

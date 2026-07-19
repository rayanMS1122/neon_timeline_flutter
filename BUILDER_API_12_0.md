# Builder API 12.0

12.x details are immutable and do not expose render objects:

- `UltimateTimelineEntryDetails<T>`
- `UltimateTimelineGapDetails<T>`
- `UltimateTimelineDragDetails<T>`
- `UltimateTimelineResizeDetails<T>`
- `UltimateTimelineConflictDetails<T>`
- `UltimateTimelineViewportDetails`
- `UltimateTimelineHeaderDetails`

The unified entry builder is:

```dart
Widget buildEntry(
  BuildContext context,
  UltimateTimelineEntryDetails<Task> details,
) {
  return MyTaskCard(task: details.value);
}
```

Pass it as `ultimateEntryBuilder`. The older
`AdvancedStructuredTimelineEntryBuilder<T>` remains available through
`entryBuilder` and takes precedence when explicitly supplied.


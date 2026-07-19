# Release report — 14.1.0

## Result

Version 14.1 fixes the public-details compile failure and restructures the
friendly UI integration around explicit presentation and rebuild boundaries.

## Public additions

- `FriendlyTimelineEntryPresentation<T>`
- `FriendlyTimelineEntryPresentationBuilder<T>`
- `FriendlyTimelineDragUiState`
- `FriendlyTimelineDragOverlay`
- `FriendlyUiStructuredTimeline.entryPresentationBuilder`
- `FriendlyUiStructuredTimeline.onCancelDrag`
- Extended `UltimateStructuredTimelineConfig.copyWith`

## Compatibility

Existing 1.x–14.0 exports remain available. The original
`FriendlyTimelineEntryCard` constructor and raw-state
`FriendlyTimelineDragCompanion` constructor remain supported. The old
`friendly_timeline_components.dart` path remains a public barrel.

## Performance change

The all-in-one widget no longer calls `setState` for each drag update. The live
drag companion listens to a small `ValueNotifier` projection while the timeline
subtree remains stable.

## Validation limitation

Flutter and Dart executables are not installed in the generation environment.
No successful `flutter analyze`, `flutter test` or browser build is claimed.
Run the commands in `VALIDATION_14_1.md` locally before publishing.

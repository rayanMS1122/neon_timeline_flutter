# Friendly Timeline 14.1

Version 14.1 keeps the friendly visual system and replaces the original tightly
coupled integration with a presentation layer and rebuild-isolated drag chrome.

## New public API

- `FriendlyUiStructuredTimeline<T>`
- `FriendlyTimelineWorkspace`
- `FriendlyTimelineTopBar`
- `FriendlyTimelineNavigationDock`
- `FriendlyTimelineMobileDock`
- `FriendlyTimelineMetricCard`
- `FriendlyTimelineIconButton`
- `FriendlyTimelineEntryCard<T>`
- `FriendlyTimelineDragFeedback<T>`
- `FriendlyTimelineDragPlaceholder<T>`
- `FriendlyTimelineDragCompanion`
- `FriendlyTimelineUiThemeData`
- `FriendlyTimelineIconTone`
- `FriendlyTimelineEntryPresentation<T>`
- `FriendlyTimelineEntryPresentationBuilder<T>`
- `FriendlyTimelineDragUiState`
- `FriendlyTimelineDragOverlay`

## Architecture

The public all-in-one widget now has four explicit layers:

1. `TimelinePlannerEngine<T>` adapts application data.
2. `UltimateStructuredTimeline<T>` owns geometry and interactions.
3. `FriendlyTimelineEntryPresentation<T>` converts entry details into display-ready labels, icons and tones.
4. `FriendlyTimelineWorkspace` renders responsive application-independent chrome.

The source is split by responsibility under `lib/src/v14/`: presentation models, theme tokens, entry cards, drag feedback, drag companion, header, metrics, navigation, panels and workspace composition.

## Performance

`FriendlyUiStructuredTimeline<T>` stores drag chrome state in a `ValueNotifier<FriendlyTimelineDragUiState>`. The notifier is consumed by `FriendlyTimelineDragOverlay`, so high-frequency pointer updates do not call `setState` on the all-in-one widget and do not rebuild the timeline subtree. Equal drag projections are ignored by `ValueNotifier` because the projection implements value equality.

## Entry presentation

Use `entryPresentationBuilder` when application labels, icons or colors require custom logic. The default resolver only reads public entry details and metadata. The card never reaches into repositories, cubits or app-specific models.

## Interaction changes

The default v14 preset uses a faster but still deliberate long-press, visible drag handles, a guided floating card, a live destination ribbon, a softer origin marker, smart-snap language, conflict icons and a bottom drag companion.

The lower-level `UltimateStructuredTimeline<T>` now exposes optional `dragFeedbackBuilder` and `dragPlaceholderBuilder` parameters. Existing callers remain source-compatible.

## Compatibility

All v1-v13 exports remain available. `structured_planner.dart` now targets v14, while `timeline_v13.dart` continues to work unchanged.

## Validation note

Run the following in an environment with Flutter installed:

```bash
flutter clean
flutter pub get
dart format lib test example/lib
flutter analyze
flutter test
flutter build web --release
```

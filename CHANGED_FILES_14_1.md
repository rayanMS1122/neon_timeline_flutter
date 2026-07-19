# Changed files — 14.1.0

## Compiler fix

- `lib/src/v14/widgets/friendly_ui_structured_timeline.dart`
  - Replaced invalid `effectiveStart` / `effectiveEnd` access on
    `UltimateTimelineEntryDetails<T>` with `visibleStart` / `visibleEnd`.

## Architecture

- `lib/src/v14/models/friendly_timeline_presentation_models.dart`
  - Added display-ready entry presentation and drag UI projection models.
- `lib/src/v14/widgets/friendly_ui_structured_timeline.dart`
  - Added `entryPresentationBuilder` and isolated drag-state notification.
- `lib/src/v12/models/ultimate_timeline_config.dart`
  - Added an extended, field-preserving `copyWith`.
- `lib/src/v14/widgets/friendly_timeline_workspace.dart`
  - Reduced to workspace composition and stable child placement.
- `lib/src/v14/widgets/friendly_timeline_header.dart`
- `lib/src/v14/widgets/friendly_timeline_metrics.dart`
- `lib/src/v14/widgets/friendly_timeline_navigation.dart`
- `lib/src/v14/widgets/friendly_timeline_panel.dart`
- `lib/src/v14/widgets/friendly_timeline_entry_card.dart`
- `lib/src/v14/widgets/friendly_timeline_drag_feedback.dart`
- `lib/src/v14/widgets/friendly_timeline_drag_companion.dart`
  - Split the previous large component files by responsibility.
- `lib/src/v14/widgets/friendly_timeline_components.dart`
  - Converted to a compatibility barrel.
- `lib/timeline_v14.dart`
  - Exported the new public modules.

## Tests and documentation

- `test/v14/friendly_ui_test.dart`
- `README.md`
- `CHANGELOG.md`
- `V14_FRIENDLY_UI.md`
- `V14_ARCHITECTURE.md`
- `VALIDATION_14_1.md`
- `RELEASE_REPORT_14_1.md`
- `pubspec.yaml`
- `example/pubspec.yaml`

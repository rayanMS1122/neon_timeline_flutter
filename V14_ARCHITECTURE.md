# Version 14.1 architecture

## Design goal

Version 14.1 separates application data, timeline mechanics, presentation and
workspace chrome. A host application can replace one layer without forking the
others.

## Layer map

### 1. Application adapter

`TimelinePlannerEngine<T>` converts host values into neutral `TimelineEntry<T>`
objects. Repositories, cubits, databases and navigation remain outside the
package.

### 2. Interaction and geometry

`UltimateStructuredTimeline<T>` owns day planning, visual coordinates,
virtualized rows, selection, drag, resize, snapping, conflicts and auto-scroll.

### 3. Presentation model

`FriendlyTimelineEntryPresentation<T>` is the display-ready contract for the
friendly card. It contains title, subtitle, formatted time, progress, icon,
tone and semantics. `entryPresentationBuilder` is the app-facing extension
point.

The default resolver reads only public `UltimateTimelineEntryDetails<T>`
properties. Visible segment time is obtained through `visibleStart` and
`visibleEnd`; it never assumes internal getters.

### 4. Workspace chrome

`FriendlyTimelineWorkspace` composes the header, metrics, timeline panel,
desktop navigation, mobile navigation and drag companion. These widgets are
public and independent from the all-in-one API.

## Source layout

```text
lib/src/v14/
  models/
    friendly_timeline_ui_models.dart
    friendly_timeline_presentation_models.dart
  theme/
    friendly_timeline_ui_theme.dart
  widgets/
    friendly_ui_structured_timeline.dart
    friendly_timeline_workspace.dart
    friendly_timeline_header.dart
    friendly_timeline_metrics.dart
    friendly_timeline_navigation.dart
    friendly_timeline_panel.dart
    friendly_timeline_entry_card.dart
    friendly_timeline_drag_feedback.dart
    friendly_timeline_drag_companion.dart
    friendly_timeline_components.dart
```

`friendly_timeline_components.dart` is a small compatibility barrel for entry
and drag presentation widgets.

## Rebuild boundaries

The v14.0 implementation called `setState` on the all-in-one widget for every
drag-state update. That rebuilt workspace chrome and recreated the complete
`UltimateStructuredTimeline` subtree while the pointer moved.

Version 14.1 projects package drag state into
`FriendlyTimelineDragUiState` and writes it to a `ValueNotifier`. Only
`FriendlyTimelineDragOverlay` listens to this notifier. Timeline geometry and
entry widgets are not rebuilt by companion-bar updates.

The projection implements value equality, so identical updates are ignored by
`ValueNotifier`.

## Configuration safety

`UltimateStructuredTimelineConfig.copyWith` now preserves every extended field:
interaction settings, contrast, responsive header, current-time behavior,
keyboard behavior, live-data stability and visual density. Workspace-specific
changes no longer reconstruct the configuration manually and accidentally drop
future fields.

## Extension rules

- Put app-specific labels and icon decisions in `entryPresentationBuilder`.
- Put geometry and interaction changes below `UltimateStructuredTimeline`.
- Put reusable visual tokens in `FriendlyTimelineUiThemeData`.
- Add workspace controls as independent widgets, not private application code.
- Do not read `base` unless no public detail getter exists.
- Do not call `setState` for high-frequency pointer updates outside the active
  interaction layer.

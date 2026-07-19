# Test Report 5.0.0

## Added test sources

- `timeline_temporal_index_v5_test.dart`
- `timeline_recurrence_v5_test.dart`
- `timeline_scenario_v5_test.dart`
- `timeline_views_v5_test.dart`
- `timeline_theme_and_command_v5_test.dart`

## Covered behavior

- intersecting range queries;
- next-entry lookup;
- combined text, date, status, and resource filters;
- daily and weekly recurrence;
- duration and occurrence identity preservation;
- added, removed, moved, and status-changed scenario entries;
- Board rendering;
- Matrix rendering;
- Overview rendering;
- Horizon, Obsidian, Paper, and Signal theme tokens;
- command filtering and execution.

## Existing regression suite

The existing 4.x and legacy tests remain in the package. The complete test tree
contains render-plan, layout, analytics, resource, dependency, controller,
theme, interaction, widget, performance, and release regression sources.

## Execution status

Flutter and Dart are not installed in the environment used to produce this
archive. The test sources were statically inspected, but `flutter test` was not
executed and is not reported as passed.

Run:

```bash
flutter pub get
flutter analyze
flutter test --coverage
```

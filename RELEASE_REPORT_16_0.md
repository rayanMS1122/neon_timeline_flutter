# Neon Timeline Flutter 16.0 release report

## Scope

Version 16.0.0 integrates the finalized compact mobile planner from
`neon_planner_timeline` 0.7.0 into the established `neon_timeline_flutter`
package. It does not remove or rewrite the legacy 1.x-15.x APIs.

## Public API

- Added `timeline_v16.dart` as the focused v16 entrypoint.
- Exported v16 through `neon_timeline_flutter.dart`.
- Updated `structured_planner.dart` to point to the latest v16 layer.
- Preserved all previous exports transitively through `timeline_v15.dart`.
- Kept the existing `NeonPlanner*` names to make migration from 0.7.0 direct.

## Integrated behavior

- Compact `micro`, `compact`, and `regular` widget geometry based on actual
  `LayoutBuilder` width.
- Free horizontal drag feedback with vertical movement mapped to clock time.
- Stable row geometry and frozen overlap lanes during drag and resize.
- Safe-area-bounded drag feedback, compact time lens, small resize visuals, and
  large invisible hit targets.
- Smart content fitting, overlap presentation, move/resize confirmation, undo,
  reduced motion, keyboard interaction, and responsive text behavior.

## Release structure

- Implementation: `lib/src/v16/`
- Public entrypoint: `lib/timeline_v16.dart`
- Regression tests: `test/v16/`
- Example: `example/lib/screens/v16/`
- Documentation: `docs/v16/`
- Benchmark: `benchmark/v16_planner_viewport_benchmark.dart`

## Validation status

Static syntax, local import/part ownership, YAML, export, package-path, archive,
and source-tree checks are included in the delivery report. Full Flutter
analysis, tests, builds, and `pub publish --dry-run` still require a Flutter SDK
and must pass before the package is published.

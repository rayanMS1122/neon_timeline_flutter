# Release Report 5.0.0

## Implemented

- version advanced to 5.0.0;
- temporal interval index;
- compound query and facets;
- daily, weekly, and monthly recurrence expansion;
- immutable scenario comparison;
- four new design systems;
- focus, board, matrix, overview, scenario, and command-palette UI;
- new 5.0 Command Center example;
- benchmark coverage for index and query;
- unit and widget test sources;
- migration, architecture, API, UI, and performance documentation.

## Change size

Against the corrected 4.0.0 advanced archive, the final source diff contains
40 changed paths, approximately 4,100 inserted lines, and 62 removed lines.

## Compatibility

- 4.x neutral APIs remain exported;
- legacy Neon APIs remain exported;
- no backend or state-management dependency added;
- no push or publication performed.

## Validation state

The source tree has been checked for:

- balanced delimiters;
- resolvable relative imports and exports;
- YAML presence;
- generated build artifacts;
- ZIP integrity.

Flutter and Dart are unavailable in the build environment used to create this
archive. Therefore analyzer, tests, platform builds, benchmarks, and publish
dry-run are not reported as passed.

Run `tool/verify_release.sh` or `tool/verify_release.ps1` in an installed Flutter
environment before release.

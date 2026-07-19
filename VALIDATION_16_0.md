# Validation — 16.0.0

## Passed in this delivery environment

- Parsed 324 Dart files with tree-sitter Dart without syntax errors.
- Parsed package, example, analysis, and CI YAML files.
- Verified package and example versions are both `16.0.0`.
- Verified all local Dart import, export, and `part` targets exist.
- Verified all `package:neon_timeline_flutter/...` imports resolve.
- Verified no old `package:neon_planner_timeline/...` imports remain.
- Verified all 38 compact planner source files were copied byte-for-byte into
  `lib/src/v16/`.
- Verified no public symbol collision between v16 and the previous source tree.
- Verified the focused and complete package entrypoints export v16.
- Verified the final ZIP can be extracted and matches the packaged source tree.

## Required before publication

The following commands were not executed because this environment has no Dart
or Flutter SDK:

```bash
./tool/verify_release.sh
```

That release gate runs dependency resolution, formatting, analysis, tests,
coverage, benchmarks, `flutter pub publish --dry-run`, example analysis/tests,
and Android/web release builds.

Do not publish 16.0.0 until that gate passes on Flutter 3.44.0 or newer.

# Version 16 file map

## Public entrypoints

```text
lib/neon_timeline_flutter.dart
lib/structured_planner.dart
lib/timeline_v16.dart
```

`timeline_v16.dart` exports the compact planner API and re-exports
`timeline_v15.dart`, so the focused latest entrypoint retains all earlier public
APIs.

## Version 16 implementation

```text
lib/src/v16/api/
lib/src/v16/domain/
lib/src/v16/geometry/
lib/src/v16/interaction/
lib/src/v16/presentation/
lib/src/v16/rendering/
lib/src/v16/theme/
lib/src/v16/viewport/
lib/src/v16/widgets/
```

Application code should use the public entrypoints instead of importing files
below `lib/src/v16/` directly.

## Validation and examples

```text
test/v16/
benchmark/v16_planner_viewport_benchmark.dart
example/lib/screens/v16/v16_compact_planner_showcase.dart
docs/v16/
tool/verify_release.sh
tool/verify_release.ps1
.github/workflows/ci.yml
```

## Release documentation

```text
CHANGELOG.md
CHANGED_FILES_16_0.md
MIGRATION_16_0.md
RELEASE_REPORT_16_0.md
PUBLISHING.md
```

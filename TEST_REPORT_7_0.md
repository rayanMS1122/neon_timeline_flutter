# Test Report 7.0

## Added test sources

- Structured light/dark style token validation;
- entry and interior-gap rendering;
- stable keyed completion action wiring;
- existing v6 reschedule tests continue to cover five-minute snapping,
  clamping, conflicts, delete disposition, and auto-scroll policy;
- export graph, relative import, YAML, artifact, and compatibility scans.

## Static result

The final tree contains 151 Dart files and 33 test files. The static validation
found no delimiter, relative-import/export, YAML, generated-artifact, public
symbol collision, or v7 Flutter-compatibility issue.

## Mandatory SDK checks before release

Flutter and Dart are not installed in the current runtime. Run:

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build apk --release
flutter build web --release
flutter pub publish --dry-run
```

The repository's `tool/verify_release.sh` remains the required release gate.

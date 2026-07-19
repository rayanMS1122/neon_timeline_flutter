# Validation 13.0

## Completed static checks

- Parsed all Dart sources in `lib`, `test` and `example/lib` with a Dart
  tree-sitter grammar.
- Result: 225 Dart files parsed, 0 syntax-error files.
- Checked all relative `import`, `export` and `part` directives.
- Result: 0 missing relative targets.
- Verified the v13 entrypoint exports the new models, theme, workspace widgets,
  all-in-one timeline and the complete 12.x API.
- Verified `structured_planner.dart` now exposes the v13 entrypoint while v13
  continues to export every earlier API.
- Verified the final ZIP with the archive integrity test.

## Flutter validation status

Flutter and Dart executables are not installed in this environment. Therefore
these commands could not be executed here:

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
flutter pub publish --dry-run
```

No successful compiler, test, build or performance result is claimed. The
static checks above are useful but are not a replacement for the Flutter tool
chain.

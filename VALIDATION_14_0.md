# Validation 14.0

## Completed static checks

- Parsed every Dart file in `lib`, `test`, and `example/lib` with the Dart tree-sitter grammar.
- Result: 233 parsed files, 0 syntax errors.
- Resolved every relative Dart import/export/part URI.
- Result: 0 missing relative URIs.
- Verified the v14 entrypoint exports the models, theme, components, workspace, all-in-one widget, and v13 compatibility layer.
- Searched for the invalid generic const drag-state pattern used by earlier builds.
- Result: no `const StructuredTimelineDragState<T>` expression in the release tree.
- Checked for packaged `.dart_tool`, `build`, and IDE project artifacts.
- Result: none found.

## Not executed in this environment

Flutter and Dart executables are not installed in the execution container. The following commands were therefore not claimed as successful:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
flutter pub publish --dry-run
```

Run them locally before publishing.

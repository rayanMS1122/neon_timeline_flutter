# Release validation — 3.3.0

Completed in this workspace:

- `pubspec.yaml` and `analysis_options.yaml` parsed;
- local Dart imports and exports resolved;
- Dart files passed a string/comment-aware structural scan;
- no direct painter blur call remains outside `NeonBlur`;
- source archives exclude build, `.dart_tool`, Git, IDE, and lock artifacts;
- generated ZIP integrity checked.

Required on a machine with Flutter:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter run --profile -d chrome
flutter run --profile -d <slowest-native-device>
dart pub publish --dry-run
```

Do not publish if any command fails. Compare profile traces against 3.2.1 using
the same device, renderer, data set, and active-entry count.

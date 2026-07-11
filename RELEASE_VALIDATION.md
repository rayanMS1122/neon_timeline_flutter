# Release validation — 3.2.0

Completed in this workspace:

- package and example YAML parsed;
- all local Dart import/export targets resolved;
- 30 Dart files passed a string/comment-aware structural scan;
- release archive tested with `unzip -t`;
- generated build, IDE, platform-host, lock, and API-doc artifacts removed;
- the uploaded `structured(1).zip` application was not modified.

Required on a machine with Flutter before publishing:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter run --profile -d <slowest-device>
dart pub publish --dry-run
```

Do not publish if any command fails. Profile mode on a real low-end device is
required; debug-mode frame timings are not a release benchmark.

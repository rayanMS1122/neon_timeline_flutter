# Release report 12.0

Status: automated release gates passed; package not published.

The package version, entrypoints, example gallery, changelog, engines, public
widgets and focused tests were updated. No push, tag or publish operation was
performed.

The following gates were executed with Flutter 3.44.6 / Dart 3.12.2:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
flutter pub publish --dry-run
```

Results: formatter clean, analyzer clean, 158 package tests and 4 example
application tests passed, Web release build passed, Wasm dry run passed, and
publish dry-run returned 0 warnings. The only publish hint is the intentional
major-version jump from the last pub.dev release (3.4.3).

The final source archive contains 497 entries and passed `unzip -t` without
errors. Generated `.dart_tool` and `build` trees are not included.

The v12 gallery exposes narrow layouts, 200% text, dark, RTL, reduced motion,
drag cancel, edge scroll, resize, midnight, offline, failure and rollback
states for manual QA. Chrome runtime and Android device testing were not
available in this assembly environment and are not claimed as completed.

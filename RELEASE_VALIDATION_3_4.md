# Release validation — 3.4.0

## Completed in the packaging environment

- Source archive extracted successfully.
- Package metadata parsed as YAML.
- Local Dart import/export targets checked.
- Dart delimiter/string/comment structural scan completed.
- Duplicate photon-lattice painter invocation checked.
- No per-widget `AnimationController` remains under `lib/`.
- Web viewport allows zoom.
- Valid example `robots.txt` added.
- Clean source archive excludes Git history, build output, `.dart_tool`, and IDE
  caches.
- ZIP CRC integrity checked.

## Must be completed with a local Flutter SDK

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
dart pub publish --dry-run
```

Performance acceptance additionally requires a release Lighthouse run and a
Chrome Performance trace. Debug-mode Lighthouse scores are not publication
criteria.

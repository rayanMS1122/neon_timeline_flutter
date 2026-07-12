# Release validation — 3.4.0

## Completed in this workspace

- source archive extracted into a clean release tree;
- 44 Dart files structurally scanned;
- zero unmatched Dart delimiters detected;
- zero missing relative Dart imports, exports, or parts detected;
- YAML and JSON configuration parsed successfully;
- package diff passed whitespace/error checking;
- source ZIP checked with `unzip -t` after generation;
- no production application was changed;
- no pub.dev publication or Git push was performed.

## Mandatory local gate

Run from the package root:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test

cd example
flutter pub get
flutter test
flutter build web --release
```

Then serve the release output:

```bash
cd build/web
python -m http.server 7357
```

Run Lighthouse against `http://localhost:7357` at least three times and record
the median. Do not publish if the analyzer, tests, release build, or package dry
run fails:

```bash
cd ../../
dart pub publish --dry-run
```

## Production integration gate

Test the package in the consuming app in **profile mode** on the slowest intended
Android/iOS device and on Web. Verify idle CPU, scrolling, day changes, dragging,
slide/dismiss actions, app background/foreground transitions, reduced motion,
and disposal. No package can truthfully guarantee zero crashes in arbitrary
consumer callbacks; this release guards its own timers, listeners, and async
operation paths.

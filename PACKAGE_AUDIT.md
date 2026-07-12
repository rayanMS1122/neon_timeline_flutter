# Package audit — 3.4.0 final candidate

## Scope

This release was prepared from the supplied `neon_timeline_flutter` 3.3.0
source archive. Only the package and its `example/` application were changed.
No consuming application source was modified, and no publish or Git operation
was performed.

The visible timeline language remains intact: neon indicators, connector beams,
glass/liquid-crystal cards, conflict states, free-time gaps, drag rescheduling,
slide actions, day paging, themes, and advanced painter variants all remain
available. New presentation widgets are optional additions rather than
replacements.

## Architecture changes

- one shared, demand-driven sampled motion source per timeline;
- no display-rate `AnimationController` per row, indicator, or connector;
- motion sleeps without listeners and pauses while scrolling, off-route,
  backgrounded, under disabled `TickerMode`, or with reduced motion;
- delayed motion startup so first content paint is not competing with particles;
- adaptive/battery/balanced/high-quality public performance profiles;
- default animation budget of one current/active row;
- lazy list/sliver construction and optional explicit animated indexes;
- O(n log n) sort plus O(n) schedule overlap/gap sweep;
- revision-driven plan reuse for application state integrations;
- coalesced day-pager pointer updates and throttled drag auto-scroll;
- one async operation lock per slidable row;
- reduced-motion settings override explicit expensive animation settings;
- split `core.dart`, `advanced.dart`, and `slidable.dart` imports while retaining
  the original all-in-one library.

## Example coverage

The example contains:

- schedule timeline with gaps, overlaps, current status, dragging, slide actions,
  full dismiss, undo, empty state, and day paging;
- lazy vertical, horizontal, fixed, and sliver timelines;
- all indicator, connector, node, and card rendering variants;
- every built-in theme preset plus a seeded theme;
- adaptive, battery-saver, balanced, and high-quality profiles;
- 20, 100, and 500-row lazy performance demonstrations;
- reduced-motion simulation and Web/native render-budget visibility;
- accessible Web bootstrap shell, zoomable viewport, manifest, and robots file.

## Static validation completed here

- every Dart file passed a string/comment-aware delimiter scan;
- every relative Dart import/export/part target exists;
- package, example, analysis, CI, and manifest configuration parsed;
- repository diff passed `git diff --check`;
- generated archive CRC/integrity is checked before delivery;
- build, `.dart_tool`, Git, IDE, and lock artifacts are excluded.

## Validation that still requires Flutter

A Flutter or Dart SDK is not installed in this execution environment. Therefore
this document does **not** claim that analyzer, tests, Web release build, or
Lighthouse passed here. Run all commands below before integrating or publishing:

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

Serve only `example/build/web` for Lighthouse. A debug `flutter run` session is
not a valid production performance measurement.

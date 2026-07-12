# Package audit — 3.3.0

## Scope

The uploaded `neon_timeline_flutter(1).zip` package was reviewed and copied into
a clean release tree. No consuming application source was modified in this turn.
The supplied animation-fix conversation was treated as historical context, not
as proof that the current package was fast.

## Confirmed hot paths

- display-rate controllers still existed for standalone indicators/connectors;
- sampled shared motion still woke from a display-rate controller;
- dozens of `Paint`, `Path`, shader, and blur wrappers were created in painter
  loops;
- direct `MaskFilter.blur` calls remained outside the old Web blur cache;
- liquid ribbons and connector waves rebuilt geometry every animation sample;
- multiple active schedule rows could repaint expensive effects;
- async slide actions could be triggered repeatedly before completion;
- hover and drag input could generate more state updates than useful frames.

## Corrections

- timer-driven 24 Hz shared and standalone sampled clocks;
- lifecycle, scrolling, listener, reduced-motion, and `TickerMode` sleep states;
- bounded paint/path and animated-geometry caches;
- global quantized native blur cache and Web blur bypass;
- lookup-table trig in painter loops;
- one-pass overlap sweep after optional sort;
- lazy row creation and one-row default animation budget;
- coalesced pointer input and throttled snapped drag auto-scroll;
- duplicate-safe row keys and async slide-action locks;
- guarded move, dismissal, action, and error-reporting futures.

## Validation available here

- package YAML parsed successfully;
- all relative Dart imports/exports resolve;
- all Dart files passed a string/comment-aware delimiter scan;
- no direct painter `MaskFilter.blur` call remains outside the shared cache;
- build, `.dart_tool`, Git, IDE, and lock-file output was removed;
- release ZIP integrity was checked.

A Flutter SDK is not installed in this environment. `dart format`,
`flutter analyze`, `flutter test`, profile-mode device testing, and
`dart pub publish --dry-run` are mandatory before release. Structural checks are
not a substitute for the Flutter analyzer.

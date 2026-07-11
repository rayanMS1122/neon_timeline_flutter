# Package audit — 3.2.0

## Scope

Two uploaded archives were reviewed:

- `neon_timeline_flutter (2).zip`, package version 3.1.0;
- `structured(1).zip`, the consuming application used only as an integration
  and scheduling-logic reference.

The application archive was not edited. Its uploaded SHA-256 remains
`b89e385a6081b96e918a6ce6afe3ad87bc038594f3b29b03fa25c5b19c79e7a0`.
All implementation changes are isolated to this package.

## Main performance faults found

- The schedule created the complete day widget tree before handing it to a
  builder-based list, so expensive cards, actions, and painters were still
  eagerly allocated.
- Every advanced visible card subscribed to display-rate motion, even when the
  entry was inactive.
- Motion continued during scrolling and while no useful animated surface was
  visible.
- Multiple glass cards independently sampled the same backdrop.
- Static indicators and connectors could still allocate local controllers.
- Drag callbacks rebuilt for every pointer update and auto-scrolled on every
  gesture event.
- The interval logic repeatedly coupled layout records to widget construction.

## 3.2.0 corrections

- Lazy schedule render plan: O(n log n) sort plus O(n) overlap/gap sweep.
- Visible-row-only content, action, card, indicator, and painter construction.
- One sampled shared motion source with configurable update rate.
- Automatic pause during scrolling, inactive lifecycle, reduced motion, and
  disabled `TickerMode`.
- Controller stops when no animated painter consumes the phase.
- Current/active-card-only animation by default.
- Grouped backdrop filters and raster-cache hints.
- Minute-aligned live clock instead of a continuously drifting periodic timer.
- Snapped drag-state updates, throttled edge auto-scroll, and scroll-aware drag
  position calculation.
- Runtime-safe configuration fallbacks and guarded asynchronous operations.
- Calendar-day boundaries preserve local/UTC mode and avoid fixed 24-hour day
  assumptions.

## Public performance controls

- `motionFramesPerSecond`
- `pauseMotionWhileScrolling`
- `animateOnlyCurrentEntry`
- `addAutomaticKeepAlives`
- `cacheExtent`
- `NeonScheduleTimelineStyle.useBackdropFilter`
- `NeonScheduleTimelineStyle.enableCardParallax`
- `NeonTimelineCard.animate`
- `NeonTimelineCard.useBackdropFilter`

## Publication metadata

- package version: `3.2.0`;
- Dart constraint: `>=3.4.0 <4.0.0`;
- Flutter constraint: `>=3.22.0`;
- `flutter_slidable` constraint: `>=3.1.2 <4.0.0`;
- MIT license retained;
- application sources, build outputs, IDE state, and generated API docs are not
  included in the release archive.

## Validation available in this workspace

- package YAML files parsed successfully;
- local import/export targets checked;
- all Dart files passed a string/comment-aware delimiter and structural scan;
- ZIP integrity and package layout checked;
- uploaded application archive remained untouched.

A Flutter SDK was not available here. `dart format`, `flutter analyze`,
`flutter test`, profile-mode device testing, and
`dart pub publish --dry-run` remain mandatory before publication. A structural
scan is not a substitute for the Dart analyzer or Flutter tests.

# Performance report — 3.4.0

## Scope

This release preserves the existing classic and advanced neon UI. It changes
when expensive work runs, how many elements subscribe to motion, and which
rendering path is selected on Flutter Web.

## User-provided baseline

The reported Lighthouse run used an emulated Moto G Power and Slow 4G:

| Metric | Reported value |
|---|---:|
| Performance | 35 |
| FCP | 1.4 s |
| LCP | 55.0 s |
| TBT | 134,040 ms |
| Speed Index | 24.1 s |
| Main-thread work | 165.7 s |
| Script evaluation | 158.953 s |
| `main.dart.js` transfer | 6.57 MiB |
| User timing marks | 14,711 |

These values strongly suggest that the tested page was either a debug-style
build, had continuous startup work, or both. This environment does not include a
Flutter SDK or Chromium, so no honest post-change Lighthouse number can be
reported here.

## Source-level findings and changes

### Continuous motion

Before 3.4, standalone advanced widgets could create independent animation
controllers, and generic timelines did not enforce their configured animation
budget. Version 3.4 uses:

- one demand-driven scope clock for a timeline;
- one package-global fallback clock for isolated widgets;
- a default 120 ms startup delay so the static first frame can paint first;
- a 24 Hz default rather than display-refresh-rate wakeups;
- automatic stop with no animation consumers;
- pause during scroll, inactive lifecycle, inactive route, reduced motion, and
  disabled `TickerMode`;
- a hard active-row budget in generic and schedule timelines.

### Painter work

- The duplicate photon-lattice connector pass was removed.
- Dynamic blur requests go through the centralized platform-aware cache.
- Flutter Web defaults to layered translucent strokes instead of Gaussian mask
  blur for large neon glows.
- Pointer/parallax updates are coalesced to one state update per rendered frame.
- Static UI remains available immediately; optional motion starts later.

### Planner algorithm

The schedule render plan is independent from painter animation:

1. Normalize and day-filter entries.
2. Sort once: O(n log n).
3. Sweep once for occupied ranges, conflicts, adjacency, and gaps: O(n).
4. Build rows lazily with `ListView.builder`.
5. Reuse the plan through `dataRevision` or a stable entry fingerprint.

### Slide and dismiss logic

- A slide action cannot start a second asynchronous operation while busy.
- Full-swipe dismissals have a separate busy lock.
- Busy state can show progress without changing the action layout.
- Errors are guarded and forwarded through the existing error callback.
- A single package-owned group closes other open slidable rows by default.

## Required local verification

Run a production build; do not benchmark ordinary `flutter run` debug output:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter build web --release
cd build/web
python -m http.server 7357
```

Then run Lighthouse at `http://localhost:7357` at least three times and use the
median. Export a Chrome Performance trace and confirm:

- no long-running startup loop;
- no continuous frames when no item is active;
- at most the configured number of active painter consumers;
- no offscreen row rebuilds during motion;
- no repeated async slide operation;
- static first paint appears before continuous motion starts.

## Claims deliberately not made

No Flutter analyzer, widget test, release build, Chrome trace, or Lighthouse run
was executable in the packaging environment. The release therefore includes
source-level checks and tests, but actual device/browser measurements must be
produced locally before publishing.

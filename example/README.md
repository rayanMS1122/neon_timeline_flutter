# neon_timeline_flutter complete example

This application is a self-contained showcase for the public package API. It
uses an in-memory repository and does not depend on an application-specific
model, database, state-management library, or backend.

## Showcase screens

### Schedule

- `NeonScheduleTimeline<DemoTask>` with an application-owned model.
- Chronological normalization, gaps, nested overlap metadata, conflict bridges,
  current-time marker, and active state.
- Long-press drag-to-reschedule with package snapping and edge auto-scroll.
- Start and end slide actions.
- Full-swipe delete, asynchronous operation locking, SnackBar undo, and error
  routing.
- Previous/next day buttons and `NeonTimelineDayPager` swipe navigation.
- Package empty state and add-demo-task action.

### Timelines

- Lazy `NeonTimeline.builder`.
- Horizontal timeline.
- `NeonFixedTimeline.builder`.
- `NeonSliverTimeline.builder` inside a `CustomScrollView`.
- Status, semantics, keys, opposite content, and item activation.

### Effects

- Every `NeonIndicatorEffect`.
- Every `NeonConnectorEffect`.
- Every `NeonTimelineCardVariant`.
- `NeonTimelineNode` in vertical and horizontal configurations.
- One selected animated preview at a time; other previews keep the same visual
  renderer at a stable phase.

### Performance

- 20, 100, or 500 lazily built rows.
- Explicit active index to avoid a full status scan.
- Adaptive rendering summary: motion rate, animated row budget, glow strategy,
  and cache behavior.
- No automatic keep-alive for offscreen rows.

## Global controls

Open the tune button in the app bar to switch:

- Every built-in theme preset: Neon, Spectral, Quantum, Hyperion, Omniverse,
  Neural Aurora, Neural Ember, Holographic, Solar Flare, Cryogenic, Void Pulse,
  Aurora, Ember, Midnight, Light, plus a `fromSeed` theme.
- Adaptive, Battery Saver, Balanced, and High Quality performance profiles.
- Simulated operating-system reduced-motion preference.

## Run

```bash
flutter pub get
flutter run
```

Measure animation and scrolling in profile mode:

```bash
flutter run --profile
```

Build the production web application:

```bash
flutter build web --release
cd build/web
python -m http.server 7357
```

Run Lighthouse against the static release server, not against a debug
`flutter run` session.

## Tests

From the package root:

```bash
flutter analyze
flutter test
```

The example tests verify the planner screen, all navigation destinations, and
the global performance/accessibility controls.

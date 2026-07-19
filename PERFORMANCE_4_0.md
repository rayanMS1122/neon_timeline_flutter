# Performance 4.0

## Implemented safeguards

### Structural planning

- Stable O(n log n) sorting followed by a linear gap and connected-overlap
  sweep.
- O(1) conflict membership and conflict-type lookup through immutable indexes.
- Calendar-day boundaries are constructed as the next local or UTC date instead
  of assuming every day is exactly 24 hours.
- `TimelineRenderPlanCache<T>` supports explicit revision invalidation and
  minute-bucketed clock state.
- `TimelineRenderPlanBuilder<T>` computes a linear entry fingerprint when no
  explicit revision is supplied, preventing stale plans after in-place list
  mutation.

### Advanced layout

- `TimelineDayLayoutEngine` uses balanced trees for active intervals and free
  columns, producing O(n log n) overlap layout.
- External subsets are sorted before layout so callers cannot accidentally feed
  an invalid order.
- `CalendarDayView` separates the static grid painter from entry widgets and
  creates no continuous animation source.
- `ResourceTimelineView` keeps vertical rows lazy and indexes entries by
  resource once.

### Resources and dependencies

- `TimelineCapacityEngine` indexes real resource assignments in one pass. Its
  work is O(A + Σ Eᵣ log Eᵣ), where A is the number of assignments and Eᵣ is
  the event count for a resource. It does not scan every entry for every
  resource.
- Capacity conflicts are indexed by entry before resource cards are built, so a
  card does not rescan every conflict interval.
- Dependency analysis remains O(V + E) after ID indexing, including forward
  earliest-start and reverse latest-start/slack passes.
- The dependency map uses one connector painter and no ticker; critical edges
  are precomputed instead of inferred repeatedly while painting.

### Correctness safeguards that also protect performance

- Analytics clips work to the requested window before status, resource, and
  duration aggregation; off-window entries no longer inflate dashboard metrics.
- Invalid ranges retain their own `invalidRange` classification without
  contaminating valid entries in the same overlap cluster.
- Resource conflict lookups are indexed before row/card construction.

### Rendering policy

- Adaptive policy reduces motion, overscan, blur, and animated-entry budgets on
  web, large datasets, low-power configurations, and reduced-motion systems.
- Neutral cards and panels require explicit per-widget backdrop-blur opt-in.
- Static neutral views create no timer or animation controller.
- Legacy motion continues to use the package's shared bounded motion engine.
- Generated build, `.dart_tool`, and IDE artifacts are rejected by release
  scripts and CI.

## Benchmark harness

Run from a Flutter-enabled package checkout:

```bash
dart run benchmark/timeline_engine_benchmark.dart
```

The harness covers 10, 100, 500, 1,000, and 5,000 entries and measures:

- render-plan construction;
- render-plan cache hits;
- day overlap layout;
- analytics sweep;
- resource-capacity sweep.

The previous harness referenced a nonexistent `conflictGroups` member. It now
uses the real `conflicts` API. No machine-specific result is committed as a
universal claim.

## Required release measurements

Before publication, record on documented hardware and release builds:

- UI and raster frame P50/P90/P99;
- slow and missed frames;
- idle and interaction CPU;
- memory and garbage collections;
- rebuild and repaint counts;
- active tickers and timers;
- web LCP and TBT;
- JavaScript/Wasm and asset size;
- 10, 100, 500, 1,000, and 5,000-entry workloads.

No fixed performance number is valid until those measurements have actually
been produced.

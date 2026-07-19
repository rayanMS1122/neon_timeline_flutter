# Performance

## Compact timeline

The compact view builds one widget per visible semantic row rather than a permanent 24-hour pixel canvas. Short days use smart content fitting; longer days use a lazy `ListView.builder` with bounded interaction cache extent.

At drag or resize start, the package captures immutable day snapshots and overlap placements. That frozen model remains on screen until the interaction finishes. Pointer events only update the active overlay; they do not recompute rows, gaps, metrics, or overlap lanes.

Pointer events are coalesced through `SchedulerBinding.scheduleFrameCallback`, so time projection, magnetic snapping, and conflict checks run at most once per rendered frame. A frozen prefix-max interval index narrows every active conflict query to relevant candidates; exact half-open overlap checks then filter endpoint touches.

Auto-scroll is synchronized to frame callbacks and uses a cubic edge-distance curve from 90 to 1,000 logical pixels per second. It stops immediately outside the edge zone or when the interaction ends. No periodic timer remains in the interaction hot path.

The drag feedback, time rule, adaptive time lens, and accepted-move confirmation use isolated repaint boundaries. The feedback avoids blur and uses one bounded shadow to reduce raster work and narrow-screen overflow risk.

## Proportional timeline

The proportional editor uses viewport interval queries, overscan, stable IDs, immutable snapshots, separate painters, and independent listenables. It never builds all 10,000 complex entry widgets simultaneously.

## Release profiling

Profile with representative 100, 1,000, and 10,000 entry data. Measure frame build/raster times, memory, scroll smoothness, and drag latency on target hardware instead of treating synthetic source checks as performance proof.

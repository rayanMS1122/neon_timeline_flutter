# Performance audit — 3.3.0

## Goal

Keep the existing timeline geometry, colors, presets, card variants, and slide
interaction while reducing CPU usage, allocation churn, duplicate async work,
and teardown risk.

## Main changes

- Shared motion no longer uses a display-refresh `AnimationController` and then
  discards samples. A one-shot timer publishes only the configured rate.
- Standalone indicators and connectors use the same 24 Hz sampled clock.
- `NeonScheduleTimeline` allows one continuously animated focal row by default.
- All painter blur requests pass through one cache; Web skips Gaussian
  `MaskFilter` passes.
- Advanced painters use bounded reusable `Paint` and `Path` pools.
- Liquid-crystal ribbon geometry and connector wave geometry use bounded phase
  caches.
- Holographic scanlines and card grid lines are submitted as batched paths.
- Hover state is coalesced to one update per frame.
- Schedule overlaps and gaps are produced by one linear sweep after sorting.
- Slide actions reject duplicate taps while an asynchronous callback is pending.

## Source-level hot-path comparison

These are source allocation sites, not claimed device benchmarks:

| Painter | 3.2.1 `Paint()` sites | 3.3.0 `Paint()` sites | direct blur sites after change |
|---|---:|---:|---:|
| Advanced indicator | 54 | 0 | 0 |
| Connector | 37 | 2 retained reusable paints | 0 |
| Card FX | 11 | 3 retained reusable paints | 0 |

All remaining actual Gaussian blur construction is centralized in
`NeonBlur.normal`, quantized, cached, and disabled on Web.

## Complexity

For `n` entries in the selected day:

- filtering: O(n);
- optional chronological sort: O(n log n);
- overlap/gap sweep: O(n);
- render-node creation: O(n);
- widget construction: lazy near the viewport.

## What still needs real measurement

A structural audit cannot establish a frame-time percentage. Run the same data
set in profile mode on the slowest Web and native targets, then compare UI/raster
frame time, allocation rate, and active painter count against 3.2.1.

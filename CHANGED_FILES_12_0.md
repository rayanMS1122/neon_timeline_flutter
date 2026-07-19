# Changed files 12.0

Major additions live under `lib/src/v12/`:

- core: snap, auto-scroll, availability, clock, semantic controller, history
  and resize;
- models: config/details and focus-aware gap layout;
- theme: complete ultimate theme tokens;
- widgets: adaptive entry, drag, resize and responsive header components.

Integration changes:

- `UltimateStructuredTimeline<T>` now supplies the 12.x production surface;
- the v6 coordinate map exposes viewport conversion/hit testing;
- the v6/v7 drag path adds target hysteresis, direction weighting, smoother
  edge scrolling, Escape cancel and stable active-entry snapshots;
- v10 forwards a zoom-dependent central refresh interval;
- the legacy public gap component now reduces secondary/action content and
  padding under tight large-text constraints instead of overflowing;
- `timeline_v12.dart`, main exports, package metadata and changelog were added
  or updated;
- a realistic v12 gallery screen, focused v12 tests and current gallery widget
  tests were added;
- legacy color, ticker, semantics and cache-extent APIs were modernized for
  Flutter 3.44 with an analyzer-clean result.

Legacy files and exports remain present.

# API changes 12.0

Added public modules for:

- ultimate config, zoom metrics and semantic controller;
- theme, entry, gap, drag, resize, header and motion tokens;
- weighted snap targets/results/engine;
- acceleration-limited auto-scroll;
- availability and blocked ranges;
- resize sessions and snap engine;
- central clock/current-time controller;
- typed history commands;
- focus-aware gap layout;
- unified builder details and 12.x public widgets.

Extended `TimelineVisualCoordinateMap<T>` with viewport conversion and hit
testing. Extended `TimelineReschedulePolicy` with `snapHysteresis`. Extended
`DelightStructuredTimeline<T>` with `refreshInterval`.

No public API was deleted. Package version is `12.0.0`.

The minimum toolchain is now Dart 3.12 and Flutter 3.44. This is the only
platform-level breaking change; the package's 1.x–11.x Dart entrypoints remain
exported.

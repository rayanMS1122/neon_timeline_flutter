# Release report 11.0.0

11.0.0 is an improvement release over 10.0.0. It does not delete legacy APIs.

Implemented:

- live-update-stable magnetic drag session with hysteresis;
- semantic zoom instead of blind scale-only zoom;
- async-safe bounded undo/redo history;
- controlled multi- and range-selection;
- working-hour and blocked-range validation;
- conflict-aware ranked slot suggestions;
- optimistic, saving, offline, rollback and failure UI states;
- optional desktop context menu component;
- calm host-clock-driven current-time marker;
- production and accessibility presets;
- focused `timeline_v11.dart` and updated `structured_planner.dart` export.

Not claimed as executed in this environment: Flutter analyzer, Flutter tests,
platform release builds and publish dry-run.

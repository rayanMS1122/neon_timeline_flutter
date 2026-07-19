# Performance 12.0

12.0 retains the cached day-plan, temporal index, viewport index, stable entry
keys and coordinate-map architecture from earlier production versions.

Drag updates rebuild the overlay and active row rather than rebuilding the
whole app. Auto-scroll has one loop, the current-time source has one lifecycle
timer, and cards do not own animation controllers or clocks. Card and drag
surfaces use repaint boundaries at useful visual boundaries.

The public snap engine is deterministic and bounded by supplied candidates.
For very large datasets, hosts should query a temporal index for the viewport
and pass only relevant snap targets rather than an unbounded history.

No synthetic runtime benchmark number is claimed. The complete 158-test suite,
an analyzer-clean source pass and the release Web compilation were executed on
Flutter 3.44.6. Device frame timing still depends on host builders, data size,
platform and GPU and should be profiled in the integrating application.

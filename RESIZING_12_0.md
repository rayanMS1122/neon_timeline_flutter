# Resizing 12.0

`UltimateTimelineResizeSession<T>` wraps the proven pure resize engine with
snap hysteresis and optional work constraints. It supports start/end edges,
minimum and maximum duration, day bounds, midnight, conflicts, commit and
cancel without owning persistence.

`UltimateTimelineResizeHandle<T>` separates its 24-pixel interaction hitbox
from its quiet four-pixel visual handle and exposes semantic increase/decrease
actions. `UltimateTimelineResizePreview<T>` communicates time, duration and a
blocked reason. `UltimateTimelineResizeLayer<T>` composes both handles and the
preview without forcing an application card.


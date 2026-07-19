# Visual coordinate map 12.0

`TimelineVisualCoordinateMap<T>` is built from the actual entry and gap
extents. It supports:

- `offsetForTime` and `timeForOffset` for content coordinates;
- `viewportOffsetForTime` and `timeForViewportOffset` with scroll/header
  offsets;
- `hitTest` returning `TimelineVisualHit<T>` with segment, interpolated time
  and local fraction.

The map uses binary search for hit testing. It remains correct for compressed
gaps and clamped short-entry heights. Callers must rebuild it when actual
layout extents change.


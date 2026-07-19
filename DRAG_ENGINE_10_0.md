# Drag Engine 10.0

10.0 replaces uniform pixel-to-minute drag conversion with `TimelineVisualCoordinateMap`. The map uses the actual rendered extents of entries and gaps, including minimum card heights and compressed gaps.

## Interaction

- configurable long-press activation
- five-minute snap by default
- magnetic day and neighbouring-entry boundaries
- optional conflict-free slot preference
- visible snap guide and target slot
- haptic feedback only when the snap index changes
- edge auto-scroll with proximity-based speed
- host callbacks for drag state and persistence

The package never writes application data. A drop is returned to the host through the existing move/delete callbacks.

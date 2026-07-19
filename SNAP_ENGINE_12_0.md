# Snap engine 12.0

`UltimateTimelineSnapEngine<T>` collects grid, day, working-hour, neighbour,
current-time and custom targets. Each candidate is evaluated for bounds,
conflicts, constraints, distance, pointer direction, velocity and target
priority. The default order is neighbour/free-slot, working boundary, custom
marker, day/current-time and grid.

`UltimateTimelineSnapResult<T>.retainedByHysteresis` tells UI code why a target
did not change. Haptic feedback should fire only when `start` or the effective
target changes.

Custom markers use `UltimateTimelineSnapTarget<T>` and never require an
internal render object.


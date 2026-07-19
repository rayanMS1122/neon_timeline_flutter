# Auto-scroll 12.0

`UltimateTimelineAutoScrollController` owns exactly one periodic loop. Its
configuration uses pixels per second, a smooth edge-intensity curve, bounded
acceleration and stronger deceleration. `updatePointer` cannot create duplicate
timers; `stop` and `dispose` cancel the loop and reset velocity.

The integrated renderer applies the same acceleration/deceleration principle
to its existing drag loop and recomputes time geometry after a scroll step.
There is no continuous idle frame loop.


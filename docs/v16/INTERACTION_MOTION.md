# Interaction motion engine

## Frozen interaction model

`NeonPlannerDayTimeline` captures sorted entry snapshots and overlap placements at the beginning of a drag or resize. Parent updates do not reorder the visible day while the pointer is active. The accepted application state is rendered only after the interaction ends.

## Frame-coalesced input

The latest global pointer position is buffered. A scheduler callback processes at most one position per rendered frame. This prevents high-frequency mouse and touch events from triggering repeated snapping and conflict work inside the same frame. A frozen interval index limits conflict work to entries that can actually intersect the proposed range.

## Adaptive time lens

The time lens adapts to the timeline's own width. Regular layouts show five
marks, compact layouts show three, and micro layouts show only the target time.
It remains independent from the compressed day rows, giving minute precision
without expanding the timeline into a full 24-hour canvas.

## Auto-scroll

Auto-scroll is frame synchronized. Velocity increases cubically as the pointer approaches the top or bottom edge. Scroll offset is included in time projection so the grabbed point remains stable while the viewport moves.

## Accepted mutation feedback

After an accepted move or resize:

1. light haptic feedback fires;
2. a compact confirmation animates near the target position;
3. the committed row receives a short settle pulse;
4. the longer-lived undo surface remains available when `onUndoMove` is supplied.

The confirmation can be controlled with `showMoveConfirmation`, `moveConfirmationDuration`, `animateCommittedMove`, and `settleAnimationDuration`.

## Reduced rendering work

The hot path avoids periodic timers, blur, large glow stacks, full lane allocation, gap rebuilding, and root timeline `setState` calls. The static rows, interaction overlays, and confirmation surfaces are separate repaint regions.

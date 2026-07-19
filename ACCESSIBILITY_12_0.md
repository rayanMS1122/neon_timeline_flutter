# Accessibility 12.0

Adaptive cards expose title, time, duration, completion, selection, lock,
recurrence, external-event, conflict, saving and error state through semantics.
Conflict, blocked and auto-scroll feedback includes icons and text; it never
depends on color alone.

Keyboard entry movement remains available with Alt+Arrow. Escape cancels an
active drag. Resize handles expose semantic increase/decrease actions. Focus
and selected borders are separate from completion state.

`UltimateStructuredTimelineConfig.accessible()` enables detailed density,
56-pixel minimum targets, reduced motion and high contrast. Card layout clamps
text scaling to the supported 100–200% adaptive range and switches to compact
or micro content before overflow.


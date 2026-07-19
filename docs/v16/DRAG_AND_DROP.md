# Drag, resize, snapping, overlap, and undo

## Real-time movement

`NeonPlannerDayDragMode.time` is the default. Vertical pointer distance is converted into clock minutes using `dragMinutesPerPixel`. Pointer positions are coalesced to one proposal calculation per rendered frame. The floating preview, horizontal scrubber, and optional adaptive time lens show proposed start, end, duration, snap source, and conflict count.

The visible rows and overlap lanes are frozen for the entire gesture. Only the interaction overlays move. The host's accepted objects are projected after the gesture finishes.

`slots` keeps explicit compressed-gap targets. `hybrid` allows both direct clock-time movement and slot targets.

## Magnetic snap system

Each proposal first respects the minute grid. When enabled, stronger candidates are added for:

- day start and day end
- neighboring entry starts
- neighboring entry ends
- moving-start alignment
- moving-end alignment

`snapTolerance` controls attraction distance. `snapHysteresis` keeps a chosen non-grid target stable until the pointer moves far enough away, preventing visual flicker.

## Conflict policy

- `allow`: commit and report overlap.
- `block`: prevent commit when intervals overlap.
- `delegate`: send the proposal to the host for its decision.

Conflict feedback includes the number of overlapping entries.

## Resize

After selecting an entry, visible start and end handles appear when `onEntryResize` is supplied. Resize uses the same snapping, conflict detection, haptics, and edge auto-scroll as movement. `minimumEntryDuration` is enforced before a proposal is emitted.

## Keyboard and assistive input

- Arrow Up/Down: move one snap interval.
- Shift + Arrow: move by the configured fast multiplier.
- Alt + Arrow: resize the end by one interval.
- F2 or E: invoke direct time editing.
- Screen-reader increase/decrease: move.
- Screen-reader custom actions: resize the end earlier/later.

## Undo and rollback

Accepted moves can show an internal undo surface. The package does not keep a private mutable task copy. `onUndoMove` receives the original accepted proposal, and the host restores its own source data. Rejected operations leave the host list unchanged.

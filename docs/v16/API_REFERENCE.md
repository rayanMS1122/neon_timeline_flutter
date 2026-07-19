# API reference

## `NeonPlannerDayTimeline<T>`

Required: `entries`, `adapter`, `selectedDate`.

### Mutation callbacks

- `onEntryMove`: receives `NeonPlannerMoveProposal<T>`.
- `onEntryResize`: receives `NeonPlannerResizeProposal<T>`.
- `onUndoMove`: receives the previously accepted move proposal; the host restores its own data.
- `onEntryTimeEdit`: opens a host-defined direct time editor.
- `onCreateTap`: optional empty-state create action.

### Drag and snap

- `dragActivation`
- `dragMode`: `time`, `slots`, or `hybrid`
- `dragMinutesPerPixel`
- `snapInterval`
- `snapToEntryEdges`
- `snapTolerance`
- `snapHysteresis`
- `conflictPolicy`
- `enableAutoScroll`
- `showTimeScrubber`
- `showAdaptiveTimeLens`
- `timeLensMode`: `automatic`, `enabled`, `disabled`

### Resize and keyboard

- `enableResize`
- `minimumEntryDuration`
- `enableKeyboardMovement`
- `keyboardFastStepMultiplier`

Arrow keys move. Shift + Arrow uses the fast multiplier. Alt + Arrow changes the end time. F2 or E invokes `onEntryTimeEdit`.

### Layout and overview

- `density`: `compact`, `comfortable`, `spacious`
- `autoResponsiveDensity`
- `responsiveDensity`: `micro`, `compact`, `regular`
- `microBreakpoint`, `compactBreakpoint`
- `fit`: `smart`, `scroll`, `content`
- `smartFitMaxRows`
- `overlapPresentation`: `none`, `stacked`, `badge`
- `metrics`
- `gapBuilder`
- `showHeader`, `showMetrics`, `showGrabber`
- `showCurrentTimeIndicator`, `currentTime`, `currentTimeLabel`
- `emptyTitle`, `emptySubtitle`

### Accepted-mutation feedback

- `showMoveConfirmation`
- `showResizeConfirmation`
- `moveConfirmationDuration`
- `animateCommittedMove`
- `settleAnimationDuration`

An accepted move or resize can animate a compact confirmation near the target and pulse the committed row. This feedback is independent from undo.

### Undo

- `showBuiltInUndo`
- `undoWindow`
- `onUndoMove`

The built-in surface is only shown when a move was accepted and an undo callback exists.

## Compact support types

- `NeonPlannerDayMoveCallback<T>`
- `NeonPlannerDayResizeCallback<T>`
- `NeonPlannerDayUndoMoveCallback<T>`
- `NeonPlannerDayMetric`
- `NeonPlannerCompressedGap`
- `NeonPlannerDayDragMode`
- `NeonPlannerDayDensity`
- `NeonPlannerResponsiveDensity`
- `NeonPlannerTimeLensMode`
- `NeonPlannerDayFit`
- `NeonPlannerOverlapPresentation`

## `NeonPlannerTimeline<T>`

The proportional editor requires `entries`, `adapter`, and `selectedDate`. Important callbacks are `onEntryMove`, `onEntryResize`, `onRangeCreate`, `onEntryTap`, `onFeedback`, and `onDiagnostics`.

## Data projection

`NeonPlannerEntryAdapter<T>` implements `idOf`, `startOf`, `endOf`, and `presentationOf`. `snapshotOf` produces immutable `NeonPlannerEntrySnapshot<T>` values.

## Mutation types

- `NeonPlannerMoveProposal<T>`
- `NeonPlannerResizeProposal<T>`
- `NeonPlannerRangeProposal`
- `NeonPlannerMutationResult`

## Theme and controls

- `NeonPlannerTimelineThemeData`
- `NeonPlannerZoomSlider`
- `NeonPlannerSnapSlider`
- `NeonPlannerTimeRangeSlider`
- `NeonPlannerTimeRangeSegment`

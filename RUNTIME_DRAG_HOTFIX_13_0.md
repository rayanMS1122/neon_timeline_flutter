# Runtime Drag Hotfix 13.0

## Symptoms

The Chrome debug build started successfully but failed during the first drag with:

- `BoxConstraints forces an infinite height` in `UltimateTimelineDragPlaceholder`;
- repeated hit-test and semantics failures caused by the missing render size;
- auto-scroll callbacks reaching deactivated or detached render objects;
- a secondary `Duplicate GlobalKey` assertion after the render tree was already inconsistent.

## Root causes

### Unbounded placeholder stack

`UltimateTimelineDragPlaceholder` used an outer `LayoutBuilder` and
`Stack(fit: StackFit.expand)`. A timeline row is a child of a vertical
`ListView`, so its incoming height constraint is intentionally unbounded.
Expanding the stack therefore requested an infinite height.

The placeholder now sizes itself from its real child. Border and label layers
use `Positioned.fill` only after the child has established a finite stack size.
The label's height decision is evaluated inside that bounded overlay.

### Drag state owned by a virtualized row

The drag timer and overlay were owned by `_StructuredEntryRowState`. During
edge auto-scroll, the source row could leave the visible sliver and be recycled.
The timer then attempted to scroll through contexts or render boxes that were no
longer active.

The row now:

- uses `AutomaticKeepAliveClientMixin` while a drag is active;
- updates keep-alive state at drag start and finish;
- cancels timers and removes overlays in `deactivate()` as well as `dispose()`;
- rejects auto-scroll when the viewport or scroll contexts are detached,
  unmounted, unlaid-out, or missing content dimensions;
- removes the per-row `GlobalKey` and resolves the row render box from the
  existing state context.

## Regression coverage

Added widget tests for:

- a drag placeholder inside a vertically unbounded `ListView`;
- removing a timeline while an active drag and edge-scroll timer are running.

## Validation performed in this environment

- all Dart files parse successfully with the Dart tree-sitter grammar;
- all relative Dart imports and exports resolve;
- the generated ZIP passes integrity testing;
- no per-row `GlobalKey` remains.

Flutter and Dart SDK executables are not installed in this environment, so
`flutter analyze`, `flutter test`, and a Chrome run were not executed here.

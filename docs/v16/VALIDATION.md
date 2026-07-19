# Validation report

## Package version

`16.0.0`

## Implemented in this revision

- Completed a final no-feature mobile density pass: Micro/Compact rows are 52/58 px at comfortable text scale, rail nodes 32/36 px, status indicators 16/18 px, and summary strips 50/54 px.
- Kept header and action hit targets at 44–48 px while reducing only their visible circles, icons, shadows, and surrounding gaps.
- Kept interactive gap rows and undo actions at a minimum 44 px hit height even when their visible content is much smaller.
- Tightened drag, resize, drop, confirmation, time-lens, current-marker, empty-state, and undo visuals without changing their callbacks or data flow.
- Restored free horizontal tracking for the floating drag preview and added a regression source that verifies rightward and leftward pointer motion.
- Reduced the visible micro/compact geometry a second time without reducing the 44–48 px interaction targets.
- Replaced the mobile full-row selection card with a compact node focus ring.
- Frozen compact-day snapshots and overlap placements during active drag and resize sessions.
- Coalesced pointer input through Flutter frame callbacks so proposal work runs at most once per rendered frame.
- Replaced periodic timer auto-scroll with frame-synchronized proportional edge scrolling.
- Added adaptive time lenses for move and resize interactions.
- Simplified bounded drag feedback for narrow viewports, added per-frame Safe
  Area correction, and reduced raster effects.
- Added animated target-time confirmation, committed-row settle pulse, and existing undo continuation after accepted moves.
- Added a frozen interval index for interaction-time conflict candidate lookup.
- Added Dart tree-sitter syntax parsing to the package contract.
- Added widget regression coverage for the time lens, confirmation animation, and narrow drag feedback.
- Added width-driven mobile geometry for 320, 360, 375, 390, 412, 480, and
  768 px containers.
- Added regression sources for 200% text scaling, frozen neighbor geometry
  during drag/resize, content/Safe-Area-bounded drag feedback, and the micro
  time lens.
- Added a static check that rejects runtime widget/layout values inside const
  object expressions.

## Checks executed in the delivery environment

- YAML parsing for package/example configuration: passed.
- Tree-sitter Dart syntax parsing across 324 package, test, example, benchmark, and tool Dart files: passed.
- Dart delimiter and structural scan: passed.
- Duplicate named-argument scan over parsed Dart argument lists: passed.
- Local import, export, and `part` ownership validation: passed.
- Compact-library checks for required foundation, semantics, and scheduler imports: passed.
- Hot-path check rejecting `Timer.periodic` in the compact interaction library: passed.
- Search for unresolved placeholder and unimplemented markers: passed.
- Runtime-value-in-const-object scan: passed.
- Version consistency, package import resolution, public export checks, and byte-for-byte v16 source-copy verification: passed.

## Checks not executed

No Flutter/Dart SDK was installed in the delivery environment, so these claims are deliberately not fabricated:

- `dart format`
- `flutter analyze`
- `flutter test`
- coverage execution
- `flutter build web --release`
- device/browser profile measurements

Run `tool/verify_release.sh`, `tool/verify_release.ps1`, or the included GitHub Actions workflow before publishing.

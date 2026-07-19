# v14.1.1 Foundation import hotfix

## Reported compiler failure

The v14.1.0 architecture split introduced public fields typed as
`ValueListenable<FriendlyTimelineDragUiState>`, but two widget modules only
imported `package:flutter/material.dart`. On the reported Flutter web toolchain,
`ValueListenable` was unresolved and the Dart web compiler then aborted while
processing the invalid type.

## Correction

These modules now explicitly import `package:flutter/foundation.dart`:

- `lib/src/v14/widgets/friendly_timeline_drag_companion.dart`
- `lib/src/v14/widgets/friendly_timeline_workspace.dart`

The v14 regression test also imports foundation explicitly. Public API and
runtime behavior remain unchanged.

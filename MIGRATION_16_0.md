# Migration to 16.0.0

Version 16 integrates the compact `neon_planner_timeline` 0.7.0 engine into
`neon_timeline_flutter` without removing the existing 1.x-15.x APIs.

## Existing neon_timeline_flutter applications

No source migration is required for existing imports. The complete package
entrypoint and every versioned entrypoint through `timeline_v15.dart` remain
available.

To adopt the compact v16 planner, import either:

```dart
import 'package:neon_timeline_flutter/timeline_v16.dart';
```

or the complete package:

```dart
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
```

## Applications previously using neon_planner_timeline 0.7.0

Change the dependency and import only:

```yaml
dependencies:
  neon_timeline_flutter: ^16.0.0
```

```dart
import 'package:neon_timeline_flutter/timeline_v16.dart';
```

The public `NeonPlanner*` types from 0.7.0 keep their names. Application data
ownership, move/resize proposals, conflict policy, responsive breakpoints, smart
fit, and callback contracts remain unchanged.

## Internal imports

Do not import `package:neon_timeline_flutter/src/v16/...` from application code.
Those paths are implementation details and can change in later releases.

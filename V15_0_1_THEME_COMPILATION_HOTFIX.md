# v15.0.1 Theme Compilation Hotfix

## Symptoms

Flutter Web compilation of v15.0.0 failed in `UltraTimelineThemeData` because
its constructor used initializing formals such as `required this.background`
without declaring the corresponding instance fields. Every downstream theme
getter error was a cascade from that missing declaration set.

A second independent compiler error came from using a generic type parameter in
a constant expression:

```dart
const StructuredTimelineDragState<T>.idle()
```

Dart does not permit a type variable such as `T` in that const invocation.

## Fix

v15.0.1 declares all 19 immutable theme tokens explicitly:

- 14 color tokens
- 4 radius tokens
- 1 command-bar height token

The drag-state initialization now uses a normal generic constructor invocation:

```dart
StructuredTimelineDragState<T>.idle()
```

## Compatibility

The hotfix does not intentionally change the public API or planner behavior.
Existing v15.0.0 source code should continue to compile without migration.

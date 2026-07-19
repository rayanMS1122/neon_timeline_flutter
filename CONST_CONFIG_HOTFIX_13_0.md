# Const configuration hotfix

## Problem

`UltimateTimelineInteractionConfig` is a `const` constructor, but its initializer list compared `Duration` objects with `>`, `>=`:

```dart
assert(dropSnapInterval > Duration.zero)
assert(snapHysteresis >= Duration.zero)
assert(snapDistance >= Duration.zero)
```

Dart does not permit those method/operator calls during constant evaluation. Therefore every const preset containing the interaction config failed to compile, including `production()` and `advancedCompact()`.

## Fix

- Removed the three non-constant `Duration` comparisons from the const initializer list.
- Added `debugAssertIsValid()` to run the same checks at debug runtime.
- Invoked that validation when `UltimateStructuredTimeline` consumes the resolved configuration.
- Kept all public const constructors and presets intact.

## Local validation still required

Run in the package root:

```bash
dart format lib test example/lib
flutter analyze
flutter test
cd example
flutter run -d chrome
```

This environment does not contain the Flutter or Dart SDK, so no successful Flutter build is claimed here.

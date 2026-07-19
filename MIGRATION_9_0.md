# Migration to 9.0

Version 9.0 is additive. Existing 3.x–8.x imports and widgets remain available.

For the new default production surface, replace:

```dart
AdvancedStructuredTimelinePlanner<Task>(...)
```

with:

```dart
ProductionStructuredTimeline<Task>(...)
```

The callback types, planner engine, controller, mutation coordinator,
reschedule policy, and resize policy remain compatible.

No migration is required for applications that keep the 8.x surface.

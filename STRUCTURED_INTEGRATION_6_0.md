# Structured integration guide — 6.0

## Goal

Version 6.0 extracts reusable planner behavior from a Structured-style app
without copying its full user interface or application architecture into the
package.

Structured remains responsible for:

- the `Task` model and its JSON/database format;
- Bloc/Cubit state and repository writes;
- authentication, shared spaces, Firebase, local storage, and calendar access;
- task cards, sheets, navigation, translations, and branding;
- deciding whether a drag updates one occurrence or a complete series.

The package is responsible for:

- adapting tasks to neutral timeline entries;
- bounded recurrence expansion;
- moved/deleted occurrence overrides;
- day gaps, conflicts, current/next state, and metrics;
- activity markers and seven-day lanes;
- snap, clamp, overlap preview, delete-target outcome, and edge auto-scroll;
- deterministic conflict-resolution proposals.

## Import

```dart
import 'package:neon_timeline_flutter/structured_planner.dart';
```

## Map the existing Task model

```dart
final planner = TimelinePlannerEngine<Task>(
  seriesExpander: TimelineSeriesExpander<Task>(
    occurrenceIdBuilder: (series, index, start) =>
        'v_${series.effectiveSeriesId}_${start.millisecondsSinceEpoch}',
  ),
  adapter: TimelineSeriesAdapter<Task>(
    entryAdapter: TimelineEntryAdapter<Task>(
      id: (task) => task.id,
      start: (task) => task.startTime,
      duration: (task) => Duration(minutes: task.duration ?? 30),
      status: (task) => task.status == TaskStatus.completed
          ? TimelineStatus.completed
          : TimelineStatus.pending,
      color: (task) => task.color,
      semanticLabel: (task) => task.title,
      draggable: (task) => task.scope != TaskScope.calendar,
      resourceIds: (task) => <Object>{
        if (task.sharedSpaceId != null) task.sharedSpaceId!,
      },
      metadata: (task) => <String, Object?>{
        'priority': task.priority.name,
        'scope': task.scope.name,
      },
    ),
    seriesId: (task) => task.seriesId,
    recurrence: (task) => switch (task.recurrence) {
      RecurrenceType.none => null,
      RecurrenceType.daily => TimelineRecurrenceRule.daily(
          until: task.recurrenceEndDate,
        ),
      RecurrenceType.weekly => TimelineRecurrenceRule.weekly(
          interval: task.weeklyInterval ?? 1,
          weekdays: <int>{
            task.weeklyWeekday ?? task.startTime.weekday,
          },
          until: task.recurrenceEndDate,
        ),
      RecurrenceType.monthly => TimelineRecurrenceRule.monthly(
          dayOfMonth: task.monthlyDay ?? task.startTime.day,
          until: task.recurrenceEndDate,
        ),
    },
    isOverride: (task) =>
        task.seriesId != null && task.recurrence == RecurrenceType.none,
    isDeleted: (task) => task.isDeleted,
    isExternal: (task) => task.scope == TaskScope.calendar,
  ),
);
```

Do not filter deleted occurrence overrides in `TimelineEntryAdapter.include`.
They must reach `TimelineSeriesExpander` so that the generated occurrence can be
removed. Use `isDeleted` for that purpose.

## Prepare once, render several surfaces

```dart
final month = planner.prepareMonth(
  values: state.tasks,
  month: selected,
);

final day = month.buildDay(
  selectedDate: selected,
  now: clock.now(),
);
final week = month.buildWeek(selectedDate: selected);
final dots = month.buildActivityIndex(
  startDate: DateTime(selected.year, selected.month),
  endDate: DateTime(selected.year, selected.month + 1, 0),
);
```

Use `TimelinePlannerDayBuilder<T>` when the app wants a widget-level cache. Pass
`dataRevision` from Cubit state. If application models can mutate in place, the
revision is mandatory; identity hashing cannot detect field changes inside the
same object instance.

## Long-press drag

The package does not own the gesture detector. Structured can keep its existing
visual drag card and time badge.

```dart
final session = planner.beginReschedule(
  entry: draggedEntry,
  bounds: planner.dayBounds(selectedDate),
  candidates: day.entries.map((item) => item.entry),
  policy: const TimelineReschedulePolicy(
    snap: Duration(minutes: 5),
    pixelsPerMinute: 1.35,
    allowConflicts: true,
  ),
);

final preview = session.previewForPixels(globalVerticalDelta);
final result = session.resolveDrop(
  preview: preview,
  overDeleteTarget: isOverDeleteTarget,
  cancelled: cancelled,
);
```

The app then handles the result:

- `move`: persist `preview.start` through `TaskCubit`;
- `delete`: invoke the app's delete/occurrence-delete flow;
- `blocked`: show conflict feedback;
- `cancel`: restore visual state;
- `unchanged`: perform no repository write.

For a recurring virtual occurrence, persist a separate override task with the
same `seriesId` and `recurrence: none`. The current Structured model can use the
default calendar-day matching for same-day rescheduling. For exact or cross-day
occurrence moves, add an original-occurrence timestamp to the app model (or
preserve it before replacing the virtual id) and map it through
`originalOccurrenceStart`. For a deleted occurrence, persist the override with
`isDeleted: true`.

## Conflict repair

```dart
final resolution = planner.resolveConflicts(
  entries: day.entries.map((item) => item.entry),
  bounds: planner.dayBounds(selectedDate),
  spacing: const Duration(minutes: 5),
);
```

`TimelineConflictResolution` is only a proposal. Structured decides whether to
show a confirmation dialog and whether to persist all changes in a transaction.
External calendar entries can remain non-draggable and appear in
`unresolvedEntries`.

## Data integrity

Inspect the series expansion before trusting it:

```dart
final expansion = month.expansion;
if (expansion.hasDataIntegrityIssues) {
  // Surface diagnostics in development or telemetry.
}
```

Diagnostics include:

- duplicate recurring series ids;
- orphan occurrence overrides;
- multiple overrides targeting the same occurrence;
- duplicate final entry ids.

Silently accepting those states would create plausible-looking but incorrect
planner data.

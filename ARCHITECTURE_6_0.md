# Architecture 6.0

## Principle

The package is a planner engine, not a second copy of the consuming app.
Application models enter through adapters. Immutable neutral results leave the
engine. Persistence always remains in the host.

## Pipeline

```text
App Task models
  -> TimelineEntryAdapter<T>
  -> TimelineSeriesAdapter<T>
  -> TimelineSeriesExpander<T>
  -> TimelinePlannerWindow<T>
  -> day / week / activity / drag / conflict results
  -> application-owned widgets and Cubit callbacks
```

## Modules

### Adaptation

`TimelineEntryAdapter<T>` maps id, time, status, color, resources, semantics,
and metadata. It does not require inheritance or generated code.

`TimelineSeriesAdapter<T>` adds series id, recurrence rule, override identity,
deleted occurrence state, and external-event classification.

### Series engine

`TimelineSeriesExpander<T>` expands only inside the requested window. It applies
single-occurrence move/delete overrides and reports inconsistent series data.
Generated entries carry reserved metadata keys prefixed with `timeline.`.

### Prepared window

`TimelinePlannerWindow<T>` reuses one bounded expansion for multiple views. It
is the recommended unit for a month screen containing a day timeline, week
selector, and month activity dots.

### Day plan

`TimelineDayPlan<T>` contains normalized entries, gaps, conflicts, current/next
insight, free/busy time, completion, utilization, and a render plan. Day ranges
may extend beyond 24 hours for night shifts.

### Interaction

`TimelineRescheduleSession<T>` is pure logic. A host gesture supplies pixel or
time delta. The session returns snapped/clamped time, conflicts, overlap, and a
drop disposition. It never calls a repository.

`TimelineAutoScrollPolicy` converts pointer position into a throttled signed
scroll step.

### Conflict solver

`TimelineConflictSolver` proposes stable push-forward changes. It respects
non-draggable entries and bounded day ranges. Proposals are immutable and must
be explicitly persisted by the host.

## Complexity

- model adaptation: O(n);
- recurrence expansion: O(number of generated occurrences), bounded by window
  and `maxOccurrences`;
- render-plan sort: O(n log n);
- gap/conflict sweep: linear after sorting;
- temporal interval index: O(n log n) build;
- reschedule candidate lookup: interval-index query plus actual overlaps;
- activity/week surfaces: bounded day-plan construction over prepared entries.

## Forbidden coupling

The 6.0 core must not depend on:

- Structured's `Task` class;
- Bloc/Cubit, Provider, Riverpod, or GetX;
- Firebase, Hive, SQLite, REST, or calendar plugins;
- application translations or navigation;
- application-specific task cards or sheets.

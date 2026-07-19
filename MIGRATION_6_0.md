# Migration to 6.0

## Existing 5.x users

No mandatory source migration is required. Existing temporal queries, recurrence
rules, views, themes, and legacy exports remain available.

Update the package version, remove any stale example lockfile, and run:

```bash
flutter pub get
flutter analyze
flutter test
```

## Structured-style integration

1. Keep the existing application `Task` model.
2. Create one `TimelineEntryAdapter<Task>`.
3. Add series callbacks through `TimelineSeriesAdapter<Task>`.
4. Create one long-lived `TimelinePlannerEngine<Task>`.
5. Prepare a bounded week/month window from immutable Cubit state.
6. Feed day/week/activity results into existing widgets.
7. Persist drag/delete/conflict results through existing Cubit methods.

Do not move repositories, authentication, calendar services, translations, or
application cards into the package.

## Recurring occurrence overrides

For reliable matching, provide `originalOccurrenceStart` when an occurrence was
moved. Calendar-day matching remains the default for compatibility with planner
models that store only series id plus target date. Use
`TimelineOverrideMatch.exactStart` when the app stores exact occurrence keys.

## Mutable models

When using `TimelinePlannerDayBuilder`, supply a monotonic `dataRevision` if the
host mutates task instances or the list in place. Prefer immutable Cubit states.

## External calendar entries

Map them with `isExternal` and `draggable: false`. The package can include them
in conflicts and metrics without attempting to persist or delete them.

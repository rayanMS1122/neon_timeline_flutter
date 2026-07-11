# FocusForge integration plan

The `structured` application archive was inspected only as a reference. It was
not modified.

## What was extracted into the package

The application already had useful planner behavior:

- day changes from horizontal swipe velocity;
- task sorting by start time;
- overlap and back-to-back detection;
- long-press vertical movement;
- five-minute snapping;
- day-boundary clamping;
- haptic selection feedback;
- edge auto-scroll;
- schedule and delete swipe actions.

Those ideas are now generic package APIs. No `Task`, Cubit, translation,
Phosphor icon, Firebase, or application-theme import exists in the package.

## Dependency compatibility

The application declares:

```yaml
flutter_slidable: ^3.1.2
```

The package accepts:

```yaml
flutter_slidable: '>=3.1.2 <4.0.0'
```

Therefore the existing application constraint can resolve without requiring a
major slidable migration.

## Add the package locally

Place the package next to the application and add:

```yaml
dependencies:
  neon_timeline_flutter:
    path: ../neon_timeline_flutter
```

Then run:

```bash
flutter pub get
```

## Map the existing `Task` model

```dart
List<NeonScheduleEntry<Task>> mapTasks(List<Task> tasks) {
  return tasks.map((task) {
    return NeonScheduleEntry<Task>(
      id: task.id,
      value: task,
      start: task.startTime,
      duration: Duration(minutes: task.duration ?? 30),
      status: task.status == TaskStatus.completed
          ? NeonTimelineStatus.completed
          : NeonTimelineStatus.pending,
      color: task.color,
      semanticLabel: task.title,
      draggable: task.category != 'Calendar',
      enabled: true,
    );
  }).toList();
}
```

## Replace only the rendering layer later

The existing Cubit callbacks can remain unchanged:

```dart
NeonScheduleTimeline<Task>(
  entries: mapTasks(tasks),
  selectedDate: state.selectedDate,
  itemBuilder: (context, details) {
    final task = details.entry.value;
    return YourExistingTaskContent(task: task);
  },
  onEntryTap: (context, details) {
    showTaskDetailSheet(context, details.entry.value);
  },
  onEntryMoved: (context, details, newStart) {
    final task = details.entry.value;
    final updated = task.copyWith(startTime: newStart);
    if (task.id.startsWith('v_')) {
      taskCubit.updateRecurringTask(updated, scope: 'this');
    } else {
      taskCubit.updateTask(updated);
    }
  },
)
```

The package reports `newStart`; the Cubit still decides how recurring tasks,
calendar events, conflicts, and persistence are handled.

## Preserve day swiping

```dart
NeonTimelineDayPager(
  selectedDate: state.selectedDate,
  onDateChanged: taskCubit.setSelectedDate,
  child: NeonScheduleTimeline<Task>(
    entries: mapTasks(tasks),
    selectedDate: state.selectedDate,
    itemBuilder: buildTaskContent,
  ),
)
```

Test this together with card slide actions. If gesture competition feels wrong,
keep day navigation on the date selector and disable the whole-page pager.

## Replace custom inbox swiping later

```dart
NeonSlidableTimeline(
  slidableKey: ValueKey(item.id),
  startActions: [
    NeonTimelineAction(
      icon: Icons.calendar_month,
      label: 'PLANEN',
      color: const Color(0xFF2980B9),
      onPressed: (_) => showScheduleMenu(item),
    ),
  ],
  endActions: [
    NeonTimelineAction(
      icon: Icons.delete_outline,
      label: 'LÖSCHEN',
      color: Colors.red,
      onPressed: (_) => taskCubit.removeInboxItem(item.id),
    ),
  ],
  onStartDismissed: () => showScheduleMenu(item),
  onEndDismissed: () => taskCubit.removeInboxItem(item.id),
  child: ExistingInboxCard(item: item),
)
```

To preserve the app's existing swipe-action artwork, pass that widget as the
`child` of `NeonTimelineAction`; the package keeps the slide mechanics and outer
neon surface while the app retains its internal icon/text composition.

The package provides overridable label builders. The app should continue to
provide its translated action, gap, conflict, current-time, and time strings.

## Recommended rollout

1. Add the path dependency and run the package example.
2. Introduce the model mapping without changing the existing screen.
3. Put the package timeline behind a temporary feature flag.
4. Compare drag, conflict, calendar-event, and recurring-task behavior.
5. Replace the old renderer only after device tests pass.
6. Publish the package after the consuming app passes CI.

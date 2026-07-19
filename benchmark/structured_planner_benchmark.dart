import 'dart:io';

import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  const sizes = <int>[100, 500, 1000, 5000];
  for (final size in sizes) {
    final tasks = _tasks(size);
    final engine = TimelinePlannerEngine<_BenchmarkTask>(
      adapter: TimelineSeriesAdapter<_BenchmarkTask>(
        entryAdapter: TimelineEntryAdapter<_BenchmarkTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => task.duration,
          resourceIds: (task) => <Object>{task.resourceId},
          metadata: (task) => <String, Object?>{'title': task.title},
        ),
        seriesId: (task) => task.seriesId,
        recurrence: (task) => task.recurring
            ? TimelineRecurrenceRule.daily(count: 31)
            : null,
      ),
    );
    final monthStart = DateTime(2026, 7);
    final monthEnd = DateTime(2026, 8);

    final prepare = _measure(() {
      return engine.prepareWindow(
        values: tasks,
        windowStart: monthStart,
        windowEnd: monthEnd,
      );
    });
    final window = prepare.value;
    final day = _measure(() {
      return window.buildDay(
        selectedDate: DateTime(2026, 7, 16),
        now: DateTime(2026, 7, 16, 12),
      );
    });
    final week = _measure(() {
      return window.buildWeek(
        selectedDate: DateTime(2026, 7, 16),
        now: DateTime(2026, 7, 16, 12),
      );
    });
    final activity = _measure(() {
      return window.buildActivityIndex(
        startDate: monthStart,
        endDate: DateTime(2026, 7, 31),
        now: DateTime(2026, 7, 16, 12),
      );
    });
    final reschedule = _measure(() {
      final entry = window.expansion.entries.first;
      return engine
          .beginReschedule(
            entry: entry,
            bounds: TimelineDateRange(
              DateTime(2026, 7, 16),
              DateTime(2026, 7, 17),
            ),
            candidates: day.value.entries.map((item) => item.entry),
          )
          .previewForPixels(185);
    });

    stdout.writeln(
      'source=$size '
      'expanded=${window.expansion.entries.length} '
      'prepare_us=${prepare.microseconds} '
      'day_us=${day.microseconds} '
      'week_us=${week.microseconds} '
      'activity_us=${activity.microseconds} '
      'reschedule_us=${reschedule.microseconds} '
      'day_entries=${day.value.entries.length} '
      'week_conflicts=${week.value.conflictCount} '
      'active_days=${activity.value.activeDays}',
    );
  }
}

_Measurement<T> _measure<T>(T Function() operation) {
  operation();
  final watch = Stopwatch()..start();
  final value = operation();
  watch.stop();
  return _Measurement<T>(value, watch.elapsedMicroseconds);
}

class _Measurement<T> {
  const _Measurement(this.value, this.microseconds);

  final T value;
  final int microseconds;
}

class _BenchmarkTask {
  const _BenchmarkTask({
    required this.id,
    required this.title,
    required this.start,
    required this.duration,
    required this.resourceId,
    required this.seriesId,
    required this.recurring,
  });

  final int id;
  final String title;
  final DateTime start;
  final Duration duration;
  final String resourceId;
  final Object? seriesId;
  final bool recurring;
}

List<_BenchmarkTask> _tasks(int count) {
  final month = DateTime(2026, 7);
  return List<_BenchmarkTask>.generate(count, (index) {
    final recurring = index % 50 == 0;
    final day = 1 + (index % 28);
    final minute = (index * 17) % (24 * 60 - 60);
    return _BenchmarkTask(
      id: index,
      title: 'Task $index',
      start: DateTime(
        month.year,
        month.month,
        day,
        minute ~/ 60,
        minute % 60,
      ),
      duration: Duration(minutes: 15 + (index % 5) * 10),
      resourceId: 'resource-${index % 8}',
      seriesId: recurring ? 'series-$index' : null,
      recurring: recurring,
    );
  }, growable: false);
}

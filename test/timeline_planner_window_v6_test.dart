import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  test('prepared window reuses one expansion across planner surfaces', () {
    final engine = TimelinePlannerEngine<_Task>(
      adapter: TimelineSeriesAdapter<_Task>(
        entryAdapter: TimelineEntryAdapter<_Task>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (_) => const Duration(minutes: 30),
        ),
        seriesId: (task) => task.seriesId,
        recurrence: (task) =>
            task.recurring ? TimelineRecurrenceRule.daily(count: 7) : null,
      ),
    );
    final window = engine.prepareWindow(
      values: <_Task>[
        _Task(
          id: 'series',
          seriesId: 'series',
          start: DateTime(2026, 7, 13, 9),
          recurring: true,
        ),
      ],
      windowStart: DateTime(2026, 7, 13),
      windowEnd: DateTime(2026, 7, 20),
    );

    final day = window.buildDay(selectedDate: DateTime(2026, 7, 16));
    final week = window.buildWeek(selectedDate: DateTime(2026, 7, 16));
    final activity = window.buildActivityIndex(
      startDate: DateTime(2026, 7, 13),
      endDate: DateTime(2026, 7, 19),
    );

    expect(window.expansion.generatedCount, 7);
    expect(day.entries, hasLength(1));
    expect(
      week.lanes.every((lane) => lane.dayPlan.entries.length == 1),
      isTrue,
    );
    expect(activity.activeDays, 7);
  });

  test('prepareMonth includes adjacent calendar weeks', () {
    final engine = TimelinePlannerEngine<_Task>(
      adapter: TimelineSeriesAdapter<_Task>(
        entryAdapter: TimelineEntryAdapter<_Task>(
          id: (task) => task.id,
          start: (task) => task.start,
        ),
      ),
    );
    final window = engine.prepareMonth(
      values: const <_Task>[],
      month: DateTime(2026, 8, 15),
    );

    expect(window.range.start, DateTime(2026, 7, 27));
    expect(window.range.end, DateTime(2026, 9, 7));
  });
}

class _Task {
  const _Task({
    required this.id,
    required this.seriesId,
    required this.start,
    required this.recurring,
  });

  final String id;
  final String seriesId;
  final DateTime start;
  final bool recurring;
}

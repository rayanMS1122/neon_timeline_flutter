import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  _weeklyCalendarAnchorRegressionTests();
  test(
    'daily recurrence preserves duration and creates stable occurrences',
    () {
      final start = DateTime(2026, 2, 1, 9);
      final prototype = TimelineEntry<String>(
        id: 'sync',
        value: 'Daily sync',
        start: start,
        duration: const Duration(minutes: 30),
      );

      final occurrences = TimelineRecurrenceRule.daily(count: 3).expand<String>(
        prototype: prototype,
        windowStart: start,
        windowEnd: start.add(const Duration(days: 10)),
      );

      expect(occurrences, hasLength(3));
      expect(occurrences[1].start, DateTime(2026, 2, 2, 9));
      expect(occurrences[2].rawDuration, const Duration(minutes: 30));
      expect(occurrences.map((entry) => entry.id).toSet(), hasLength(3));
    },
  );

  test('weekly recurrence respects selected weekdays', () {
    final monday = DateTime(2026, 2, 2, 9);
    final prototype = TimelineEntry<String>(
      id: 'review',
      value: 'Review',
      start: monday,
      duration: const Duration(hours: 1),
    );

    final occurrences =
        TimelineRecurrenceRule.weekly(
          count: 4,
          weekdays: const <int>{DateTime.monday, DateTime.wednesday},
        ).expand<String>(
          prototype: prototype,
          windowStart: monday,
          windowEnd: monday.add(const Duration(days: 30)),
        );

    expect(occurrences, hasLength(4));
    expect(occurrences.map((entry) => entry.start.weekday), <int>[
      DateTime.monday,
      DateTime.wednesday,
      DateTime.monday,
      DateTime.wednesday,
    ]);
  });
}

void _weeklyCalendarAnchorRegressionTests() {
  test('weekly recurrence is anchored to calendar weeks', () {
    final wednesday = DateTime(2026, 7, 15, 9);
    final prototype = TimelineEntry<String>(
      id: 'calendar-week',
      value: 'Calendar week',
      start: wednesday,
      duration: const Duration(minutes: 30),
    );

    final occurrences =
        TimelineRecurrenceRule.weekly(
          count: 4,
          weekdays: const <int>{DateTime.monday, DateTime.friday},
        ).expand<String>(
          prototype: prototype,
          windowStart: DateTime(2026, 7, 1),
          windowEnd: DateTime(2026, 8, 1),
        );

    expect(occurrences.map((entry) => entry.start), <DateTime>[
      DateTime(2026, 7, 17, 9),
      DateTime(2026, 7, 20, 9),
      DateTime(2026, 7, 24, 9),
      DateTime(2026, 7, 27, 9),
    ]);
  });

  test('weekly fast-forward keeps global occurrence count', () {
    final monday = DateTime(2020, 1, 6, 9);
    final prototype = TimelineEntry<String>(
      id: 'bounded-weekly',
      value: 'Bounded weekly',
      start: monday,
      duration: const Duration(minutes: 30),
    );

    final occurrences =
        TimelineRecurrenceRule.weekly(
          count: 3,
          weekdays: const <int>{DateTime.monday},
        ).expand<String>(
          prototype: prototype,
          windowStart: DateTime(2026, 7, 1),
          windowEnd: DateTime(2026, 8, 1),
        );

    expect(occurrences, isEmpty);
  });
}

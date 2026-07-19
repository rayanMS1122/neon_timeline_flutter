import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  _customOccurrenceIdTests();
  test('recurring occurrence can be moved and one occurrence deleted', () {
    final base = TimelineEntry<String>(
      id: 'series',
      value: 'base',
      start: DateTime(2026, 7, 13, 9),
      duration: const Duration(minutes: 30),
    );
    final moved = TimelineEntry<String>(
      id: 'override-1',
      value: 'moved',
      start: DateTime(2026, 7, 14, 11),
      duration: const Duration(minutes: 30),
    );
    final deleted = TimelineEntry<String>(
      id: 'override-2',
      value: 'deleted',
      start: DateTime(2026, 7, 15, 9),
      duration: const Duration(minutes: 30),
    );

    final expansion = const TimelineSeriesExpander<String>().expand(
      items: <TimelineSeriesItem<String>>[
        TimelineSeriesItem<String>.recurring(
          entry: base,
          rule: TimelineRecurrenceRule.daily(),
        ),
        TimelineSeriesItem<String>.override(
          entry: moved,
          seriesId: 'series',
          originalOccurrenceStart: DateTime(2026, 7, 14, 9),
        ),
        TimelineSeriesItem<String>.override(
          entry: deleted,
          seriesId: 'series',
          originalOccurrenceStart: DateTime(2026, 7, 15, 9),
          deleted: true,
        ),
      ],
      windowStart: DateTime(2026, 7, 13),
      windowEnd: DateTime(2026, 7, 17),
    );

    expect(expansion.entries, hasLength(3));
    expect(
      expansion.entries.any(
        (entry) => entry.start == DateTime(2026, 7, 14, 11),
      ),
      isTrue,
    );
    expect(
      expansion.entries.any((entry) => entry.start == DateTime(2026, 7, 15, 9)),
      isFalse,
    );
    expect(expansion.overriddenCount, 1);
    expect(expansion.deletedOccurrenceCount, 1);
  });

  _seriesIntegrityTests();
}

void _seriesIntegrityTests() {
  test('duplicate overrides and final entry ids are reported', () {
    final base = TimelineEntry<String>(
      id: 'series',
      value: 'base',
      start: DateTime(2026, 7, 13, 9),
      duration: const Duration(minutes: 30),
    );
    TimelineSeriesItem<String> override(String id, String value) {
      return TimelineSeriesItem<String>.override(
        entry: TimelineEntry<String>(
          id: id,
          value: value,
          start: DateTime(2026, 7, 14, 11),
          duration: const Duration(minutes: 30),
        ),
        seriesId: 'series',
        originalOccurrenceStart: DateTime(2026, 7, 14, 9),
      );
    }

    final expansion = const TimelineSeriesExpander<String>().expand(
      items: <TimelineSeriesItem<String>>[
        TimelineSeriesItem<String>.recurring(
          entry: base,
          rule: TimelineRecurrenceRule.daily(count: 2),
        ),
        override('same-id', 'first'),
        override('same-id', 'second'),
      ],
      windowStart: DateTime(2026, 7, 13),
      windowEnd: DateTime(2026, 7, 16),
    );

    expect(expansion.shadowedOverrides, hasLength(1));
    expect(expansion.duplicateEntryIds, isEmpty);
    expect(expansion.hasDataIntegrityIssues, isTrue);
  });

  test('deleted recurring base emits no occurrences', () {
    final base = TimelineEntry<String>(
      id: 'deleted-series',
      value: 'deleted-series',
      start: DateTime(2026, 7, 1, 9),
      duration: const Duration(minutes: 30),
    );
    final expansion = const TimelineSeriesExpander<String>().expand(
      items: <TimelineSeriesItem<String>>[
        TimelineSeriesItem<String>.recurring(
          entry: base,
          rule: TimelineRecurrenceRule.daily(),
          deleted: true,
        ),
      ],
      windowStart: DateTime(2026, 7, 1),
      windowEnd: DateTime(2026, 7, 8),
    );

    expect(expansion.entries, isEmpty);
  });

  test('monthly recurrence accepts an application-owned month day', () {
    final prototype = TimelineEntry<String>(
      id: 'monthly',
      value: 'monthly',
      start: DateTime(2026, 1, 5, 9),
      duration: const Duration(minutes: 30),
    );
    final entries = TimelineRecurrenceRule.monthly(dayOfMonth: 31, count: 3)
        .expand<String>(
          prototype: prototype,
          windowStart: DateTime(2026, 1),
          windowEnd: DateTime(2026, 4),
        );

    expect(entries.map((entry) => entry.start.day), <int>[31, 28, 31]);
  });

  test('weekly UTC recurrence preserves UTC semantics', () {
    final prototype = TimelineEntry<String>(
      id: 'utc',
      value: 'utc',
      start: DateTime.utc(2026, 7, 13, 9),
      duration: const Duration(minutes: 30),
    );
    final entries =
        TimelineRecurrenceRule.weekly(
          weekdays: const <int>{DateTime.monday, DateTime.wednesday},
          count: 3,
        ).expand<String>(
          prototype: prototype,
          windowStart: DateTime.utc(2026, 7, 13),
          windowEnd: DateTime.utc(2026, 7, 24),
        );

    expect(entries, hasLength(3));
    expect(entries.every((entry) => entry.start.isUtc), isTrue);
  });
}

void _customOccurrenceIdTests() {
  test('series expander supports application-owned virtual ids', () {
    final base = TimelineSeriesItem<String>.recurring(
      entry: TimelineEntry<String>(
        id: 'series-id',
        value: 'base',
        start: DateTime(2026, 7, 13, 9),
        duration: const Duration(minutes: 30),
      ),
      rule: TimelineRecurrenceRule.daily(count: 2),
    );

    final expansion =
        TimelineSeriesExpander<String>(
          occurrenceIdBuilder: (series, index, start) =>
              'v_${series.effectiveSeriesId}_${start.millisecondsSinceEpoch}',
        ).expand(
          items: <TimelineSeriesItem<String>>[base],
          windowStart: DateTime(2026, 7, 13),
          windowEnd: DateTime(2026, 7, 16),
        );

    expect(expansion.entries, hasLength(2));
    expect(expansion.entries.first.id, startsWith('v_series-id_'));
  });
}

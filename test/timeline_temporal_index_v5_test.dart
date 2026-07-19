import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  test('temporal index returns only intersecting entries', () {
    final day = DateTime(2026, 1, 10);
    final entries = <TimelineEntry<String>>[
      TimelineEntry(
        id: 'a',
        value: 'A',
        start: day.add(const Duration(hours: 8)),
        duration: const Duration(hours: 1),
      ),
      TimelineEntry(
        id: 'b',
        value: 'B',
        start: day.add(const Duration(hours: 10)),
        duration: const Duration(hours: 2),
      ),
      TimelineEntry(
        id: 'c',
        value: 'C',
        start: day.add(const Duration(hours: 14)),
        duration: const Duration(hours: 1),
      ),
    ];

    final index = TimelineTemporalIndex<String>.build(entries);
    final result = index.query(
      start: day.add(const Duration(hours: 9, minutes: 30)),
      end: day.add(const Duration(hours: 10, minutes: 30)),
    );

    expect(result.map((entry) => entry.id), <Object>['b']);
    expect(index.nextAfter(day.add(const Duration(hours: 12)))?.id, 'c');
  });

  test('query combines range, text, status, and resource filters', () {
    final day = DateTime(2026, 1, 10);
    final entries = <TimelineEntry<String>>[
      TimelineEntry(
        id: 'a',
        value: 'Architecture',
        start: day.add(const Duration(hours: 8)),
        duration: const Duration(hours: 1),
        status: TimelineStatus.active,
        resourceIds: const <Object>{'engineering'},
      ),
      TimelineEntry(
        id: 'b',
        value: 'Documentation',
        start: day.add(const Duration(hours: 10)),
        duration: const Duration(hours: 1),
        status: TimelineStatus.pending,
        resourceIds: const <Object>{'product'},
      ),
    ];

    final result = TimelineQuery<String>(
      text: 'arch',
      statuses: const <TimelineStatus>{TimelineStatus.active},
      resourceIds: const <Object>{'engineering'},
      rangeStart: day,
      rangeEnd: day.add(const Duration(days: 1)),
      searchText: (entry) => entry.value,
    ).apply(entries);

    expect(result.matchCount, 1);
    expect(result.entries.single.id, 'a');
    expect(result.countForStatus(TimelineStatus.active), 1);
  });
}

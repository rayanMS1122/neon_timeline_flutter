import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('day plan exposes gaps, conflicts, current and next entries', () {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'a',
        value: 'a',
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(hours: 1),
      ),
      TimelineEntry<String>(
        id: 'b',
        value: 'b',
        start: DateTime(2026, 7, 16, 9, 30),
        duration: const Duration(hours: 1),
      ),
      TimelineEntry<String>(
        id: 'c',
        value: 'c',
        start: DateTime(2026, 7, 16, 12),
        duration: const Duration(minutes: 30),
      ),
    ];

    final plan = TimelineDayPlanBuilder.build<String>(
      entries: entries,
      selectedDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 10, 45),
      config: const TimelineDayPlanConfig(
        dayStartOffset: Duration(hours: 8),
        dayEndOffset: Duration(hours: 18),
      ),
    );

    expect(plan.entries, hasLength(3));
    expect(plan.conflicts, hasLength(1));
    expect(plan.insight.current, isNull);
    expect(plan.insight.next?.entry.id, 'c');
    expect(plan.insight.currentGap, isNotNull);
    expect(plan.busyDuration, const Duration(hours: 2));
    expect(
      plan.nodes.any((node) => node.kind == TimelineDayNodeKind.now),
      isTrue,
    );
  });
}

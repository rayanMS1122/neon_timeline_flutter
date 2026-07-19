import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v10.dart';

void main() {
  test('maps compressed visual gaps back to real clock time', () {
    final day = DateTime(2026, 7, 17);
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'morning',
        value: 'morning',
        start: day.add(const Duration(hours: 8)),
        duration: const Duration(hours: 1),
      ),
      TimelineEntry<String>(
        id: 'evening',
        value: 'evening',
        start: day.add(const Duration(hours: 17)),
        duration: const Duration(hours: 1),
      ),
    ];
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: entries,
      selectedDate: day,
      config: const TimelineDayPlanConfig(
        dayStartOffset: Duration(hours: 8),
        dayEndOffset: Duration(hours: 18),
        includeBoundaryGaps: false,
      ),
    );
    final map = TimelineVisualCoordinateMap<String>.build(
      plan: plan,
      entryExtent: (_) => 60,
      gapExtent: (_) => 80,
    );

    // 60 px first entry + halfway through the compressed eight-hour gap.
    final mapped = map.timeForOffset(100);
    expect(mapped, day.add(const Duration(hours: 13)));
  });

  test('round-trips an entry start using its stable id', () {
    final day = DateTime(2026, 7, 17);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'entry',
      start: day.add(const Duration(hours: 10, minutes: 15)),
      duration: const Duration(minutes: 45),
    );
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: <TimelineEntry<String>>[entry],
      selectedDate: day,
      config: const TimelineDayPlanConfig(
        dayStartOffset: Duration(hours: 8),
        dayEndOffset: Duration(hours: 18),
        includeBoundaryGaps: true,
      ),
    );
    final map = TimelineVisualCoordinateMap<String>.build(
      plan: plan,
      includeBoundaryGaps: true,
      entryExtent: (_) => 72,
      gapExtent: (gap) => gap.duration.inHours * 20,
    );

    final offset = map.offsetForTime(entry.start, entryId: entry.id);
    expect(map.timeForOffset(offset), entry.start);
  });

  test('viewport conversion and hit-test expose the real visual segment', () {
    final day = DateTime(2026, 7, 17);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'entry',
      start: day.add(const Duration(hours: 9)),
      duration: const Duration(hours: 1),
    );
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: [entry],
      selectedDate: day,
      config: const TimelineDayPlanConfig(
        dayStartOffset: Duration(hours: 8),
        dayEndOffset: Duration(hours: 12),
        includeBoundaryGaps: true,
      ),
    );
    final map = TimelineVisualCoordinateMap<String>.build(
      plan: plan,
      includeBoundaryGaps: true,
      entryExtent: (_) => 60,
      gapExtent: (_) => 40,
    );

    final viewportOffset = map.viewportOffsetForTime(
      entry.start,
      scrollOffset: 20,
      headerExtent: 10,
    );
    expect(
      map.timeForViewportOffset(
        viewportOffset,
        scrollOffset: 20,
        headerExtent: 10,
      ),
      entry.start,
    );
    expect(map.hitTest(map.offsetForTime(entry.start)).isEntry, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  group('Timeline 4.0 advanced engine', () {
    test('conflict index exposes O(1) type lookups', () {
      final start = DateTime(2026, 7, 13, 9);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'outer',
            value: 'Outer',
            start: start,
            duration: const Duration(hours: 3),
          ),
          TimelineEntry<String>(
            id: 'inner',
            value: 'Inner',
            start: start.add(const Duration(minutes: 30)),
            duration: const Duration(minutes: 30),
          ),
        ],
      );

      expect(plan.entryHasConflict('outer'), isTrue);
      expect(plan.entryHasConflict('missing'), isFalse);
      expect(
        plan.conflictTypeFor('inner'),
        TimelineConflictType.fullContainment,
      );
      expect(plan.conflictingEntryIds, <Object>{'outer', 'inner'});
    });

    test('selected day uses the next calendar date as its boundary', () {
      final selected = DateTime(2026, 3, 29, 12);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'day',
            value: 'day',
            start: DateTime(2026, 3, 29, 8),
          ),
        ],
        selectedDate: selected,
      );

      expect(plan.dayStart?.year, 2026);
      expect(plan.dayStart?.month, 3);
      expect(plan.dayStart?.day, 29);
      expect(plan.dayEnd?.year, 2026);
      expect(plan.dayEnd?.month, 3);
      expect(plan.dayEnd?.day, 30);
      expect(plan.currentTimePosition, inInclusiveRange(0, 1));
    });

    test('day layout reuses columns after entries end', () {
      final start = DateTime(2026, 7, 13, 8);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'a',
            value: 'A',
            start: start,
            duration: const Duration(hours: 2),
          ),
          TimelineEntry<String>(
            id: 'b',
            value: 'B',
            start: start.add(const Duration(minutes: 30)),
            duration: const Duration(minutes: 30),
          ),
          TimelineEntry<String>(
            id: 'c',
            value: 'C',
            start: start.add(const Duration(hours: 1)),
            duration: const Duration(minutes: 30),
          ),
        ],
      );
      final layout = TimelineDayLayoutEngine.layout<String>(
        plan: plan,
        rangeStart: start,
        rangeEnd: start.add(const Duration(hours: 4)),
      );

      expect(layout, hasLength(3));
      expect(layout.map((item) => item.columnCount).toSet(), <int>{2});
      expect(layout.first.column, 0);
      expect(layout[1].column, 1);
      expect(layout[2].column, 1);
    });

    test(
      'analytics measures occupied union instead of double-counting overlap',
      () {
        final start = DateTime(2026, 7, 13, 8);
        final plan = TimelineRenderPlan<String>.build(
          entries: <TimelineEntry<String>>[
            TimelineEntry<String>(
              id: 'a',
              value: 'A',
              start: start,
              duration: const Duration(hours: 2),
              status: TimelineStatus.completed,
            ),
            TimelineEntry<String>(
              id: 'b',
              value: 'B',
              start: start.add(const Duration(hours: 1)),
              duration: const Duration(hours: 2),
            ),
          ],
        );
        final analytics = TimelineAnalytics.analyze<String>(
          plan: plan,
          rangeStart: start,
          rangeEnd: start.add(const Duration(hours: 4)),
        );

        expect(analytics.totalScheduledDuration, const Duration(hours: 4));
        expect(analytics.occupiedDuration, const Duration(hours: 3));
        expect(analytics.availableDuration, const Duration(hours: 1));
        expect(analytics.peakConcurrency, 2);
        expect(analytics.completionRate, 0.5);
      },
    );

    test('adaptive performance disables motion for reduced motion', () {
      const config = TimelinePerformanceConfig.adaptive();
      final reduced = config.resolve(
        isWeb: true,
        entryCount: 5000,
        reduceMotion: true,
      );

      expect(reduced.maxAnimatedEntries, 0);
      expect(reduced.motionFramesPerSecond, 1);
      expect(reduced.enableBackdropBlur, isFalse);
      expect(reduced.overscanItems, lessThanOrEqualTo(3));
    });

    test('capacity analysis resolves only real resource assignments', () {
      final start = DateTime(2026, 7, 13, 9);
      final entries = <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'a',
          value: 'A',
          start: start,
          duration: const Duration(hours: 2),
          resourceIds: const <Object>{'team-a'},
        ),
        TimelineEntry<String>(
          id: 'b',
          value: 'B',
          start: start.add(const Duration(minutes: 30)),
          duration: const Duration(hours: 1),
          resourceIds: const <Object>{'team-a', 'room'},
        ),
        TimelineEntry<String>(
          id: 'c',
          value: 'C',
          start: start,
          resourceIds: const <Object>{'unknown'},
        ),
      ];
      var resolverCalls = 0;
      final conflicts = TimelineCapacityEngine.analyze<String>(
        entries: entries,
        resources: const <TimelineResourceCapacity>[
          TimelineResourceCapacity(id: 'team-a'),
          TimelineResourceCapacity(id: 'room'),
          TimelineResourceCapacity(id: 'unused'),
        ],
        usageResolver: (entry, resourceId) {
          resolverCalls++;
          return 1;
        },
      );

      expect(resolverCalls, 3);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.resourceId, 'team-a');
    });

    test('window analytics excludes entries outside the requested range', () {
      final start = DateTime(2026, 7, 13, 8);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'inside',
            value: 'Inside',
            start: start,
            duration: const Duration(hours: 1),
            status: TimelineStatus.completed,
          ),
          TimelineEntry<String>(
            id: 'outside',
            value: 'Outside',
            start: start.add(const Duration(hours: 6)),
            duration: const Duration(hours: 1),
          ),
        ],
      );

      final analytics = TimelineAnalytics.analyze<String>(
        plan: plan,
        rangeStart: start,
        rangeEnd: start.add(const Duration(hours: 2)),
      );

      expect(analytics.entryCount, 1);
      expect(analytics.countForStatus(TimelineStatus.completed), 1);
      expect(analytics.totalScheduledDuration, const Duration(hours: 1));
    });

    test('invalid range type is not copied to valid cluster members', () {
      final start = DateTime(2026, 7, 13, 9);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'invalid',
            value: 'Invalid',
            start: start,
            end: start,
          ),
          TimelineEntry<String>(
            id: 'valid',
            value: 'Valid',
            start: start,
            duration: const Duration(hours: 1),
          ),
        ],
      );

      expect(
        plan.conflictTypeFor('invalid'),
        TimelineConflictType.invalidRange,
      );
      expect(
        plan.conflictTypeFor('valid'),
        TimelineConflictType.partialOverlap,
      );
    });

    test('entry revision changes when the application value changes', () {
      final entry = TimelineEntry<String>(
        id: 'entry',
        value: 'Before',
        start: DateTime(2026, 7, 13, 9),
      );
      final changed = entry.copyWith(value: 'After');

      expect(changed.revisionHash, isNot(entry.revisionHash));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  group('TimelineRenderPlan 4.0', () {
    test('sorts once, detects containment, and emits real free gaps', () {
      final entries = <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'late',
          value: 'late',
          start: DateTime(2026, 7, 13, 13),
          duration: const Duration(hours: 1),
        ),
        TimelineEntry<String>(
          id: 'outer',
          value: 'outer',
          start: DateTime(2026, 7, 13, 9),
          duration: const Duration(hours: 3),
        ),
        TimelineEntry<String>(
          id: 'inner',
          value: 'inner',
          start: DateTime(2026, 7, 13, 10),
          duration: const Duration(minutes: 30),
        ),
      ];

      final plan = TimelineRenderPlan<String>.build(
        entries: entries,
        now: DateTime(2026, 7, 13, 10, 15),
      );

      expect(plan.entries.map((entry) => entry.entry.id), <Object>[
        'outer',
        'inner',
        'late',
      ]);
      expect(plan.conflicts, hasLength(1));
      expect(plan.conflicts.single.type, TimelineConflictType.fullContainment);
      expect(plan.gaps, hasLength(1));
      expect(plan.gaps.single.duration, const Duration(hours: 1));
      expect(plan.activeEntries.map((entry) => entry.entry.id), <Object>[
        'outer',
        'inner',
      ]);
    });

    test('classifies same-range entries and duplicate ids', () {
      final start = DateTime.utc(2026, 7, 13, 9);
      final plan = TimelineRenderPlan<int>.build(
        entries: <TimelineEntry<int>>[
          TimelineEntry<int>(
            id: 'duplicate',
            value: 1,
            start: start,
            duration: const Duration(hours: 1),
          ),
          TimelineEntry<int>(
            id: 'duplicate',
            value: 2,
            start: start,
            duration: const Duration(hours: 1),
          ),
        ],
        timeSemantics: TimelineTimeSemantics.utc,
      );

      expect(plan.conflicts.single.type, TimelineConflictType.sameRange);
      expect(plan.hasDuplicateIds, isTrue);
      expect(plan.duplicateIds, contains('duplicate'));
    });

    test('normalizes an invalid singleton without losing diagnostics', () {
      final start = DateTime(2026, 7, 13, 9);
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'invalid',
            value: 'invalid',
            start: start,
            end: start.subtract(const Duration(minutes: 10)),
          ),
        ],
      );

      expect(plan.entries.single.invalidRange, isTrue);
      expect(plan.entries.single.duration, const Duration(minutes: 1));
      expect(plan.conflicts.single.type, TimelineConflictType.invalidRange);
    });

    test('cache reuses a revision-stable plan', () {
      final entries = <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'cached',
          value: 'cached',
          start: DateTime(2026, 7, 13, 9),
        ),
      ];
      final cache = TimelineRenderPlanCache<String>();
      final now = DateTime(2026, 7, 13, 9, 10);

      final first = cache.resolve(entries: entries, dataRevision: 1, now: now);
      final second = cache.resolve(
        entries: List<TimelineEntry<String>>.of(entries),
        dataRevision: 1,
        now: now.add(const Duration(seconds: 20)),
      );

      expect(second, same(first));
      expect(cache.builds, 1);
      expect(cache.hits, 1);
    });

    test('clips selected UTC days with UTC boundaries', () {
      final plan = TimelineRenderPlan<String>.build(
        entries: <TimelineEntry<String>>[
          TimelineEntry<String>(
            id: 'crossing',
            value: 'crossing',
            start: DateTime.utc(2026, 7, 12, 23, 30),
            duration: const Duration(hours: 2),
          ),
        ],
        selectedDate: DateTime.utc(2026, 7, 13),
        timeSemantics: TimelineTimeSemantics.utc,
      );

      expect(plan.entries.single.start, DateTime.utc(2026, 7, 13));
      expect(plan.entries.single.end, DateTime.utc(2026, 7, 13, 1, 30));
      expect(plan.entries.single.start.isUtc, isTrue);
    });
  });
}

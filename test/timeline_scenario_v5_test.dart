import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  test('scenario comparison detects added, removed, and modified entries', () {
    final day = DateTime(2026, 3, 1);
    final baseEntry = TimelineEntry<String>(
      id: 'a',
      value: 'A',
      start: day,
      duration: const Duration(hours: 1),
    );
    final removed = TimelineEntry<String>(
      id: 'removed',
      value: 'Removed',
      start: day.add(const Duration(hours: 2)),
    );
    final modified = baseEntry.copyWith(
      start: day.add(const Duration(minutes: 30)),
      status: TimelineStatus.completed,
    );
    final added = TimelineEntry<String>(
      id: 'added',
      value: 'Added',
      start: day.add(const Duration(hours: 4)),
    );

    final comparison = TimelineScenarioEngine.compare<String>(
      base: TimelineScenario<String>(
        id: 'base',
        name: 'Base',
        entries: <TimelineEntry<String>>[baseEntry, removed],
      ),
      candidate: TimelineScenario<String>(
        id: 'candidate',
        name: 'Candidate',
        entries: <TimelineEntry<String>>[modified, added],
      ),
    );

    expect(comparison.addedCount, 1);
    expect(comparison.removedCount, 1);
    expect(comparison.modifiedCount, 1);
    expect(comparison.modified.single.moved, isTrue);
    expect(comparison.modified.single.statusChanged, isTrue);
  });
}

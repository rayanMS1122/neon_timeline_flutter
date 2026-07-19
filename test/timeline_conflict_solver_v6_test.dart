import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('push-forward solver returns persistence proposals', () {
    final resolution = TimelineConflictSolver.pushForward<String>(
      entries: <TimelineEntry<String>>[
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
          duration: const Duration(minutes: 30),
        ),
      ],
      bounds: TimelineDateRange(
        DateTime(2026, 7, 16, 8),
        DateTime(2026, 7, 16, 18),
      ),
    );

    expect(resolution.proposals[1].proposedStart, DateTime(2026, 7, 16, 10));
    expect(resolution.isFullyResolved, isTrue);
  });

  test('non-draggable boundary entry is never shifted', () {
    final external = TimelineEntry<String>(
      id: 'calendar',
      value: 'calendar',
      start: DateTime(2026, 7, 16, 7, 45),
      duration: const Duration(minutes: 45),
      draggable: false,
    );
    final resolution = TimelineConflictSolver.pushForward<String>(
      entries: <TimelineEntry<String>>[external],
      bounds: TimelineDateRange(
        DateTime(2026, 7, 16, 8),
        DateTime(2026, 7, 16, 18),
      ),
    );

    expect(resolution.proposals.single.proposedStart, external.start);
    expect(resolution.unresolvedEntries, <TimelineEntry<String>>[external]);
  });
}

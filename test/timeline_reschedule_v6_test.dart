import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test(
    'drag preview snaps, clamps, previews conflicts, and supports delete',
    () {
      final entry = TimelineEntry<String>(
        id: 'move',
        value: 'move',
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(hours: 1),
      );
      final blocker = TimelineEntry<String>(
        id: 'blocker',
        value: 'blocker',
        start: DateTime(2026, 7, 16, 10),
        duration: const Duration(hours: 1),
      );
      final session = TimelineRescheduleSession<String>(
        entry: entry,
        bounds: TimelineDateRange(
          DateTime(2026, 7, 16, 8),
          DateTime(2026, 7, 16, 18),
        ),
        candidates: <TimelineEntry<String>>[entry, blocker],
        policy: const TimelineReschedulePolicy(allowConflicts: false),
      );

      final preview = session.previewForDelta(const Duration(minutes: 58));
      expect(preview.start, DateTime(2026, 7, 16, 10));
      expect(preview.requestedDelta, const Duration(minutes: 58));
      expect(preview.snappedDelta, const Duration(hours: 1));
      expect(preview.snapIndex, 12);
      expect(preview.apply().start, preview.start);
      expect(preview.hasConflicts, isTrue);
      expect(preview.canCommit, isFalse);
      expect(
        session.resolveDrop(preview: preview).disposition,
        TimelineDropDisposition.blocked,
      );
      expect(
        session
            .resolveDrop(preview: preview, overDeleteTarget: true)
            .disposition,
        TimelineDropDisposition.delete,
      );
    },
  );

  test('entry longer than bounds is blocked', () {
    final entry = TimelineEntry<String>(
      id: 'long',
      value: 'long',
      start: DateTime(2026, 7, 16, 8),
      duration: const Duration(hours: 12),
    );
    final session = TimelineRescheduleSession<String>(
      entry: entry,
      bounds: TimelineDateRange(
        DateTime(2026, 7, 16, 8),
        DateTime(2026, 7, 16, 12),
      ),
    );
    final preview = session.previewForDelta(Duration.zero);

    expect(preview.fitsInBounds, isFalse);
    expect(preview.canCommit, isFalse);
    expect(
      session.resolveDrop(preview: preview).disposition,
      TimelineDropDisposition.blocked,
    );
  });

  test('non-draggable entry cannot use drag delete target', () {
    final entry = TimelineEntry<String>(
      id: 'external',
      value: 'external',
      start: DateTime(2026, 7, 16, 9),
      draggable: false,
    );
    final session = TimelineRescheduleSession<String>(
      entry: entry,
      bounds: TimelineDateRange(DateTime(2026, 7, 16), DateTime(2026, 7, 17)),
    );
    final preview = session.previewForDelta(Duration.zero);

    expect(
      session.resolveDrop(preview: preview, overDeleteTarget: true).disposition,
      TimelineDropDisposition.blocked,
    );
  });

  test('auto scroll direction follows pointer edge', () {
    const policy = TimelineAutoScrollPolicy();
    expect(policy.deltaFor(pointer: 10, viewportExtent: 800), lessThan(0));
    expect(policy.deltaFor(pointer: 790, viewportExtent: 800), greaterThan(0));
    expect(policy.deltaFor(pointer: 400, viewportExtent: 800), 0);
    expect(policy.deltaFor(pointer: 50, viewportExtent: 100), 0);
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  group('StructuredTimelineController', () {
    test('publishes navigation, nudge, zoom and invalidation requests', () {
      final controller = StructuredTimelineController<String>();
      controller.selectEntry('a');
      controller.jumpToEntry('a');
      controller.moveSelectionBy(const Duration(minutes: 5));
      controller.zoomIn();
      controller.invalidateEntry('a');

      expect(controller.selectedId, 'a');
      expect(controller.navigationRequest?.entryId, 'a');
      expect(controller.nudgeRequest?.delta, const Duration(minutes: 5));
      expect(controller.zoom, greaterThan(1));
      expect(controller.invalidation?.entryIds, contains('a'));
    });
  });

  group('TimelineResizeSession', () {
    test('snaps and resizes the end edge', () {
      final entry = TimelineEntry<String>(
        id: 'a',
        value: 'A',
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(minutes: 30),
      );
      final session = TimelineResizeSession<String>(
        entry: entry,
        edge: TimelineResizeEdge.end,
        bounds: TimelineDateRange(DateTime(2026, 7, 16), DateTime(2026, 7, 17)),
        policy: const TimelineResizePolicy(
          snap: Duration(minutes: 5),
          pixelsPerMinute: 1,
        ),
      );

      final preview = session.previewForPixels(13);
      expect(preview.end, DateTime(2026, 7, 16, 9, 45));
      expect(preview.duration, const Duration(minutes: 45));
      expect(session.resolve(preview: preview).accepted, isTrue);
    });

    test('does not commit a disabled or locked entry', () {
      final entry = TimelineEntry<String>(
        id: 'locked',
        value: 'Locked',
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(minutes: 30),
        draggable: false,
      );
      final session = TimelineResizeSession<String>(
        entry: entry,
        edge: TimelineResizeEdge.end,
        bounds: TimelineDateRange(DateTime(2026, 7, 16), DateTime(2026, 7, 17)),
      );

      final preview = session.previewForDelta(const Duration(minutes: 10));
      expect(preview.canCommit, isFalse);
      expect(session.resolve(preview: preview).accepted, isFalse);
    });

    test('can block conflicting resize', () {
      final entry = TimelineEntry<String>(
        id: 'a',
        value: 'A',
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(minutes: 30),
      );
      final blocker = TimelineEntry<String>(
        id: 'b',
        value: 'B',
        start: DateTime(2026, 7, 16, 9, 40),
        duration: const Duration(minutes: 30),
      );
      final session = TimelineResizeSession<String>(
        entry: entry,
        edge: TimelineResizeEdge.end,
        bounds: TimelineDateRange(DateTime(2026, 7, 16), DateTime(2026, 7, 17)),
        candidates: <TimelineEntry<String>>[entry, blocker],
        policy: const TimelineResizePolicy(
          allowConflicts: false,
          pixelsPerMinute: 1,
        ),
      );

      final preview = session.previewForDelta(const Duration(minutes: 20));
      expect(preview.hasConflicts, isTrue);
      expect(preview.canCommit, isFalse);
    });
  });

  test('TimelineViewportIndex returns only intersecting entries', () {
    final day = DateTime(2026, 7, 16);
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'a',
          value: 'A',
          start: DateTime(2026, 7, 16, 8),
          duration: const Duration(hours: 1),
        ),
        TimelineEntry<String>(
          id: 'b',
          value: 'B',
          start: DateTime(2026, 7, 16, 11),
          duration: const Duration(hours: 1),
        ),
      ],
      selectedDate: day,
      now: DateTime(2026, 7, 16, 7),
    );
    final index = TimelineViewportIndex<String>.build(plan.entries);
    final slice = index.query(
      start: DateTime(2026, 7, 16, 10, 30),
      end: DateTime(2026, 7, 16, 12, 30),
    );

    expect(slice.entries.map((entry) => entry.entry.id), <Object>['b']);
    expect(slice.firstIndex, 1);
  });

  test('slot suggestions rank a usable free range', () {
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'a',
          value: 'A',
          start: DateTime(2026, 7, 16, 9),
          duration: const Duration(hours: 1),
        ),
      ],
      selectedDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 10, 15),
    );
    final suggestions = TimelineSlotSuggestionEngine.suggest<String>(
      plan: plan,
      requestedDuration: const Duration(minutes: 45),
      policy: TimelineSlotSuggestionPolicy(
        earliest: DateTime(2026, 7, 16, 10),
        latest: DateTime(2026, 7, 16, 18),
      ),
    );

    expect(suggestions, isNotEmpty);
    expect(suggestions.first.duration, const Duration(minutes: 45));
    expect(suggestions.first.start.minute % 5, 0);
  });

  test('mutation coordinator runs rollback after a failed commit', () async {
    final coordinator = TimelineMutationCoordinator<String>();
    final entry = TimelineEntry<String>(
      id: 'rollback',
      value: 'Rollback',
      start: DateTime(2026, 7, 16, 9),
    );
    var rolledBack = false;
    final result = await coordinator.execute(
      request: TimelineMutationRequest<String>(
        type: TimelineMutationType.move,
        entry: entry,
      ),
      commit: (_) => throw StateError('save failed'),
      rollback: (_, __, ___) => rolledBack = true,
    );

    expect(rolledBack, isTrue);
    expect(result.disposition, TimelineMutationDisposition.rolledBack);
    coordinator.dispose();
  });

  test('mutation coordinator does not notify after disposal', () async {
    final coordinator = TimelineMutationCoordinator<String>();
    final gate = Completer<void>();
    var notifications = 0;
    coordinator.addListener(() => notifications++);
    final entry = TimelineEntry<String>(
      id: 'late',
      value: 'Late',
      start: DateTime(2026, 7, 16, 9),
    );
    final future = coordinator.execute(
      request: TimelineMutationRequest<String>(
        type: TimelineMutationType.custom,
        entry: entry,
      ),
      commit: (_) => gate.future,
    );
    await Future<void>.delayed(Duration.zero);
    coordinator.dispose();
    final beforeCompletion = notifications;
    gate.complete();
    await future;
    expect(notifications, beforeCompletion);
  });

  test('mutation coordinator rejects duplicate work for one entry', () async {
    final coordinator = TimelineMutationCoordinator<String>();
    final gate = Completer<void>();
    final entry = TimelineEntry<String>(
      id: 'a',
      value: 'A',
      start: DateTime(2026, 7, 16, 9),
    );
    final request = TimelineMutationRequest<String>(
      type: TimelineMutationType.move,
      entry: entry,
    );

    final first = coordinator.execute(
      request: request,
      commit: (_) => gate.future,
    );
    await Future<void>.delayed(Duration.zero);
    final second = await coordinator.execute(request: request, commit: (_) {});
    expect(second.disposition, TimelineMutationDisposition.rejectedBusy);

    gate.complete();
    expect((await first).succeeded, isTrue);
    coordinator.dispose();
  });
}

import 'dart:io';

import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  const sizes = <int>[100, 500, 1000, 5000];
  for (final size in sizes) {
    final day = DateTime(2026, 7, 16);
    final entries = _entries(day, size);
    final planSample = _measure(() {
      return TimelineDayPlanBuilder.build<int>(
        entries: entries,
        selectedDate: day,
        now: day.add(const Duration(hours: 12)),
      );
    });
    final plan = planSample.value;

    final viewportSample = _measure(() {
      final index = TimelineViewportIndex<int>.build(plan.entries);
      return index.query(
        start: day.add(const Duration(hours: 8)),
        end: day.add(const Duration(hours: 18)),
        overscan: const Duration(hours: 1),
      );
    });

    final slotSample = _measure(() {
      return TimelineSlotSuggestionEngine.suggest<int>(
        plan: plan,
        requestedDuration: const Duration(minutes: 30),
        policy: TimelineSlotSuggestionPolicy(
          earliest: day.add(const Duration(hours: 8)),
          latest: day.add(const Duration(hours: 20)),
        ),
      );
    });

    final resizeSample = _measure(() {
      final entry = entries[entries.length ~/ 2];
      return TimelineResizeSession<int>(
        entry: entry,
        edge: TimelineResizeEdge.end,
        bounds: TimelineDateRange(day, DateTime(2026, 7, 17)),
        candidates: entries,
        policy: const TimelineResizePolicy(
          pixelsPerMinute: 1.35,
          allowConflicts: true,
        ),
      ).previewForPixels(74);
    });

    stdout.writeln(
      'entries=$size '
      'plan_us=${planSample.microseconds} '
      'viewport_us=${viewportSample.microseconds} '
      'slot_us=${slotSample.microseconds} '
      'resize_us=${resizeSample.microseconds} '
      'visible=${viewportSample.value.entries.length} '
      'suggestions=${slotSample.value.length} '
      'resize_conflicts=${resizeSample.value.conflicts.length}',
    );
  }
}

_Measurement<T> _measure<T>(T Function() operation) {
  operation();
  final watch = Stopwatch()..start();
  final value = operation();
  watch.stop();
  return _Measurement<T>(value, watch.elapsedMicroseconds);
}

class _Measurement<T> {
  const _Measurement(this.value, this.microseconds);

  final T value;
  final int microseconds;
}

List<TimelineEntry<int>> _entries(DateTime day, int count) {
  return List<TimelineEntry<int>>.generate(count, (index) {
    final minute = (index * 11) % (24 * 60 - 90);
    return TimelineEntry<int>(
      id: index,
      value: index,
      start: day.add(Duration(minutes: minute)),
      duration: Duration(minutes: 20 + (index % 7) * 5),
      draggable: index % 17 != 0,
      semanticLabel: 'Task $index',
    );
  }, growable: false);
}

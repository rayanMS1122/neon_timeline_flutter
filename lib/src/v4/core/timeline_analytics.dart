import 'package:flutter/foundation.dart';

import '../models/timeline_types.dart';
import 'timeline_render_plan.dart';

@immutable
class TimelineAnalyticsSnapshot<T> {
  const TimelineAnalyticsSnapshot({
    required this.entryCount,
    required this.statusCounts,
    required this.totalScheduledDuration,
    required this.occupiedDuration,
    required this.availableDuration,
    required this.peakConcurrency,
    required this.conflictingEntryCount,
    required this.resourceAssignmentCounts,
  });

  final int entryCount;
  final Map<TimelineStatus, int> statusCounts;

  /// Sum of every entry duration. Overlaps are counted more than once.
  final Duration totalScheduledDuration;

  /// Union of occupied ranges inside the requested analysis window.
  final Duration occupiedDuration;
  final Duration availableDuration;
  final int peakConcurrency;
  final int conflictingEntryCount;
  final Map<Object, int> resourceAssignmentCounts;

  int countForStatus(TimelineStatus status) => statusCounts[status] ?? 0;

  double get completionRate {
    if (entryCount == 0) return 0;
    return countForStatus(TimelineStatus.completed) / entryCount;
  }

  double utilizationFor(Duration window) {
    if (window <= Duration.zero) return 0;
    return (occupiedDuration.inMicroseconds / window.inMicroseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

/// Aggregate planning metrics with an O(n log n) concurrency sweep.
class TimelineAnalytics {
  const TimelineAnalytics._();

  static TimelineAnalyticsSnapshot<T> analyze<T>({
    required TimelineRenderPlan<T> plan,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    final candidateStart =
        rangeStart ??
        plan.dayStart ??
        (plan.entries.isEmpty ? null : plan.entries.first.start);
    final candidateEnd =
        rangeEnd ??
        plan.dayEnd ??
        (plan.entries.isEmpty ? null : plan.entries.last.end);
    final invalidWindow =
        candidateStart != null &&
        candidateEnd != null &&
        !candidateEnd.isAfter(candidateStart);
    final window =
        candidateStart != null &&
            candidateEnd != null &&
            candidateEnd.isAfter(candidateStart)
        ? (start: candidateStart, end: candidateEnd)
        : null;
    final statusCounts = <TimelineStatus, int>{
      for (final status in TimelineStatus.values) status: 0,
    };
    final resourceCounts = <Object, int>{};
    final consideredConflictIds = <Object>{};
    var includedEntries = 0;
    var totalScheduledMicros = 0;
    final events = <_ConcurrencyEvent>[];

    for (final normalized in plan.entries) {
      if (invalidWindow) continue;
      if (window != null &&
          (!normalized.start.isBefore(window.end) ||
              !normalized.end.isAfter(window.start))) {
        continue;
      }

      includedEntries++;
      statusCounts.update(normalized.entry.status, (count) => count + 1);
      if (plan.entryHasConflict(normalized.entry.id)) {
        consideredConflictIds.add(normalized.entry.id);
      }
      for (final resourceId in normalized.entry.resourceIds) {
        resourceCounts.update(
          resourceId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      if (window == null) continue;
      final clippedStart = normalized.start.isBefore(window.start)
          ? window.start
          : normalized.start;
      final clippedEnd = normalized.end.isAfter(window.end)
          ? window.end
          : normalized.end;
      if (!clippedEnd.isAfter(clippedStart)) continue;
      totalScheduledMicros += clippedEnd
          .difference(clippedStart)
          .inMicroseconds;
      events
        ..add(_ConcurrencyEvent(time: clippedStart, delta: 1))
        ..add(_ConcurrencyEvent(time: clippedEnd, delta: -1));
    }

    events.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      if (byTime != 0) return byTime;
      // End events run before starts, so adjacent entries do not overlap.
      return a.delta.compareTo(b.delta);
    });

    var active = 0;
    var peak = 0;
    var occupiedMicros = 0;
    DateTime? previous;
    var index = 0;
    while (index < events.length) {
      final time = events[index].time;
      if (previous != null && active > 0 && time.isAfter(previous)) {
        occupiedMicros += time.difference(previous).inMicroseconds;
      }
      while (index < events.length && events[index].time == time) {
        active += events[index].delta;
        index++;
      }
      if (active > peak) peak = active;
      previous = time;
    }

    final windowMicros = window == null
        ? 0
        : window.end.difference(window.start).inMicroseconds;
    final availableMicros = (windowMicros - occupiedMicros)
        .clamp(0, windowMicros)
        .toInt();

    return TimelineAnalyticsSnapshot<T>(
      entryCount: includedEntries,
      statusCounts: Map<TimelineStatus, int>.unmodifiable(statusCounts),
      totalScheduledDuration: Duration(microseconds: totalScheduledMicros),
      occupiedDuration: Duration(microseconds: occupiedMicros),
      availableDuration: Duration(microseconds: availableMicros),
      peakConcurrency: peak,
      conflictingEntryCount: consideredConflictIds.length,
      resourceAssignmentCounts: Map<Object, int>.unmodifiable(resourceCounts),
    );
  }
}

@immutable
class _ConcurrencyEvent {
  const _ConcurrencyEvent({required this.time, required this.delta});

  final DateTime time;
  final int delta;
}

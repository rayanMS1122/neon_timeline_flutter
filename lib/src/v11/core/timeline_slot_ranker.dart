import 'package:flutter/foundation.dart';

import '../../v11/core/timeline_work_constraints.dart';
import '../../v4/models/timeline_entry.dart';

@immutable
class TimelineRankedSlot {
  const TimelineRankedSlot({
    required this.start,
    required this.end,
    required this.score,
    required this.conflictCount,
    required this.insideWorkingHours,
  });

  final DateTime start;
  final DateTime end;
  final double score;
  final int conflictCount;
  final bool insideWorkingHours;
}

/// Ranks candidate positions by conflicts, distance and work constraints.
class TimelineSlotRanker<T> {
  const TimelineSlotRanker({
    this.conflictPenalty = 1000,
    this.distanceWeight = 1,
  });

  final double conflictPenalty;
  final double distanceWeight;

  List<TimelineRankedSlot> rank({
    required DateTime preferredStart,
    required Duration duration,
    required Iterable<DateTime> candidateStarts,
    required Iterable<TimelineEntry<T>> entries,
    TimelineWorkConstraints? constraints,
  }) {
    final result = <TimelineRankedSlot>[];
    for (final start in candidateStarts) {
      final end = start.add(duration);
      final conflicts = entries
          .where(
            (entry) =>
                entry.hasValidRange &&
                start.isBefore(entry.rawEnd) &&
                end.isAfter(entry.start),
          )
          .length;
      final validation = constraints?.validate(start, end);
      final allowed = validation?.isValid ?? true;
      final distance = start.difference(preferredStart).inMinutes.abs();
      final score =
          conflicts * conflictPenalty +
          distance * distanceWeight +
          (allowed ? 0 : conflictPenalty * 10);
      result.add(
        TimelineRankedSlot(
          start: start,
          end: end,
          score: score,
          conflictCount: conflicts,
          insideWorkingHours: allowed,
        ),
      );
    }
    result.sort((a, b) => a.score.compareTo(b.score));
    return List<TimelineRankedSlot>.unmodifiable(result);
  }
}

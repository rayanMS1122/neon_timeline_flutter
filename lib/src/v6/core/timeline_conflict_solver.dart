import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';

@immutable
class TimelineMoveProposal<T> {
  const TimelineMoveProposal({
    required this.entry,
    required this.originalStart,
    required this.proposedStart,
    required this.proposedEnd,
  });

  final TimelineEntry<T> entry;
  final DateTime originalStart;
  final DateTime proposedStart;
  final DateTime proposedEnd;

  Duration get delta => proposedStart.difference(originalStart);
  bool get changed => proposedStart != originalStart;

  TimelineEntry<T> apply() {
    return entry.copyWith(
      start: proposedStart,
      end: entry.end == null ? null : proposedEnd,
    );
  }
}

@immutable
class TimelineConflictResolution<T> {
  const TimelineConflictResolution({
    required this.proposals,
    required this.unresolvedEntries,
  });

  final List<TimelineMoveProposal<T>> proposals;
  final List<TimelineEntry<T>> unresolvedEntries;

  bool get changed => proposals.any((proposal) => proposal.changed);
  bool get isFullyResolved => unresolvedEntries.isEmpty;

  List<TimelineEntry<T>> apply() {
    return List<TimelineEntry<T>>.unmodifiable(
      proposals.map((proposal) => proposal.apply()),
    );
  }
}

/// Deterministic conflict repair used by planner applications before they
/// persist changes. Entries are kept in stable start order and pushed forward
/// only when necessary.
class TimelineConflictSolver {
  const TimelineConflictSolver._();

  static TimelineConflictResolution<T> pushForward<T>({
    required Iterable<TimelineEntry<T>> entries,
    required TimelineDateRange bounds,
    Duration spacing = Duration.zero,
    bool respectDraggable = true,
  }) {
    if (spacing.isNegative) {
      throw ArgumentError.value(spacing, 'spacing', 'must not be negative');
    }
    final ordered = <_SolverEntry<T>>[];
    var sourceIndex = 0;
    for (final entry in entries) {
      ordered.add(_SolverEntry<T>(entry, sourceIndex));
      sourceIndex++;
    }
    ordered.sort((a, b) {
      final byStart = a.entry.start.compareTo(b.entry.start);
      if (byStart != 0) return byStart;
      final byEnd = b.entry.rawEnd.compareTo(a.entry.rawEnd);
      if (byEnd != 0) return byEnd;
      return a.sourceIndex.compareTo(b.sourceIndex);
    });

    final proposals = <TimelineMoveProposal<T>>[];
    final unresolved = <TimelineEntry<T>>[];
    final unresolvedIds = <Object>{};
    var cursor = bounds.start;

    void markUnresolved(TimelineEntry<T> entry) {
      if (unresolvedIds.add(entry.id)) unresolved.add(entry);
    }

    for (final item in ordered) {
      final entry = item.entry;
      final duration = entry.rawDuration > Duration.zero
          ? entry.rawDuration
          : const Duration(minutes: 1);
      var proposedStart = entry.start;
      if (proposedStart.isBefore(bounds.start)) {
        if (respectDraggable && !entry.draggable) {
          markUnresolved(entry);
        } else {
          proposedStart = bounds.start;
        }
      }
      final requiredStart = cursor.add(
        proposals.isEmpty ? Duration.zero : spacing,
      );
      if (proposedStart.isBefore(requiredStart)) {
        if (respectDraggable && !entry.draggable) {
          markUnresolved(entry);
        } else {
          proposedStart = requiredStart;
        }
      }
      final proposedEnd = proposedStart.add(duration);
      if (proposedEnd.isAfter(bounds.end)) {
        markUnresolved(entry);
        proposedStart = entry.start;
      }
      final effectiveEnd = proposedStart.add(duration);
      proposals.add(
        TimelineMoveProposal<T>(
          entry: entry,
          originalStart: entry.start,
          proposedStart: proposedStart,
          proposedEnd: effectiveEnd,
        ),
      );
      if (effectiveEnd.isAfter(cursor)) cursor = effectiveEnd;
    }

    return TimelineConflictResolution<T>(
      proposals: List<TimelineMoveProposal<T>>.unmodifiable(proposals),
      unresolvedEntries: List<TimelineEntry<T>>.unmodifiable(unresolved),
    );
  }
}

@immutable
class _SolverEntry<T> {
  const _SolverEntry(this.entry, this.sourceIndex);

  final TimelineEntry<T> entry;
  final int sourceIndex;
}

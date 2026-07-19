import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v5/core/timeline_temporal_index.dart';

enum TimelineResizeEdge { start, end }

@immutable
class TimelineResizePolicy {
  const TimelineResizePolicy({
    this.snap = const Duration(minutes: 5),
    this.minimumDuration = const Duration(minutes: 5),
    this.maximumDuration = const Duration(days: 1),
    this.keepEntireEntryInBounds = true,
    this.allowConflicts = true,
    this.pixelsPerMinute = 1.35,
  });

  final Duration snap;
  final Duration minimumDuration;
  final Duration maximumDuration;
  final bool keepEntireEntryInBounds;
  final bool allowConflicts;
  final double pixelsPerMinute;
}

@immutable
class TimelineResizePreview<T> {
  const TimelineResizePreview({
    required this.entry,
    required this.edge,
    required this.originalStart,
    required this.originalEnd,
    required this.start,
    required this.end,
    required this.requestedDelta,
    required this.snappedDelta,
    required this.snapIndex,
    required this.conflicts,
    required this.wasClamped,
    required this.fitsInBounds,
    required this.canCommit,
  });

  final TimelineEntry<T> entry;
  final TimelineResizeEdge edge;
  final DateTime originalStart;
  final DateTime originalEnd;
  final DateTime start;
  final DateTime end;
  final Duration requestedDelta;
  final Duration snappedDelta;
  final int snapIndex;
  final List<TimelineEntry<T>> conflicts;
  final bool wasClamped;
  final bool fitsInBounds;
  final bool canCommit;

  Duration get duration => end.difference(start);
  bool get changed => start != originalStart || end != originalEnd;
  bool get hasConflicts => conflicts.isNotEmpty;
}

@immutable
class TimelineResizeResult<T> {
  const TimelineResizeResult({
    required this.preview,
    required this.accepted,
    this.cancelled = false,
  });

  final TimelineResizePreview<T> preview;
  final bool accepted;
  final bool cancelled;
}

/// Pure resize engine used by the 8.x Structured timeline.
class TimelineResizeSession<T> {
  TimelineResizeSession({
    required this.entry,
    required this.edge,
    required this.bounds,
    Iterable<TimelineEntry<T>>? candidates,
    this.policy = const TimelineResizePolicy(),
  }) : _index = TimelineTemporalIndex<T>.build(
         candidates ?? <TimelineEntry<T>>[],
       ) {
    _validatePolicy(policy);
  }

  final TimelineEntry<T> entry;
  final TimelineResizeEdge edge;
  final TimelineDateRange bounds;
  final TimelineResizePolicy policy;
  final TimelineTemporalIndex<T> _index;

  TimelineResizePreview<T> previewForPixels(double verticalDelta) {
    if (!verticalDelta.isFinite) return previewForDelta(Duration.zero);
    final minutes = verticalDelta / policy.pixelsPerMinute;
    return previewForDelta(
      Duration(
        microseconds: (minutes * Duration.microsecondsPerMinute).round(),
      ),
    );
  }

  TimelineResizePreview<T> previewForDelta(Duration rawDelta) {
    final snapped = _snap(rawDelta, policy.snap);
    final originalStart = entry.start;
    final originalEnd = entry.rawEnd.isAfter(entry.start)
        ? entry.rawEnd
        : entry.start.add(policy.minimumDuration);

    var start = originalStart;
    var end = originalEnd;
    var wasClamped = false;

    if (edge == TimelineResizeEdge.start) {
      start = originalStart.add(snapped);
      final latestStart = end.subtract(policy.minimumDuration);
      final earliestStart = end.subtract(policy.maximumDuration);
      if (start.isAfter(latestStart)) {
        start = latestStart;
        wasClamped = true;
      }
      if (start.isBefore(earliestStart)) {
        start = earliestStart;
        wasClamped = true;
      }
      if (policy.keepEntireEntryInBounds && start.isBefore(bounds.start)) {
        start = bounds.start;
        wasClamped = true;
      }
    } else {
      end = originalEnd.add(snapped);
      final earliestEnd = start.add(policy.minimumDuration);
      final latestEnd = start.add(policy.maximumDuration);
      if (end.isBefore(earliestEnd)) {
        end = earliestEnd;
        wasClamped = true;
      }
      if (end.isAfter(latestEnd)) {
        end = latestEnd;
        wasClamped = true;
      }
      if (policy.keepEntireEntryInBounds && end.isAfter(bounds.end)) {
        end = bounds.end;
        wasClamped = true;
      }
    }

    final fitsInBounds =
        !start.isBefore(bounds.start) && !end.isAfter(bounds.end);
    final conflicts = <TimelineEntry<T>>[];
    if (end.isAfter(start)) {
      for (final candidate in _index.query(start: start, end: end)) {
        if (candidate.id == entry.id) continue;
        if (candidate.rawEnd.isAfter(start) && candidate.start.isBefore(end)) {
          conflicts.add(candidate);
        }
      }
    }

    final duration = end.difference(start);
    final durationAllowed =
        duration >= policy.minimumDuration &&
        duration <= policy.maximumDuration;
    final canCommit =
        entry.draggable &&
        entry.enabled &&
        end.isAfter(start) &&
        durationAllowed &&
        fitsInBounds &&
        (policy.allowConflicts || conflicts.isEmpty);

    return TimelineResizePreview<T>(
      entry: entry,
      edge: edge,
      originalStart: originalStart,
      originalEnd: originalEnd,
      start: start,
      end: end,
      requestedDelta: rawDelta,
      snappedDelta: snapped,
      snapIndex: snapped.inMicroseconds ~/ policy.snap.inMicroseconds,
      conflicts: List<TimelineEntry<T>>.unmodifiable(conflicts),
      wasClamped: wasClamped,
      fitsInBounds: fitsInBounds,
      canCommit: canCommit,
    );
  }

  TimelineResizeResult<T> resolve({
    required TimelineResizePreview<T> preview,
    bool cancelled = false,
  }) {
    if (cancelled) {
      return TimelineResizeResult<T>(
        preview: preview,
        accepted: false,
        cancelled: true,
      );
    }
    return TimelineResizeResult<T>(
      preview: preview,
      accepted: preview.canCommit && preview.changed,
    );
  }

  static Duration _snap(Duration value, Duration step) {
    final micros = step.inMicroseconds;
    if (micros <= 0) return value;
    final units = value.inMicroseconds / micros;
    return Duration(microseconds: units.round() * micros);
  }

  static void _validatePolicy(TimelineResizePolicy policy) {
    if (policy.snap <= Duration.zero) {
      throw ArgumentError.value(policy.snap, 'policy.snap');
    }
    if (policy.minimumDuration <= Duration.zero) {
      throw ArgumentError.value(
        policy.minimumDuration,
        'policy.minimumDuration',
      );
    }
    if (policy.maximumDuration < policy.minimumDuration) {
      throw ArgumentError.value(
        policy.maximumDuration,
        'policy.maximumDuration',
      );
    }
    if (!policy.pixelsPerMinute.isFinite || policy.pixelsPerMinute <= 0) {
      throw ArgumentError.value(
        policy.pixelsPerMinute,
        'policy.pixelsPerMinute',
      );
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v5/core/timeline_temporal_index.dart';

enum TimelineDropDisposition { unchanged, move, delete, cancel, blocked }

@immutable
class TimelineReschedulePolicy {
  const TimelineReschedulePolicy({
    this.snap = const Duration(minutes: 5),
    this.keepEntireEntryInBounds = true,
    this.allowConflicts = true,
    this.enableDeleteTarget = true,
    this.pixelsPerMinute = 1.35,
    this.magnetizeToNeighbors = false,
    this.magnetDistance = Duration.zero,
    this.snapHysteresis = Duration.zero,
    this.preferConflictFreeDrop = false,
  }) : assert(pixelsPerMinute > 0);

  final Duration snap;
  final bool keepEntireEntryInBounds;
  final bool allowConflicts;
  final bool enableDeleteTarget;
  final double pixelsPerMinute;
  final bool magnetizeToNeighbors;
  final Duration magnetDistance;
  final Duration snapHysteresis;
  final bool preferConflictFreeDrop;
}

@immutable
class TimelineReschedulePreview<T> {
  const TimelineReschedulePreview({
    required this.entry,
    required this.originalStart,
    required this.start,
    required this.end,
    required this.requestedDelta,
    required this.snappedDelta,
    required this.delta,
    required this.snapIndex,
    required this.wasClamped,
    required this.conflicts,
    required this.totalOverlap,
    required this.fitsInBounds,
    required this.canCommit,
    this.magnetized = false,
    this.magnetTarget,
    this.magnetEntryId,
  });

  final TimelineEntry<T> entry;
  final DateTime originalStart;
  final DateTime start;
  final DateTime end;

  /// Raw gesture/keyboard delta before snapping.
  final Duration requestedDelta;

  /// Delta rounded to the configured snap grid before boundary clamping.
  final Duration snappedDelta;

  /// Effective delta after snapping and boundary clamping.
  final Duration delta;

  /// Stable grid index that hosts can compare before triggering haptics.
  final int snapIndex;
  final bool wasClamped;
  final List<TimelineEntry<T>> conflicts;

  /// Sum of pairwise overlaps with candidates. Overlapping conflicts may make
  /// this greater than the entry duration.
  final Duration totalOverlap;
  final bool fitsInBounds;
  final bool canCommit;
  final bool magnetized;
  final DateTime? magnetTarget;
  final Object? magnetEntryId;

  bool get changed => start != originalStart;
  bool get hasConflicts => conflicts.isNotEmpty;
  Object? get seriesId => entry.metadata['timeline.seriesId'];
  DateTime? get originalOccurrenceStart =>
      entry.metadata['timeline.originalOccurrenceStart'] as DateTime?;

  TimelineEntry<T> apply() {
    return entry.copyWith(start: start, end: entry.end == null ? null : end);
  }
}

@immutable
class TimelineDropResult<T> {
  const TimelineDropResult({required this.disposition, required this.preview});

  final TimelineDropDisposition disposition;
  final TimelineReschedulePreview<T> preview;
}

/// Pure rescheduling engine for long-press drag, keyboard movement, or custom
/// gesture systems. The package computes snapping, clamping, and conflict
/// preview; the host decides how and where to persist the result.
class TimelineRescheduleSession<T> {
  TimelineRescheduleSession({
    required this.entry,
    required this.bounds,
    Iterable<TimelineEntry<T>> candidates = const [],
    this.policy = const TimelineReschedulePolicy(),
  }) : _index = TimelineTemporalIndex<T>.build(candidates) {
    if (policy.snap <= Duration.zero) {
      throw ArgumentError.value(
        policy.snap,
        'policy.snap',
        'must be greater than zero',
      );
    }
  }

  final TimelineEntry<T> entry;
  final TimelineDateRange bounds;
  final TimelineReschedulePolicy policy;
  final TimelineTemporalIndex<T> _index;
  DateTime? _lastDesiredStart;
  _TimelineMagnet? _lastMagnet;

  TimelineReschedulePreview<T> previewForPixels(double verticalDelta) {
    if (!verticalDelta.isFinite) return previewForDelta(Duration.zero);
    final rawMinutes = verticalDelta / policy.pixelsPerMinute;
    return previewForDelta(
      Duration(
        microseconds: (rawMinutes * Duration.microsecondsPerMinute).round(),
      ),
    );
  }

  TimelineReschedulePreview<T> previewForDelta(Duration rawDelta) {
    final snapped = _snap(rawDelta, policy.snap);
    final duration = entry.rawDuration > Duration.zero
        ? entry.rawDuration
        : const Duration(minutes: 1);
    final desiredStart = entry.start.add(snapped);
    final magnet =
        policy.magnetizeToNeighbors && policy.magnetDistance > Duration.zero
        ? _nearestMagnet(desiredStart, duration)
        : null;

    var start = magnet?.start ?? desiredStart;
    var wasClamped = false;
    if (start.isBefore(bounds.start)) {
      start = bounds.start;
      wasClamped = true;
    }
    final fitsInBounds =
        !policy.keepEntireEntryInBounds || duration <= bounds.duration;
    final latestStart = policy.keepEntireEntryInBounds
        ? bounds.end.subtract(duration)
        : bounds.end.subtract(const Duration(microseconds: 1));
    final safeLatest = latestStart.isBefore(bounds.start)
        ? bounds.start
        : latestStart;
    if (start.isAfter(safeLatest)) {
      start = safeLatest;
      wasClamped = true;
    }
    final end = start.add(duration);

    final conflicts = <TimelineEntry<T>>[];
    var overlapMicros = 0;
    for (final candidate in _index.query(start: start, end: end)) {
      if (candidate.id == entry.id) continue;
      final overlapStart = candidate.start.isAfter(start)
          ? candidate.start
          : start;
      final candidateEnd = candidate.rawEnd;
      final overlapEnd = candidateEnd.isBefore(end) ? candidateEnd : end;
      if (!overlapEnd.isAfter(overlapStart)) continue;
      conflicts.add(candidate);
      overlapMicros += overlapEnd.difference(overlapStart).inMicroseconds;
    }

    final effectiveDelta = start.difference(entry.start);
    return TimelineReschedulePreview<T>(
      entry: entry,
      originalStart: entry.start,
      start: start,
      end: end,
      requestedDelta: rawDelta,
      snappedDelta: snapped,
      delta: effectiveDelta,
      snapIndex: effectiveDelta.inMicroseconds ~/ policy.snap.inMicroseconds,
      wasClamped: wasClamped,
      conflicts: List<TimelineEntry<T>>.unmodifiable(conflicts),
      totalOverlap: Duration(microseconds: overlapMicros),
      fitsInBounds: fitsInBounds,
      canCommit:
          entry.draggable &&
          fitsInBounds &&
          (policy.allowConflicts || conflicts.isEmpty),
      magnetized: magnet != null && start == magnet.start,
      magnetTarget: magnet?.start,
      magnetEntryId: magnet?.entryId,
    );
  }

  _TimelineMagnet? _nearestMagnet(DateTime desiredStart, Duration duration) {
    final maxDistance = policy.magnetDistance.inMicroseconds.abs();
    if (maxDistance <= 0) return null;
    _TimelineMagnet? best;
    var bestScore = double.infinity;

    final previousDesired = _lastDesiredStart;
    final direction = previousDesired == null
        ? 0
        : desiredStart.compareTo(previousDesired);

    void consider(DateTime target, Object? entryId, int priority) {
      final distance = target.difference(desiredStart).inMicroseconds.abs();
      if (distance > maxDistance) return;
      var score = distance.toDouble() + priority * maxDistance * 4;
      if (policy.preferConflictFreeDrop) {
        score += _conflictCountAt(target, duration) * maxDistance * 2;
      }
      if ((direction > 0 && target.isBefore(desiredStart)) ||
          (direction < 0 && target.isAfter(desiredStart))) {
        score += maxDistance * 0.35;
      }
      if (score < bestScore) {
        bestScore = score;
        best = _TimelineMagnet(start: target, entryId: entryId);
      }
    }

    consider(bounds.start, null, 3);
    consider(bounds.end.subtract(duration), null, 3);
    final searchStart = desiredStart
        .subtract(policy.magnetDistance)
        .subtract(duration);
    final searchEnd = desiredStart.add(duration).add(policy.magnetDistance);
    for (final candidate in _index.query(start: searchStart, end: searchEnd)) {
      if (candidate.id == entry.id || !candidate.hasValidRange) continue;
      consider(candidate.rawEnd, candidate.id, 0);
      consider(candidate.start.subtract(duration), candidate.id, 0);
    }
    final last = _lastMagnet;
    final hysteresis = policy.snapHysteresis.inMicroseconds.abs();
    if (last != null &&
        best != null &&
        last.start != best!.start &&
        desiredStart.difference(last.start).inMicroseconds.abs() <=
            hysteresis) {
      best = last;
    }
    _lastDesiredStart = desiredStart;
    _lastMagnet = best;
    return best;
  }

  int _conflictCountAt(DateTime start, Duration duration) {
    final end = start.add(duration);
    var count = 0;
    for (final candidate in _index.query(start: start, end: end)) {
      if (candidate.id == entry.id) continue;
      if (candidate.rawEnd.isAfter(start) && candidate.start.isBefore(end)) {
        count++;
      }
    }
    return count;
  }

  TimelineDropResult<T> resolveDrop({
    required TimelineReschedulePreview<T> preview,
    bool overDeleteTarget = false,
    bool cancelled = false,
  }) {
    if (cancelled) {
      return TimelineDropResult<T>(
        disposition: TimelineDropDisposition.cancel,
        preview: preview,
      );
    }
    if (overDeleteTarget && policy.enableDeleteTarget && entry.draggable) {
      return TimelineDropResult<T>(
        disposition: TimelineDropDisposition.delete,
        preview: preview,
      );
    }
    if (!preview.canCommit) {
      return TimelineDropResult<T>(
        disposition: TimelineDropDisposition.blocked,
        preview: preview,
      );
    }
    return TimelineDropResult<T>(
      disposition: preview.changed
          ? TimelineDropDisposition.move
          : TimelineDropDisposition.unchanged,
      preview: preview,
    );
  }

  static Duration _snap(Duration value, Duration step) {
    final stepMicros = step.inMicroseconds;
    if (stepMicros <= 0) return value;
    final units = value.inMicroseconds / stepMicros;
    return Duration(microseconds: units.round() * stepMicros);
  }
}

class _TimelineMagnet {
  const _TimelineMagnet({required this.start, this.entryId});

  final DateTime start;
  final Object? entryId;
}

@immutable
class TimelineAutoScrollPolicy {
  const TimelineAutoScrollPolicy({
    this.edgeExtent = 120,
    this.minimumStep = 2,
    this.maximumStep = 15,
  }) : assert(edgeExtent > 0),
       assert(minimumStep >= 0),
       assert(maximumStep >= minimumStep);

  final double edgeExtent;
  final double minimumStep;
  final double maximumStep;

  /// Signed scroll delta for one gesture update. Negative scrolls toward the
  /// start, positive toward the end, and zero means no edge scrolling.
  double deltaFor({required double pointer, required double viewportExtent}) {
    if (!pointer.isFinite || !viewportExtent.isFinite || viewportExtent <= 0) {
      return 0;
    }
    final effectiveEdge = edgeExtent < viewportExtent / 2
        ? edgeExtent
        : viewportExtent / 2;
    if (pointer < effectiveEdge) {
      final intensity = ((effectiveEdge - pointer) / effectiveEdge).clamp(
        0.0,
        1.0,
      );
      return -_step(intensity);
    }
    final lowerEdge = viewportExtent - effectiveEdge;
    if (pointer > lowerEdge) {
      final intensity = ((pointer - lowerEdge) / effectiveEdge).clamp(0.0, 1.0);
      return _step(intensity);
    }
    return 0;
  }

  double _step(double intensity) {
    return (minimumStep + ((maximumStep - minimumStep) * intensity))
        .clamp(minimumStep, maximumStep)
        .toDouble();
  }
}

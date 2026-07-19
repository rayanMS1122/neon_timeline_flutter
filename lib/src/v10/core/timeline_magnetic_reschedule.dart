import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v6/core/timeline_reschedule.dart';

enum TimelineMagnetKind { none, dayStart, dayEnd, afterEntry, beforeEntry }

@immutable
class TimelineMagneticPreview<T> {
  const TimelineMagneticPreview({
    required this.preview,
    required this.kind,
    required this.confidence,
    this.anchorEntry,
    this.anchorTime,
  });

  final TimelineReschedulePreview<T> preview;
  final TimelineMagnetKind kind;
  final double confidence;
  final TimelineEntry<T>? anchorEntry;
  final DateTime? anchorTime;

  bool get magnetized => kind != TimelineMagnetKind.none;
  bool get canCommit => preview.canCommit;
  bool get hasConflicts => preview.hasConflicts;
}

/// Adds optional neighbour magnetism and conflict-aware slot preference on top
/// of the stable 6.x reschedule engine.
class TimelineMagneticRescheduleEngine<T> {
  factory TimelineMagneticRescheduleEngine({
    required TimelineEntry<T> entry,
    required TimelineDateRange bounds,
    required Iterable<TimelineEntry<T>> candidates,
    TimelineReschedulePolicy policy = const TimelineReschedulePolicy(),
    Duration magnetDistance = const Duration(minutes: 8),
    bool preferConflictFree = true,
  }) {
    final materialized = List<TimelineEntry<T>>.unmodifiable(candidates);
    return TimelineMagneticRescheduleEngine<T>._(
      entry: entry,
      bounds: bounds,
      candidates: materialized,
      policy: policy,
      magnetDistance: magnetDistance,
      preferConflictFree: preferConflictFree,
    );
  }

  TimelineMagneticRescheduleEngine._({
    required this.entry,
    required this.bounds,
    required List<TimelineEntry<T>> candidates,
    required this.policy,
    required this.magnetDistance,
    required this.preferConflictFree,
  }) : _candidates = candidates,
       _session = TimelineRescheduleSession<T>(
         entry: entry,
         bounds: bounds,
         candidates: candidates,
         policy: policy,
       );

  final TimelineEntry<T> entry;
  final TimelineDateRange bounds;
  final TimelineReschedulePolicy policy;
  final Duration magnetDistance;
  final bool preferConflictFree;
  final List<TimelineEntry<T>> _candidates;
  final TimelineRescheduleSession<T> _session;

  TimelineMagneticPreview<T> previewForPixels(double verticalDelta) {
    if (!verticalDelta.isFinite) return previewForDelta(Duration.zero);
    final minutes = verticalDelta / policy.pixelsPerMinute;
    return previewForDelta(
      Duration(
        microseconds: (minutes * Duration.microsecondsPerMinute).round(),
      ),
    );
  }

  TimelineMagneticPreview<T> previewForDelta(Duration rawDelta) {
    final base = _session.previewForDelta(rawDelta);
    if (magnetDistance <= Duration.zero || !entry.draggable) {
      return TimelineMagneticPreview<T>(
        preview: base,
        kind: TimelineMagnetKind.none,
        confidence: 0,
      );
    }

    final targets = <_MagnetTarget<T>>[
      _MagnetTarget<T>(start: bounds.start, kind: TimelineMagnetKind.dayStart),
      _MagnetTarget<T>(
        start: bounds.end.subtract(entry.rawDuration),
        kind: TimelineMagnetKind.dayEnd,
      ),
    ];
    for (final candidate in _candidates) {
      if (candidate.id == entry.id || !candidate.hasValidRange) continue;
      targets.add(
        _MagnetTarget<T>(
          start: candidate.rawEnd,
          kind: TimelineMagnetKind.afterEntry,
          entry: candidate,
        ),
      );
      targets.add(
        _MagnetTarget<T>(
          start: candidate.start.subtract(entry.rawDuration),
          kind: TimelineMagnetKind.beforeEntry,
          entry: candidate,
        ),
      );
    }

    final maxMicros = math.max(1, magnetDistance.inMicroseconds);
    _MagnetTarget<T>? selected;
    TimelineReschedulePreview<T>? selectedPreview;
    var selectedScore = double.infinity;

    for (final target in targets) {
      final distance = target.start.difference(base.start).inMicroseconds.abs();
      if (distance > maxMicros) continue;
      final candidatePreview = _session.previewForDelta(
        target.start.difference(entry.start),
      );
      if (!candidatePreview.fitsInBounds) continue;
      final conflictPenalty = candidatePreview.conflicts.length * maxMicros * 2;
      final blockedPenalty = candidatePreview.canCommit ? 0 : maxMicros * 4;
      final score =
          distance +
          (preferConflictFree ? conflictPenalty : 0) +
          blockedPenalty;
      if (score < selectedScore) {
        selectedScore = score.toDouble();
        selected = target;
        selectedPreview = candidatePreview;
      }
    }

    if (selected == null || selectedPreview == null) {
      return TimelineMagneticPreview<T>(
        preview: base,
        kind: TimelineMagnetKind.none,
        confidence: 0,
      );
    }
    final distance = selected.start.difference(base.start).inMicroseconds.abs();
    final confidence = (1 - distance / maxMicros).clamp(0.0, 1.0).toDouble();
    final shouldUseMagnet = preferConflictFree
        ? selectedPreview.conflicts.length <= base.conflicts.length
        : true;
    if (!shouldUseMagnet) {
      return TimelineMagneticPreview<T>(
        preview: base,
        kind: TimelineMagnetKind.none,
        confidence: 0,
      );
    }
    return TimelineMagneticPreview<T>(
      preview: selectedPreview,
      kind: selected.kind,
      confidence: confidence,
      anchorEntry: selected.entry,
      anchorTime: selected.start,
    );
  }
}

class _MagnetTarget<T> {
  const _MagnetTarget({required this.start, required this.kind, this.entry});

  final DateTime start;
  final TimelineMagnetKind kind;
  final TimelineEntry<T>? entry;
}

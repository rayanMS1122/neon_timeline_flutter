import 'package:flutter/foundation.dart';

import '../../v11/core/timeline_work_constraints.dart';
import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v8/core/timeline_resize.dart';

/// Pure magnetic delta snapper shared by pointer and keyboard resizing.
@immutable
class UltimateTimelineResizeSnapEngine<T> {
  const UltimateTimelineResizeSnapEngine({
    this.step = const Duration(minutes: 5),
    this.hysteresis = const Duration(minutes: 1),
  });

  final Duration step;
  final Duration hysteresis;

  Duration snap(Duration raw, {Duration? previous}) {
    if (previous != null && (raw - previous).abs() <= hysteresis) {
      return previous;
    }
    final units = raw.inMicroseconds / step.inMicroseconds;
    return Duration(microseconds: units.round() * step.inMicroseconds);
  }
}

/// Interaction phase of a public resize session.
enum UltimateTimelineResizePhase { idle, active, blocked, committed, cancelled }

/// Constraint-aware public resize session with stable snap hysteresis.
class UltimateTimelineResizeSession<T> {
  UltimateTimelineResizeSession({
    required this.entry,
    required this.edge,
    required this.bounds,
    required Iterable<TimelineEntry<T>> entries,
    this.policy = const TimelineResizePolicy(),
    this.constraints,
    UltimateTimelineResizeSnapEngine<T>? snapEngine,
  }) : snapEngine =
           snapEngine ?? UltimateTimelineResizeSnapEngine<T>(step: policy.snap),
       _base = TimelineResizeSession<T>(
         entry: entry,
         edge: edge,
         bounds: bounds,
         candidates: entries,
         policy: policy,
       );

  final TimelineEntry<T> entry;
  final TimelineResizeEdge edge;
  final TimelineDateRange bounds;
  final TimelineResizePolicy policy;
  final TimelineWorkConstraints? constraints;
  final UltimateTimelineResizeSnapEngine<T> snapEngine;
  final TimelineResizeSession<T> _base;

  TimelineResizePreview<T>? _preview;
  Duration? _lastSnappedDelta;
  UltimateTimelineResizePhase _phase = UltimateTimelineResizePhase.idle;

  UltimateTimelineResizePhase get phase => _phase;
  TimelineResizePreview<T>? get preview => _preview;

  TimelineResizePreview<T> update(Duration rawDelta) {
    if (_phase == UltimateTimelineResizePhase.committed ||
        _phase == UltimateTimelineResizePhase.cancelled) {
      throw StateError('The resize session has already finished.');
    }
    final snapped = snapEngine.snap(rawDelta, previous: _lastSnappedDelta);
    _lastSnappedDelta = snapped;
    final base = _base.previewForDelta(snapped);
    final validation = constraints?.validate(base.start, base.end);
    final allowed = base.canCommit && (validation?.isValid ?? true);
    final resolved = TimelineResizePreview<T>(
      entry: base.entry,
      edge: base.edge,
      originalStart: base.originalStart,
      originalEnd: base.originalEnd,
      start: base.start,
      end: base.end,
      requestedDelta: rawDelta,
      snappedDelta: snapped,
      snapIndex: snapped.inMicroseconds ~/ policy.snap.inMicroseconds,
      conflicts: base.conflicts,
      wasClamped: base.wasClamped,
      fitsInBounds: base.fitsInBounds,
      canCommit: allowed,
    );
    _preview = resolved;
    _phase = allowed
        ? UltimateTimelineResizePhase.active
        : UltimateTimelineResizePhase.blocked;
    return resolved;
  }

  TimelineResizeResult<T> commit() {
    final current = _preview ?? update(Duration.zero);
    final result = _base.resolve(preview: current);
    _phase = result.accepted
        ? UltimateTimelineResizePhase.committed
        : UltimateTimelineResizePhase.blocked;
    return result;
  }

  TimelineResizeResult<T> cancel() {
    final current = _preview ?? update(Duration.zero);
    final result = _base.resolve(preview: current, cancelled: true);
    _phase = UltimateTimelineResizePhase.cancelled;
    return result;
  }
}

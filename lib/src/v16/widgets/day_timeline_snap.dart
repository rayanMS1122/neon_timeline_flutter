part of 'day_timeline_view.dart';

/// Snaps [value] to the nearest [interval] relative to [origin].
///
/// The implementation uses integer microseconds to avoid floating-point drift.
DateTime _snapDateTime(
  DateTime value,
  Duration interval,
  DateTime origin,
) {
  final step = interval.inMicroseconds;
  if (step <= 0) {
    throw ArgumentError.value(
      interval,
      'interval',
      'Must be greater than zero.',
    );
  }

  final delta = value.difference(origin).inMicroseconds;
  final halfStep = step ~/ 2;
  final snappedDelta = delta >= 0
      ? ((delta + halfStep) ~/ step) * step
      : -(((-delta + halfStep) ~/ step) * step);
  return origin.add(Duration(microseconds: snappedDelta));
}


enum _DaySnapKind {
  grid,
  entryStart,
  entryEnd,
  dayBoundary,
}

@immutable
class _DaySnapResult {
  const _DaySnapResult({
    required this.time,
    required this.kind,
    required this.label,
    this.anchorId,
  });

  final DateTime time;
  final _DaySnapKind kind;
  final String label;
  final Object? anchorId;
}

final class _DayIndexedSnapshot<T> implements NeonPlannerInterval {
  const _DayIndexedSnapshot(this.snapshot);

  final NeonPlannerEntrySnapshot<T> snapshot;

  @override
  int get startMicros => snapshot.start.microsecondsSinceEpoch;

  @override
  int get endMicros => snapshot.end.microsecondsSinceEpoch;
}

@immutable
class _DayConflictInfo {
  const _DayConflictInfo(this.ids);

  final List<Object> ids;

  bool get hasConflict => ids.isNotEmpty;

  int get count => ids.length;
}

extension _DayTimelineSnap<T> on _NeonPlannerDayTimelineState<T> {
  _DaySnapResult _resolveMoveSnap(
    DateTime rawStart,
    NeonPlannerEntrySnapshot<T> moving,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    final duration = moving.duration;
    final clampedRaw =
        _DayTimelineDrag<T>(this)._clampStart(rawStart, duration);

    final latched = _latchedSnap;
    if (latched != null && latched.kind != _DaySnapKind.grid) {
      final release = widget.snapTolerance + widget.snapHysteresis;
      if (_distance(clampedRaw, latched.time) <= release) {
        return latched;
      }
    }

    final grid = _DaySnapResult(
      time: _DayTimelineDrag<T>(this)._clampStart(
        _snapDateTime(clampedRaw, widget.snapInterval, _dayStart),
        duration,
      ),
      kind: _DaySnapKind.grid,
      label: '${widget.snapInterval.inMinutes}-Minuten-Raster',
    );

    final candidates = <_DaySnapResult>[
      _DaySnapResult(
        time: _dayStart,
        kind: _DaySnapKind.dayBoundary,
        label: 'Tagesanfang',
      ),
      _DaySnapResult(
        time: _dayEnd.subtract(duration),
        kind: _DaySnapKind.dayBoundary,
        label: 'Tagesende',
      ),
    ];

    if (widget.snapToEntryEdges) {
      for (final snapshot in snapshots) {
        if (snapshot.id == moving.id) {
          continue;
        }
        candidates.addAll(<_DaySnapResult>[
          _DaySnapResult(
            time: snapshot.start,
            kind: _DaySnapKind.entryStart,
            label: 'Start an „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
          _DaySnapResult(
            time: snapshot.end,
            kind: _DaySnapKind.entryEnd,
            label: 'Start nach „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
          _DaySnapResult(
            time: snapshot.start.subtract(duration),
            kind: _DaySnapKind.entryStart,
            label: 'Ende vor „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
          _DaySnapResult(
            time: snapshot.end.subtract(duration),
            kind: _DaySnapKind.entryEnd,
            label: 'Ende an „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
        ]);
      }
    }

    _DaySnapResult selected = grid;
    var selectedDistance = _distance(clampedRaw, grid.time);
    for (final candidate in candidates) {
      final clamped = _DayTimelineDrag<T>(this)._clampStart(
        candidate.time,
        duration,
      );
      final distance = _distance(clampedRaw, clamped);
      if (distance > widget.snapTolerance) {
        continue;
      }
      if (distance < selectedDistance || selected.kind == _DaySnapKind.grid) {
        selected = _DaySnapResult(
          time: clamped,
          kind: candidate.kind,
          label: candidate.label,
          anchorId: candidate.anchorId,
        );
        selectedDistance = distance;
      }
    }

    _latchedSnap = selected.kind == _DaySnapKind.grid ? null : selected;
    return selected;
  }

  _DaySnapResult _resolveEdgeSnap(
    DateTime rawEdge,
    NeonPlannerEntrySnapshot<T> moving,
    NeonPlannerResizeEdge edge,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    final minimum = widget.minimumEntryDuration;
    final clampedRaw = edge == NeonPlannerResizeEdge.start
        ? _clampDateTime(
            rawEdge,
            _dayStart,
            moving.end.subtract(minimum),
          )
        : _clampDateTime(
            rawEdge,
            moving.start.add(minimum),
            _dayEnd,
          );

    final latched = _latchedSnap;
    if (latched != null && latched.kind != _DaySnapKind.grid) {
      final release = widget.snapTolerance + widget.snapHysteresis;
      if (_distance(clampedRaw, latched.time) <= release) {
        return latched;
      }
    }

    final snappedGrid = _snapDateTime(
      clampedRaw,
      widget.snapInterval,
      _dayStart,
    );
    final grid = _DaySnapResult(
      time: edge == NeonPlannerResizeEdge.start
          ? _clampDateTime(
              snappedGrid,
              _dayStart,
              moving.end.subtract(minimum),
            )
          : _clampDateTime(
              snappedGrid,
              moving.start.add(minimum),
              _dayEnd,
            ),
      kind: _DaySnapKind.grid,
      label: '${widget.snapInterval.inMinutes}-Minuten-Raster',
    );
    final candidates = <_DaySnapResult>[
      _DaySnapResult(
        time: _dayStart,
        kind: _DaySnapKind.dayBoundary,
        label: 'Tagesanfang',
      ),
      _DaySnapResult(
        time: _dayEnd,
        kind: _DaySnapKind.dayBoundary,
        label: 'Tagesende',
      ),
    ];

    if (widget.snapToEntryEdges) {
      for (final snapshot in snapshots) {
        if (snapshot.id == moving.id) {
          continue;
        }
        candidates.addAll(<_DaySnapResult>[
          _DaySnapResult(
            time: snapshot.start,
            kind: _DaySnapKind.entryStart,
            label: 'Anfang von „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
          _DaySnapResult(
            time: snapshot.end,
            kind: _DaySnapKind.entryEnd,
            label: 'Ende von „${snapshot.presentation.title}“',
            anchorId: snapshot.id,
          ),
        ]);
      }
    }

    _DaySnapResult selected = grid;
    var selectedDistance = _distance(clampedRaw, grid.time);
    for (final candidate in candidates) {
      final constrained = edge == NeonPlannerResizeEdge.start
          ? _clampDateTime(
              candidate.time,
              _dayStart,
              moving.end.subtract(minimum),
            )
          : _clampDateTime(
              candidate.time,
              moving.start.add(minimum),
              _dayEnd,
            );
      final distance = _distance(clampedRaw, constrained);
      if (distance > widget.snapTolerance) {
        continue;
      }
      if (distance < selectedDistance || selected.kind == _DaySnapKind.grid) {
        selected = _DaySnapResult(
          time: constrained,
          kind: candidate.kind,
          label: candidate.label,
          anchorId: candidate.anchorId,
        );
        selectedDistance = distance;
      }
    }

    _latchedSnap = selected.kind == _DaySnapKind.grid ? null : selected;
    return selected;
  }

  _DayConflictInfo _conflicts(
    Object movingId,
    DateTime start,
    DateTime end,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    final indexed = _interactionConflictIndex;
    final candidates = indexed == null
        ? snapshots
        : indexed
            .query(
              start.microsecondsSinceEpoch,
              end.microsecondsSinceEpoch,
            )
            .map((item) => item.snapshot);
    final ids = <Object>[];
    for (final snapshot in candidates) {
      if (!snapshot.start.isBefore(end)) {
        break;
      }
      if (snapshot.id == movingId || !snapshot.end.isAfter(start)) {
        continue;
      }
      ids.add(snapshot.id);
    }
    return _DayConflictInfo(List<Object>.unmodifiable(ids));
  }

  Duration _distance(DateTime a, DateTime b) {
    final microseconds =
        (a.microsecondsSinceEpoch - b.microsecondsSinceEpoch).abs();
    return Duration(microseconds: microseconds);
  }

  DateTime _clampDateTime(DateTime value, DateTime minimum, DateTime maximum) {
    if (maximum.isBefore(minimum)) {
      return minimum;
    }
    if (value.isBefore(minimum)) {
      return minimum;
    }
    if (value.isAfter(maximum)) {
      return maximum;
    }
    return value;
  }
}

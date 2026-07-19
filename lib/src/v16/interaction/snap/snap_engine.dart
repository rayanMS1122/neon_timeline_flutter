import '../../api/models.dart';

/// Type of snap target.
enum NeonPlannerSnapTargetKind {
  /// Regular minute grid.
  grid,

  /// Start of a neighboring event.
  entryStart,

  /// End of a neighboring event.
  entryEnd,

  /// Current-time marker.
  currentTime,

  /// Application-defined marker.
  custom,
}

/// Candidate target for magnetic snapping.
final class NeonPlannerSnapTarget {
  /// Creates a snap target.
  const NeonPlannerSnapTarget({
    required this.time,
    required this.kind,
    this.priority = 0,
    this.id,
  });

  /// Target time.
  final DateTime time;

  /// Target type.
  final NeonPlannerSnapTargetKind kind;

  /// Higher values win near-equal comparisons.
  final int priority;

  /// Optional stable target identity.
  final Object? id;
}

/// Result from the snap engine.
final class NeonPlannerSnapResult {
  /// Creates a snap result.
  const NeonPlannerSnapResult({
    required this.time,
    required this.didSnap,
    this.target,
  });

  /// Resolved time.
  final DateTime time;

  /// Whether a target was selected.
  final bool didSnap;

  /// Selected target.
  final NeonPlannerSnapTarget? target;
}

/// Stateful pure-Dart snap engine with hysteresis.
final class NeonPlannerSnapEngine {
  /// Creates a snap engine.
  NeonPlannerSnapEngine({
    required this.interval,
    this.strength = NeonPlannerSnapStrength.balanced,
  }) : assert(interval > Duration.zero);

  /// Base grid interval.
  final Duration interval;

  /// Attraction strength.
  NeonPlannerSnapStrength strength;

  Object? _lastTargetId;
  DateTime? _lastTargetTime;

  /// Clears hysteresis state at the end of an interaction.
  void reset() {
    _lastTargetId = null;
    _lastTargetTime = null;
  }

  /// Snaps [candidate] to the best target.
  NeonPlannerSnapResult resolve({
    required DateTime candidate,
    Iterable<NeonPlannerSnapTarget> targets = const <NeonPlannerSnapTarget>[],
    double velocityPixelsPerSecond = 0,
  }) {
    if (strength == NeonPlannerSnapStrength.off) {
      return NeonPlannerSnapResult(time: candidate, didSnap: false);
    }

    final grid = _gridTarget(candidate);
    final allTargets = <NeonPlannerSnapTarget>[grid, ...targets];
    final baseRadius = switch (strength) {
      NeonPlannerSnapStrength.off => 0,
      NeonPlannerSnapStrength.soft => 4,
      NeonPlannerSnapStrength.balanced => 8,
      NeonPlannerSnapStrength.strong => 14,
    };
    final velocityPenalty = (velocityPixelsPerSecond.abs() / 650)
        .clamp(0.0, 0.55)
        .toDouble();
    final radiusMinutes = baseRadius * (1 - velocityPenalty);

    NeonPlannerSnapTarget? best;
    var bestScore = double.infinity;
    for (final target in allTargets) {
      final distanceMinutes =
          (target.time.difference(candidate).inMicroseconds.abs() /
          Duration.microsecondsPerMinute);
      final sameAsLast = _isLast(target);
      final allowedRadius = radiusMinutes * (sameAsLast ? 1.7 : 1);
      if (distanceMinutes > allowedRadius) {
        continue;
      }
      final score = distanceMinutes - target.priority * 0.35;
      if (score < bestScore) {
        best = target;
        bestScore = score;
      }
    }

    if (best == null) {
      _lastTargetId = null;
      _lastTargetTime = null;
      return NeonPlannerSnapResult(time: candidate, didSnap: false);
    }
    _lastTargetId = best.id;
    _lastTargetTime = best.time;
    return NeonPlannerSnapResult(
      time: best.time,
      didSnap: true,
      target: best,
    );
  }

  NeonPlannerSnapTarget _gridTarget(DateTime candidate) {
    final micros = candidate.microsecondsSinceEpoch;
    final step = interval.inMicroseconds;
    final rounded = ((micros / step).round()) * step;
    return NeonPlannerSnapTarget(
      time: DateTime.fromMicrosecondsSinceEpoch(
        rounded,
        isUtc: candidate.isUtc,
      ),
      kind: NeonPlannerSnapTargetKind.grid,
      priority: -1,
      id: 'grid:$rounded',
    );
  }

  bool _isLast(NeonPlannerSnapTarget target) {
    if (target.id != null && _lastTargetId != null) {
      return target.id == _lastTargetId;
    }
    return target.time == _lastTargetTime;
  }
}

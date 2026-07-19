/// Strength levels exposed by the v15 snap slider.
enum UltraTimelineSnapStrength { off, soft, balanced, strong }

/// Candidate magnetic destination.
class UltraTimelineSnapTarget {
  const UltraTimelineSnapTarget({
    required this.id,
    required this.time,
    this.blocked = false,
    this.priority = 0,
  });

  final Object id;
  final DateTime time;
  final bool blocked;
  final int priority;
}

/// Result of one pure-Dart magnetic snap evaluation.
class UltraTimelineSnapResult {
  const UltraTimelineSnapResult({
    required this.time,
    required this.snapped,
    this.target,
    this.blocked = false,
  });

  final DateTime time;
  final bool snapped;
  final UltraTimelineSnapTarget? target;
  final bool blocked;
}

/// Direction-aware magnetic snapping with hysteresis.
class UltraMagneticSnapEngine {
  const UltraMagneticSnapEngine({
    this.grid = const Duration(minutes: 5),
    this.softDistance = const Duration(minutes: 4),
    this.balancedDistance = const Duration(minutes: 8),
    this.strongDistance = const Duration(minutes: 14),
    this.hysteresis = const Duration(minutes: 2),
  });

  final Duration grid;
  final Duration softDistance;
  final Duration balancedDistance;
  final Duration strongDistance;
  final Duration hysteresis;

  UltraTimelineSnapResult resolve({
    required DateTime raw,
    required UltraTimelineSnapStrength strength,
    Iterable<UltraTimelineSnapTarget> targets = const <UltraTimelineSnapTarget>[],
    Object? previousTargetId,
    int direction = 0,
  }) {
    if (strength == UltraTimelineSnapStrength.off) {
      return UltraTimelineSnapResult(time: raw, snapped: false);
    }

    final gridTime = _roundToGrid(raw);
    UltraTimelineSnapTarget? best;
    var bestScore = double.infinity;
    final maximumDistance = _distanceFor(strength);

    for (final target in targets) {
      final distance = target.time.difference(raw).inMicroseconds.abs();
      final allowedDistance = maximumDistance.inMicroseconds +
          (target.id == previousTargetId ? hysteresis.inMicroseconds : 0);
      if (distance > allowedDistance) continue;

      final directionPenalty = direction == 0
          ? 0
          : ((target.time.isAfter(raw) ? 1 : -1) == direction ? 0 : 250000);
      final priorityBonus = target.priority * 100000;
      final score = distance + directionPenalty - priorityBonus;
      if (score < bestScore) {
        bestScore = score.toDouble();
        best = target;
      }
    }

    final gridDistance = gridTime.difference(raw).inMicroseconds.abs();
    if (best == null || gridDistance < bestScore) {
      return UltraTimelineSnapResult(time: gridTime, snapped: true);
    }

    return UltraTimelineSnapResult(
      time: best.time,
      snapped: true,
      target: best,
      blocked: best.blocked,
    );
  }

  DateTime _roundToGrid(DateTime value) {
    final step = grid.inMicroseconds;
    if (step <= 0) return value;
    final epoch = value.microsecondsSinceEpoch;
    final rounded = ((epoch / step).round()) * step;
    return DateTime.fromMicrosecondsSinceEpoch(
      rounded,
      isUtc: value.isUtc,
    );
  }

  Duration _distanceFor(UltraTimelineSnapStrength strength) {
    return switch (strength) {
      UltraTimelineSnapStrength.off => Duration.zero,
      UltraTimelineSnapStrength.soft => softDistance,
      UltraTimelineSnapStrength.balanced => balancedDistance,
      UltraTimelineSnapStrength.strong => strongDistance,
    };
  }

  bool debugAssertIsValid() {
    assert(grid.inMicroseconds > 0, 'grid must be positive.');
    assert(softDistance.inMicroseconds >= 0);
    assert(balancedDistance.inMicroseconds >= softDistance.inMicroseconds);
    assert(strongDistance.inMicroseconds >= balancedDistance.inMicroseconds);
    return true;
  }
}

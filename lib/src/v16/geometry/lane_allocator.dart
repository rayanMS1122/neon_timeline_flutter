/// Input interval for lane allocation.
final class NeonPlannerLaneInterval<T> {
  /// Creates a lane interval.
  const NeonPlannerLaneInterval({
    required this.value,
    required this.startMicros,
    required this.endMicros,
  });

  /// Original value.
  final T value;

  /// Inclusive start.
  final int startMicros;

  /// Exclusive end.
  final int endMicros;
}

/// Lane assignment for an overlapping interval.
final class NeonPlannerLanePlacement<T> {
  /// Creates a placement.
  const NeonPlannerLanePlacement({
    required this.value,
    required this.lane,
    required this.laneCount,
  });

  /// Original value.
  final T value;

  /// Zero-based lane.
  final int lane;

  /// Maximum concurrent lane count in the local overlap group.
  final int laneCount;
}

/// Deterministic O(n log n) interval lane allocator.
final class NeonPlannerLaneAllocator {
  /// Creates a lane allocator.
  const NeonPlannerLaneAllocator();

  /// Allocates the lowest available lane to every interval.
  List<NeonPlannerLanePlacement<T>> allocate<T>(
    Iterable<NeonPlannerLaneInterval<T>> source,
  ) {
    final intervals = List<NeonPlannerLaneInterval<T>>.of(source)
      ..sort((a, b) {
        final start = a.startMicros.compareTo(b.startMicros);
        return start != 0 ? start : a.endMicros.compareTo(b.endMicros);
      });
    if (intervals.isEmpty) {
      return <NeonPlannerLanePlacement<T>>[];
    }

    final laneEnds = <int>[];
    final temporary = <({T value, int lane})>[];
    var maxLaneCount = 1;

    for (final interval in intervals) {
      var lane = -1;
      for (var index = 0; index < laneEnds.length; index += 1) {
        if (laneEnds[index] <= interval.startMicros) {
          lane = index;
          break;
        }
      }
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(interval.endMicros);
      } else {
        laneEnds[lane] = interval.endMicros;
      }
      maxLaneCount = laneEnds.length > maxLaneCount
          ? laneEnds.length
          : maxLaneCount;
      temporary.add((value: interval.value, lane: lane));
    }

    return temporary
        .map(
          (item) => NeonPlannerLanePlacement<T>(
            value: item.value,
            lane: item.lane,
            laneCount: maxLaneCount,
          ),
        )
        .toList(growable: false);
  }
}

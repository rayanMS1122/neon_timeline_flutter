/// Immutable half-open time interval used by the v15 interaction layer.
class UltraTimeRange {
  const UltraTimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
  bool get isValid => end.isAfter(start);

  bool overlaps(UltraTimeRange other) {
    return start.isBefore(other.end) && other.start.isBefore(end);
  }

  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  UltraTimeRange shift(Duration delta) {
    return UltraTimeRange(start: start.add(delta), end: end.add(delta));
  }

  UltraTimeRange copyWith({DateTime? start, DateTime? end}) {
    return UltraTimeRange(start: start ?? this.start, end: end ?? this.end);
  }

  bool debugAssertIsValid() {
    assert(isValid, 'UltraTimeRange.end must be after start.');
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is UltraTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

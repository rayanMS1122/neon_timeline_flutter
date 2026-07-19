import '../domain/ultra_time_range.dart';

/// One indexed interval for viewport and conflict queries.
class UltraTimelineIndexedInterval<T> {
  const UltraTimelineIndexedInterval({
    required this.range,
    required this.value,
  });

  final UltraTimeRange range;
  final T value;
}

/// Sorted interval index with a monotonic prefix-end index.
///
/// The prefix maximum keeps queries correct even when an early long interval
/// overlaps many later short intervals. The implementation remains Flutter-
/// free so it can be unit-tested and reused by isolates.
class UltraTimelineViewportIndex<T> {
  factory UltraTimelineViewportIndex(
    Iterable<UltraTimelineIndexedInterval<T>> values,
  ) {
    final sorted = values.toList(growable: false)
      ..sort((a, b) => a.range.start.compareTo(b.range.start));
    final prefix = <DateTime>[];
    DateTime? maximum;
    for (final item in sorted) {
      if (maximum == null || item.range.end.isAfter(maximum)) {
        maximum = item.range.end;
      }
      prefix.add(maximum);
    }
    return UltraTimelineViewportIndex<T>._(
      List<UltraTimelineIndexedInterval<T>>.unmodifiable(sorted),
      List<DateTime>.unmodifiable(prefix),
    );
  }

  const UltraTimelineViewportIndex._(this._values, this._prefixMaxEnd);

  final List<UltraTimelineIndexedInterval<T>> _values;
  final List<DateTime> _prefixMaxEnd;

  int get length => _values.length;

  List<UltraTimelineIndexedInterval<T>> query(UltraTimeRange range) {
    if (_values.isEmpty) {
      return List<UltraTimelineIndexedInterval<T>>.empty(growable: false);
    }

    var low = 0;
    var high = _prefixMaxEnd.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (_prefixMaxEnd[middle].isAfter(range.start)) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }

    final result = <UltraTimelineIndexedInterval<T>>[];
    for (var index = low; index < _values.length; index += 1) {
      final candidate = _values[index];
      if (!candidate.range.start.isBefore(range.end)) break;
      if (candidate.range.overlaps(range)) result.add(candidate);
    }
    return List<UltraTimelineIndexedInterval<T>>.unmodifiable(result);
  }
}

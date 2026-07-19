/// Minimal interval contract used by the viewport index.
abstract interface class NeonPlannerInterval {
  /// Stable interval start in microseconds since epoch.
  int get startMicros;

  /// Stable interval end in microseconds since epoch.
  int get endMicros;
}

/// Immutable sorted interval index optimized for viewport queries.
final class NeonPlannerIntervalIndex<T extends NeonPlannerInterval> {
  /// Builds an index from [items].
  NeonPlannerIntervalIndex(Iterable<T> items)
    : _items = List<T>.of(items)..sort(
        (T a, T b) => a.startMicros.compareTo(b.startMicros),
      ) {
    if (_items.isEmpty) {
      _prefixMaximumEnd = const <int>[];
      return;
    }

    var maximum = _items.first.endMicros;
    _prefixMaximumEnd = List<int>.generate(_items.length, (index) {
      final end = _items[index].endMicros;
      if (end > maximum) {
        maximum = end;
      }
      return maximum;
    }, growable: false);
  }

  final List<T> _items;
  late final List<int> _prefixMaximumEnd;

  /// Number of indexed items.
  int get length => _items.length;

  /// Returns intervals intersecting `[startMicros, endMicros]`.
  List<T> query(int startMicros, int endMicros) {
    if (_items.isEmpty || endMicros < startMicros) {
      return <T>[];
    }

    // The first prefix whose maximum end can still touch the query.
    var low = 0;
    var high = _prefixMaximumEnd.length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (_prefixMaximumEnd[mid] < startMicros) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    final result = <T>[];
    for (var index = low; index < _items.length; index += 1) {
      final item = _items[index];
      if (item.startMicros > endMicros) {
        break;
      }
      if (item.endMicros >= startMicros) {
        result.add(item);
      }
    }
    return result;
  }
}

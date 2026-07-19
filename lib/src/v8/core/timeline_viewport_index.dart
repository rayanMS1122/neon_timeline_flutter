import 'package:flutter/foundation.dart';

import '../../v6/core/timeline_day_plan.dart';

@immutable
class TimelineViewportSlice<T> {
  const TimelineViewportSlice({
    required this.start,
    required this.end,
    required this.entries,
    required this.firstIndex,
    required this.lastIndex,
  });

  final DateTime start;
  final DateTime end;
  final List<TimelineDayEntry<T>> entries;
  final int firstIndex;
  final int lastIndex;

  bool get isEmpty => entries.isEmpty;
}

/// Immutable interval index for time-window virtualization.
///
/// Queries are O(log n + k), where k is the number of returned entries.
class TimelineViewportIndex<T> {
  TimelineViewportIndex._({
    required this.entries,
    required this.prefixMaximumEndMicros,
  });

  factory TimelineViewportIndex.build(Iterable<TimelineDayEntry<T>> source) {
    final entries = source.toList(growable: false)
      ..sort((left, right) {
        final byStart = left.start.compareTo(right.start);
        if (byStart != 0) return byStart;
        final byEnd = left.end.compareTo(right.end);
        if (byEnd != 0) return byEnd;
        return left.entry.id.toString().compareTo(right.entry.id.toString());
      });
    final prefix = <int>[];
    var maximum = -1 << 62;
    for (final entry in entries) {
      final micros = entry.end.microsecondsSinceEpoch;
      if (micros > maximum) maximum = micros;
      prefix.add(maximum);
    }
    return TimelineViewportIndex<T>._(
      entries: List<TimelineDayEntry<T>>.unmodifiable(entries),
      prefixMaximumEndMicros: List<int>.unmodifiable(prefix),
    );
  }

  final List<TimelineDayEntry<T>> entries;
  final List<int> prefixMaximumEndMicros;

  TimelineViewportSlice<T> query({
    required DateTime start,
    required DateTime end,
    Duration overscan = Duration.zero,
  }) {
    if (!end.isAfter(start) || entries.isEmpty) {
      return TimelineViewportSlice<T>(
        start: start,
        end: end,
        entries: List<TimelineDayEntry<T>>.empty(),
        firstIndex: -1,
        lastIndex: -1,
      );
    }
    final safeOverscan = overscan.isNegative ? Duration.zero : overscan;
    final queryStart = start.subtract(safeOverscan);
    final queryEnd = end.add(safeOverscan);
    final startMicros = queryStart.microsecondsSinceEpoch;

    var low = 0;
    var high = prefixMaximumEndMicros.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (prefixMaximumEndMicros[middle] > startMicros) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }

    final first = low;
    if (first >= entries.length) {
      return TimelineViewportSlice<T>(
        start: queryStart,
        end: queryEnd,
        entries: List<TimelineDayEntry<T>>.empty(),
        firstIndex: -1,
        lastIndex: -1,
      );
    }

    final visible = <TimelineDayEntry<T>>[];
    var firstVisible = -1;
    var lastVisible = -1;
    for (var index = first; index < entries.length; index++) {
      final entry = entries[index];
      if (!entry.start.isBefore(queryEnd)) break;
      if (entry.end.isAfter(queryStart)) {
        firstVisible = firstVisible < 0 ? index : firstVisible;
        lastVisible = index;
        visible.add(entry);
      }
    }

    return TimelineViewportSlice<T>(
      start: queryStart,
      end: queryEnd,
      entries: List<TimelineDayEntry<T>>.unmodifiable(visible),
      firstIndex: firstVisible,
      lastIndex: lastVisible,
    );
  }
}

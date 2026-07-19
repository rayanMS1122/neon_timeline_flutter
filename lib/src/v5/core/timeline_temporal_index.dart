import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';

@immutable
class TimelineTemporalHit<T> {
  const TimelineTemporalHit({
    required this.entry,
    required this.start,
    required this.end,
  });

  final TimelineEntry<T> entry;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

/// Immutable temporal index for fast range queries.
///
/// Entries are sorted once. A monotonic prefix of maximum end values lets the
/// query jump directly to the first interval that can still intersect the
/// requested range, then scan only plausible candidates.
@immutable
class TimelineTemporalIndex<T> {
  const TimelineTemporalIndex._({
    required this.entries,
    required this._prefixMaxEnd,
    required this.invalidEntries,
  });

  factory TimelineTemporalIndex.build(
    Iterable<TimelineEntry<T>> source, {
    bool includeInvalid = false,
  }) {
    final valid = <TimelineTemporalHit<T>>[];
    final invalid = <TimelineEntry<T>>[];
    for (final entry in source) {
      final end = entry.rawEnd;
      if (!end.isAfter(entry.start)) {
        invalid.add(entry);
        if (!includeInvalid) continue;
      }
      valid.add(
        TimelineTemporalHit<T>(
          entry: entry,
          start: entry.start,
          end: end.isAfter(entry.start)
              ? end
              : entry.start.add(const Duration(microseconds: 1)),
        ),
      );
    }
    valid.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      final byEnd = a.end.compareTo(b.end);
      if (byEnd != 0) return byEnd;
      return a.entry.id.hashCode.compareTo(b.entry.id.hashCode);
    });

    final prefix = <DateTime>[];
    DateTime? maximum;
    for (final hit in valid) {
      if (maximum == null || hit.end.isAfter(maximum)) {
        maximum = hit.end;
      }
      prefix.add(maximum);
    }

    return TimelineTemporalIndex<T>._(
      entries: List<TimelineTemporalHit<T>>.unmodifiable(valid),
      prefixMaxEnd: List<DateTime>.unmodifiable(prefix),
      invalidEntries: List<TimelineEntry<T>>.unmodifiable(invalid),
    );
  }

  final List<TimelineTemporalHit<T>> entries;
  final List<DateTime> _prefixMaxEnd;
  final List<TimelineEntry<T>> invalidEntries;

  int get length => entries.length;
  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  List<TimelineEntry<T>> query({
    required DateTime start,
    required DateTime end,
  }) {
    if (!end.isAfter(start) || entries.isEmpty) {
      return <TimelineEntry<T>>[];
    }

    final first = _firstPrefixAfter(start);
    if (first >= entries.length) return <TimelineEntry<T>>[];

    final result = <TimelineEntry<T>>[];
    for (var index = first; index < entries.length; index++) {
      final hit = entries[index];
      if (!hit.start.isBefore(end)) break;
      if (hit.end.isAfter(start)) result.add(hit.entry);
    }
    return List<TimelineEntry<T>>.unmodifiable(result);
  }

  List<TimelineEntry<T>> at(DateTime instant) {
    return query(
      start: instant,
      end: instant.add(const Duration(microseconds: 1)),
    );
  }

  TimelineEntry<T>? nextAfter(DateTime instant) {
    var low = 0;
    var high = entries.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (entries[middle].start.isBefore(instant)) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low < entries.length ? entries[low].entry : null;
  }

  TimelineEntry<T>? previousBefore(DateTime instant) {
    var low = 0;
    var high = entries.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (entries[middle].start.isBefore(instant)) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    for (var index = low - 1; index >= 0; index--) {
      if (!entries[index].end.isAfter(instant)) {
        return entries[index].entry;
      }
    }
    return null;
  }

  int _firstPrefixAfter(DateTime start) {
    var low = 0;
    var high = _prefixMaxEnd.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (_prefixMaxEnd[middle].isAfter(start)) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }
    return low;
  }
}

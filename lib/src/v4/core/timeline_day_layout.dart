import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/timeline_entry.dart';
import 'timeline_render_plan.dart';

/// Positioned entry produced by [TimelineDayLayoutEngine].
@immutable
class TimelineDayLayoutItem<T> {
  const TimelineDayLayoutItem({
    required this.normalizedEntry,
    required this.column,
    required this.columnCount,
    required this.startFraction,
    required this.endFraction,
  });

  final TimelineNormalizedEntry<T> normalizedEntry;
  final int column;
  final int columnCount;
  final double startFraction;
  final double endFraction;

  TimelineEntry<T> get entry => normalizedEntry.entry;
  double get extentFraction => endFraction - startFraction;
  double get leftFraction => column / columnCount;
  double get widthFraction => 1 / columnCount;
}

/// Deterministic overlap-column assignment for day and resource canvases.
///
/// Sorting is inherited from [TimelineRenderPlan]. Active ranges and reusable
/// columns are maintained in balanced trees, so layout is O(n log n).
class TimelineDayLayoutEngine {
  const TimelineDayLayoutEngine._();

  static List<TimelineDayLayoutItem<T>> layout<T>({
    required TimelineRenderPlan<T> plan,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    Iterable<TimelineNormalizedEntry<T>>? sourceEntries,
  }) {
    if (!rangeEnd.isAfter(rangeStart)) {
      throw ArgumentError.value(
        rangeEnd,
        'rangeEnd',
        'must be after rangeStart',
      );
    }

    final totalMicros = rangeEnd.difference(rangeStart).inMicroseconds;
    final active = SplayTreeSet<_ActiveDayColumn<T>>((a, b) {
      final byEnd = a.end.compareTo(b.end);
      if (byEnd != 0) return byEnd;
      return a.serial.compareTo(b.serial);
    });
    final freeColumns = SplayTreeSet<int>();
    final result = <TimelineDayLayoutItem<T>>[];
    var cluster = <_PendingDayItem<T>>[];
    var nextColumn = 0;
    var clusterColumnCount = 0;
    var serial = 0;

    void finishCluster() {
      if (cluster.isEmpty) return;
      final columns = clusterColumnCount.clamp(1, 1 << 20).toInt();
      for (final item in cluster) {
        result.add(
          TimelineDayLayoutItem<T>(
            normalizedEntry: item.entry,
            column: item.column,
            columnCount: columns,
            startFraction: item.startFraction,
            endFraction: item.endFraction,
          ),
        );
      }
      cluster = <_PendingDayItem<T>>[];
      active.clear();
      freeColumns.clear();
      nextColumn = 0;
      clusterColumnCount = 0;
    }

    final orderedEntries = sourceEntries == null
        ? plan.entries
        : (sourceEntries.toList(growable: false)..sort((a, b) {
            final byStart = a.start.compareTo(b.start);
            if (byStart != 0) return byStart;
            final byEnd = b.end.compareTo(a.end);
            if (byEnd != 0) return byEnd;
            return a.originalIndex.compareTo(b.originalIndex);
          }));

    for (final normalized in orderedEntries) {
      if (!normalized.start.isBefore(rangeEnd) ||
          !normalized.end.isAfter(rangeStart)) {
        continue;
      }

      while (active.isNotEmpty && !active.first.end.isAfter(normalized.start)) {
        final ended = active.first;
        active.remove(ended);
        freeColumns.add(ended.column);
      }
      if (active.isEmpty && cluster.isNotEmpty) finishCluster();

      final column = freeColumns.isEmpty ? nextColumn++ : freeColumns.first;
      freeColumns.remove(column);
      active.add(
        _ActiveDayColumn<T>(
          end: normalized.end,
          column: column,
          serial: serial++,
        ),
      );
      if (active.length > clusterColumnCount) {
        clusterColumnCount = active.length;
      }

      final clippedStart = normalized.start.isBefore(rangeStart)
          ? rangeStart
          : normalized.start;
      final clippedEnd = normalized.end.isAfter(rangeEnd)
          ? rangeEnd
          : normalized.end;
      final startFraction =
          clippedStart.difference(rangeStart).inMicroseconds / totalMicros;
      final endFraction =
          clippedEnd.difference(rangeStart).inMicroseconds / totalMicros;
      cluster.add(
        _PendingDayItem<T>(
          entry: normalized,
          column: column,
          startFraction: startFraction.clamp(0.0, 1.0).toDouble(),
          endFraction: endFraction.clamp(0.0, 1.0).toDouble(),
        ),
      );
    }
    finishCluster();

    result.sort((a, b) {
      final byStart = a.normalizedEntry.start.compareTo(
        b.normalizedEntry.start,
      );
      if (byStart != 0) return byStart;
      return a.column.compareTo(b.column);
    });
    return List<TimelineDayLayoutItem<T>>.unmodifiable(result);
  }
}

@immutable
class _ActiveDayColumn<T> {
  const _ActiveDayColumn({
    required this.end,
    required this.column,
    required this.serial,
  });

  final DateTime end;
  final int column;
  final int serial;
}

@immutable
class _PendingDayItem<T> {
  const _PendingDayItem({
    required this.entry,
    required this.column,
    required this.startFraction,
    required this.endFraction,
  });

  final TimelineNormalizedEntry<T> entry;
  final int column;
  final double startFraction;
  final double endFraction;
}

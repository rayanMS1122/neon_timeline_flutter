import 'package:flutter/foundation.dart';

import 'timeline_day_plan.dart';

enum TimelineVisualSegmentKind { entry, gap }

/// Result of a visual hit test in a timeline with compressed gaps and clamped
/// entry heights.
@immutable
class TimelineVisualHit<T> {
  const TimelineVisualHit({
    required this.segment,
    required this.time,
    required this.viewportOffset,
    required this.fraction,
  });

  final TimelineVisualSegment<T> segment;
  final DateTime time;
  final double viewportOffset;
  final double fraction;

  TimelineVisualSegmentKind get kind => segment.kind;
  TimelineDayEntry<T>? get entry => segment.entry;
  TimelineDayGap<T>? get gap => segment.gap;
  bool get isEntry => kind == TimelineVisualSegmentKind.entry;
  bool get isGap => kind == TimelineVisualSegmentKind.gap;
}

@immutable
class TimelineVisualSegment<T> {
  const TimelineVisualSegment({
    required this.kind,
    required this.start,
    required this.end,
    required this.visualStart,
    required this.visualEnd,
    this.entry,
    this.gap,
  });

  final TimelineVisualSegmentKind kind;
  final DateTime start;
  final DateTime end;
  final double visualStart;
  final double visualEnd;
  final TimelineDayEntry<T>? entry;
  final TimelineDayGap<T>? gap;

  double get extent => visualEnd - visualStart;
  Duration get duration => end.difference(start);
  bool get containsTime => end.isAfter(start);
}

/// Converts between timeline time and the actual visual coordinates used by a
/// compressed, clamped day list.
///
/// Unlike a simple pixels-per-minute calculation, this map stays correct when
/// long gaps are compressed and short entries use a minimum card height.
@immutable
class TimelineVisualCoordinateMap<T> {
  const TimelineVisualCoordinateMap._({
    required this.segments,
    required this.totalExtent,
  });

  factory TimelineVisualCoordinateMap.build({
    required TimelineDayPlan<T> plan,
    required double Function(TimelineDayEntry<T> entry) entryExtent,
    required double Function(TimelineDayGap<T> gap) gapExtent,
    bool includeBoundaryGaps = false,
  }) {
    final nodes =
        <_VisualNode<T>>[
          for (final entry in plan.entries) _VisualNode<T>.entry(entry),
          for (final gap in plan.gaps)
            if (includeBoundaryGaps ||
                (gap.previous != null && gap.next != null))
              _VisualNode<T>.gap(gap),
        ]..sort((left, right) {
          final byStart = left.start.compareTo(right.start);
          if (byStart != 0) return byStart;
          return left.entry != null ? -1 : 1;
        });

    final segments = <TimelineVisualSegment<T>>[];
    var cursor = 0.0;
    for (final node in nodes) {
      final rawExtent = node.entry != null
          ? entryExtent(node.entry!)
          : gapExtent(node.gap!);
      final extent = rawExtent.isFinite && rawExtent > 0 ? rawExtent : 0.0;
      final visualEnd = cursor + extent;
      segments.add(
        TimelineVisualSegment<T>(
          kind: node.entry != null
              ? TimelineVisualSegmentKind.entry
              : TimelineVisualSegmentKind.gap,
          start: node.start,
          end: node.end,
          visualStart: cursor,
          visualEnd: visualEnd,
          entry: node.entry,
          gap: node.gap,
        ),
      );
      cursor = visualEnd;
    }
    return TimelineVisualCoordinateMap<T>._(
      segments: List<TimelineVisualSegment<T>>.unmodifiable(segments),
      totalExtent: cursor,
    );
  }

  final List<TimelineVisualSegment<T>> segments;
  final double totalExtent;

  bool get isEmpty => segments.isEmpty;

  DateTime timeForOffset(double offset) {
    return hitTest(offset).time;
  }

  /// Converts a coordinate inside the viewport into real clock time.
  DateTime timeForViewportOffset(
    double offset, {
    double scrollOffset = 0,
    double headerExtent = 0,
  }) {
    return timeForOffset(offset + scrollOffset - headerExtent);
  }

  /// Returns the visual segment and interpolated clock time at [offset].
  TimelineVisualHit<T> hitTest(double offset) {
    if (segments.isEmpty) {
      throw StateError('Cannot hit-test an empty timeline.');
    }
    final clamped = offset.clamp(0.0, totalExtent).toDouble();
    var low = 0;
    var high = segments.length;
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      // Visual segments are half-open. At an exact boundary, resolve to the
      // segment that starts there (for example the entry after a gap).
      if (segments[middle].visualEnd <= clamped) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    final index = low.clamp(0, segments.length - 1);
    final segment = segments[index];
    if (segment.extent <= 0 || segment.duration <= Duration.zero) {
      return TimelineVisualHit<T>(
        segment: segment,
        time: segment.start,
        viewportOffset: clamped,
        fraction: 0,
      );
    }
    final fraction = ((clamped - segment.visualStart) / segment.extent)
        .clamp(0.0, 1.0)
        .toDouble();
    return TimelineVisualHit<T>(
      segment: segment,
      time: segment.start.add(
        Duration(
          microseconds: (segment.duration.inMicroseconds * fraction).round(),
        ),
      ),
      viewportOffset: clamped,
      fraction: fraction,
    );
  }

  double offsetForTime(DateTime value, {Object? entryId}) {
    if (segments.isEmpty) return 0;
    if (entryId != null) {
      for (final segment in segments) {
        if (segment.entry?.entry.id == entryId) {
          return _offsetInside(segment, value);
        }
      }
    }

    TimelineVisualSegment<T>? closest;
    var closestDistance = 1 << 62;
    for (final segment in segments) {
      if (!value.isBefore(segment.start) && value.isBefore(segment.end)) {
        return _offsetInside(segment, value);
      }
      final distance = value.isBefore(segment.start)
          ? segment.start.difference(value).inMicroseconds
          : value.difference(segment.end).inMicroseconds;
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = segment;
      }
    }
    if (closest == null) return 0;
    return value.isBefore(closest.start)
        ? closest.visualStart
        : closest.visualEnd;
  }

  /// Converts real clock time to a coordinate inside the viewport.
  double viewportOffsetForTime(
    DateTime value, {
    Object? entryId,
    double scrollOffset = 0,
    double headerExtent = 0,
  }) {
    return offsetForTime(value, entryId: entryId) - scrollOffset + headerExtent;
  }

  double _offsetInside(TimelineVisualSegment<T> segment, DateTime value) {
    if (segment.extent <= 0 || segment.duration <= Duration.zero) {
      return segment.visualStart;
    }
    final elapsed = value.difference(segment.start).inMicroseconds;
    final fraction = (elapsed / segment.duration.inMicroseconds).clamp(
      0.0,
      1.0,
    );
    return segment.visualStart + segment.extent * fraction;
  }
}

class _VisualNode<T> {
  const _VisualNode._({
    required this.start,
    required this.end,
    this.entry,
    this.gap,
  });

  factory _VisualNode.entry(TimelineDayEntry<T> entry) =>
      _VisualNode<T>._(start: entry.start, end: entry.end, entry: entry);

  factory _VisualNode.gap(TimelineDayGap<T> gap) =>
      _VisualNode<T>._(start: gap.start, end: gap.end, gap: gap);

  final DateTime start;
  final DateTime end;
  final TimelineDayEntry<T>? entry;
  final TimelineDayGap<T>? gap;
}

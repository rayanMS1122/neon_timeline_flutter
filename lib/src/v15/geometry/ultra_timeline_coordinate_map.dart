import '../domain/ultra_time_range.dart';

/// Pure-Dart conversion between timeline time and viewport coordinates.
class UltraTimelineCoordinateMap {
  const UltraTimelineCoordinateMap({
    required this.rangeStart,
    required this.rangeEnd,
    required this.pixelsPerMinute,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double pixelsPerMinute;

  Duration get duration => rangeEnd.difference(rangeStart);
  double get extent => duration.inMicroseconds / Duration.microsecondsPerMinute * pixelsPerMinute;

  double offsetFor(DateTime value) {
    final minutes = value.difference(rangeStart).inMicroseconds /
        Duration.microsecondsPerMinute;
    return minutes * pixelsPerMinute;
  }

  DateTime dateAtOffset(double offset) {
    final microseconds =
        (offset / pixelsPerMinute * Duration.microsecondsPerMinute).round();
    return rangeStart.add(Duration(microseconds: microseconds));
  }

  UltraTimeRange rangeForViewport({
    required double offset,
    required double extent,
    double overscan = 0,
  }) {
    final start = dateAtOffset((offset - overscan).clamp(0, this.extent).toDouble());
    final end = dateAtOffset((offset + extent + overscan).clamp(0, this.extent).toDouble());
    return UltraTimeRange(start: start, end: end);
  }

  bool debugAssertIsValid() {
    assert(rangeEnd.isAfter(rangeStart), 'rangeEnd must be after rangeStart.');
    assert(pixelsPerMinute > 0, 'pixelsPerMinute must be greater than zero.');
    return true;
  }
}

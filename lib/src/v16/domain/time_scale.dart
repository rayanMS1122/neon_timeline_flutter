/// Pure-Dart conversion between time and vertical pixels.
final class NeonPlannerTimeScale {
  /// Creates a time scale.
  const NeonPlannerTimeScale({
    required this.origin,
    required this.pixelsPerMinute,
  }) : assert(pixelsPerMinute > 0);

  /// Temporal origin mapped to pixel zero.
  final DateTime origin;

  /// Vertical density.
  final double pixelsPerMinute;

  /// Converts [time] to a vertical pixel coordinate.
  double timeToPixels(DateTime time) {
    return time.difference(origin).inMicroseconds /
        Duration.microsecondsPerMinute *
        pixelsPerMinute;
  }

  /// Converts a vertical pixel coordinate to a time.
  DateTime pixelsToTime(double pixels) {
    final microseconds =
        pixels / pixelsPerMinute * Duration.microsecondsPerMinute;
    return origin.add(Duration(microseconds: microseconds.round()));
  }

  /// Converts a duration to pixels.
  double durationToPixels(Duration duration) {
    return duration.inMicroseconds /
        Duration.microsecondsPerMinute *
        pixelsPerMinute;
  }

  /// Converts pixels to a duration.
  Duration pixelsToDuration(double pixels) {
    final microseconds =
        pixels / pixelsPerMinute * Duration.microsecondsPerMinute;
    return Duration(microseconds: microseconds.round());
  }
}

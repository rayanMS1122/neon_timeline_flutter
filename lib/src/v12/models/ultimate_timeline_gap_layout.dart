import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Strategy used to convert real free time into visual timeline height.
enum UltimateTimelineGapLayoutType {
  proportional,
  compressed,
  hybrid,
  focusAware,
  custom,
}

/// Computes a custom visual gap extent from time and focus proximity.
typedef UltimateTimelineGapExtent =
    double Function(
      Duration duration,
      Duration distanceFromFocus,
      bool activeDropTarget,
    );

/// 12.x gap geometry including a stable focus-aware compression strategy.
@immutable
class UltimateTimelineGapLayout {
  const UltimateTimelineGapLayout.proportional({
    this.pixelsPerMinute = 1.25,
    this.minimumExtent = 28,
    this.maximumExtent = 480,
  }) : type = UltimateTimelineGapLayoutType.proportional,
       compressedExtent = 480,
       compressionStartsAt = const Duration(days: 1),
       focusRadius = Duration.zero,
       customExtent = null;

  const UltimateTimelineGapLayout.compressed({
    this.minimumExtent = 38,
    this.maximumExtent = 92,
    this.compressedExtent = 64,
  }) : type = UltimateTimelineGapLayoutType.compressed,
       pixelsPerMinute = 1,
       compressionStartsAt = Duration.zero,
       focusRadius = Duration.zero,
       customExtent = null;

  const UltimateTimelineGapLayout.hybrid({
    this.pixelsPerMinute = 1.15,
    this.minimumExtent = 36,
    this.maximumExtent = 164,
    this.compressedExtent = 82,
    this.compressionStartsAt = const Duration(hours: 2),
  }) : type = UltimateTimelineGapLayoutType.hybrid,
       focusRadius = Duration.zero,
       customExtent = null;

  const UltimateTimelineGapLayout.focusAware({
    this.pixelsPerMinute = 1.2,
    this.minimumExtent = 38,
    this.maximumExtent = 190,
    this.compressedExtent = 68,
    this.compressionStartsAt = const Duration(hours: 1),
    this.focusRadius = const Duration(hours: 3),
  }) : type = UltimateTimelineGapLayoutType.focusAware,
       customExtent = null;

  const UltimateTimelineGapLayout.custom({
    required this.customExtent,
    this.minimumExtent = 0,
    this.maximumExtent = double.infinity,
  }) : type = UltimateTimelineGapLayoutType.custom,
       pixelsPerMinute = 1,
       compressedExtent = 0,
       compressionStartsAt = Duration.zero,
       focusRadius = Duration.zero;

  final UltimateTimelineGapLayoutType type;
  final double pixelsPerMinute;
  final double minimumExtent;
  final double maximumExtent;
  final double compressedExtent;
  final Duration compressionStartsAt;
  final Duration focusRadius;
  final UltimateTimelineGapExtent? customExtent;

  double extentFor(
    Duration duration, {
    Duration distanceFromFocus = Duration.zero,
    bool activeDropTarget = false,
  }) {
    final raw =
        duration.inMicroseconds /
        Duration.microsecondsPerMinute *
        pixelsPerMinute;
    final value = switch (type) {
      UltimateTimelineGapLayoutType.proportional => raw,
      UltimateTimelineGapLayoutType.compressed => compressedExtent,
      UltimateTimelineGapLayoutType.hybrid =>
        duration > compressionStartsAt ? compressedExtent : raw,
      UltimateTimelineGapLayoutType.focusAware => _focusAwareExtent(
        raw,
        distanceFromFocus,
        activeDropTarget,
      ),
      UltimateTimelineGapLayoutType.custom => customExtent!(
        duration,
        distanceFromFocus,
        activeDropTarget,
      ),
    };
    if (!value.isFinite) return minimumExtent;
    return value.clamp(minimumExtent, maximumExtent).toDouble();
  }

  double _focusAwareExtent(
    double raw,
    Duration distance,
    bool activeDropTarget,
  ) {
    if (activeDropTarget) {
      return math.max(compressedExtent, math.min(raw, maximumExtent));
    }
    if (focusRadius <= Duration.zero) return compressedExtent;
    final normalized =
        (distance.inMicroseconds.abs() / focusRadius.inMicroseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final detail = 1 - normalized * normalized;
    return compressedExtent +
        (math.min(raw, maximumExtent) - compressedExtent) * detail;
  }
}

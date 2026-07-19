import 'package:flutter/foundation.dart';

enum StructuredTimelineGapLayoutType {
  proportional,
  compressed,
  hybrid,
  fixedMaximum,
  custom,
}

@immutable
class StructuredTimelineGapLayout {
  const StructuredTimelineGapLayout({
    this.type = StructuredTimelineGapLayoutType.hybrid,
    this.pixelsPerMinute = 1.2,
    this.minimumExtent = 34,
    this.maximumExtent = 144,
    this.compressionStartsAt = const Duration(hours: 2),
    this.compressedExtent = 84,
    this.customExtent,
  });

  const StructuredTimelineGapLayout.proportional({
    this.pixelsPerMinute = 1.2,
    this.minimumExtent = 24,
    this.maximumExtent = 420,
  }) : type = StructuredTimelineGapLayoutType.proportional,
       compressionStartsAt = const Duration(hours: 24),
       compressedExtent = 420,
       customExtent = null;

  const StructuredTimelineGapLayout.compressed({
    this.minimumExtent = 42,
    this.maximumExtent = 88,
    this.compressedExtent = 64,
  }) : type = StructuredTimelineGapLayoutType.compressed,
       pixelsPerMinute = 1,
       compressionStartsAt = Duration.zero,
       customExtent = null;

  const StructuredTimelineGapLayout.hybrid({
    this.pixelsPerMinute = 1.1,
    this.minimumExtent = 36,
    this.maximumExtent = 148,
    this.compressionStartsAt = const Duration(hours: 2),
    this.compressedExtent = 92,
  }) : type = StructuredTimelineGapLayoutType.hybrid,
       customExtent = null;

  const StructuredTimelineGapLayout.fixedMaximum({
    required double maximumExtent,
    this.minimumExtent = 36,
    this.pixelsPerMinute = 1.15,
  }) : maximumExtent = maximumExtent,
       type = StructuredTimelineGapLayoutType.fixedMaximum,
       compressionStartsAt = const Duration(hours: 24),
       compressedExtent = maximumExtent,
       customExtent = null;

  const StructuredTimelineGapLayout.custom({
    required this.customExtent,
    this.minimumExtent = 0,
    this.maximumExtent = double.infinity,
  }) : type = StructuredTimelineGapLayoutType.custom,
       pixelsPerMinute = 1,
       compressionStartsAt = Duration.zero,
       compressedExtent = 0;

  final StructuredTimelineGapLayoutType type;
  final double pixelsPerMinute;
  final double minimumExtent;
  final double maximumExtent;
  final Duration compressionStartsAt;
  final double compressedExtent;
  final double Function(Duration duration)? customExtent;

  double extentFor(Duration duration) {
    final minutes = duration.inMicroseconds / Duration.microsecondsPerMinute;
    final raw = minutes * pixelsPerMinute;
    final resolved = switch (type) {
      StructuredTimelineGapLayoutType.proportional => raw,
      StructuredTimelineGapLayoutType.compressed => compressedExtent,
      StructuredTimelineGapLayoutType.hybrid =>
        duration > compressionStartsAt ? compressedExtent : raw,
      StructuredTimelineGapLayoutType.fixedMaximum => raw,
      StructuredTimelineGapLayoutType.custom => customExtent!(duration),
    };
    if (!resolved.isFinite) return minimumExtent;
    return resolved.clamp(minimumExtent, maximumExtent).toDouble();
  }

  bool isCompressed(Duration duration) {
    return switch (type) {
      StructuredTimelineGapLayoutType.compressed => true,
      StructuredTimelineGapLayoutType.hybrid => duration > compressionStartsAt,
      StructuredTimelineGapLayoutType.fixedMaximum =>
        duration.inMicroseconds /
                Duration.microsecondsPerMinute *
                pixelsPerMinute >
            maximumExtent,
      _ => false,
    };
  }
}

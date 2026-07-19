import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v9.dart';

void main() {
  group('StructuredTimelineSegmenter', () {
    test('clips an entry that ends after the viewport', () {
      final start = DateTime(2026, 7, 16, 23, 24);
      final entry = TimelineEntry<String>(
        id: 'overnight',
        value: 'Overnight',
        start: start,
        duration: const Duration(minutes: 55),
      );
      final segment = StructuredTimelineSegmenter.segment<String>(
        entry: entry,
        viewportStart: DateTime(2026, 7, 16),
        viewportEnd: DateTime(2026, 7, 17),
      );

      expect(segment, isNotNull);
      expect(segment!.type, TimelineEntrySegmentType.endsAfterViewport);
      expect(segment.visibleEnd, DateTime(2026, 7, 17));
      expect(segment.visibleDuration, const Duration(minutes: 36));
      expect(segment.originalDuration, const Duration(minutes: 55));
    });

    test('returns null outside the viewport', () {
      final entry = TimelineEntry<String>(
        id: 'outside',
        value: 'Outside',
        start: DateTime(2026, 7, 18, 9),
      );
      expect(
        StructuredTimelineSegmenter.segment<String>(
          entry: entry,
          viewportStart: DateTime(2026, 7, 16),
          viewportEnd: DateTime(2026, 7, 17),
        ),
        isNull,
      );
    });
  });

  group('StructuredTimelineGapLayout', () {
    test('hybrid compresses long free windows', () {
      const layout = StructuredTimelineGapLayout.hybrid(
        compressionStartsAt: Duration(hours: 2),
        compressedExtent: 90,
      );
      expect(layout.isCompressed(const Duration(hours: 4)), isTrue);
      expect(layout.extentFor(const Duration(hours: 4)), 90);
      expect(layout.isCompressed(const Duration(minutes: 30)), isFalse);
    });
  });
}

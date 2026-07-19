import '../../v4/models/timeline_entry.dart';
import '../models/structured_timeline_entry_segment.dart';

class StructuredTimelineSegmenter {
  const StructuredTimelineSegmenter._();

  static StructuredTimelineEntrySegment<T>? segment<T>({
    required TimelineEntry<T> entry,
    required DateTime viewportStart,
    required DateTime viewportEnd,
  }) {
    if (!viewportEnd.isAfter(viewportStart)) {
      throw ArgumentError('viewportEnd must be after viewportStart');
    }
    if (!entry.rawEnd.isAfter(viewportStart) ||
        !entry.start.isBefore(viewportEnd)) {
      return null;
    }

    final visibleStart = entry.start.isBefore(viewportStart)
        ? viewportStart
        : entry.start;
    final visibleEnd = entry.rawEnd.isAfter(viewportEnd)
        ? viewportEnd
        : entry.rawEnd;

    final startsBefore = entry.start.isBefore(viewportStart);
    final endsAfter = entry.rawEnd.isAfter(viewportEnd);
    final type = startsBefore && endsAfter
        ? TimelineEntrySegmentType.middleSegment
        : startsBefore
        ? TimelineEntrySegmentType.startsBeforeViewport
        : endsAfter
        ? TimelineEntrySegmentType.endsAfterViewport
        : TimelineEntrySegmentType.complete;

    return StructuredTimelineEntrySegment<T>(
      entry: entry,
      viewportStart: viewportStart,
      viewportEnd: viewportEnd,
      visibleStart: visibleStart,
      visibleEnd: visibleEnd,
      type: type,
    );
  }
}

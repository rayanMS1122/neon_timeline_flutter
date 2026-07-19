import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';

enum TimelineEntrySegmentType {
  complete,
  startsBeforeViewport,
  endsAfterViewport,
  middleSegment,
}

@immutable
class StructuredTimelineEntrySegment<T> {
  const StructuredTimelineEntrySegment({
    required this.entry,
    required this.viewportStart,
    required this.viewportEnd,
    required this.visibleStart,
    required this.visibleEnd,
    required this.type,
  });

  final TimelineEntry<T> entry;
  final DateTime viewportStart;
  final DateTime viewportEnd;
  final DateTime visibleStart;
  final DateTime visibleEnd;
  final TimelineEntrySegmentType type;

  DateTime get originalStart => entry.start;
  DateTime get originalEnd => entry.rawEnd;
  Duration get originalDuration => entry.rawEnd.difference(entry.start);
  Duration get visibleDuration => visibleEnd.difference(visibleStart);
  bool get continuesBefore => visibleStart.isAfter(entry.start);
  bool get continuesAfter => visibleEnd.isBefore(entry.rawEnd);
}

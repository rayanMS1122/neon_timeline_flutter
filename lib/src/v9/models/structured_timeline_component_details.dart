import 'package:flutter/widgets.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';

@immutable
class StructuredTimelineViewportDetails {
  const StructuredTimelineViewportDetails({
    required this.visibleRange,
    required this.viewportExtent,
    required this.scrollOffset,
    required this.overscan,
  });

  final TimelineDateRange? visibleRange;
  final double viewportExtent;
  final double scrollOffset;
  final Duration overscan;
}

@immutable
class StructuredTimelineGapDetails<T> {
  const StructuredTimelineGapDetails({
    required this.gap,
    required this.visible,
    required this.compressed,
  });

  final TimelineDayGap<T> gap;
  final bool visible;
  final bool compressed;

  DateTime get start => gap.start;
  DateTime get end => gap.end;
  Duration get duration => gap.duration;
  TimelineDayEntry<T>? get previous => gap.previous;
  TimelineDayEntry<T>? get next => gap.next;
}

@immutable
class StructuredTimelineConflictDetails<T> {
  const StructuredTimelineConflictDetails({
    required this.conflict,
    required this.preview,
  });

  final TimelineDayConflict<T> conflict;
  final bool preview;

  DateTime get start => conflict.start;
  DateTime get end => conflict.end;
  Duration get duration => conflict.duration;
  List<TimelineDayEntry<T>> get entries => conflict.entries;
}

@immutable
class StructuredTimelineDragDetails<T> {
  const StructuredTimelineDragDetails({
    required this.entryDetails,
    this.preview,
  });

  final AdvancedStructuredTimelineEntryDetails<T> entryDetails;
  final TimelineReschedulePreview<T>? preview;

  TimelineEntry<T> get entry => entryDetails.entry;
  bool get hasConflict => preview?.hasConflicts ?? entryDetails.hasConflict;
}

@immutable
class StructuredTimelineResizeDetails<T> {
  const StructuredTimelineResizeDetails({
    required this.item,
    required this.preview,
  });

  final TimelineDayEntry<T> item;
  final TimelineResizePreview<T> preview;

  TimelineEntry<T> get entry => item.entry;
}

@immutable
class StructuredTimelineSelectionDetails<T> {
  const StructuredTimelineSelectionDetails({
    required this.entry,
    required this.selected,
    required this.focused,
    required this.multiSelect,
  });

  final TimelineEntry<T> entry;
  final bool selected;
  final bool focused;
  final bool multiSelect;
}

@immutable
class StructuredTimelineInteractionState<T> {
  const StructuredTimelineInteractionState({
    this.activeEntry,
    this.dragging = false,
    this.resizing = false,
    this.busy = false,
    this.deleteTargetActive = false,
  });

  final TimelineEntry<T>? activeEntry;
  final bool dragging;
  final bool resizing;
  final bool busy;
  final bool deleteTargetActive;
}

@immutable
class StructuredTimelineCurrentEntryDetails<T> {
  const StructuredTimelineCurrentEntryDetails({
    required this.item,
    required this.now,
    required this.remaining,
    required this.progress,
  });

  final TimelineDayEntry<T> item;
  final DateTime now;
  final Duration remaining;
  final double progress;
}

@immutable
class StructuredTimelineNextEntryDetails<T> {
  const StructuredTimelineNextEntryDetails({
    required this.item,
    required this.now,
    required this.startsIn,
  });

  final TimelineDayEntry<T> item;
  final DateTime now;
  final Duration startsIn;
}

@immutable
class StructuredTimelineMetrics {
  const StructuredTimelineMetrics({
    required this.entries,
    required this.conflicts,
    required this.busy,
    required this.free,
    required this.utilization,
  });

  static StructuredTimelineMetrics fromPlan<T>(TimelineDayPlan<T> plan) {
    return StructuredTimelineMetrics(
      entries: plan.entries.length,
      conflicts: plan.conflicts.length,
      busy: plan.busyDuration,
      free: plan.freeDuration,
      utilization: plan.utilization,
    );
  }

  final int entries;
  final int conflicts;
  final Duration busy;
  final Duration free;
  final double utilization;
}

typedef StructuredTimelinePublicEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      AdvancedStructuredTimelineEntryDetails<T> details,
    );

import 'package:flutter/widgets.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../core/ultimate_timeline_snap_engine.dart';

/// Visible relationship of one entry segment to its original time range.
enum UltimateTimelineSegmentType {
  complete,
  start,
  middle,
  end,
  clippedBefore,
  clippedAfter,
}

/// Host-selected policy for incoming data while an interaction is active.
enum UltimateTimelineLiveUpdatePolicy {
  freezeDraggedEntry,
  mergeUnrelatedChanges,
  cancelOnDraggedEntryChange,
  rebaseDraggedEntry,
  custom,
}

/// Explicit, composable entry state; no ambiguous single status circle.
@immutable
class UltimateTimelineEntryInteractionState<T> {
  const UltimateTimelineEntryInteractionState({
    this.selected = false,
    this.focused = false,
    this.hovered = false,
    this.completed = false,
    this.locked = false,
    this.recurring = false,
    this.external = false,
    this.busy = false,
    this.error = false,
    this.dragging = false,
    this.resizing = false,
    this.errorMessage,
  });

  final bool selected;
  final bool focused;
  final bool hovered;
  final bool completed;
  final bool locked;
  final bool recurring;
  final bool external;
  final bool busy;
  final bool error;
  final bool dragging;
  final bool resizing;
  final String? errorMessage;
}

/// Stable copy of the moved entry used while host data changes underneath it.
@immutable
class UltimateTimelineDragSnapshot<T> {
  const UltimateTimelineDragSnapshot({
    required this.entry,
    required this.originalStart,
    required this.originalEnd,
    required this.dataRevision,
  });

  final TimelineEntry<T> entry;
  final DateTime originalStart;
  final DateTime originalEnd;
  final Object? dataRevision;
}

/// Unified immutable builder details for an entry.
@immutable
class UltimateTimelineEntryDetails<T> {
  const UltimateTimelineEntryDetails({
    required this.base,
    required this.interaction,
    this.segmentType = UltimateTimelineSegmentType.complete,
    this.visible = true,
  });

  final AdvancedStructuredTimelineEntryDetails<T> base;
  final UltimateTimelineEntryInteractionState<T> interaction;
  final UltimateTimelineSegmentType segmentType;
  final bool visible;

  TimelineEntry<T> get entry => base.entry;
  T get value => base.value;
  DateTime get originalStart => entry.start;
  DateTime get originalEnd => entry.rawEnd;
  DateTime get visibleStart => base.effectiveStart;
  DateTime get visibleEnd => base.effectiveEnd;
  Duration get duration => visibleEnd.difference(visibleStart);
}

/// Unified immutable builder details for a free timeline range.
@immutable
class UltimateTimelineGapDetails<T> {
  const UltimateTimelineGapDetails({
    required this.gap,
    required this.extent,
    this.compressed = false,
    this.activeDropTarget = false,
  });

  final TimelineDayGap<T> gap;
  final double extent;
  final bool compressed;
  final bool activeDropTarget;

  DateTime get start => gap.start;
  DateTime get end => gap.end;
  Duration get duration => gap.duration;
}

/// Builder details for the active drag operation.
@immutable
class UltimateTimelineDragDetails<T> {
  const UltimateTimelineDragDetails({
    required this.entry,
    required this.preview,
    this.snap,
    this.blockReason,
  });

  final TimelineEntry<T> entry;
  final TimelineReschedulePreview<T> preview;
  final UltimateTimelineSnapResult<T>? snap;
  final String? blockReason;

  DateTime get start => preview.start;
  DateTime get end => preview.end;
  Duration get duration => end.difference(start);
  bool get allowed => preview.canCommit && (snap?.allowed ?? true);
}

/// Builder details for the active resize operation.
@immutable
class UltimateTimelineResizeDetails<T> {
  const UltimateTimelineResizeDetails({
    required this.entry,
    required this.preview,
    this.blockReason,
  });

  final TimelineEntry<T> entry;
  final TimelineResizePreview<T> preview;
  final String? blockReason;
}

/// Builder details for a visible conflict range.
@immutable
class UltimateTimelineConflictDetails<T> {
  const UltimateTimelineConflictDetails({
    required this.start,
    required this.end,
    required this.entries,
    this.blocking = false,
  });

  final DateTime start;
  final DateTime end;
  final List<TimelineEntry<T>> entries;
  final bool blocking;

  Duration get overlap => end.difference(start);
}

/// Current viewport state exposed without leaking render objects.
@immutable
class UltimateTimelineViewportDetails {
  const UltimateTimelineViewportDetails({
    required this.offset,
    required this.extent,
    required this.rangeStart,
    required this.rangeEnd,
    required this.overscan,
  });

  final double offset;
  final double extent;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double overscan;
}

/// Responsive header input independent from app navigation/state management.
@immutable
class UltimateTimelineHeaderDetails {
  const UltimateTimelineHeaderDetails({
    required this.selectedDate,
    required this.compact,
    this.busyDuration = Duration.zero,
    this.freeDuration = Duration.zero,
    this.conflictCount = 0,
  });

  final DateTime selectedDate;
  final bool compact;
  final Duration busyDuration;
  final Duration freeDuration;
  final int conflictCount;
}

/// Builds an entry from the complete unified 12.x details object.
typedef UltimateTimelineEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      UltimateTimelineEntryDetails<T> details,
    );

/// Builds a free-time gap from unified 12.x gap details.
typedef UltimateTimelineGapBuilder<T> =
    Widget Function(
      BuildContext context,
      UltimateTimelineGapDetails<T> details,
    );

/// Builds active drag feedback from immutable drag details.
typedef UltimateTimelineDragBuilder<T> =
    Widget Function(
      BuildContext context,
      UltimateTimelineDragDetails<T> details,
    );

/// Builds a resize preview from immutable resize details.
typedef UltimateTimelineResizeBuilder<T> =
    Widget Function(
      BuildContext context,
      UltimateTimelineResizeDetails<T> details,
    );

/// Builds conflict feedback without requiring package-owned app models.
typedef UltimateTimelineConflictBuilder<T> =
    Widget Function(
      BuildContext context,
      UltimateTimelineConflictDetails<T> details,
    );

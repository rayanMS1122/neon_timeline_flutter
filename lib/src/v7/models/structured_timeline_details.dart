import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import 'structured_timeline_style.dart';

@immutable
class StructuredTimelineEntryDetails<T> {
  const StructuredTimelineEntryDetails({
    required this.item,
    required this.style,
    required this.isDragging,
    required this.isBusy,
    this.preview,
  });

  final TimelineDayEntry<T> item;
  final StructuredTimelineStyle style;
  final bool isDragging;
  final bool isBusy;
  final TimelineReschedulePreview<T>? preview;

  TimelineEntry<T> get entry => item.entry;
  T get value => item.entry.value;
  bool get hasConflict => preview?.hasConflicts ?? item.hasConflict;
  bool get isCompleted => entry.status == TimelineStatus.completed;
  bool get isRecurring =>
      entry.metadata['timeline.generated'] == true ||
      entry.metadata['timeline.seriesId'] != null;
  bool get isExternal =>
      entry.metadata['timeline.external'] == true || !entry.draggable;
}

@immutable
class StructuredTimelineMoveDetails<T> {
  const StructuredTimelineMoveDetails({
    required this.item,
    required this.result,
  });

  final TimelineDayEntry<T> item;
  final TimelineDropResult<T> result;

  TimelineEntry<T> get entry => item.entry;
  T get value => item.entry.value;
  TimelineReschedulePreview<T> get preview => result.preview;
}

typedef StructuredTimelineEntryCallback<T> =
    FutureOr<void> Function(
      BuildContext context,
      StructuredTimelineEntryDetails<T> details,
    );

typedef StructuredTimelineMoveCallback<T> =
    FutureOr<void> Function(
      BuildContext context,
      StructuredTimelineMoveDetails<T> details,
    );

typedef StructuredTimelineGapCallback<T> =
    FutureOr<void> Function(BuildContext context, TimelineDayGap<T> gap);

typedef StructuredTimelineCardBuilder<T> =
    Widget Function(
      BuildContext context,
      StructuredTimelineEntryDetails<T> details,
    );

typedef StructuredTimelineIconBuilder<T> =
    Widget Function(
      BuildContext context,
      StructuredTimelineEntryDetails<T> details,
    );

typedef StructuredTimelineTrailingBuilder<T> =
    Widget Function(
      BuildContext context,
      StructuredTimelineEntryDetails<T> details,
    );

typedef StructuredTimelineTitleBuilder<T> =
    String Function(TimelineEntry<T> entry);

typedef StructuredTimelineSubtitleBuilder<T> =
    String? Function(TimelineEntry<T> entry);

typedef StructuredTimelineProgressBuilder<T> =
    double? Function(TimelineEntry<T> entry);

typedef StructuredTimelineTimeFormatter = String Function(DateTime value);
typedef StructuredTimelineDurationFormatter = String Function(Duration value);

typedef StructuredTimelineGapBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayGap<T> gap,
      StructuredTimelineStyle style,
    );

/// Computes the visual extent used for navigation and visibility calculations.
///
/// Custom gap widgets should return the same height from their layout.
typedef StructuredTimelineGapExtentBuilder<T> =
    double Function(TimelineDayGap<T> gap, StructuredTimelineStyle style);

typedef StructuredTimelineTimeLabelBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayEntry<T> item,
      DateTime value,
      bool isEnd,
      StructuredTimelineStyle style,
    );

typedef StructuredTimelineInsightBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayPlan<T> plan,
      StructuredTimelineStyle style,
    );

typedef StructuredTimelineConflictBridgeBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayEntry<T> item,
      Duration overlap,
      StructuredTimelineStyle style,
    );

typedef StructuredTimelineDragDecorator<T> =
    Widget Function(
      BuildContext context,
      StructuredTimelineEntryDetails<T> details,
      Widget child,
    );

typedef StructuredTimelineDeleteTargetBuilder =
    Widget Function(
      BuildContext context,
      bool active,
      StructuredTimelineStyle style,
    );

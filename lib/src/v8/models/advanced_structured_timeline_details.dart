import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../core/timeline_mutation_coordinator.dart';
import '../core/timeline_resize.dart';

@immutable
class AdvancedStructuredTimelineEntryDetails<T> {
  const AdvancedStructuredTimelineEntryDetails({
    required this.base,
    required this.selected,
    required this.focused,
    required this.busy,
    this.resizePreview,
    this.onComplete,
  });

  final StructuredTimelineEntryDetails<T> base;
  final bool selected;
  final bool focused;
  final bool busy;
  final TimelineResizePreview<T>? resizePreview;
  final Future<void> Function()? onComplete;

  TimelineDayEntry<T> get item => base.item;
  TimelineEntry<T> get entry => base.entry;
  T get value => base.value;
  StructuredTimelineStyle get style => base.style;
  TimelineReschedulePreview<T>? get movePreview => base.preview;
  bool get isDragging => base.isDragging;
  bool get isResizing => resizePreview != null;
  bool get hasConflict => resizePreview?.hasConflicts ?? base.hasConflict;
  DateTime get effectiveStart =>
      resizePreview?.start ?? movePreview?.start ?? item.start;
  DateTime get effectiveEnd =>
      resizePreview?.end ?? movePreview?.end ?? item.end;
  Duration get effectiveDuration => effectiveEnd.difference(effectiveStart);
}

@immutable
class AdvancedStructuredTimelineResizeDetails<T> {
  const AdvancedStructuredTimelineResizeDetails({
    required this.item,
    required this.result,
  });

  final TimelineDayEntry<T> item;
  final TimelineResizeResult<T> result;

  TimelineEntry<T> get entry => item.entry;
  T get value => item.entry.value;
  TimelineResizePreview<T> get preview => result.preview;
}

typedef AdvancedStructuredTimelineEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      AdvancedStructuredTimelineEntryDetails<T> details,
    );

typedef AdvancedStructuredTimelineGapBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayGap<T> gap,
      StructuredTimelineStyle style,
    );

typedef AdvancedStructuredTimelineTimeLabelBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayEntry<T> item,
      DateTime value,
      bool isEnd,
      StructuredTimelineStyle style,
    );

typedef AdvancedStructuredTimelineInsightBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayPlan<T> plan,
      StructuredTimelineStyle style,
    );

typedef AdvancedStructuredTimelineConflictBridgeBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDayEntry<T> item,
      Duration overlap,
      StructuredTimelineStyle style,
    );

typedef AdvancedStructuredTimelineDragDecorator<T> =
    Widget Function(
      BuildContext context,
      AdvancedStructuredTimelineEntryDetails<T> details,
      Widget child,
    );

typedef AdvancedStructuredTimelineDeleteTargetBuilder =
    Widget Function(
      BuildContext context,
      bool active,
      StructuredTimelineStyle style,
    );

typedef AdvancedStructuredTimelineResizeCallback<T> =
    FutureOr<void> Function(
      BuildContext context,
      AdvancedStructuredTimelineResizeDetails<T> details,
    );

typedef AdvancedStructuredTimelineMutationError<T> =
    void Function(
      BuildContext context,
      TimelineEntry<T> entry,
      Object error,
      StackTrace stackTrace,
    );

typedef AdvancedStructuredTimelineMutationRollback<T> =
    FutureOr<void> Function(
      BuildContext context,
      TimelineMutationRequest<T> request,
      Object error,
      StackTrace stackTrace,
    );

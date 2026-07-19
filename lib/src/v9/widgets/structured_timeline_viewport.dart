import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../../v8/models/structured_timeline_layout.dart';
import '../../v8/widgets/advanced_structured_timeline.dart';
import '../models/structured_timeline_entry_style.dart';
import '../models/structured_timeline_gap_layout.dart';
import 'structured_timeline_entry_components.dart';
import 'structured_timeline_gap_components.dart';
import 'structured_timeline_states.dart';

class StructuredTimelineViewport<T> extends StatelessWidget {
  const StructuredTimelineViewport({
    required this.plan,
    this.style,
    this.layout = const StructuredTimelineLayout.comfortable(),
    this.entryStyle = const StructuredTimelineEntryStyle.comfortable(),
    this.gapLayout = const StructuredTimelineGapLayout.hybrid(),
    this.strings = const StructuredTimelineStrings(),
    this.controller,
    this.mutationCoordinator,
    this.onEntryTap,
    this.onComplete,
    this.onMove,
    this.onResize,
    this.onDelete,
    this.onInsert,
    this.onMutationError,
    this.onMutationRollback,
    this.entryBuilder,
    this.entryHeaderBuilder,
    this.entryBodyBuilder,
    this.entryFooterBuilder,
    this.completionBuilder,
    this.lockBuilder,
    this.recurringBuilder,
    this.gapBuilder,
    this.timeLabelBuilder,
    this.insightBuilder,
    this.conflictBridgeBuilder,
    this.dragFeedbackBuilder,
    this.dragPlaceholderBuilder,
    this.deleteTargetBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.timeFormatter,
    this.durationFormatter,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 8, bottom: 136),
    this.showInsightBanner = true,
    this.showCompletionToggle = false,
    this.showBoundaryGaps = false,
    this.showGapActions = false,
    this.enableDragging = true,
    this.enableResizing = true,
    this.enableDeleteTarget = false,
    this.initialScroll = StructuredTimelineInitialScroll.current,
    this.reschedulePolicy = const TimelineReschedulePolicy(),
    this.resizePolicy = const TimelineResizePolicy(),
    this.autoScrollPolicy = const TimelineAutoScrollPolicy(),
    this.dragActivationDelay = const Duration(milliseconds: 300),
    this.autoScrollFrameInterval = const Duration(milliseconds: 32),
    this.showDragScrim = false,
    this.showSnapGuide = false,
    this.showDropSlot = false,
    this.showConflictPreview = true,
    this.dragScrimOpacity = 0.035,
    this.announceDragChanges = false,
    this.dragPlaceholderOpacity = 0.18,
    this.dragLiftScale,
    this.onDragChanged,
    this.onDragPreviewChanged,
    super.key,
  });

  final TimelineDayPlan<T> plan;
  final StructuredTimelineStyle? style;
  final StructuredTimelineLayout layout;
  final StructuredTimelineEntryStyle entryStyle;
  final StructuredTimelineGapLayout gapLayout;
  final StructuredTimelineStrings strings;
  final StructuredTimelineController<T>? controller;
  final TimelineMutationCoordinator<T>? mutationCoordinator;
  final StructuredTimelineEntryCallback<T>? onEntryTap;
  final StructuredTimelineEntryCallback<T>? onComplete;
  final StructuredTimelineMoveCallback<T>? onMove;
  final AdvancedStructuredTimelineResizeCallback<T>? onResize;
  final StructuredTimelineMoveCallback<T>? onDelete;
  final StructuredTimelineGapCallback<T>? onInsert;
  final AdvancedStructuredTimelineMutationError<T>? onMutationError;
  final AdvancedStructuredTimelineMutationRollback<T>? onMutationRollback;
  final AdvancedStructuredTimelineEntryBuilder<T>? entryBuilder;
  final StructuredTimelineEntryComponentBuilder<T>? entryHeaderBuilder;
  final StructuredTimelineEntryComponentBuilder<T>? entryBodyBuilder;
  final StructuredTimelineEntryComponentBuilder<T>? entryFooterBuilder;
  final StructuredTimelineEntryControlBuilder<T>? completionBuilder;
  final StructuredTimelineEntryControlBuilder<T>? lockBuilder;
  final StructuredTimelineEntryControlBuilder<T>? recurringBuilder;
  final AdvancedStructuredTimelineGapBuilder<T>? gapBuilder;
  final AdvancedStructuredTimelineTimeLabelBuilder<T>? timeLabelBuilder;
  final AdvancedStructuredTimelineInsightBuilder<T>? insightBuilder;
  final AdvancedStructuredTimelineConflictBridgeBuilder<T>?
  conflictBridgeBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragFeedbackBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragPlaceholderBuilder;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final StructuredTimelineTimeFormatter? timeFormatter;
  final StructuredTimelineDurationFormatter? durationFormatter;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showInsightBanner;
  final bool showCompletionToggle;
  final bool showBoundaryGaps;
  final bool showGapActions;
  final bool enableDragging;
  final bool enableResizing;
  final bool enableDeleteTarget;
  final StructuredTimelineInitialScroll initialScroll;
  final TimelineReschedulePolicy reschedulePolicy;
  final TimelineResizePolicy resizePolicy;
  final TimelineAutoScrollPolicy autoScrollPolicy;
  final Duration dragActivationDelay;
  final Duration autoScrollFrameInterval;
  final bool showDragScrim;
  final bool showSnapGuide;
  final bool showDropSlot;
  final bool showConflictPreview;
  final double dragScrimOpacity;
  final bool announceDragChanges;
  final double dragPlaceholderOpacity;
  final double? dragLiftScale;
  final ValueChanged<bool>? onDragChanged;
  final ValueChanged<TimelineReschedulePreview<T>?>? onDragPreviewChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        style ??
        (Theme.of(context).brightness == Brightness.dark
            ? StructuredTimelineStyle.dark()
            : StructuredTimelineStyle.light());
    final formatTime = timeFormatter ?? _time;
    final formatDuration = durationFormatter ?? _duration;
    final minimumCardExtent =
        entryStyle.minimumHeight + (onComplete == null ? 8 : 24);
    final resolvedLayout = layout.copyWith(
      minimumEntryExtent: math
          .max(layout.minimumEntryExtent, minimumCardExtent)
          .toDouble(),
      cardMinimumHeight: math
          .max(layout.cardMinimumHeight, entryStyle.minimumHeight)
          .toDouble(),
    );
    return AdvancedStructuredTimeline<T>(
      plan: plan,
      style: resolvedStyle,
      layout: resolvedLayout,
      strings: strings,
      controller: controller,
      mutationCoordinator: mutationCoordinator,
      onEntryTap: onEntryTap,
      onComplete: onComplete,
      onMove: onMove,
      onResize: onResize,
      onDelete: onDelete,
      onInsert: onInsert,
      onMutationError: onMutationError,
      onMutationRollback: onMutationRollback,
      titleBuilder: titleBuilder,
      subtitleBuilder: subtitleBuilder,
      progressBuilder: progressBuilder,
      timeFormatter: formatTime,
      durationFormatter: formatDuration,
      scrollController: scrollController,
      physics: physics,
      padding: padding,
      showInsightBanner: showInsightBanner,
      showCompletionToggle: showCompletionToggle,
      showBoundaryGaps: showBoundaryGaps,
      enableDragging: enableDragging,
      enableResizing: enableResizing,
      enableDeleteTarget: enableDeleteTarget,
      initialScroll: initialScroll,
      reschedulePolicy: reschedulePolicy,
      resizePolicy: resizePolicy,
      autoScrollPolicy: autoScrollPolicy,
      dragActivationDelay: dragActivationDelay,
      autoScrollFrameInterval: autoScrollFrameInterval,
      showDragScrim: showDragScrim,
      showSnapGuide: showSnapGuide,
      showDropSlot: showDropSlot,
      showConflictPreview: showConflictPreview,
      dragScrimOpacity: dragScrimOpacity,
      announceDragChanges: announceDragChanges,
      dragPlaceholderOpacity: dragPlaceholderOpacity,
      dragLiftScale: dragLiftScale,
      onDragChanged: onDragChanged,
      onDragPreviewChanged: onDragPreviewChanged,
      emptyBuilder: (context) => StructuredTimelineEmptyState(
        style: resolvedStyle,
        title: strings.noTasks,
        description: strings.noTasksDescription,
      ),
      entryBuilder:
          entryBuilder ??
          (context, details) => StructuredTimelineEntryCard<T>(
            details: details,
            title:
                titleBuilder?.call(details.entry) ??
                details.entry.semanticLabel ??
                details.value.toString(),
            subtitle:
                subtitleBuilder?.call(details.entry) ??
                details.entry.metadata['structured.subtitle'] as String?,
            progress:
                progressBuilder?.call(details.entry) ??
                (details.entry.metadata['structured.progress'] as num?)
                    ?.toDouble(),
            entryStyle: entryStyle,
            strings: strings,
            headerBuilder: entryHeaderBuilder,
            bodyBuilder: entryBodyBuilder,
            footerBuilder: entryFooterBuilder,
            completionBuilder: completionBuilder,
            lockBuilder: lockBuilder,
            recurringBuilder: recurringBuilder,
            timeFormatter: formatTime,
            durationFormatter: formatDuration,
          ),
      gapExtentBuilder: (gap, _) => gapLayout.extentFor(gap.duration),
      gapBuilder:
          gapBuilder ??
          (context, gap, valueStyle) => StructuredTimelineGap<T>(
            gap: gap,
            style: valueStyle,
            strings: strings,
            durationFormatter: formatDuration,
            layout: gapLayout,
            onTap: onInsert,
            showAction: showGapActions,
            actionVisible: showGapActions,
            timeColumnOnRight:
                resolvedLayout.timeColumnPosition ==
                StructuredTimelineTimeColumnPosition.right,
          ),
      timeLabelBuilder: timeLabelBuilder,
      insightBuilder: insightBuilder,
      conflictBridgeBuilder:
          conflictBridgeBuilder ??
          (context, item, overlap, valueStyle) =>
              StructuredTimelineConflictBridge(
                color: valueStyle.conflictColor,
                overlap: overlap,
                durationFormatter: formatDuration,
              ),
      dragFeedbackBuilder:
          dragFeedbackBuilder ??
          (context, details, child) =>
              StructuredTimelineDragFeedback<T>(details: details, child: child),
      dragPlaceholderBuilder: dragPlaceholderBuilder,
      deleteTargetBuilder:
          deleteTargetBuilder ??
          (context, active, valueStyle) => StructuredTimelineDeleteTarget<T>(
            active: active,
            style: valueStyle,
            label: strings.delete,
          ),
    );
  }

  static String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

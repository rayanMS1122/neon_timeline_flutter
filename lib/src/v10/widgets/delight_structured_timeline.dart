import 'package:flutter/material.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../../v8/models/structured_timeline_layout.dart';
import '../../v9/models/structured_timeline_entry_style.dart';
import '../../v9/models/structured_timeline_gap_layout.dart';
import '../../v9/widgets/production_structured_timeline.dart';
import '../../v9/widgets/structured_timeline_entry_components.dart';
import '../models/structured_timeline_experience.dart';
import 'structured_timeline_drag_components.dart';

/// Delight-first 10.x timeline with magnetic drag defaults and polished
/// feedback, while keeping every persistence decision in the host app.
class DelightStructuredTimeline<T> extends StatelessWidget {
  const DelightStructuredTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    this.dataRevision,
    this.now,
    this.refreshInterval = const Duration(seconds: 30),
    this.dayConfig = const TimelineDayPlanConfig(),
    this.style,
    this.layout = const StructuredTimelineLayout.comfortable(),
    this.entryStyle = const StructuredTimelineEntryStyle.delight(),
    this.gapLayout = const StructuredTimelineGapLayout.hybrid(
      compressionStartsAt: Duration(hours: 2),
      compressedExtent: 78,
    ),
    this.experience = const StructuredTimelineExperience.delight(),
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
    this.onDragStateChanged,
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
    this.padding = const EdgeInsets.only(top: 10, bottom: 156),
    this.showInsightBanner = true,
    this.showCompletionToggle = true,
    this.showBoundaryGaps = false,
    this.showGapActions = false,
    this.enableDragging = true,
    this.enableResizing = true,
    this.enableDeleteTarget = true,
    this.initialScroll = StructuredTimelineInitialScroll.current,
    this.reschedulePolicy = const TimelineReschedulePolicy(),
    this.resizePolicy = const TimelineResizePolicy(),
    this.autoScrollPolicy = const TimelineAutoScrollPolicy(
      edgeExtent: 136,
      minimumStep: 2.5,
      maximumStep: 18,
    ),
    super.key,
  });

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime selectedDate;
  final Object? dataRevision;
  final DateTime? now;
  final Duration refreshInterval;
  final TimelineDayPlanConfig dayConfig;
  final StructuredTimelineStyle? style;
  final StructuredTimelineLayout layout;
  final StructuredTimelineEntryStyle entryStyle;
  final StructuredTimelineGapLayout gapLayout;
  final StructuredTimelineExperience experience;
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
  final ValueChanged<StructuredTimelineDragState<T>>? onDragStateChanged;
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

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style ?? StructuredTimelineStyle.delight();
    final formatTime = timeFormatter ?? _formatTime;
    final magneticPolicy = TimelineReschedulePolicy(
      snap: reschedulePolicy.snap,
      keepEntireEntryInBounds: reschedulePolicy.keepEntireEntryInBounds,
      allowConflicts: reschedulePolicy.allowConflicts,
      enableDeleteTarget: enableDeleteTarget,
      pixelsPerMinute: reschedulePolicy.pixelsPerMinute,
      magnetizeToNeighbors: experience.magnetizeToNeighbors,
      magnetDistance: experience.magnetDistance,
      snapHysteresis: reschedulePolicy.snapHysteresis,
      preferConflictFreeDrop: experience.preferConflictFreeDrop,
    );

    return ProductionStructuredTimeline<T>(
      values: values,
      engine: engine,
      selectedDate: selectedDate,
      dataRevision: dataRevision,
      now: now,
      refreshInterval: refreshInterval,
      dayConfig: dayConfig,
      style: resolvedStyle,
      layout: layout,
      entryStyle: entryStyle,
      gapLayout: gapLayout,
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
      entryBuilder: entryBuilder,
      entryHeaderBuilder: entryHeaderBuilder,
      entryBodyBuilder: entryBodyBuilder,
      entryFooterBuilder: entryFooterBuilder,
      completionBuilder: completionBuilder,
      lockBuilder: lockBuilder,
      recurringBuilder: recurringBuilder,
      gapBuilder: gapBuilder,
      timeLabelBuilder: timeLabelBuilder,
      insightBuilder: insightBuilder,
      conflictBridgeBuilder: conflictBridgeBuilder,
      dragFeedbackBuilder:
          dragFeedbackBuilder ??
          (context, details, child) {
            final preview = details.movePreview;
            return StructuredTimelineDragFeedbackCard(
              style: resolvedStyle,
              timeLabel: preview == null
                  ? formatTime(details.effectiveStart)
                  : '${formatTime(preview.start)}–${formatTime(preview.end)}',
              blocked: preview != null && !preview.canCommit,
              magnetized: preview?.magnetized ?? false,
              conflictCount: preview?.conflicts.length ?? 0,
              scale: experience.dragLiftScale,
              elevation: experience.dragElevation,
              child: child,
            );
          },
      dragPlaceholderBuilder: dragPlaceholderBuilder,
      deleteTargetBuilder: deleteTargetBuilder,
      titleBuilder: titleBuilder,
      subtitleBuilder: subtitleBuilder,
      progressBuilder: progressBuilder,
      timeFormatter: formatTime,
      durationFormatter: durationFormatter,
      scrollController: scrollController,
      physics: physics,
      padding: padding,
      showInsightBanner: showInsightBanner,
      showCompletionToggle: showCompletionToggle,
      showBoundaryGaps: showBoundaryGaps,
      showGapActions: showGapActions,
      enableDragging: enableDragging,
      enableResizing: enableResizing,
      enableDeleteTarget: enableDeleteTarget,
      initialScroll: initialScroll,
      reschedulePolicy: magneticPolicy,
      resizePolicy: resizePolicy,
      autoScrollPolicy: autoScrollPolicy,
      dragActivationDelay: experience.dragActivationDelay,
      autoScrollFrameInterval: experience.edgeScrollFrameInterval,
      showDragScrim: experience.showDragScrim,
      showSnapGuide: experience.showSnapGuide,
      showDropSlot: experience.showDropSlot,
      showConflictPreview: experience.showConflictPreview,
      dragScrimOpacity: experience.scrimOpacity,
      announceDragChanges: experience.announceDragChanges,
      dragPlaceholderOpacity: experience.placeholderOpacity,
      dragLiftScale: 1,
      onDragPreviewChanged: (preview) {
        if (preview == null) {
          controller?.endDrag();
        } else if (experience.selectOnDragStart) {
          controller?.beginDrag(preview.entry.id);
        }
        onDragStateChanged?.call(
          preview == null
              ? StructuredTimelineDragState<T>.idle()
              : StructuredTimelineDragState<T>(
                  phase: preview.canCommit
                      ? StructuredTimelineDragPhase.dragging
                      : StructuredTimelineDragPhase.blocked,
                  value: preview.entry.value,
                  entryId: preview.entry.id,
                  start: preview.start,
                  end: preview.end,
                  conflictCount: preview.conflicts.length,
                  magnetized: preview.magnetized,
                ),
        );
      },
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

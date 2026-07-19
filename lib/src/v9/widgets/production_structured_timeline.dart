import 'dart:async';

import 'package:flutter/material.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v6/widgets/timeline_planner_day_builder.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../../v8/models/structured_timeline_layout.dart';
import '../models/structured_timeline_entry_style.dart';
import '../models/structured_timeline_gap_layout.dart';
import 'structured_timeline_entry_components.dart';
import 'structured_timeline_viewport.dart';

class ProductionStructuredTimeline<T> extends StatefulWidget {
  const ProductionStructuredTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    this.dataRevision,
    this.now,
    this.refreshInterval = const Duration(seconds: 30),
    this.dayConfig = const TimelineDayPlanConfig(),
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
  State<ProductionStructuredTimeline<T>> createState() =>
      _ProductionStructuredTimelineState<T>();
}

class _ProductionStructuredTimelineState<T>
    extends State<ProductionStructuredTimeline<T>>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _clock;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = widget.now ?? DateTime.now();
    _restartClock();
  }

  @override
  void didUpdateWidget(covariant ProductionStructuredTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.now != widget.now) _clock = widget.now ?? DateTime.now();
    if (oldWidget.now != widget.now ||
        oldWidget.refreshInterval != widget.refreshInterval) {
      _restartClock();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _restartClock();
  }

  void _restartClock() {
    _timer?.cancel();
    _timer = null;
    if (widget.now != null ||
        widget.refreshInterval <= Duration.zero ||
        _lifecycle != AppLifecycleState.resumed) {
      return;
    }
    _timer = Timer.periodic(widget.refreshInterval, (_) {
      if (mounted) setState(() => _clock = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimelinePlannerDayBuilder<T>(
      values: widget.values,
      engine: widget.engine,
      selectedDate: widget.selectedDate,
      now: widget.now ?? _clock,
      config: widget.dayConfig,
      dataRevision: widget.dataRevision,
      builder: (context, snapshot) {
        return StructuredTimelineViewport<T>(
          plan: snapshot.dayPlan,
          style: widget.style,
          layout: widget.layout,
          entryStyle: widget.entryStyle,
          gapLayout: widget.gapLayout,
          strings: widget.strings,
          controller: widget.controller,
          mutationCoordinator: widget.mutationCoordinator,
          onEntryTap: widget.onEntryTap,
          onComplete: widget.onComplete,
          onMove: widget.onMove,
          onResize: widget.onResize,
          onDelete: widget.onDelete,
          onInsert: widget.onInsert,
          onMutationError: widget.onMutationError,
          onMutationRollback: widget.onMutationRollback,
          entryBuilder: widget.entryBuilder,
          entryHeaderBuilder: widget.entryHeaderBuilder,
          entryBodyBuilder: widget.entryBodyBuilder,
          entryFooterBuilder: widget.entryFooterBuilder,
          completionBuilder: widget.completionBuilder,
          lockBuilder: widget.lockBuilder,
          recurringBuilder: widget.recurringBuilder,
          gapBuilder: widget.gapBuilder,
          timeLabelBuilder: widget.timeLabelBuilder,
          insightBuilder: widget.insightBuilder,
          conflictBridgeBuilder: widget.conflictBridgeBuilder,
          dragFeedbackBuilder: widget.dragFeedbackBuilder,
          dragPlaceholderBuilder: widget.dragPlaceholderBuilder,
          deleteTargetBuilder: widget.deleteTargetBuilder,
          titleBuilder: widget.titleBuilder,
          subtitleBuilder: widget.subtitleBuilder,
          progressBuilder: widget.progressBuilder,
          timeFormatter: widget.timeFormatter,
          durationFormatter: widget.durationFormatter,
          scrollController: widget.scrollController,
          physics: widget.physics,
          padding: widget.padding,
          showInsightBanner: widget.showInsightBanner,
          showCompletionToggle: widget.showCompletionToggle,
          showBoundaryGaps: widget.showBoundaryGaps,
          showGapActions: widget.showGapActions,
          enableDragging: widget.enableDragging,
          enableResizing: widget.enableResizing,
          enableDeleteTarget: widget.enableDeleteTarget,
          initialScroll: widget.initialScroll,
          reschedulePolicy: widget.reschedulePolicy,
          resizePolicy: widget.resizePolicy,
          autoScrollPolicy: widget.autoScrollPolicy,
          dragActivationDelay: widget.dragActivationDelay,
          autoScrollFrameInterval: widget.autoScrollFrameInterval,
          showDragScrim: widget.showDragScrim,
          showSnapGuide: widget.showSnapGuide,
          showDropSlot: widget.showDropSlot,
          showConflictPreview: widget.showConflictPreview,
          dragScrimOpacity: widget.dragScrimOpacity,
          announceDragChanges: widget.announceDragChanges,
          dragPlaceholderOpacity: widget.dragPlaceholderOpacity,
          dragLiftScale: widget.dragLiftScale,
          onDragChanged: widget.onDragChanged,
          onDragPreviewChanged: widget.onDragPreviewChanged,
        );
      },
    );
  }
}

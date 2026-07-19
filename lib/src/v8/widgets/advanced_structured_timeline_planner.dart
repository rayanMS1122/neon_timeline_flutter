import 'dart:async';

import 'package:flutter/material.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v6/widgets/timeline_planner_day_builder.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../core/structured_timeline_controller.dart';
import '../core/timeline_mutation_coordinator.dart';
import '../core/timeline_resize.dart';
import '../models/advanced_structured_timeline_details.dart';
import '../models/structured_timeline_layout.dart';
import 'advanced_structured_timeline.dart';

/// Convenience bridge from application-owned values to the 8.x advanced
/// Structured timeline.
class AdvancedStructuredTimelinePlanner<T> extends StatefulWidget {
  const AdvancedStructuredTimelinePlanner({
    required this.values,
    required this.engine,
    required this.selectedDate,
    this.dataRevision,
    this.now,
    this.refreshInterval = const Duration(seconds: 30),
    this.dayConfig = const TimelineDayPlanConfig(),
    this.style,
    this.layout = const StructuredTimelineLayout.comfortable(),
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
    this.gapBuilder,
    this.timeLabelBuilder,
    this.insightBuilder,
    this.conflictBridgeBuilder,
    this.dragFeedbackBuilder,
    this.dragPlaceholderBuilder,
    this.deleteTargetBuilder,
    this.iconBuilder,
    this.trailingBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.timeFormatter,
    this.durationFormatter,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 8, bottom: 120),
    this.showInsightBanner = true,
    this.showCompletionToggle = true,
    this.showBoundaryGaps = false,
    this.enableDragging = true,
    this.enableResizing = true,
    this.enableDeleteTarget = false,
    this.initialScroll = StructuredTimelineInitialScroll.current,
    this.reschedulePolicy = const TimelineReschedulePolicy(),
    this.resizePolicy = const TimelineResizePolicy(),
    this.autoScrollPolicy = const TimelineAutoScrollPolicy(),
    this.emptyBuilder,
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
  final AdvancedStructuredTimelineGapBuilder<T>? gapBuilder;
  final AdvancedStructuredTimelineTimeLabelBuilder<T>? timeLabelBuilder;
  final AdvancedStructuredTimelineInsightBuilder<T>? insightBuilder;
  final AdvancedStructuredTimelineConflictBridgeBuilder<T>?
  conflictBridgeBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragFeedbackBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragPlaceholderBuilder;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final StructuredTimelineIconBuilder<T>? iconBuilder;
  final StructuredTimelineTrailingBuilder<T>? trailingBuilder;
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
  final bool enableDragging;
  final bool enableResizing;
  final bool enableDeleteTarget;
  final StructuredTimelineInitialScroll initialScroll;
  final TimelineReschedulePolicy reschedulePolicy;
  final TimelineResizePolicy resizePolicy;
  final TimelineAutoScrollPolicy autoScrollPolicy;
  final WidgetBuilder? emptyBuilder;

  @override
  State<AdvancedStructuredTimelinePlanner<T>> createState() =>
      _AdvancedStructuredTimelinePlannerState<T>();
}

class _AdvancedStructuredTimelinePlannerState<T>
    extends State<AdvancedStructuredTimelinePlanner<T>>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _clock;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = widget.now ?? DateTime.now();
    _restartClock();
  }

  @override
  void didUpdateWidget(
    covariant AdvancedStructuredTimelinePlanner<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.now != oldWidget.now) {
      _clock = widget.now ?? DateTime.now();
    }
    if (widget.now != oldWidget.now ||
        widget.refreshInterval != oldWidget.refreshInterval) {
      _restartClock();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _restartClock();
  }

  void _restartClock() {
    _timer?.cancel();
    _timer = null;
    if (widget.now != null ||
        widget.refreshInterval <= Duration.zero ||
        _lifecycleState != AppLifecycleState.resumed) {
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
        return AdvancedStructuredTimeline<T>(
          plan: snapshot.dayPlan,
          style: widget.style,
          layout: widget.layout,
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
          gapBuilder: widget.gapBuilder,
          timeLabelBuilder: widget.timeLabelBuilder,
          insightBuilder: widget.insightBuilder,
          conflictBridgeBuilder: widget.conflictBridgeBuilder,
          dragFeedbackBuilder: widget.dragFeedbackBuilder,
          dragPlaceholderBuilder: widget.dragPlaceholderBuilder,
          deleteTargetBuilder: widget.deleteTargetBuilder,
          iconBuilder: widget.iconBuilder,
          trailingBuilder: widget.trailingBuilder,
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
          enableDragging: widget.enableDragging,
          enableResizing: widget.enableResizing,
          enableDeleteTarget: widget.enableDeleteTarget,
          initialScroll: widget.initialScroll,
          reschedulePolicy: widget.reschedulePolicy,
          resizePolicy: widget.resizePolicy,
          autoScrollPolicy: widget.autoScrollPolicy,
          emptyBuilder: widget.emptyBuilder,
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v6/widgets/timeline_planner_day_builder.dart';
import '../models/structured_timeline_details.dart';
import '../models/structured_timeline_style.dart';
import 'structured_timeline_view.dart';

/// Convenience bridge from application-owned models directly to the
/// Structured-style 7.x timeline.
///
/// Only one lifecycle-aware clock is created for the entire timeline. Set
/// [now] to control the clock externally or set [refreshInterval] to zero to
/// disable automatic refreshes.
class StructuredTimelinePlanner<T> extends StatefulWidget {
  const StructuredTimelinePlanner({
    required this.values,
    required this.engine,
    required this.selectedDate,
    this.dataRevision,
    this.now,
    this.refreshInterval = const Duration(seconds: 30),
    this.dayConfig = const TimelineDayPlanConfig(),
    this.style,
    this.strings = const StructuredTimelineStrings(),
    this.onEntryTap,
    this.onComplete,
    this.onMove,
    this.onDelete,
    this.onInsert,
    this.cardBuilder,
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
    this.enableDeleteTarget = false,
    this.initialScroll = StructuredTimelineInitialScroll.current,
    this.reschedulePolicy = const TimelineReschedulePolicy(),
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
  final StructuredTimelineStrings strings;

  final StructuredTimelineEntryCallback<T>? onEntryTap;
  final StructuredTimelineEntryCallback<T>? onComplete;
  final StructuredTimelineMoveCallback<T>? onMove;
  final StructuredTimelineMoveCallback<T>? onDelete;
  final StructuredTimelineGapCallback<T>? onInsert;

  final StructuredTimelineCardBuilder<T>? cardBuilder;
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
  final bool enableDeleteTarget;
  final StructuredTimelineInitialScroll initialScroll;
  final TimelineReschedulePolicy reschedulePolicy;
  final TimelineAutoScrollPolicy autoScrollPolicy;
  final WidgetBuilder? emptyBuilder;

  @override
  State<StructuredTimelinePlanner<T>> createState() =>
      _StructuredTimelinePlannerState<T>();
}

class _StructuredTimelinePlannerState<T>
    extends State<StructuredTimelinePlanner<T>>
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
  void didUpdateWidget(covariant StructuredTimelinePlanner<T> oldWidget) {
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
        return StructuredTimelineView<T>(
          plan: snapshot.dayPlan,
          style: widget.style,
          strings: widget.strings,
          onEntryTap: widget.onEntryTap,
          onComplete: widget.onComplete,
          onMove: widget.onMove,
          onDelete: widget.onDelete,
          onInsert: widget.onInsert,
          cardBuilder: widget.cardBuilder,
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
          enableDeleteTarget: widget.enableDeleteTarget,
          initialScroll: widget.initialScroll,
          reschedulePolicy: widget.reschedulePolicy,
          autoScrollPolicy: widget.autoScrollPolicy,
          emptyBuilder: widget.emptyBuilder,
        );
      },
    );
  }
}

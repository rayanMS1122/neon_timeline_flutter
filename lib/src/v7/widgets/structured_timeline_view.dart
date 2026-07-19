import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_types.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v6/core/timeline_visual_coordinate_map.dart';
import '../models/structured_timeline_details.dart';
import '../models/structured_timeline_style.dart';

/// A production-oriented, app-friendly day timeline based on the interaction
/// and visual language of the Structured planner.
///
/// The widget owns only presentation and gesture state. Application state,
/// recurrence persistence, repositories, task sheets, and navigation remain in
/// the host application.
class StructuredTimelineView<T> extends StatefulWidget {
  const StructuredTimelineView({
    required this.plan,
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
    this.gapBuilder,
    this.gapExtentBuilder,
    this.timeLabelBuilder,
    this.insightBuilder,
    this.conflictBridgeBuilder,
    this.dragFeedbackBuilder,
    this.dragPlaceholderBuilder,
    this.deleteTargetBuilder,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 8, bottom: 120),
    this.showInsightBanner = true,
    this.showCompletionToggle = true,
    this.showBoundaryGaps = false,
    this.timeColumnOnRight = false,
    this.enableDragging = true,
    this.enableDeleteTarget = false,
    this.initialScroll = StructuredTimelineInitialScroll.current,
    this.reschedulePolicy = const TimelineReschedulePolicy(),
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
    this.emptyBuilder,
    super.key,
  });

  final TimelineDayPlan<T> plan;
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
  final StructuredTimelineGapBuilder<T>? gapBuilder;
  final StructuredTimelineGapExtentBuilder<T>? gapExtentBuilder;
  final StructuredTimelineTimeLabelBuilder<T>? timeLabelBuilder;
  final StructuredTimelineInsightBuilder<T>? insightBuilder;
  final StructuredTimelineConflictBridgeBuilder<T>? conflictBridgeBuilder;
  final StructuredTimelineDragDecorator<T>? dragFeedbackBuilder;
  final StructuredTimelineDragDecorator<T>? dragPlaceholderBuilder;
  final StructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;

  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showInsightBanner;
  final bool showCompletionToggle;
  final bool showBoundaryGaps;
  final bool timeColumnOnRight;
  final bool enableDragging;
  final bool enableDeleteTarget;
  final StructuredTimelineInitialScroll initialScroll;
  final TimelineReschedulePolicy reschedulePolicy;
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
  final WidgetBuilder? emptyBuilder;

  @override
  State<StructuredTimelineView<T>> createState() =>
      _StructuredTimelineViewState<T>();
}

class _StructuredTimelineViewState<T> extends State<StructuredTimelineView<T>> {
  final GlobalKey _viewportKey = GlobalKey();
  late ScrollController _scrollController;
  bool _ownsController = false;
  bool _initialScrollApplied = false;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant StructuredTimelineView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (_ownsController) _scrollController.dispose();
      _attachController();
    }
    if (oldWidget.plan.selectedDate != widget.plan.selectedDate ||
        oldWidget.plan.entries.length != widget.plan.entries.length ||
        oldWidget.initialScroll != widget.initialScroll) {
      _initialScrollApplied = false;
    }
  }

  void _attachController() {
    _ownsController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (_ownsController) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style =
        widget.style ??
        (Theme.of(context).brightness == Brightness.dark
            ? StructuredTimelineStyle.dark()
            : StructuredTimelineStyle.light());
    final nodes = _buildNodes(widget.plan);
    final coordinateMap = TimelineVisualCoordinateMap<T>.build(
      plan: widget.plan,
      includeBoundaryGaps: widget.showBoundaryGaps,
      entryExtent: (entry) => (entry.duration.inMinutes * style.pixelsPerMinute)
          .clamp(style.minimumEntryExtent, style.maximumEntryExtent)
          .toDouble(),
      gapExtent: (gap) {
        final custom = widget.gapExtentBuilder?.call(gap, style);
        if (custom != null && custom.isFinite && custom >= 0) return custom;
        return (gap.duration.inMinutes * style.pixelsPerMinute)
            .clamp(style.minimumGapExtent, style.maximumGapExtent)
            .toDouble();
      },
    );

    _scheduleInitialScroll(nodes, style);

    if (widget.plan.isEmpty) {
      return ColoredBox(
        color: style.backgroundColor,
        child:
            widget.emptyBuilder?.call(context) ??
            _StructuredEmptyState(
              style: style,
              strings: widget.strings,
              onAdd: widget.onInsert == null
                  ? null
                  : () {
                      final gap = TimelineDayGap<T>(
                        start: widget.plan.rangeStart,
                        end: widget.plan.rangeEnd,
                        containsNow: true,
                      );
                      unawaited(
                        Future<void>.sync(() => widget.onInsert!(context, gap)),
                      );
                    },
            ),
      );
    }

    final itemCount = nodes.length + (widget.showInsightBanner ? 1 : 0);
    return ColoredBox(
      color: style.backgroundColor,
      child: SizedBox.expand(
        key: _viewportKey,
        child: ListView.builder(
          controller: _scrollController,
          physics: widget.physics,
          padding: widget.padding,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (widget.showInsightBanner && index == 0) {
              return widget.insightBuilder?.call(context, widget.plan, style) ??
                  _StructuredInsightBanner<T>(
                    plan: widget.plan,
                    style: style,
                    strings: widget.strings,
                    titleBuilder: widget.titleBuilder,
                    durationFormatter:
                        widget.durationFormatter ?? _defaultDurationFormatter,
                    onComplete: widget.onComplete,
                  );
            }
            final nodeIndex = index - (widget.showInsightBanner ? 1 : 0);
            final node = nodes[nodeIndex];
            if (node.entry != null) {
              return _StructuredEntryRow<T>(
                key: ValueKey<Object>(node.entry!.entry.id),
                item: node.entry!,
                plan: widget.plan,
                style: style,
                strings: widget.strings,
                scrollController: _scrollController,
                viewportKey: _viewportKey,
                coordinateMap: coordinateMap,
                onEntryTap: widget.onEntryTap,
                onComplete: widget.onComplete,
                onMove: widget.onMove,
                onDelete: widget.onDelete,
                cardBuilder: widget.cardBuilder,
                iconBuilder: widget.iconBuilder,
                trailingBuilder: widget.trailingBuilder,
                titleBuilder: widget.titleBuilder,
                subtitleBuilder: widget.subtitleBuilder,
                progressBuilder: widget.progressBuilder,
                timeLabelBuilder: widget.timeLabelBuilder,
                conflictBridgeBuilder: widget.conflictBridgeBuilder,
                dragFeedbackBuilder: widget.dragFeedbackBuilder,
                dragPlaceholderBuilder: widget.dragPlaceholderBuilder,
                deleteTargetBuilder: widget.deleteTargetBuilder,
                timeFormatter: widget.timeFormatter ?? _defaultTimeFormatter,
                durationFormatter:
                    widget.durationFormatter ?? _defaultDurationFormatter,
                showCompletionToggle: widget.showCompletionToggle,
                timeColumnOnRight: widget.timeColumnOnRight,
                enableDragging: widget.enableDragging,
                enableDeleteTarget: widget.enableDeleteTarget,
                reschedulePolicy: widget.reschedulePolicy,
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
            }
            return widget.gapBuilder?.call(context, node.gap!, style) ??
                _StructuredGapRow<T>(
                  gap: node.gap!,
                  now: widget.plan.insight.now,
                  style: style,
                  strings: widget.strings,
                  timeColumnOnRight: widget.timeColumnOnRight,
                  titleBuilder: widget.titleBuilder,
                  durationFormatter:
                      widget.durationFormatter ?? _defaultDurationFormatter,
                  onInsert: widget.onInsert,
                );
          },
        ),
      ),
    );
  }

  List<_StructuredNode<T>> _buildNodes(TimelineDayPlan<T> plan) {
    final nodes = <_StructuredNode<T>>[
      for (final entry in plan.entries) _StructuredNode<T>.entry(entry),
    ];
    for (final gap in plan.gaps) {
      final isBoundary = gap.previous == null || gap.next == null;
      if (!widget.showBoundaryGaps && isBoundary) continue;
      nodes.add(_StructuredNode<T>.gap(gap));
    }
    nodes.sort((left, right) {
      final byStart = left.start.compareTo(right.start);
      if (byStart != 0) return byStart;
      return left.entry != null ? -1 : 1;
    });
    return nodes;
  }

  void _scheduleInitialScroll(
    List<_StructuredNode<T>> nodes,
    StructuredTimelineStyle style,
  ) {
    if (_initialScrollApplied ||
        widget.initialScroll == StructuredTimelineInitialScroll.none) {
      return;
    }
    _initialScrollApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = switch (widget.initialScroll) {
        StructuredTimelineInitialScroll.none => null,
        StructuredTimelineInitialScroll.current =>
          widget.plan.insight.current ?? widget.plan.insight.next,
        StructuredTimelineInitialScroll.next => widget.plan.insight.next,
        StructuredTimelineInitialScroll.first =>
          widget.plan.entries.isEmpty ? null : widget.plan.entries.first,
      };
      if (target == null) return;

      var offset = widget.showInsightBanner ? 92.0 : 0.0;
      for (final node in nodes) {
        if (node.entry?.entry.id == target.entry.id) break;
        offset += node.extent(style, gapExtentBuilder: widget.gapExtentBuilder);
      }
      final position = _scrollController.position;
      final desired = (offset - 84).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.jumpTo(desired.toDouble());
    });
  }
}

class _StructuredNode<T> {
  const _StructuredNode._({required this.start, this.entry, this.gap});

  factory _StructuredNode.entry(TimelineDayEntry<T> value) {
    return _StructuredNode<T>._(start: value.start, entry: value);
  }

  factory _StructuredNode.gap(TimelineDayGap<T> value) {
    return _StructuredNode<T>._(start: value.start, gap: value);
  }

  final DateTime start;
  final TimelineDayEntry<T>? entry;
  final TimelineDayGap<T>? gap;

  double extent(
    StructuredTimelineStyle style, {
    StructuredTimelineGapExtentBuilder<T>? gapExtentBuilder,
  }) {
    if (entry != null) {
      return (entry!.duration.inMinutes * style.pixelsPerMinute)
          .clamp(style.minimumEntryExtent, style.maximumEntryExtent)
          .toDouble();
    }
    final custom = gapExtentBuilder?.call(gap!, style);
    if (custom != null && custom.isFinite && custom >= 0) return custom;
    return (gap!.duration.inMinutes * style.pixelsPerMinute)
        .clamp(style.minimumGapExtent, style.maximumGapExtent)
        .toDouble();
  }
}

class _StructuredEntryRow<T> extends StatefulWidget {
  const _StructuredEntryRow({
    required this.item,
    required this.plan,
    required this.style,
    required this.strings,
    required this.scrollController,
    required this.viewportKey,
    required this.coordinateMap,
    required this.timeFormatter,
    required this.durationFormatter,
    required this.showCompletionToggle,
    required this.timeColumnOnRight,
    required this.enableDragging,
    required this.enableDeleteTarget,
    required this.reschedulePolicy,
    required this.autoScrollPolicy,
    required this.dragActivationDelay,
    required this.autoScrollFrameInterval,
    required this.showDragScrim,
    required this.showSnapGuide,
    required this.showDropSlot,
    required this.showConflictPreview,
    required this.dragScrimOpacity,
    required this.announceDragChanges,
    required this.dragPlaceholderOpacity,
    this.dragLiftScale,
    this.onDragChanged,
    this.onDragPreviewChanged,
    this.onEntryTap,
    this.onComplete,
    this.onMove,
    this.onDelete,
    this.cardBuilder,
    this.iconBuilder,
    this.trailingBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.timeLabelBuilder,
    this.conflictBridgeBuilder,
    this.dragFeedbackBuilder,
    this.dragPlaceholderBuilder,
    this.deleteTargetBuilder,
    super.key,
  });

  final TimelineDayEntry<T> item;
  final TimelineDayPlan<T> plan;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final ScrollController scrollController;
  final GlobalKey viewportKey;
  final TimelineVisualCoordinateMap<T> coordinateMap;
  final StructuredTimelineTimeFormatter timeFormatter;
  final StructuredTimelineDurationFormatter durationFormatter;
  final bool showCompletionToggle;
  final bool timeColumnOnRight;
  final bool enableDragging;
  final bool enableDeleteTarget;
  final TimelineReschedulePolicy reschedulePolicy;
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
  final StructuredTimelineEntryCallback<T>? onEntryTap;
  final StructuredTimelineEntryCallback<T>? onComplete;
  final StructuredTimelineMoveCallback<T>? onMove;
  final StructuredTimelineMoveCallback<T>? onDelete;
  final StructuredTimelineCardBuilder<T>? cardBuilder;
  final StructuredTimelineIconBuilder<T>? iconBuilder;
  final StructuredTimelineTrailingBuilder<T>? trailingBuilder;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final StructuredTimelineTimeLabelBuilder<T>? timeLabelBuilder;
  final StructuredTimelineConflictBridgeBuilder<T>? conflictBridgeBuilder;
  final StructuredTimelineDragDecorator<T>? dragFeedbackBuilder;
  final StructuredTimelineDragDecorator<T>? dragPlaceholderBuilder;
  final StructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;

  @override
  State<_StructuredEntryRow<T>> createState() => _StructuredEntryRowState<T>();
}

class _StructuredEntryRowState<T> extends State<_StructuredEntryRow<T>>
    with AutomaticKeepAliveClientMixin<_StructuredEntryRow<T>> {
  OverlayEntry? _overlayEntry;
  TimelineRescheduleSession<T>? _session;
  TimelineReschedulePreview<T>? _preview;
  bool _dragging = false;
  bool _busy = false;
  bool _overDeleteTarget = false;
  double _startGlobalY = 0;
  double _startScrollOffset = 0;
  double _startVisualOffset = 0;
  double _originOverlayTop = 0;
  double _overlayTop = 0;
  double _overlayLeft = 0;
  double _overlayWidth = 0;
  DateTime? _lastSnapTarget;
  int? _lastConflictCount;
  bool? _lastCanCommit;
  Timer? _autoScrollTimer;
  Offset? _lastPointerGlobal;
  double _autoScrollVelocity = 0;
  TimelineDayEntry<T>? _dragItemSnapshot;
  bool _activeInTree = true;

  @override
  bool get wantKeepAlive => _dragging;

  bool get _canDrag =>
      widget.enableDragging &&
      widget.item.entry.draggable &&
      widget.item.entry.enabled &&
      widget.onMove != null &&
      !_busy;

  @override
  void activate() {
    super.activate();
    _activeInTree = true;
  }

  @override
  void deactivate() {
    _activeInTree = false;
    _releaseDragResources();
    _dragging = false;
    _preview = null;
    super.deactivate();
  }

  @override
  void dispose() {
    _activeInTree = false;
    _releaseDragResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activeItem = _dragging
        ? _dragItemSnapshot ?? widget.item
        : widget.item;
    final extent =
        (activeItem.duration.inMinutes * widget.style.pixelsPerMinute)
            .clamp(
              widget.style.minimumEntryExtent,
              widget.style.maximumEntryExtent,
            )
            .toDouble();
    final details = StructuredTimelineEntryDetails<T>(
      item: activeItem,
      style: widget.style,
      isDragging: _dragging,
      isBusy: _busy,
      preview: _preview,
    );

    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
          const _MoveEarlierIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
          const _MoveLaterIntent(),
      const SingleActivator(LogicalKeyboardKey.enter):
          const _ActivateEntryIntent(),
      const SingleActivator(LogicalKeyboardKey.escape):
          const _CancelDragIntent(),
    };
    final actions = <Type, Action<Intent>>{
      _MoveEarlierIntent: CallbackAction<_MoveEarlierIntent>(
        onInvoke: (_) {
          _moveByKeyboard(
            Duration(
              microseconds: -widget.reschedulePolicy.snap.inMicroseconds,
            ),
          );
          return null;
        },
      ),
      _MoveLaterIntent: CallbackAction<_MoveLaterIntent>(
        onInvoke: (_) {
          _moveByKeyboard(widget.reschedulePolicy.snap);
          return null;
        },
      ),
      _ActivateEntryIntent: CallbackAction<_ActivateEntryIntent>(
        onInvoke: (_) {
          _invokeEntryCallback(widget.onEntryTap, details);
          return null;
        },
      ),
      _CancelDragIntent: CallbackAction<_CancelDragIntent>(
        onInvoke: (_) {
          if (_dragging) _cancelDrag();
          return null;
        },
      ),
    };

    return FocusableActionDetector(
      shortcuts: shortcuts,
      actions: actions,
      child: Semantics(
        container: true,
        button: widget.onEntryTap != null,
        enabled: activeItem.entry.enabled,
        label: _title,
        hint: _canDrag
            ? '${widget.strings.moveEarlier}: Alt+↑. '
                  '${widget.strings.moveLater}: Alt+↓.'
            : null,
        child: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                  (recognizer) {
                    recognizer.onTap = widget.onEntryTap == null
                        ? null
                        : () => _invokeEntryCallback(
                            widget.onEntryTap,
                            details,
                          );
                  },
                ),
            if (_canDrag)
              LongPressGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    LongPressGestureRecognizer
                  >(
                    () => LongPressGestureRecognizer(
                      duration: widget.dragActivationDelay,
                    ),
                    (recognizer) {
                      recognizer
                        ..onLongPressStart = _startDrag
                        ..onLongPressMoveUpdate = _updateDrag
                        ..onLongPressEnd = _endDrag
                        ..onLongPressCancel = _cancelDrag;
                    },
                  ),
          },
          child: Builder(
            builder: (context) {
              final visual = _buildVisual(
                context,
                details: details,
                extent: extent,
                floating: false,
              );
              if (_dragging && widget.dragPlaceholderBuilder != null) {
                return widget.dragPlaceholderBuilder!(
                  context,
                  details,
                  visual,
                );
              }
              return AnimatedOpacity(
                duration: widget.style.dragAnimationDuration,
                opacity: _dragging ? widget.dragPlaceholderOpacity : 1,
                child: visual,
              );
            },
          ),
        ),
      ),
    );
  }

  String get _title {
    final entry = _dragItemSnapshot?.entry ?? widget.item.entry;
    return widget.titleBuilder?.call(entry) ??
        entry.semanticLabel ??
        entry.value.toString();
  }

  Widget _buildVisual(
    BuildContext context, {
    required StructuredTimelineEntryDetails<T> details,
    required double extent,
    required bool floating,
  }) {
    final style = widget.style;
    final item = details.item;
    final entry = item.entry;
    final completed = entry.status == TimelineStatus.completed;
    final entryColor = completed
        ? style.completedColor
        : (entry.color ?? style.accentColor);
    final hasPreviousOverlap =
        item.previous != null && item.start.isBefore(item.previous!.end);
    final hasNextOverlap =
        item.next != null && item.next!.start.isBefore(item.end);
    final previousOverlapMinutes = hasPreviousOverlap
        ? item.previous!.end.difference(item.start).inMinutes
        : 0;
    final cardRadius = BorderRadius.only(
      topLeft: Radius.circular(hasPreviousOverlap ? 6 : style.cardRadius),
      topRight: Radius.circular(hasPreviousOverlap ? 6 : style.cardRadius),
      bottomLeft: Radius.circular(hasNextOverlap ? 6 : style.cardRadius),
      bottomRight: Radius.circular(hasNextOverlap ? 6 : style.cardRadius),
    );

    return SizedBox(
      height: extent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final horizontalPadding = compact
              ? math.max(10.0, style.horizontalPadding - 4)
              : style.horizontalPadding;
          final timeWidth = compact
              ? math.max(36.0, style.timeColumnWidth - 6)
              : style.timeColumnWidth;
          final markerWidth = compact
              ? math.max(38.0, style.markerWidth - 6)
              : style.markerWidth;
          final onRight = widget.timeColumnOnRight;
          final markerCenterX = onRight
              ? constraints.maxWidth -
                    horizontalPadding -
                    timeWidth -
                    style.columnGap -
                    markerWidth / 2
              : horizontalPadding +
                    timeWidth +
                    style.columnGap +
                    markerWidth / 2;
          final completionSpace =
              widget.showCompletionToggle && widget.onComplete != null
              ? style.completionSize + 22
              : 0.0;
          final cardLeft = onRight
              ? horizontalPadding + completionSpace
              : horizontalPadding +
                    timeWidth +
                    style.columnGap +
                    markerWidth +
                    style.columnGap;
          final cardRight = onRight
              ? horizontalPadding +
                    timeWidth +
                    style.columnGap +
                    markerWidth +
                    style.columnGap
              : horizontalPadding + completionSpace;
          final timeLeft = onRight ? null : horizontalPadding;
          final timeRight = onRight ? horizontalPadding : null;
          final markerLeft = onRight
              ? null
              : horizontalPadding + timeWidth + style.columnGap;
          final markerRight = onRight
              ? horizontalPadding + timeWidth + style.columnGap
              : null;

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: markerCenterX - 1,
                top: style.markerHeight / 2,
                bottom: 0,
                child: SizedBox(
                  width: 2,
                  child: CustomPaint(
                    painter: _StructuredRailPainter(
                      color: style.railColor,
                      activeColor: entryColor,
                      activeExtent: math.min(
                        extent,
                        math.max(
                          style.markerHeight,
                          item.duration.inMinutes * style.pixelsPerMinute,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: timeLeft,
                right: timeRight,
                top: style.markerHeight <= 34 ? 7 : 18,
                width: timeWidth,
                child:
                    widget.timeLabelBuilder?.call(
                      context,
                      item,
                      details.preview?.start ?? item.start,
                      false,
                      style,
                    ) ??
                    Text(
                      widget.timeFormatter(
                        details.preview?.start ?? item.start,
                      ),
                      textAlign: onRight ? TextAlign.left : TextAlign.right,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: compact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              ),
              Positioned(
                left: markerLeft,
                right: markerRight,
                top: 0,
                width: markerWidth,
                height: style.markerHeight,
                child:
                    widget.iconBuilder?.call(context, details) ??
                    _DefaultMarker(
                      color: entryColor,
                      style: style,
                      completed: completed,
                      external: details.isExternal,
                    ),
              ),
              Positioned(
                left: cardLeft,
                right: cardRight,
                top: 0,
                child: AnimatedScale(
                  scale: floating
                      ? (widget.dragLiftScale ?? style.dragScale)
                      : 1,
                  duration: style.dragAnimationDuration,
                  child:
                      widget.cardBuilder?.call(context, details) ??
                      _DefaultStructuredCard<T>(
                        details: details,
                        style: style,
                        strings: widget.strings,
                        title: _title,
                        subtitle: widget.subtitleBuilder?.call(details.entry),
                        progress: widget.progressBuilder?.call(details.entry),
                        timeFormatter: widget.timeFormatter,
                        durationFormatter: widget.durationFormatter,
                        borderRadius: cardRadius,
                        floating: floating,
                      ),
                ),
              ),
              if (widget.trailingBuilder != null)
                Positioned(
                  left: onRight ? cardLeft + 8 : null,
                  right: onRight ? null : cardRight + 8,
                  top: 16,
                  child: widget.trailingBuilder!(context, details),
                ),
              if (widget.showCompletionToggle && widget.onComplete != null)
                Positioned(
                  left: onRight ? horizontalPadding : null,
                  right: onRight ? null : horizontalPadding,
                  top: (style.cardMinimumHeight - style.completionSize) / 2,
                  child: _CompletionButton(
                    key: ValueKey<String>('structured_complete_${entry.id}'),
                    color: entryColor,
                    style: style,
                    completed: completed,
                    busy: _busy,
                    semanticLabel: widget.strings.completeTask,
                    onPressed: entry.enabled && !_busy
                        ? () => _invokeEntryCallback(widget.onComplete, details)
                        : null,
                  ),
                ),
              if (extent > style.cardMinimumHeight + 18)
                Positioned(
                  left: timeLeft,
                  right: timeRight,
                  bottom: 5,
                  width: timeWidth,
                  child:
                      widget.timeLabelBuilder?.call(
                        context,
                        item,
                        details.preview?.end ?? item.end,
                        true,
                        style,
                      ) ??
                      Text(
                        widget.timeFormatter(details.preview?.end ?? item.end),
                        textAlign: onRight ? TextAlign.left : TextAlign.right,
                        style: TextStyle(
                          color: style.mutedTextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
              if (!floating && previousOverlapMinutes > 0)
                Positioned(
                  left: onRight ? null : cardLeft + 10,
                  right: onRight ? cardRight + 10 : null,
                  top: -11,
                  child:
                      widget.conflictBridgeBuilder?.call(
                        context,
                        item,
                        Duration(minutes: previousOverlapMinutes),
                        style,
                      ) ??
                      _ConflictBridgeBadge(
                        minutes: previousOverlapMinutes,
                        style: style,
                        label: widget.strings.overlap,
                      ),
                ),
              if (floating &&
                  details.preview != null &&
                  widget.dragFeedbackBuilder == null)
                Positioned(
                  left: onRight ? null : math.max(0, horizontalPadding - 8),
                  right: onRight ? math.max(0, horizontalPadding - 8) : null,
                  top: style.markerHeight + 4,
                  child: _DragTimeBadge(
                    value:
                        '${widget.timeFormatter(details.preview!.start)}–${widget.timeFormatter(details.preview!.end)}',
                    style: style,
                    blocked: !details.preview!.canCommit,
                    conflictCount: details.preview!.conflicts.length,
                    magnetized: details.preview!.magnetized,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _startDrag(LongPressStartDetails details) {
    if (!_activeInTree || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return;
    }

    _dragItemSnapshot = widget.item;
    final dragItem = _dragItemSnapshot!;
    final effectivePolicy = TimelineReschedulePolicy(
      snap: widget.reschedulePolicy.snap,
      keepEntireEntryInBounds: widget.reschedulePolicy.keepEntireEntryInBounds,
      allowConflicts: widget.reschedulePolicy.allowConflicts,
      enableDeleteTarget: widget.enableDeleteTarget && widget.onDelete != null,
      pixelsPerMinute: widget.style.pixelsPerMinute,
      magnetizeToNeighbors: widget.reschedulePolicy.magnetizeToNeighbors,
      magnetDistance: widget.reschedulePolicy.magnetDistance,
      snapHysteresis: widget.reschedulePolicy.snapHysteresis,
      preferConflictFreeDrop: widget.reschedulePolicy.preferConflictFreeDrop,
    );
    _session = TimelineRescheduleSession<T>(
      entry: dragItem.entry,
      bounds: TimelineDateRange(widget.plan.rangeStart, widget.plan.rangeEnd),
      candidates: widget.plan.entries.map((value) => value.entry),
      policy: effectivePolicy,
    );
    _preview = _session!.previewForDelta(Duration.zero);
    widget.onDragPreviewChanged?.call(_preview);
    _lastSnapTarget = _preview!.magnetTarget ?? _preview!.start;
    _lastConflictCount = _preview!.conflicts.length;
    _lastCanCommit = _preview!.canCommit;
    _startGlobalY = details.globalPosition.dy;
    _lastPointerGlobal = details.globalPosition;
    _startScrollOffset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0;
    _startVisualOffset = widget.coordinateMap.offsetForTime(
      dragItem.start,
      entryId: dragItem.entry.id,
    );
    final origin = renderObject.localToGlobal(Offset.zero);
    _originOverlayTop = origin.dy;
    _overlayLeft = origin.dx;
    _overlayTop = origin.dy;
    _overlayWidth = renderObject.size.width;
    _overDeleteTarget = false;
    setState(() => _dragging = true);
    updateKeepAlive();
    widget.onDragChanged?.call(true);
    HapticFeedback.heavyImpact();
    _insertOverlay();
    _startAutoScrollLoop();
  }

  void _insertOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final preview = _preview;
        if (preview == null) return const SizedBox.shrink();
        final dragItem = _dragItemSnapshot ?? widget.item;
        final details = StructuredTimelineEntryDetails<T>(
          item: dragItem,
          style: widget.style,
          isDragging: true,
          isBusy: _busy,
          preview: preview,
        );
        final extent =
            (dragItem.duration.inMinutes * widget.style.pixelsPerMinute)
                .clamp(
                  widget.style.minimumEntryExtent,
                  widget.style.maximumEntryExtent,
                )
                .toDouble();
        final media = MediaQuery.of(overlayContext);
        return Stack(
          children: <Widget>[
            if (widget.showDragScrim)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withValues(
                      alpha: widget.dragScrimOpacity.clamp(0.0, 1.0),
                    ),
                  ),
                ),
              ),
            if (widget.showSnapGuide)
              Positioned(
                left: 16,
                right: 16,
                top: _overlayTop + extent / 2 - 1,
                child: _StructuredSnapGuide(
                  label:
                      '${widget.timeFormatter(preview.start)}–${widget.timeFormatter(preview.end)}',
                  style: widget.style,
                  blocked: !preview.canCommit,
                  conflictCount: widget.showConflictPreview
                      ? preview.conflicts.length
                      : 0,
                  magnetized: preview.magnetized,
                ),
              ),
            if (widget.showDropSlot)
              Positioned(
                left: _overlayLeft - 5,
                top: _overlayTop - 5,
                width: _overlayWidth + 10,
                height: extent + 10,
                child: IgnorePointer(
                  child: _StructuredDropSlot(
                    style: widget.style,
                    blocked: !preview.canCommit,
                    magnetized: preview.magnetized,
                    label:
                        '${widget.timeFormatter(preview.start)}–${widget.timeFormatter(preview.end)}',
                    conflictCount: widget.showConflictPreview
                        ? preview.conflicts.length
                        : 0,
                  ),
                ),
              ),
            Positioned(
              left: _overlayLeft,
              top: _overlayTop,
              width: _overlayWidth,
              height: extent,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Builder(
                    builder: (context) {
                      final visual = _buildVisual(
                        overlayContext,
                        details: details,
                        extent: extent,
                        floating: true,
                      );
                      return widget.dragFeedbackBuilder?.call(
                            overlayContext,
                            details,
                            visual,
                          ) ??
                          visual;
                    },
                  ),
                ),
              ),
            ),
            if (widget.enableDeleteTarget && widget.onDelete != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: media.padding.bottom + 22,
                child: IgnorePointer(
                  child:
                      widget.deleteTargetBuilder?.call(
                        overlayContext,
                        _overDeleteTarget,
                        widget.style,
                      ) ??
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: MediaQuery.withClampedTextScaling(
                          minScaleFactor: 1,
                          maxScaleFactor: 1.25,
                          child: AnimatedContainer(
                            duration: widget.style.dragAnimationDuration,
                            width: _overDeleteTarget ? 184 : 154,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _overDeleteTarget
                                  ? widget.style.conflictColor
                                  : widget.style.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _overDeleteTarget
                                    ? widget.style.conflictColor
                                    : widget.style.borderColor,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: widget.style.shadowColor,
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: _overDeleteTarget
                                      ? Colors.white
                                      : widget.style.conflictColor,
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    widget.strings.delete,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _overDeleteTarget
                                          ? Colors.white
                                          : widget.style.conflictColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
              ),
          ],
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _updateDrag(LongPressMoveUpdateDetails details) {
    _lastPointerGlobal = details.globalPosition;
    _refreshDragPreview(details.globalPosition);
  }

  void _startAutoScrollLoop() {
    _autoScrollTimer?.cancel();
    if (!_activeInTree || !mounted || !_dragging) return;
    _autoScrollTimer = Timer.periodic(widget.autoScrollFrameInterval, (timer) {
      if (!_activeInTree || !mounted || !_dragging) {
        timer.cancel();
        if (identical(_autoScrollTimer, timer)) _autoScrollTimer = null;
        return;
      }
      final pointer = _lastPointerGlobal;
      if (pointer == null) return;
      if (_autoScroll(pointer) && _activeInTree && mounted && _dragging) {
        _refreshDragPreview(pointer, performAutoScroll: false);
      }
    });
  }

  void _refreshDragPreview(
    Offset globalPosition, {
    bool performAutoScroll = false,
  }) {
    if (!_activeInTree || !mounted || !_dragging) return;
    final session = _session;
    if (session == null) return;

    if (performAutoScroll) _autoScroll(globalPosition);
    if (!_activeInTree || !mounted || !_dragging) return;
    final scrollOffset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : _startScrollOffset;
    final visualTarget =
        _startVisualOffset +
        (globalPosition.dy - _startGlobalY) +
        (scrollOffset - _startScrollOffset);
    final desiredStart = widget.coordinateMap.timeForOffset(visualTarget);
    final nextPreview = session.previewForDelta(
      desiredStart.difference((_dragItemSnapshot ?? widget.item).start),
    );
    final effectiveSnapTarget = nextPreview.magnetTarget ?? nextPreview.start;
    final targetChanged = _lastSnapTarget != effectiveSnapTarget;
    final conflictChanged =
        widget.showConflictPreview &&
        _lastConflictCount != nextPreview.conflicts.length;
    final commitChanged = _lastCanCommit != nextPreview.canCommit;
    if (targetChanged || commitChanged) {
      _lastSnapTarget = effectiveSnapTarget;
      HapticFeedback.selectionClick();
    }
    if (widget.announceDragChanges &&
        (targetChanged || conflictChanged || commitChanged)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        _dragAnnouncement(nextPreview),
        Directionality.of(context),
      );
    }
    _lastConflictCount = nextPreview.conflicts.length;
    _lastCanCommit = nextPreview.canCommit;
    _preview = nextPreview;
    widget.onDragPreviewChanged?.call(nextPreview);
    final targetVisualOffset = widget.coordinateMap.offsetForTime(
      nextPreview.start,
    );
    _overlayTop =
        _originOverlayTop +
        (targetVisualOffset - _startVisualOffset) -
        (scrollOffset - _startScrollOffset);
    final media = MediaQuery.of(context);
    _overDeleteTarget =
        widget.enableDeleteTarget &&
        widget.onDelete != null &&
        globalPosition.dy > media.size.height - media.padding.bottom - 104;
    _overlayEntry?.markNeedsBuild();
  }

  bool _autoScroll(Offset globalPosition) {
    if (!_activeInTree || !mounted || !_dragging) return false;
    final viewportContext = widget.viewportKey.currentContext;
    final renderObject = viewportContext?.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize ||
        !renderObject.size.height.isFinite ||
        renderObject.size.height <= 0 ||
        !widget.scrollController.hasClients) {
      return false;
    }
    final position = widget.scrollController.position;
    final notificationContext = position.context.notificationContext;
    if (!position.hasPixels ||
        !position.hasContentDimensions ||
        !position.viewportDimension.isFinite ||
        !position.context.storageContext.mounted ||
        notificationContext == null ||
        !notificationContext.mounted) {
      return false;
    }
    final local = renderObject.globalToLocal(globalPosition);
    final requestedDelta = widget.autoScrollPolicy.deltaFor(
      pointer: local.dy,
      viewportExtent: renderObject.size.height,
    );
    final accelerating =
        requestedDelta != 0 && requestedDelta.sign == _autoScrollVelocity.sign;
    final response = accelerating ? 0.24 : 0.42;
    _autoScrollVelocity += (requestedDelta - _autoScrollVelocity) * response;
    if (requestedDelta == 0 && _autoScrollVelocity.abs() < 0.35) {
      _autoScrollVelocity = 0;
    }
    if (_autoScrollVelocity == 0 || !_activeInTree || !_dragging) {
      return false;
    }
    final target = (position.pixels + _autoScrollVelocity).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return false;
    position.jumpTo(target.toDouble());
    return _activeInTree && mounted && _dragging;
  }

  void _endDrag(LongPressEndDetails details) {
    final session = _session;
    final preview = _preview;
    if (session == null || preview == null) {
      _finishDragVisuals();
      return;
    }
    final result = session.resolveDrop(
      preview: preview,
      overDeleteTarget: _overDeleteTarget,
    );
    final sourceItem = _dragItemSnapshot ?? widget.item;
    _finishDragVisuals();
    unawaited(_commitResult(result, sourceItem: sourceItem));
  }

  void _cancelDrag() {
    final session = _session;
    final preview = _preview;
    if (session != null && preview != null) {
      session.resolveDrop(preview: preview, cancelled: true);
    }
    if (widget.announceDragChanges && _activeInTree && mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Move cancelled',
        Directionality.of(context),
      );
    }
    _finishDragVisuals();
  }

  void _finishDragVisuals() {
    final wasDragging = _dragging;
    _releaseDragResources();
    _dragging = false;
    _preview = null;
    if (_activeInTree && mounted) {
      if (wasDragging) widget.onDragChanged?.call(false);
      widget.onDragPreviewChanged?.call(null);
      setState(() {});
      updateKeepAlive();
    }
  }

  void _releaseDragResources() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _lastPointerGlobal = null;
    _autoScrollVelocity = 0;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _session = null;
    _overDeleteTarget = false;
    _lastSnapTarget = null;
    _lastConflictCount = null;
    _lastCanCommit = null;
    _dragItemSnapshot = null;
  }

  Future<void> _commitResult(
    TimelineDropResult<T> result, {
    TimelineDayEntry<T>? sourceItem,
  }) async {
    final StructuredTimelineMoveCallback<T>? callback =
        switch (result.disposition) {
          TimelineDropDisposition.move => widget.onMove,
          TimelineDropDisposition.delete => widget.onDelete,
          TimelineDropDisposition.unchanged => null,
          TimelineDropDisposition.cancel => null,
          TimelineDropDisposition.blocked => null,
        };
    if (result.disposition == TimelineDropDisposition.blocked) {
      HapticFeedback.vibrate();
      return;
    }
    if (callback == null) return;
    HapticFeedback.mediumImpact();
    if (mounted) setState(() => _busy = true);
    try {
      await Future<void>.sync(
        () => callback(
          context,
          StructuredTimelineMoveDetails<T>(
            item: sourceItem ?? widget.item,
            result: result,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _dragAnnouncement(TimelineReschedulePreview<T> preview) {
    final time =
        '${widget.timeFormatter(preview.start)}–${widget.timeFormatter(preview.end)}';
    if (!preview.canCommit) {
      return 'Drop blocked at $time. ${preview.conflicts.length} conflict${preview.conflicts.length == 1 ? '' : 's'}.';
    }
    if (preview.conflicts.isNotEmpty) {
      return '$time. ${preview.conflicts.length} conflict${preview.conflicts.length == 1 ? '' : 's'}.';
    }
    return preview.magnetized ? '$time. Magnetic target.' : '$time. Drop available.';
  }

  void _moveByKeyboard(Duration delta) {
    if (!_canDrag) return;
    final policy = TimelineReschedulePolicy(
      snap: widget.reschedulePolicy.snap,
      keepEntireEntryInBounds: widget.reschedulePolicy.keepEntireEntryInBounds,
      allowConflicts: widget.reschedulePolicy.allowConflicts,
      enableDeleteTarget: false,
      pixelsPerMinute: widget.style.pixelsPerMinute,
      magnetizeToNeighbors: widget.reschedulePolicy.magnetizeToNeighbors,
      magnetDistance: widget.reschedulePolicy.magnetDistance,
      snapHysteresis: widget.reschedulePolicy.snapHysteresis,
      preferConflictFreeDrop: widget.reschedulePolicy.preferConflictFreeDrop,
    );
    final session = TimelineRescheduleSession<T>(
      entry: widget.item.entry,
      bounds: TimelineDateRange(widget.plan.rangeStart, widget.plan.rangeEnd),
      candidates: widget.plan.entries.map((value) => value.entry),
      policy: policy,
    );
    final preview = session.previewForDelta(delta);
    final result = session.resolveDrop(preview: preview);
    unawaited(_commitResult(result));
  }

  void _invokeEntryCallback(
    StructuredTimelineEntryCallback<T>? callback,
    StructuredTimelineEntryDetails<T> details,
  ) {
    if (callback == null) return;
    unawaited(Future<void>.sync(() => callback(context, details)));
  }
}

class _DefaultStructuredCard<T> extends StatelessWidget {
  const _DefaultStructuredCard({
    required this.details,
    required this.style,
    required this.strings,
    required this.title,
    required this.timeFormatter,
    required this.durationFormatter,
    required this.borderRadius,
    required this.floating,
    this.subtitle,
    this.progress,
  });

  final StructuredTimelineEntryDetails<T> details;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final String title;
  final String? subtitle;
  final double? progress;
  final StructuredTimelineTimeFormatter timeFormatter;
  final StructuredTimelineDurationFormatter durationFormatter;
  final BorderRadius borderRadius;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final entry = details.entry;
    final completed = entry.status == TimelineStatus.completed;
    final color = completed
        ? style.completedColor
        : (entry.color ?? style.accentColor);
    final preview = details.preview;
    final start = preview?.start ?? details.item.start;
    final end = preview?.end ?? details.item.end;
    final normalizedProgress = progress?.clamp(0.0, 1.0).toDouble();
    final tint = Color.alphaBlend(
      color.withValues(alpha: style.cardTintOpacity),
      style.cardColor,
    );
    final conflict = details.hasConflict;
    final borderColor = floating
        ? style.primaryColor
        : conflict
        ? style.conflictColor
        : color.withValues(alpha: style.cardBorderOpacity);

    return Container(
      constraints: BoxConstraints(minHeight: style.cardMinimumHeight),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: floating ? 2 : 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: floating
                ? style.shadowColor
                : style.shadowColor.withValues(alpha: 0.45),
            blurRadius: floating ? 28 : 12,
            offset: Offset(0, floating ? 14 : 5),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: conflict ? style.conflictColor : color,
                borderRadius: BorderRadius.only(
                  topLeft: borderRadius.topLeft,
                  bottomLeft: borderRadius.bottomLeft,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 9, details.isBusy ? 38 : 12, 9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  runSpacing: 3,
                  children: <Widget>[
                    Text(
                      '${timeFormatter(start)}–${timeFormatter(end)}',
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '· ${durationFormatter(end.difference(start))}',
                      style: TextStyle(
                        color: style.mutedTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (details.isRecurring)
                      Icon(
                        Icons.sync_rounded,
                        size: 12,
                        color: style.mutedTextColor,
                      ),
                    if (details.isExternal)
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: style.mutedTextColor,
                      ),
                    if (conflict)
                      _SmallStatusBadge(
                        label: strings.conflict,
                        color: style.conflictColor,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: completed ? style.mutedTextColor : style.textColor,
                    fontSize: 14.5,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: style.mutedTextColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (normalizedProgress != null) ...<Widget>[
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: normalizedProgress,
                      minHeight: 4,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (details.isBusy)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DefaultMarker extends StatelessWidget {
  const _DefaultMarker({
    required this.color,
    required this.style,
    required this.completed,
    required this.external,
  });

  final Color color;
  final StructuredTimelineStyle style;
  final bool completed;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final compact = style.markerHeight <= 34;
    return Center(
      child: SizedBox.square(
        dimension: compact ? 26 : style.markerHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              color.withValues(alpha: completed ? 0.04 : 0.08),
              style.surfaceColor,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: completed ? 0.1 : 0.2),
            ),
          ),
          child: Center(
            child: Icon(
              compact
                  ? external
                        ? Icons.event_outlined
                        : Icons.circle
                  : external
                  ? Icons.event_outlined
                  : Icons.alarm_rounded,
              color: completed ? style.disabledColor : color,
              size: compact
                  ? external
                        ? 12
                        : 8
                  : 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({
    required this.color,
    required this.style,
    required this.completed,
    required this.busy,
    required this.semanticLabel,
    this.onPressed,
    super.key,
  });

  final Color color;
  final StructuredTimelineStyle style;
  final bool completed;
  final bool busy;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: completed,
      label: semanticLabel,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: style.completionSize,
          height: style.completionSize,
          decoration: BoxDecoration(
            color: completed ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: completed
                  ? color
                  : style.mutedTextColor.withValues(alpha: 0.35),
              width: 1.6,
            ),
            boxShadow: completed
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: busy
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: completed ? Colors.white : color,
                  ),
                )
              : completed
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _StructuredGapRow<T> extends StatelessWidget {
  const _StructuredGapRow({
    required this.gap,
    required this.now,
    required this.style,
    required this.strings,
    required this.timeColumnOnRight,
    required this.durationFormatter,
    this.titleBuilder,
    this.onInsert,
  });

  final TimelineDayGap<T> gap;
  final DateTime now;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final bool timeColumnOnRight;
  final StructuredTimelineDurationFormatter durationFormatter;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineGapCallback<T>? onInsert;

  @override
  Widget build(BuildContext context) {
    final extent = (gap.duration.inMinutes * style.pixelsPerMinute)
        .clamp(style.minimumGapExtent, style.maximumGapExtent)
        .toDouble();
    return SizedBox(
      height: extent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerCenterX = timeColumnOnRight
              ? constraints.maxWidth -
                    style.horizontalPadding -
                    style.timeColumnWidth -
                    style.columnGap -
                    style.markerWidth / 2
              : style.horizontalPadding +
                    style.timeColumnWidth +
                    style.columnGap +
                    style.markerWidth / 2;
          final contentInset =
              style.horizontalPadding +
              style.timeColumnWidth +
              style.columnGap * 2 +
              style.markerWidth;
          return Stack(
            children: <Widget>[
              Positioned(
                left: markerCenterX - 1,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 2,
                  child: CustomPaint(
                    painter: _StructuredRailPainter(
                      color: style.railColor,
                      activeColor: gap.containsNow
                          ? style.primaryColor
                          : Colors.transparent,
                      activeExtent: gap.containsNow ? 20 : 0,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                left: timeColumnOnRight
                    ? style.horizontalPadding
                    : contentInset,
                right: timeColumnOnRight
                    ? contentInset
                    : style.horizontalPadding,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (gap.containsNow &&
                          gap.next != null &&
                          gap.next!.start.isAfter(now)) ...<Widget>[
                        Text(
                          '${strings.nextIn} '
                          '${durationFormatter(gap.next!.start.difference(now))}',
                          style: TextStyle(
                            color: style.mutedTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (titleBuilder != null)
                          Text(
                            titleBuilder!(gap.next!.entry),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: style.textColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        const SizedBox(height: 7),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: gap.containsNow
                                ? style.primaryColor
                                : style.mutedTextColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${durationFormatter(gap.duration)} '
                            '${strings.freeToPlan}',
                            style: TextStyle(
                              color: style.mutedTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (onInsert != null) ...<Widget>[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            unawaited(
                              Future<void>.sync(() => onInsert!(context, gap)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: BorderSide(color: style.borderColor),
                            foregroundColor: style.primaryColor,
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 15),
                          label: Text(strings.addTask),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StructuredInsightBanner<T> extends StatelessWidget {
  const _StructuredInsightBanner({
    required this.plan,
    required this.style,
    required this.strings,
    required this.durationFormatter,
    this.titleBuilder,
    this.onComplete,
  });

  final TimelineDayPlan<T> plan;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final StructuredTimelineDurationFormatter durationFormatter;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineEntryCallback<T>? onComplete;

  @override
  Widget build(BuildContext context) {
    final current = plan.insight.current;
    final next = plan.insight.next;
    if (current == null && next == null) return const SizedBox.shrink();

    final active = current ?? next!;
    final title =
        titleBuilder?.call(active.entry) ??
        active.entry.semanticLabel ??
        active.entry.value.toString();
    final isCurrent = current != null;
    final duration = isCurrent
        ? plan.insight.timeRemainingCurrent
        : plan.insight.timeUntilNext;
    final details = StructuredTimelineEntryDetails<T>(
      item: active,
      style: style,
      isDragging: false,
      isBusy: false,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        style.horizontalPadding,
        4,
        style.horizontalPadding,
        16,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isCurrent
              ? LinearGradient(
                  colors: <Color>[style.primaryColor, style.accentColor],
                )
              : null,
          color: isCurrent ? null : style.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: isCurrent ? null : Border.all(color: style.borderColor),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isCurrent
                  ? style.primaryColor.withValues(alpha: 0.2)
                  : style.shadowColor.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          child: Row(
            children: <Widget>[
              Icon(
                isCurrent ? Icons.alarm_on_rounded : Icons.schedule_rounded,
                color: isCurrent ? Colors.white : style.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isCurrent ? strings.nowActive : strings.next,
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white.withValues(alpha: 0.72)
                            : style.mutedTextColor,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration == null
                          ? title
                          : isCurrent
                          ? '$title · ${durationFormatter(duration)} ${strings.timeLeft}'
                          : '${strings.nextIn} ${durationFormatter(duration)} · $title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : style.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent && onComplete != null) ...<Widget>[
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    unawaited(
                      Future<void>.sync(() => onComplete!(context, details)),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(strings.done),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StructuredEmptyState extends StatelessWidget {
  const _StructuredEmptyState({
    required this.style,
    required this.strings,
    this.onAdd,
  });

  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: style.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 34,
                color: style.primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              strings.noTasks,
              style: TextStyle(
                color: style.textColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.noTasksDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: style.mutedTextColor, fontSize: 12),
            ),
            if (onAdd != null) ...<Widget>[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(strings.addTask),
                style: FilledButton.styleFrom(
                  backgroundColor: style.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConflictBridgeBadge extends StatelessWidget {
  const _ConflictBridgeBadge({
    required this.minutes,
    required this.style,
    required this.label,
  });

  final int minutes;
  final StructuredTimelineStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.conflictColor,
        borderRadius: BorderRadius.circular(100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: style.conflictColor.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          '$minutes min $label',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SmallStatusBadge extends StatelessWidget {
  const _SmallStatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StructuredDropSlot extends StatelessWidget {
  const _StructuredDropSlot({
    required this.style,
    required this.blocked,
    required this.magnetized,
    required this.label,
    required this.conflictCount,
  });

  final StructuredTimelineStyle style;
  final bool blocked;
  final bool magnetized;
  final String label;
  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    final stateLabel = blocked
        ? 'Drop blocked at $label'
        : magnetized
        ? 'Magnetic target at $label'
        : 'Drop target at $label';
    return Semantics(
      container: true,
      label: conflictCount == 0
          ? stateLabel
          : '$stateLabel, $conflictCount conflicts',
      child: AnimatedContainer(
        duration: style.dragAnimationDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: color.withValues(alpha: blocked ? 0.055 : 0.035),
          borderRadius: BorderRadius.circular(style.cardRadius + 3),
          boxShadow: magnetized
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.13),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 10,
              bottom: 10,
              width: magnetized ? 4 : 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: blocked ? 0.8 : 0.65),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 0,
              height: 1,
              child: ColoredBox(
                color: color.withValues(alpha: magnetized ? 0.5 : 0.24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StructuredSnapGuide extends StatelessWidget {
  const _StructuredSnapGuide({
    required this.label,
    required this.style,
    required this.blocked,
    required this.conflictCount,
    this.magnetized = false,
  });

  final String label;
  final StructuredTimelineStyle style;
  final bool blocked;
  final int conflictCount;
  final bool magnetized;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return IgnorePointer(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    blocked
                        ? Icons.block_rounded
                        : magnetized
                        ? Icons.auto_fix_high_rounded
                        : Icons.drag_indicator_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    conflictCount == 0
                        ? label
                        : '$label · $conflictCount conflicts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragTimeBadge extends StatelessWidget {
  const _DragTimeBadge({
    required this.value,
    required this.style,
    required this.blocked,
    this.conflictCount = 0,
    this.magnetized = false,
  });

  final String value;
  final StructuredTimelineStyle style;
  final bool blocked;
  final int conflictCount;
  final bool magnetized;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              blocked
                  ? Icons.block_rounded
                  : magnetized
                  ? Icons.auto_fix_high_rounded
                  : Icons.schedule_rounded,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (conflictCount > 0) ...<Widget>[
              const SizedBox(width: 5),
              Text(
                '· $conflictCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StructuredRailPainter extends CustomPainter {
  const _StructuredRailPainter({
    required this.color,
    required this.activeColor,
    required this.activeExtent,
  });

  final Color color;
  final Color activeColor;
  final double activeExtent;

  @override
  void paint(Canvas canvas, Size size) {
    final dashed = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(1, y),
        Offset(1, math.min(y + 4, size.height)),
        dashed,
      );
      y += 10;
    }
    if (activeExtent > 0 && activeColor.a > 0) {
      final active = Paint()
        ..color = activeColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        const Offset(1, 0),
        Offset(1, math.min(activeExtent, size.height)),
        active,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StructuredRailPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeExtent != activeExtent;
  }
}

class _MoveEarlierIntent extends Intent {
  const _MoveEarlierIntent();
}

class _MoveLaterIntent extends Intent {
  const _MoveLaterIntent();
}

class _ActivateEntryIntent extends Intent {
  const _ActivateEntryIntent();
}

class _CancelDragIntent extends Intent {
  const _CancelDragIntent();
}

String _defaultTimeFormatter(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _defaultDurationFormatter(Duration value) {
  final minutes = value.inMinutes.abs();
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '${hours}h' : '${hours}h ${remainder}m';
}

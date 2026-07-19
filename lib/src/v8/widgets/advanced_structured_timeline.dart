import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_types.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v7/widgets/structured_timeline_view.dart';
import '../core/structured_timeline_controller.dart';
import '../core/timeline_mutation_coordinator.dart';
import '../core/timeline_resize.dart';
import '../models/advanced_structured_timeline_details.dart';
import '../models/structured_timeline_layout.dart';

/// Builder-first Structured timeline for production applications.
///
/// The widget composes the stable 7.x timeline with 8.x controller,
/// mutation-lock, resize, selection, zoom, and navigation capabilities.
class AdvancedStructuredTimeline<T> extends StatefulWidget {
  const AdvancedStructuredTimeline({
    required this.plan,
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
    this.gapExtentBuilder,
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
  final StructuredTimelineGapExtentBuilder<T>? gapExtentBuilder;
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
  State<AdvancedStructuredTimeline<T>> createState() =>
      _AdvancedStructuredTimelineState<T>();
}

class _AdvancedStructuredTimelineState<T>
    extends State<AdvancedStructuredTimeline<T>> {
  late StructuredTimelineController<T> _controller;
  late TimelineMutationCoordinator<T> _mutations;
  late ScrollController _scrollController;
  bool _ownsController = false;
  bool _ownsMutations = false;
  bool _ownsScrollController = false;
  int _lastNavigationRevision = -1;
  int _lastNudgeRevision = -1;
  bool _scrollUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    _attachController();
    _attachMutations();
    _attachScrollController();
  }

  @override
  void didUpdateWidget(covariant AdvancedStructuredTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    }
    if (oldWidget.mutationCoordinator != widget.mutationCoordinator) {
      _detachMutations();
      _attachMutations();
    }
    if (oldWidget.scrollController != widget.scrollController) {
      _detachScrollController();
      _attachScrollController();
    }
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? StructuredTimelineController<T>();
    _controller.addListener(_onControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _attachMutations() {
    _ownsMutations = widget.mutationCoordinator == null;
    _mutations = widget.mutationCoordinator ?? TimelineMutationCoordinator<T>();
    _mutations.addListener(_onMutationChanged);
  }

  void _detachMutations() {
    _mutations.removeListener(_onMutationChanged);
    if (_ownsMutations) _mutations.dispose();
  }

  void _attachScrollController() {
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _detachScrollController() {
    _scrollController.removeListener(_onScroll);
    if (_ownsScrollController) _scrollController.dispose();
  }

  @override
  void dispose() {
    _detachController();
    _detachMutations();
    _detachScrollController();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _processNavigationRequest();
    _processNudgeRequest();
  }

  void _onMutationChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollUpdateScheduled || !_scrollController.hasClients) return;
    _scrollUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollUpdateScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;
      final visible = _visibleRangeForOffset(
        _scrollController.offset,
        _scrollController.position.viewportDimension,
      );
      if (visible != null) _controller.setVisibleRange(visible);
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        widget.style ??
        (Theme.of(context).brightness == Brightness.dark
            ? StructuredTimelineStyle.dark()
            : StructuredTimelineStyle.light());
    final resolvedStyle = widget.layout.applyTo(
      baseStyle,
      zoom: _controller.zoom,
    );
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 2.0).toDouble();
    final accessibleMinimum = math
        .max(
          resolvedStyle.minimumEntryExtent,
          resolvedStyle.cardMinimumHeight + (textScale - 1) * 40,
        )
        .toDouble();
    final style = resolvedStyle.copyWith(
      minimumEntryExtent: accessibleMinimum,
      maximumEntryExtent: math
          .max(resolvedStyle.maximumEntryExtent, accessibleMinimum)
          .toDouble(),
    );

    return StructuredTimelineView<T>(
      plan: widget.plan,
      style: style,
      strings: widget.strings,
      scrollController: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      showInsightBanner: widget.showInsightBanner,
      showCompletionToggle: widget.showCompletionToggle,
      showBoundaryGaps: widget.showBoundaryGaps,
      timeColumnOnRight:
          widget.layout.timeColumnPosition ==
          StructuredTimelineTimeColumnPosition.right,
      enableDragging: widget.enableDragging,
      enableDeleteTarget: widget.enableDeleteTarget,
      initialScroll: widget.initialScroll,
      reschedulePolicy: TimelineReschedulePolicy(
        snap: widget.reschedulePolicy.snap,
        keepEntireEntryInBounds:
            widget.reschedulePolicy.keepEntireEntryInBounds,
        allowConflicts: widget.reschedulePolicy.allowConflicts,
        enableDeleteTarget: widget.enableDeleteTarget,
        pixelsPerMinute: style.pixelsPerMinute,
        magnetizeToNeighbors: widget.reschedulePolicy.magnetizeToNeighbors,
        magnetDistance: widget.reschedulePolicy.magnetDistance,
        snapHysteresis: widget.reschedulePolicy.snapHysteresis,
        preferConflictFreeDrop: widget.reschedulePolicy.preferConflictFreeDrop,
      ),
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
      emptyBuilder: widget.emptyBuilder,
      titleBuilder: widget.titleBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      progressBuilder: widget.progressBuilder,
      timeFormatter: widget.timeFormatter,
      durationFormatter: widget.durationFormatter,
      iconBuilder: widget.iconBuilder,
      trailingBuilder: widget.trailingBuilder,
      onEntryTap: _handleEntryTap,
      onComplete: widget.onComplete == null ? null : _handleComplete,
      onMove: widget.onMove == null ? null : _handleMove,
      onDelete: widget.onDelete == null ? null : _handleDelete,
      onInsert: widget.onInsert,
      gapExtentBuilder: widget.gapExtentBuilder,
      gapBuilder: widget.gapBuilder == null
          ? null
          : (context, gap, valueStyle) =>
                widget.gapBuilder!(context, gap, valueStyle),
      timeLabelBuilder: widget.timeLabelBuilder == null
          ? null
          : (context, item, value, isEnd, valueStyle) =>
                widget.timeLabelBuilder!(
                  context,
                  item,
                  value,
                  isEnd,
                  valueStyle,
                ),
      insightBuilder: widget.insightBuilder == null
          ? null
          : (context, plan, valueStyle) =>
                widget.insightBuilder!(context, plan, valueStyle),
      conflictBridgeBuilder: widget.conflictBridgeBuilder == null
          ? null
          : (context, item, overlap, valueStyle) =>
                widget.conflictBridgeBuilder!(
                  context,
                  item,
                  overlap,
                  valueStyle,
                ),
      dragFeedbackBuilder: widget.dragFeedbackBuilder == null
          ? null
          : (context, details, child) => widget.dragFeedbackBuilder!(
              context,
              _advancedDetails(details),
              child,
            ),
      dragPlaceholderBuilder: widget.dragPlaceholderBuilder == null
          ? null
          : (context, details, child) => widget.dragPlaceholderBuilder!(
              context,
              _advancedDetails(details),
              child,
            ),
      deleteTargetBuilder: widget.deleteTargetBuilder,
      cardBuilder: (context, details) {
        return _AdvancedStructuredCard<T>(
          key: ValueKey<String>('advanced_card_${details.entry.id}'),
          details: details,
          plan: widget.plan,
          style: style,
          strings: widget.strings,
          layout: widget.layout,
          selected: _controller.isSelected(details.entry.id),
          focused: _controller.isFocused(details.entry.id),
          busy: _mutations.isBusy(details.entry.id),
          enableResizing: widget.enableResizing && widget.onResize != null,
          resizePolicy: TimelineResizePolicy(
            snap: widget.resizePolicy.snap,
            minimumDuration: widget.resizePolicy.minimumDuration,
            maximumDuration: widget.resizePolicy.maximumDuration,
            keepEntireEntryInBounds:
                widget.resizePolicy.keepEntireEntryInBounds,
            allowConflicts: widget.resizePolicy.allowConflicts,
            pixelsPerMinute: style.pixelsPerMinute,
          ),
          titleBuilder: widget.titleBuilder,
          subtitleBuilder: widget.subtitleBuilder,
          progressBuilder: widget.progressBuilder,
          timeFormatter: widget.timeFormatter ?? _defaultTimeFormatter,
          durationFormatter:
              widget.durationFormatter ?? _defaultDurationFormatter,
          entryBuilder: widget.entryBuilder,
          onComplete: widget.onComplete == null
              ? null
              : () => _handleComplete(context, details),
          onResize: _handleResize,
        );
      },
    );
  }

  AdvancedStructuredTimelineEntryDetails<T> _advancedDetails(
    StructuredTimelineEntryDetails<T> details, {
    TimelineResizePreview<T>? resizePreview,
  }) {
    return AdvancedStructuredTimelineEntryDetails<T>(
      base: details,
      selected: _controller.isSelected(details.entry.id),
      focused: _controller.isFocused(details.entry.id),
      busy: _mutations.isBusy(details.entry.id),
      resizePreview: resizePreview,
    );
  }

  Future<void> _handleEntryTap(
    BuildContext context,
    StructuredTimelineEntryDetails<T> details,
  ) async {
    _controller.selectEntry(details.entry.id);
    final callback = widget.onEntryTap;
    if (callback != null) {
      await Future<void>.sync(() => callback(context, details));
    }
  }

  Future<void> _handleComplete(
    BuildContext context,
    StructuredTimelineEntryDetails<T> details,
  ) async {
    final callback = widget.onComplete;
    if (callback == null) return;
    await _runMutation(
      context: context,
      request: TimelineMutationRequest<T>(
        type: TimelineMutationType.complete,
        entry: details.entry,
      ),
      commit: (_) => callback(context, details),
    );
  }

  Future<void> _handleMove(
    BuildContext context,
    StructuredTimelineMoveDetails<T> details,
  ) async {
    final callback = widget.onMove;
    if (callback == null) return;
    await _runMutation(
      context: context,
      request: TimelineMutationRequest<T>(
        type: TimelineMutationType.move,
        entry: details.entry,
        proposedStart: details.preview.start,
        proposedEnd: details.preview.end,
      ),
      commit: (_) => callback(context, details),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    StructuredTimelineMoveDetails<T> details,
  ) async {
    final callback = widget.onDelete;
    if (callback == null) return;
    await _runMutation(
      context: context,
      request: TimelineMutationRequest<T>(
        type: TimelineMutationType.delete,
        entry: details.entry,
      ),
      commit: (_) => callback(context, details),
    );
  }

  Future<void> _handleResize(
    BuildContext context,
    AdvancedStructuredTimelineResizeDetails<T> details,
  ) async {
    final callback = widget.onResize;
    if (callback == null) return;
    await _runMutation(
      context: context,
      request: TimelineMutationRequest<T>(
        type: TimelineMutationType.resize,
        entry: details.entry,
        proposedStart: details.preview.start,
        proposedEnd: details.preview.end,
      ),
      commit: (_) => callback(context, details),
    );
  }

  Future<void> _runMutation({
    required BuildContext context,
    required TimelineMutationRequest<T> request,
    required TimelineMutationCommit<T> commit,
  }) async {
    final result = await _mutations.execute(
      request: request,
      commit: commit,
      rollback: widget.onMutationRollback == null
          ? null
          : (value, error, stackTrace) =>
                widget.onMutationRollback!(context, value, error, stackTrace),
    );
    if (!context.mounted || result.succeeded || result.error == null) return;
    widget.onMutationError?.call(
      context,
      request.entry,
      result.error!,
      result.stackTrace ?? StackTrace.current,
    );
  }

  void _processNavigationRequest() {
    final request = _controller.navigationRequest;
    if (request == null || request.revision == _lastNavigationRevision) return;
    _lastNavigationRevision = request.revision;
    Object? targetId = request.entryId;
    if (request.kind == StructuredTimelineNavigationKind.now) {
      targetId =
          widget.plan.insight.current?.entry.id ??
          widget.plan.insight.next?.entry.id;
    }
    if (targetId == null) return;
    _scheduleScrollTo(
      targetId,
      request.animated,
      ensureOnly:
          request.kind == StructuredTimelineNavigationKind.ensureVisible,
    );
  }

  void _processNudgeRequest() {
    final request = _controller.nudgeRequest;
    if (request == null || request.revision == _lastNudgeRevision) return;
    _lastNudgeRevision = request.revision;
    final item = _entryById(request.entryId);
    if (item == null || widget.onMove == null) return;
    final session = TimelineRescheduleSession<T>(
      entry: item.entry,
      bounds: TimelineDateRange(widget.plan.rangeStart, widget.plan.rangeEnd),
      candidates: widget.plan.entries.map((value) => value.entry),
      policy: TimelineReschedulePolicy(
        snap: widget.reschedulePolicy.snap,
        keepEntireEntryInBounds:
            widget.reschedulePolicy.keepEntireEntryInBounds,
        allowConflicts: widget.reschedulePolicy.allowConflicts,
        pixelsPerMinute: widget.layout
            .applyTo(
              widget.style ?? StructuredTimelineStyle.light(),
              zoom: _controller.zoom,
            )
            .pixelsPerMinute,
        magnetizeToNeighbors: widget.reschedulePolicy.magnetizeToNeighbors,
        magnetDistance: widget.reschedulePolicy.magnetDistance,
        snapHysteresis: widget.reschedulePolicy.snapHysteresis,
        preferConflictFreeDrop: widget.reschedulePolicy.preferConflictFreeDrop,
      ),
    );
    final preview = session.previewForDelta(request.delta);
    final result = session.resolveDrop(preview: preview);
    if (result.disposition != TimelineDropDisposition.move) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _handleMove(
          context,
          StructuredTimelineMoveDetails<T>(item: item, result: result),
        ),
      );
    });
  }

  TimelineDayEntry<T>? _entryById(Object id) {
    for (final item in widget.plan.entries) {
      if (item.entry.id == id) return item;
    }
    return null;
  }

  void _scheduleScrollTo(Object id, bool animated, {required bool ensureOnly}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final geometry = _geometryForEntry(id);
      if (geometry == null) return;
      final position = _scrollController.position;
      final viewportStart = _scrollController.offset;
      final viewportEnd = viewportStart + position.viewportDimension;
      if (ensureOnly &&
          geometry.$1 >= viewportStart &&
          geometry.$2 <= viewportEnd) {
        return;
      }
      final target = (geometry.$1 - position.viewportDimension * 0.18).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (animated) {
        unawaited(
          _scrollController.animateTo(
            target.toDouble(),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
          ),
        );
      } else {
        _scrollController.jumpTo(target.toDouble());
      }
    });
  }

  (double, double)? _geometryForEntry(Object id) {
    final style = widget.layout.applyTo(
      widget.style ?? StructuredTimelineStyle.light(),
      zoom: _controller.zoom,
    );
    var offset = widget.showInsightBanner ? 94.0 : 0.0;
    final nodes = _nodes(style);
    for (final node in nodes) {
      final end = offset + node.extent;
      if (node.entry?.entry.id == id) return (offset, end);
      offset = end;
    }
    return null;
  }

  TimelineDateRange? _visibleRangeForOffset(double offset, double viewport) {
    final style = widget.layout.applyTo(
      widget.style ?? StructuredTimelineStyle.light(),
      zoom: _controller.zoom,
    );
    final startOffset = math.max(0, offset - 40);
    final endOffset = offset + viewport + 40;
    var cursor = widget.showInsightBanner ? 94.0 : 0.0;
    DateTime? start;
    DateTime? end;
    for (final node in _nodes(style)) {
      final nodeEnd = cursor + node.extent;
      if (nodeEnd >= startOffset && cursor <= endOffset) {
        start ??= node.start;
        end = node.end;
      }
      if (cursor > endOffset) break;
      cursor = nodeEnd;
    }
    if (start == null || end == null || !end.isAfter(start)) return null;
    return TimelineDateRange(start, end);
  }

  List<_AdvancedNode<T>> _nodes(StructuredTimelineStyle style) {
    final nodes = <_AdvancedNode<T>>[
      for (final entry in widget.plan.entries)
        _AdvancedNode<T>.entry(entry, _entryExtent(entry, style)),
    ];
    for (final gap in widget.plan.gaps) {
      final boundary = gap.previous == null || gap.next == null;
      if (!widget.showBoundaryGaps && boundary) continue;
      nodes.add(_AdvancedNode<T>.gap(gap, _gapExtent(gap, style)));
    }
    nodes.sort((left, right) {
      final byStart = left.start.compareTo(right.start);
      if (byStart != 0) return byStart;
      return left.entry != null ? -1 : 1;
    });
    return nodes;
  }

  double _gapExtent(TimelineDayGap<T> gap, StructuredTimelineStyle style) {
    final custom = widget.gapExtentBuilder?.call(gap, style);
    if (custom != null && custom.isFinite && custom >= 0) return custom;
    return (gap.duration.inMinutes * style.pixelsPerMinute)
        .clamp(style.minimumGapExtent, style.maximumGapExtent)
        .toDouble();
  }

  double _entryExtent(TimelineDayEntry<T> item, StructuredTimelineStyle style) {
    return (item.duration.inMinutes * style.pixelsPerMinute)
        .clamp(style.minimumEntryExtent, style.maximumEntryExtent)
        .toDouble();
  }
}

class _AdvancedNode<T> {
  const _AdvancedNode._({
    required this.start,
    required this.end,
    required this.extent,
    this.entry,
    this.gap,
  });

  factory _AdvancedNode.entry(TimelineDayEntry<T> entry, double extent) {
    return _AdvancedNode<T>._(
      start: entry.start,
      end: entry.end,
      extent: extent,
      entry: entry,
    );
  }

  factory _AdvancedNode.gap(TimelineDayGap<T> gap, double extent) {
    return _AdvancedNode<T>._(
      start: gap.start,
      end: gap.end,
      extent: extent,
      gap: gap,
    );
  }

  final DateTime start;
  final DateTime end;
  final double extent;
  final TimelineDayEntry<T>? entry;
  final TimelineDayGap<T>? gap;
}

class _AdvancedStructuredCard<T> extends StatefulWidget {
  const _AdvancedStructuredCard({
    required this.details,
    required this.plan,
    required this.style,
    required this.strings,
    required this.layout,
    required this.selected,
    required this.focused,
    required this.busy,
    required this.enableResizing,
    required this.resizePolicy,
    required this.timeFormatter,
    required this.durationFormatter,
    required this.onResize,
    this.onComplete,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.entryBuilder,
    super.key,
  });

  final StructuredTimelineEntryDetails<T> details;
  final TimelineDayPlan<T> plan;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final StructuredTimelineLayout layout;
  final bool selected;
  final bool focused;
  final bool busy;
  final bool enableResizing;
  final TimelineResizePolicy resizePolicy;
  final StructuredTimelineTimeFormatter timeFormatter;
  final StructuredTimelineDurationFormatter durationFormatter;
  final AdvancedStructuredTimelineResizeCallback<T> onResize;
  final Future<void> Function()? onComplete;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final AdvancedStructuredTimelineEntryBuilder<T>? entryBuilder;

  @override
  State<_AdvancedStructuredCard<T>> createState() =>
      _AdvancedStructuredCardState<T>();
}

class _AdvancedStructuredCardState<T>
    extends State<_AdvancedStructuredCard<T>> {
  TimelineResizeSession<T>? _resizeSession;
  TimelineResizePreview<T>? _resizePreview;
  double _resizeStartY = 0;
  int? _lastSnapIndex;
  bool _hovered = false;

  bool get _canResize =>
      widget.enableResizing &&
      widget.details.entry.draggable &&
      widget.details.entry.enabled &&
      !widget.busy &&
      !widget.details.isDragging;

  @override
  Widget build(BuildContext context) {
    final advanced = AdvancedStructuredTimelineEntryDetails<T>(
      base: widget.details,
      selected: widget.selected,
      focused: widget.focused,
      busy: widget.busy,
      resizePreview: _resizePreview,
      onComplete: widget.onComplete,
    );
    final originalExtent = _extent(widget.details.item.duration);
    final preview = _resizePreview;
    final previewExtent = preview == null
        ? originalExtent
        : _extent(preview.duration);
    final translateY = preview == null
        ? 0.0
        : preview.start.difference(widget.details.item.start).inMinutes *
              widget.style.pixelsPerMinute;

    Widget child =
        widget.entryBuilder?.call(context, advanced) ??
        _DefaultAdvancedStructuredCard<T>(
          details: advanced,
          strings: widget.strings,
          title:
              widget.titleBuilder?.call(widget.details.entry) ??
              widget.details.entry.semanticLabel ??
              widget.details.value.toString(),
          subtitle:
              widget.subtitleBuilder?.call(widget.details.entry) ??
              widget.details.entry.metadata['structured.subtitle'] as String?,
          progress:
              widget.progressBuilder?.call(widget.details.entry) ??
              (widget.details.entry.metadata['structured.progress'] as num?)
                  ?.toDouble(),
          timeFormatter: widget.timeFormatter,
          durationFormatter: widget.durationFormatter,
        );

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    child = AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 160),
      height: previewExtent,
      constraints: BoxConstraints(minHeight: widget.style.cardMinimumHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.style.cardRadius),
        border: widget.selected || widget.focused
            ? Border.all(
                color: widget.style.primaryColor,
                width: widget.focused ? 2 : 1.5,
              )
            : null,
        boxShadow: widget.selected
            ? <BoxShadow>[
                BoxShadow(
                  color: widget.style.primaryColor.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.style.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child,
            if (_resizePreview != null)
              Positioned(
                left: 12,
                top: 7,
                child: _ResizeTimeBadge(
                  label:
                      '${widget.timeFormatter(advanced.effectiveStart)}–${widget.timeFormatter(advanced.effectiveEnd)}',
                  blocked: !_resizePreview!.canCommit,
                  style: widget.style,
                ),
              ),
            if (_canResize &&
                widget.layout.showResizeHandles &&
                (_hovered ||
                    widget.selected ||
                    _resizePreview != null)) ...<Widget>[
              _ResizeHandle(
                edge: TimelineResizeEdge.start,
                color: widget.style.primaryColor,
                onStart: _startResize,
                onUpdate: _updateResize,
                onEnd: _endResize,
                onCancel: _cancelResize,
                semanticLabel: widget.strings.resizeStart,
                onIncrease: () => _keyboardResize(
                  TimelineResizeEdge.start,
                  widget.resizePolicy.snap,
                ),
                onDecrease: () => _keyboardResize(
                  TimelineResizeEdge.start,
                  Duration(
                    microseconds: -widget.resizePolicy.snap.inMicroseconds,
                  ),
                ),
              ),
              _ResizeHandle(
                edge: TimelineResizeEdge.end,
                color: widget.style.primaryColor,
                onStart: _startResize,
                onUpdate: _updateResize,
                onEnd: _endResize,
                onCancel: _cancelResize,
                semanticLabel: widget.strings.resizeEnd,
                onIncrease: () => _keyboardResize(
                  TimelineResizeEdge.end,
                  widget.resizePolicy.snap,
                ),
                onDecrease: () => _keyboardResize(
                  TimelineResizeEdge.end,
                  Duration(
                    microseconds: -widget.resizePolicy.snap.inMicroseconds,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Transform.translate(offset: Offset(0, translateY), child: child),
    );
  }

  double _extent(Duration duration) {
    return (duration.inMinutes * widget.style.pixelsPerMinute)
        .clamp(widget.style.minimumEntryExtent, widget.style.maximumEntryExtent)
        .toDouble();
  }

  void _keyboardResize(TimelineResizeEdge edge, Duration delta) {
    if (!_canResize) return;
    final session = TimelineResizeSession<T>(
      entry: widget.details.entry,
      edge: edge,
      bounds: TimelineDateRange(widget.plan.rangeStart, widget.plan.rangeEnd),
      candidates: widget.plan.entries.map((item) => item.entry),
      policy: widget.resizePolicy,
    );
    final preview = session.previewForDelta(delta);
    final result = session.resolve(preview: preview);
    if (!result.accepted) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.selectionClick();
    unawaited(
      Future<void>.sync(
        () => widget.onResize(
          context,
          AdvancedStructuredTimelineResizeDetails<T>(
            item: widget.details.item,
            result: result,
          ),
        ),
      ),
    );
  }

  void _startResize(TimelineResizeEdge edge, DragStartDetails details) {
    if (!_canResize) return;
    _resizeStartY = details.globalPosition.dy;
    _resizeSession = TimelineResizeSession<T>(
      entry: widget.details.entry,
      edge: edge,
      bounds: TimelineDateRange(widget.plan.rangeStart, widget.plan.rangeEnd),
      candidates: widget.plan.entries.map((item) => item.entry),
      policy: widget.resizePolicy,
    );
    _resizePreview = _resizeSession!.previewForDelta(Duration.zero);
    _lastSnapIndex = _resizePreview!.snapIndex;
    HapticFeedback.mediumImpact();
    setState(() {});
  }

  void _updateResize(DragUpdateDetails details) {
    final session = _resizeSession;
    if (session == null) return;
    final preview = session.previewForPixels(
      details.globalPosition.dy - _resizeStartY,
    );
    if (preview.snapIndex != _lastSnapIndex) {
      _lastSnapIndex = preview.snapIndex;
      HapticFeedback.selectionClick();
    }
    setState(() => _resizePreview = preview);
  }

  void _endResize(DragEndDetails details) {
    final session = _resizeSession;
    final preview = _resizePreview;
    if (session == null || preview == null) {
      _clearResize();
      return;
    }
    final result = session.resolve(preview: preview);
    _clearResize();
    if (!result.accepted) {
      if (!preview.canCommit) HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.mediumImpact();
    unawaited(
      Future<void>.sync(
        () => widget.onResize(
          context,
          AdvancedStructuredTimelineResizeDetails<T>(
            item: widget.details.item,
            result: result,
          ),
        ),
      ),
    );
  }

  void _cancelResize() {
    final session = _resizeSession;
    final preview = _resizePreview;
    if (session != null && preview != null) {
      session.resolve(preview: preview, cancelled: true);
    }
    _clearResize();
  }

  void _clearResize() {
    if (!mounted) return;
    setState(() {
      _resizeSession = null;
      _resizePreview = null;
      _lastSnapIndex = null;
    });
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.edge,
    required this.color,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    required this.semanticLabel,
    required this.onIncrease,
    required this.onDecrease,
  });

  final TimelineResizeEdge edge;
  final Color color;
  final void Function(TimelineResizeEdge edge, DragStartDetails details)
  onStart;
  final ValueChanged<DragUpdateDetails> onUpdate;
  final ValueChanged<DragEndDetails> onEnd;
  final VoidCallback onCancel;
  final String semanticLabel;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: edge == TimelineResizeEdge.start ? 0 : null,
      bottom: edge == TimelineResizeEdge.end ? 0 : null,
      height: 18,
      child: Semantics(
        button: true,
        label: semanticLabel,
        onIncrease: onIncrease,
        onDecrease: onDecrease,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (details) => onStart(edge, details),
          onVerticalDragUpdate: onUpdate,
          onVerticalDragEnd: onEnd,
          onVerticalDragCancel: onCancel,
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAdvancedStructuredCard<T> extends StatelessWidget {
  const _DefaultAdvancedStructuredCard({
    required this.details,
    required this.strings,
    required this.title,
    required this.timeFormatter,
    required this.durationFormatter,
    this.subtitle,
    this.progress,
  });

  final AdvancedStructuredTimelineEntryDetails<T> details;
  final StructuredTimelineStrings strings;
  final String title;
  final String? subtitle;
  final double? progress;
  final StructuredTimelineTimeFormatter timeFormatter;
  final StructuredTimelineDurationFormatter durationFormatter;

  @override
  Widget build(BuildContext context) {
    final style = details.style;
    final entry = details.entry;
    final completed = entry.status == TimelineStatus.completed;
    final color = completed
        ? style.completedColor
        : entry.color ?? style.accentColor;
    final tint = Color.alphaBlend(
      color.withValues(alpha: style.cardTintOpacity),
      style.cardColor,
    );
    final normalizedProgress = progress?.clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : style.cardMinimumHeight;
        final compact = available < 78;
        final showSubtitle =
            subtitle != null && subtitle!.trim().isNotEmpty && available >= 92;
        final showProgress = normalizedProgress != null && available >= 110;
        final verticalPadding = compact ? 7.0 : 10.0;
        final titleSize = compact ? 13.5 : 14.5;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(style.cardRadius),
            border: Border.all(
              color: details.hasConflict
                  ? style.conflictColor
                  : color.withValues(alpha: style.cardBorderOpacity),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: style.shadowColor.withValues(alpha: 0.42),
                blurRadius: details.isDragging || details.isResizing ? 24 : 10,
                offset: Offset(
                  0,
                  details.isDragging || details.isResizing ? 10 : 4,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(style.cardRadius),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(
                    color: details.hasConflict ? style.conflictColor : color,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    verticalPadding,
                    details.busy ? 38 : 14,
                    verticalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${timeFormatter(details.effectiveStart)}–'
                              '${timeFormatter(details.effectiveEnd)} · '
                              '${durationFormatter(details.effectiveDuration)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: style.mutedTextColor,
                                fontSize: compact ? 9.3 : 10,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (details.base.isRecurring)
                            Icon(
                              Icons.sync_rounded,
                              size: 13,
                              color: style.mutedTextColor,
                            ),
                          if (details.base.isExternal)
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: style.mutedTextColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: completed
                                ? style.mutedTextColor
                                : style.textColor,
                            fontSize: titleSize,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (showSubtitle) ...<Widget>[
                        const SizedBox(height: 3),
                        Flexible(
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: style.mutedTextColor,
                              fontSize: 10.5,
                              height: 1.08,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (showProgress) ...<Widget>[
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: normalizedProgress,
                            color: color,
                            backgroundColor: color.withValues(alpha: 0.14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (details.busy)
                  Positioned(
                    right: 12,
                    top: 10,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResizeTimeBadge extends StatelessWidget {
  const _ResizeTimeBadge({
    required this.label,
    required this.blocked,
    required this.style,
  });

  final String label;
  final bool blocked;
  final StructuredTimelineStyle style;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _defaultTimeFormatter(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.hour)}:${two(value.minute)}';
}

String _defaultDurationFormatter(Duration value) {
  final minutes = value.inMinutes.abs();
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '${remainder}m';
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}m';
}

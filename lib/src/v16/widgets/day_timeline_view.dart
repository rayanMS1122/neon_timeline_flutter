import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../api/entry_adapter.dart';
import '../api/models.dart';
import '../geometry/lane_allocator.dart';
import '../theme/timeline_theme.dart';
import '../viewport/interval_index.dart';

part 'day_timeline_api.dart';
part 'day_timeline_responsive.dart';
part 'day_timeline_model.dart';
part 'day_timeline_chrome.dart';
part 'day_timeline_rows.dart';
part 'day_timeline_row_support.dart';
part 'day_timeline_drag.dart';
part 'day_timeline_drop_target.dart';
part 'day_timeline_drag_feedback.dart';
part 'day_timeline_time_scrubber.dart';
part 'day_timeline_snap.dart';
part 'day_timeline_resize.dart';
part 'day_timeline_undo.dart';
part 'day_timeline_motion.dart';

class _NeonPlannerDayTimelineState<T>
    extends State<NeonPlannerDayTimeline<T>> {
  final GlobalKey _listKey = GlobalKey();
  final ValueNotifier<_DayDragPreview<T>?> _dragPreview =
      ValueNotifier<_DayDragPreview<T>?>(null);
  final ValueNotifier<_DayResizePreview<T>?> _resizePreview =
      ValueNotifier<_DayResizePreview<T>?>(null);
  final ValueNotifier<_DayCommitVisual<T>?> _commitVisual =
      ValueNotifier<_DayCommitVisual<T>?>(null);

  late ScrollController _scrollController;
  _DayLayoutMetrics? _layoutMetrics;
  _DayLayoutMetrics? _frozenLayoutMetrics;
  _DragFeedbackGeometry? _dragFeedbackGeometry;
  late bool _ownsScrollController;
  Object? _selectedId;
  Object? _draggingId;
  Object? _resizingId;
  Object? _activeDropSlot;
  DateTime? _activeDropStart;
  bool _activeDropConflict = false;
  bool _committing = false;
  bool _dropAccepted = false;
  double? _pendingDragAnchorGlobalY;
  double? _dragAnchorGlobalY;
  double _dragAnchorScrollOffset = 0;
  Offset? _lastDragGlobalPosition;
  List<NeonPlannerEntrySnapshot<T>> _dragSnapshots =
      <NeonPlannerEntrySnapshot<T>>[];
  List<NeonPlannerEntrySnapshot<T>> _resizeSnapshots =
      <NeonPlannerEntrySnapshot<T>>[];
  NeonPlannerEntrySnapshot<T>? _resizeOriginal;
  NeonPlannerResizeEdge? _activeResizeEdge;
  double? _resizeAnchorGlobalY;
  double _resizeAnchorScrollOffset = 0;
  double _autoScrollVelocity = 0;
  bool _autoScrollFrameScheduled = false;
  Duration? _lastAutoScrollFrameTime;
  Offset? _pendingInteractionGlobalPosition;
  bool _interactionFrameScheduled = false;
  Object? _lastHapticSnapToken;
  List<NeonPlannerEntrySnapshot<T>>? _frozenSnapshots;
  Map<Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>?
      _frozenPlacements;
  NeonPlannerIntervalIndex<_DayIndexedSnapshot<T>>? _interactionConflictIndex;
  Object? _recentlyMovedId;
  Timer? _recentlyMovedTimer;
  Timer? _commitVisualTimer;
  int _commitVisualSequence = 0;
  _DaySnapResult? _latchedSnap;
  _PendingUndo<T>? _pendingUndo;
  Timer? _undoTimer;

  DateTime get _dayStart => DateTime(
    widget.selectedDate.year,
    widget.selectedDate.month,
    widget.selectedDate.day,
  );

  DateTime get _dayEnd => _dayStart.add(const Duration(days: 1));

  bool get _dragEnabled =>
      widget.onEntryMove != null &&
      widget.dragActivation != NeonPlannerDragActivation.disabled &&
      widget.dragActivation != NeonPlannerDragActivation.keyboard;

  bool get _resizeEnabled =>
      widget.enableResize && widget.onEntryResize != null;

  DateTime? get _currentTimeForDay {
    if (!widget.showCurrentTimeIndicator) {
      return null;
    }
    final value = widget.currentTime ?? DateTime.now();
    final sameDay = value.year == _dayStart.year &&
        value.month == _dayStart.month &&
        value.day == _dayStart.day;
    return sameDay ? value : null;
  }

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant NeonPlannerDayTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (_ownsScrollController) {
        _scrollController.dispose();
      }
      _ownsScrollController = widget.scrollController == null;
      _scrollController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  void dispose() {
    _autoScrollVelocity = 0;
    _undoTimer?.cancel();
    _recentlyMovedTimer?.cancel();
    _commitVisualTimer?.cancel();
    _dragPreview.dispose();
    _resizePreview.dispose();
    _commitVisual.dispose();
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _buildTimeline(context, constraints),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    _DayTimelineModel<T>(this)._validateConfiguration();
    final resolvedTheme = widget.theme ?? NeonPlannerTimelineTheme.of(context);
    final interactionActive = _draggingId != null || _resizingId != null;
    final responsiveDensity =
        _resolveResponsiveDensity(constraints.maxWidth);
    final resolvedLayout = _DayLayoutMetrics.resolve(
      width: constraints.maxWidth,
      configuredPadding: widget.padding,
      configuredBorderRadius: widget.borderRadius,
      verticalDensity: widget.density,
      responsiveDensity: responsiveDensity,
    );
    final layout = interactionActive && _frozenLayoutMetrics != null
        ? _frozenLayoutMetrics!
        : resolvedLayout;
    _layoutMetrics = layout;

    final snapshots = interactionActive && _frozenSnapshots != null
        ? _frozenSnapshots!
        : _snapshotsForDay();
    final placements = interactionActive && _frozenPlacements != null
        ? _frozenPlacements!
        : _DayTimelineModel<T>(this)._overlapPlacements(snapshots);
    final resolvedMetrics =
        widget.metrics ??
        _DayTimelineModel<T>(this)._defaultMetrics(snapshots, resolvedTheme);
    final rows = _DayTimelineModel<T>(
      this,
    )._rows(snapshots, placements, resolvedTheme, layout);
    final contentFit = widget.fit == NeonPlannerDayFit.content ||
        (widget.fit == NeonPlannerDayFit.smart &&
            (!constraints.hasBoundedHeight ||
                rows.length <= widget.smartFitMaxRows));
    final showTimeLens = _showTimeLens(layout);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    Widget buildDragLens(_DayDragPreview<T> preview) {
      final y = preview.viewportY;
      if (y == null) {
        return const SizedBox.shrink();
      }
      return Positioned(
        left: 2,
        top: (y - layout.timeLensHeight / 2)
            .clamp(2.0, double.infinity)
            .toDouble(),
        width: layout.timeLensWidth,
        height: layout.timeLensHeight,
        child: IgnorePointer(
          child: RepaintBoundary(
            child: _AdaptiveTimeLens(
              center: preview.proposedStart,
              interval: widget.snapInterval,
              theme: resolvedTheme,
              hasConflict: preview.hasConflict,
              blocked: preview.hasConflict &&
                  widget.conflictPolicy == NeonPlannerConflictPolicy.block,
              markCount: layout.timeLensMarks,
              labelOnly: layout.timeLensLabelOnly,
            ),
          ),
        ),
      );
    }

    Widget buildResizeLens(_DayResizePreview<T> preview) {
      final y = preview.viewportY;
      if (y == null) {
        return const SizedBox.shrink();
      }
      final center = preview.edge == NeonPlannerResizeEdge.start
          ? preview.proposedStart
          : preview.proposedEnd;
      return Positioned(
        left: 2,
        top: (y - layout.timeLensHeight / 2)
            .clamp(2.0, double.infinity)
            .toDouble(),
        width: layout.timeLensWidth,
        height: layout.timeLensHeight,
        child: IgnorePointer(
          child: RepaintBoundary(
            child: _AdaptiveTimeLens(
              center: center,
              interval: widget.snapInterval,
              theme: resolvedTheme,
              hasConflict: preview.hasConflict,
              blocked: preview.hasConflict &&
                  widget.conflictPolicy == NeonPlannerConflictPolicy.block,
              markCount: layout.timeLensMarks,
              labelOnly: layout.timeLensLabelOnly,
            ),
          ),
        ),
      );
    }

    final timelineStack = Stack(
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        ListView.builder(
          key: _listKey,
          controller: contentFit ? null : _scrollController,
          shrinkWrap: contentFit,
          padding: EdgeInsets.zero,
          physics: contentFit
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          // ignore: deprecated_member_use
          cacheExtent: _draggingId == null && _resizingId == null ? null : 420.0,
          itemCount: rows.length,
          itemBuilder: (context, index) => rows[index],
        ),
        if ((_dragEnabled || _resizeEnabled) && widget.showTimeScrubber)
          ValueListenableBuilder<_DayDragPreview<T>?>(
            valueListenable: _dragPreview,
            builder: (context, preview, child) {
              final y = preview?.viewportY;
              if (preview == null || y == null) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 0,
                right: 0,
                top: (y - (layout.isRegular ? 24 : 18))
                    .clamp(0.0, double.infinity)
                    .toDouble(),
                child: IgnorePointer(
                  child: _TimeDragScrubber<T>(
                    preview: preview,
                    theme: resolvedTheme,
                    conflictPolicy: widget.conflictPolicy,
                    layout: layout,
                  ),
                ),
              );
            },
          ),
        if (_resizeEnabled && widget.showTimeScrubber)
          ValueListenableBuilder<_DayResizePreview<T>?>(
            valueListenable: _resizePreview,
            builder: (context, preview, child) {
              final y = preview?.viewportY;
              if (preview == null || y == null) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 0,
                right: 0,
                top: (y - (layout.isRegular ? 24 : 18))
                    .clamp(0.0, double.infinity)
                    .toDouble(),
                child: IgnorePointer(
                  child: _ResizeDragScrubber<T>(
                    preview: preview,
                    theme: resolvedTheme,
                    conflictPolicy: widget.conflictPolicy,
                    layout: layout,
                  ),
                ),
              );
            },
          ),
        if (showTimeLens)
          ValueListenableBuilder<_DayDragPreview<T>?>(
            valueListenable: _dragPreview,
            builder: (context, preview, child) => preview == null
                ? const SizedBox.shrink()
                : buildDragLens(preview),
          ),
        if (showTimeLens)
          ValueListenableBuilder<_DayResizePreview<T>?>(
            valueListenable: _resizePreview,
            builder: (context, preview, child) => preview == null
                ? const SizedBox.shrink()
                : buildResizeLens(preview),
          ),
        ValueListenableBuilder<_DayCommitVisual<T>?>(
          valueListenable: _commitVisual,
          builder: (context, visual, child) {
            if (visual == null) {
              return const SizedBox.shrink();
            }
            final showConfirmation = visual.resized
                ? widget.showResizeConfirmation
                : widget.showMoveConfirmation;
            if (!showConfirmation) {
              return const SizedBox.shrink();
            }
            final top = (visual.viewportY ?? 72) - 30;
            return Positioned(
              left: layout.isRegular ? 14 : 6,
              right: layout.isRegular ? 14 : 6,
              top: top.clamp(6.0, double.infinity).toDouble(),
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: _MoveCommitOverlay<T>(
                    key: ValueKey<int>(visual.sequence),
                    visual: visual,
                    theme: resolvedTheme,
                    layout: layout,
                  ),
                ),
              ),
            );
          },
        ),
        if (_pendingUndo != null && widget.showBuiltInUndo)
          Positioned(
            left: 8,
            right: 8,
            bottom: math.max(8.0, safeBottom).toDouble(),
            child: _UndoBar(
              message: _pendingUndo!.message,
              theme: resolvedTheme,
              layout: layout,
              onUndo: () => unawaited(
                _DayTimelineUndo<T>(this)._handleUndo(),
              ),
              onDismiss: () => _DayTimelineUndo<T>(this)._dismissUndo(),
            ),
          ),
      ],
    );

    final timelineBody = contentFit
        ? timelineStack
        : Expanded(child: timelineStack);
    final shadowBlur = layout.isRegular ? 34.0 : layout.isCompact ? 8.0 : 4.0;
    final shadowOffset = layout.isRegular
        ? const Offset(0, 14)
        : layout.isCompact
        ? const Offset(0, 3)
        : const Offset(0, 2);
    final sectionGap = layout.isRegular ? 22.0 : layout.isCompact ? 6.0 : 5.0;
    final grabberGap = layout.isRegular ? 20.0 : layout.isCompact ? 5.0 : 4.0;
    final grabberWidth =
        layout.isRegular ? 54.0 : layout.isCompact ? 36.0 : 32.0;
    final grabberHeight = layout.isRegular ? 6.0 : layout.isCompact ? 2.5 : 2.0;

    final surface = DecoratedBox(
      key: const ValueKey<String>('neon-day-timeline-surface'),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? resolvedTheme.surfaceColor,
        borderRadius: BorderRadius.circular(layout.borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: resolvedTheme.shadowColor.withValues(
              alpha: layout.isRegular ? 0.55 : 0.16,
            ),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(layout.borderRadius),
        child: Padding(
          padding: layout.surfacePadding,
          child: Column(
            mainAxisSize: contentFit ? MainAxisSize.min : MainAxisSize.max,
            children: <Widget>[
              if (widget.showGrabber) ...<Widget>[
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: resolvedTheme.secondaryTextColor.withValues(
                        alpha: 0.36,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: SizedBox(
                      width: grabberWidth,
                      height: grabberHeight,
                    ),
                  ),
                ),
                SizedBox(height: grabberGap),
              ],
              if (widget.showHeader) ...<Widget>[
                _DayHeader(
                  label: widget.dateLabelBuilder?.call(widget.selectedDate) ??
                      _germanDate(widget.selectedDate),
                  theme: resolvedTheme,
                  onBack: widget.onBack,
                  onCalendarTap: widget.onCalendarTap,
                  onMoreTap: widget.onMoreTap,
                  layout: layout,
                ),
                SizedBox(height: sectionGap),
              ],
              if (widget.showMetrics && resolvedMetrics.isNotEmpty) ...<Widget>[
                _MetricsStrip(
                  metrics: resolvedMetrics,
                  theme: resolvedTheme,
                  layout: layout,
                ),
                SizedBox(height: sectionGap),
              ],
              timelineBody,
            ],
          ),
        ),
      ),
    );

    return NeonPlannerTimelineTheme(
      data: resolvedTheme,
      child: contentFit
          ? Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : null,
                child: surface,
              ),
            )
          : surface,
    );
  }

  List<NeonPlannerEntrySnapshot<T>> _snapshotsForDay() {
    final snapshots = widget.entries
        .map(widget.adapter.snapshotOf)
        .where(
          (snapshot) =>
              snapshot.end.isAfter(_dayStart) &&
              snapshot.start.isBefore(_dayEnd),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final start = a.start.compareTo(b.start);
        return start != 0 ? start : a.end.compareTo(b.end);
      });
    return snapshots;
  }

}

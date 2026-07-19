import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';

import '../models/neon_schedule_entry.dart';
import '../models/neon_timeline_types.dart';
import '../performance/neon_timeline_performance_config.dart';
import '../theme/neon_schedule_timeline_style.dart';
import '../theme/neon_timeline_theme.dart';
import 'neon_slidable_timeline.dart';
import 'neon_timeline_card.dart';
import 'neon_timeline_connector.dart';
import 'neon_timeline_indicator.dart';
import 'neon_timeline_motion.dart';

/// Builds slide actions for one scheduled entry.
typedef NeonScheduleActionsBuilder<T> =
    List<NeonTimelineAction> Function(
      BuildContext context,
      NeonScheduleEntryDetails<T> details,
    );

/// Receives a guarded asynchronous schedule-operation failure.
typedef NeonScheduleOperationErrorCallback<T> =
    void Function(
      BuildContext context,
      NeonScheduleEntryDetails<T> details,
      Object error,
      StackTrace stackTrace,
    );

/// A planner-grade, generic schedule timeline.
///
/// Layout records are normalized once per input list and exposed through a
/// genuinely lazy [ListView.builder]. Entry builders, cards, slide actions,
/// and painters are therefore created only for visible rows rather than for
/// the complete day up front.
class NeonScheduleTimeline<T> extends StatefulWidget {
  /// Creates a schedule timeline.
  const NeonScheduleTimeline({
    required this.entries,
    required this.selectedDate,
    required this.itemBuilder,
    this.theme,
    this.style = const NeonScheduleTimelineStyle(),
    this.controller,
    this.physics = const BouncingScrollPhysics(),
    this.emptyBuilder,
    this.timeBuilder,
    this.indicatorBuilder,
    this.gapLabelBuilder,
    this.nowLabelBuilder,
    this.conflictLabelBuilder,
    this.startActionsBuilder,
    this.endActionsBuilder,
    this.onEntryTap,
    this.onEntryMoved,
    this.onEntryStartDismissed,
    this.onEntryEndDismissed,
    this.onOperationError,
    this.sortEntries = true,
    this.showNowIndicator = true,
    this.autoActivateCurrentEntry = true,
    this.useDefaultCard = true,
    this.enableDragHaptics = true,
    this.motionEnabled = true,
    this.motionPhaseOffset = 0,
    this.motionFramesPerSecond = 24,
    this.pauseMotionWhileScrolling = true,
    this.animateOnlyCurrentEntry = true,
    this.maxAnimatedEntries = 1,
    this.performance = const NeonTimelinePerformanceConfig.adaptive(),
    this.dataRevision,
    this.slidableMotion = NeonSlidableMotion.scroll,
    this.slidableGroupTag,
    this.closeSlidablesOnScroll = true,
    this.addAutomaticKeepAlives = false,
    this.cacheExtent,
    this.clipBehavior = Clip.none,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.now,
    super.key,
  }) : assert(motionPhaseOffset >= 0 && motionPhaseOffset <= 1),
       assert(motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
       assert(maxAnimatedEntries >= 0),
       assert(cacheExtent == null || cacheExtent >= 0);

  /// Application entries. They can arrive in any order when [sortEntries] is
  /// true. Treat this list as immutable and replace it when data changes.
  final List<NeonScheduleEntry<T>> entries;

  /// Day represented by the timeline.
  final DateTime selectedDate;

  /// Builds content placed inside the optional package card.
  final NeonScheduleEntryBuilder<T> itemBuilder;

  /// Optional local timeline theme.
  final NeonTimelineThemeData? theme;

  /// Schedule-specific geometry and interaction styling.
  final NeonScheduleTimelineStyle style;

  /// Optional external scroll controller.
  final ScrollController? controller;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Optional empty-state builder.
  final WidgetBuilder? emptyBuilder;

  /// Optional localized/custom time-label builder.
  final NeonScheduleTimeBuilder<T>? timeBuilder;

  /// Optional custom marker builder.
  final NeonScheduleIndicatorBuilder<T>? indicatorBuilder;

  /// Optional localized free-time label builder.
  final NeonScheduleGapLabelBuilder? gapLabelBuilder;

  /// Optional localized current-time marker label builder.
  final NeonScheduleNowLabelBuilder? nowLabelBuilder;

  /// Optional localized overlap label builder.
  final NeonScheduleConflictLabelBuilder<T>? conflictLabelBuilder;

  /// Optional logical-start slide actions.
  final NeonScheduleActionsBuilder<T>? startActionsBuilder;

  /// Optional logical-end slide actions.
  final NeonScheduleActionsBuilder<T>? endActionsBuilder;

  /// Optional activation callback.
  final NeonScheduleEntryCallback<T>? onEntryTap;

  /// Optional snapped and clamped reschedule callback.
  final NeonScheduleMoveCallback<T>? onEntryMoved;

  /// Optional full-swipe request from the logical start side.
  final NeonScheduleDismissCallback<T>? onEntryStartDismissed;

  /// Optional full-swipe request from the logical end side.
  final NeonScheduleDismissCallback<T>? onEntryEndDismissed;

  /// Optional guarded-operation error callback.
  final NeonScheduleOperationErrorCallback<T>? onOperationError;

  /// Whether entries are sorted by [NeonScheduleEntry.start].
  final bool sortEntries;

  /// Whether the current-time marker is rendered on the selected day.
  final bool showNowIndicator;

  /// Whether a pending entry containing the current time is painted active.
  final bool autoActivateCurrentEntry;

  /// Whether [itemBuilder] output is wrapped in [NeonTimelineCard].
  final bool useDefaultCard;

  /// Whether drag snapping emits selection and impact haptics.
  final bool enableDragHaptics;

  /// Whether advanced painters share an active motion clock.
  final bool motionEnabled;

  /// Normalized shared motion phase offset.
  final double motionPhaseOffset;

  /// Maximum expensive painter updates per second.
  final int motionFramesPerSecond;

  /// Whether painter motion pauses while the list is scrolling.
  final bool pauseMotionWhileScrolling;

  /// Whether only the current/active entry card follows the motion clock.
  ///
  /// The visual card style is unchanged for inactive entries; only continuous
  /// repainting is disabled.
  final bool animateOnlyCurrentEntry;

  /// Maximum number of schedule rows allowed to repaint continuously.
  ///
  /// Active rows beyond this limit keep the same active colors and advanced
  /// surface, but remain on a still animation phase. `1` is the production
  /// default because one card, indicator, and connector already form a rich
  /// animated focal point.
  final int maxAnimatedEntries;

  /// Optional adaptive rendering policy. Pass null to use only the legacy
  /// motion and style fields above.
  final NeonTimelinePerformanceConfig? performance;

  /// Optional application-owned revision used to skip O(n) identity checks.
  /// Increment it whenever entry order, time, duration, status, or ids change.
  final Object? dataRevision;

  /// Slide action-pane motion.
  final NeonSlidableMotion slidableMotion;

  /// Optional auto-close group tag forwarded to slidable rows.
  final Object? slidableGroupTag;

  /// Whether list scrolling closes open action panes.
  final bool closeSlidablesOnScroll;

  /// Whether offscreen row states are retained by the lazy list.
  final bool addAutomaticKeepAlives;

  /// Optional viewport cache extent in logical pixels.
  final double? cacheExtent;

  /// List clipping behavior.
  final Clip clipBehavior;

  /// Keyboard dismissal behavior while scrolling.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Optional deterministic clock value for tests and screenshots.
  final DateTime? now;

  @override
  State<NeonScheduleTimeline<T>> createState() =>
      _NeonScheduleTimelineState<T>();
}

class _NeonScheduleTimelineState<T> extends State<NeonScheduleTimeline<T>> {
  ScrollController? _internalController;
  Timer? _clock;
  DateTime _now = DateTime.now();
  _SchedulePlan<T>? _cachedPlan;
  List<NeonScheduleEntry<T>>? _cachedEntrySnapshot;
  int? _cachedEntryCount;
  DateTime? _cachedSelectedDate;
  bool? _cachedSortEntries;
  Object? _cachedDataRevision;

  ScrollController get _controller =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _now = _clockForDay(widget.now ?? DateTime.now(), widget.selectedDate);
    _configureClock();
  }

  @override
  void didUpdateWidget(covariant NeonScheduleTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final revisionDriven =
        oldWidget.dataRevision != null || widget.dataRevision != null;
    final entriesChanged = revisionDriven
        ? oldWidget.dataRevision != widget.dataRevision ||
              oldWidget.entries.length != widget.entries.length
        : !_sameEntryObjects(oldWidget.entries, widget.entries);
    if (entriesChanged ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.sortEntries != widget.sortEntries) {
      _invalidatePlan();
    }
    if (oldWidget.now != widget.now ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.showNowIndicator != widget.showNowIndicator ||
        oldWidget.autoActivateCurrentEntry != widget.autoActivateCurrentEntry) {
      _now = _clockForDay(widget.now ?? DateTime.now(), widget.selectedDate);
      _configureClock();
    }
    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    }
  }

  void _invalidatePlan() {
    _cachedPlan = null;
    _cachedEntrySnapshot = null;
    _cachedEntryCount = null;
    _cachedSelectedDate = null;
    _cachedSortEntries = null;
    _cachedDataRevision = null;
  }

  void _configureClock() {
    _clock?.cancel();
    final needsLiveClock =
        widget.showNowIndicator || widget.autoActivateCurrentEntry;
    if (!needsLiveClock || widget.now != null) return;

    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    final delay = nextMinute.difference(now) + const Duration(milliseconds: 8);
    _clock = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _now = _clockForDay(DateTime.now(), widget.selectedDate);
      });
      _configureClock();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = _resolvePlan();
    final resolvedPerformance = widget.performance?.resolve(
      context,
      itemCount: plan.entryCount,
    );
    final baseTheme = widget.theme ?? NeonTimelineTheme.of(context);
    final resolvedTheme =
        resolvedPerformance?.tuneTheme(baseTheme) ?? baseTheme;
    final resolvedStyle = resolvedPerformance == null
        ? widget.style
        : widget.style.copyWith(
            useBackdropFilter: resolvedPerformance.enableBackdropBlur,
            enableCardParallax: resolvedPerformance.enableParallax,
          );
    final animatedKeys = _resolveAnimatedKeys(
      plan,
      resolvedPerformance?.maxAnimatedEntries ?? widget.maxAnimatedEntries,
    );
    final resolvedCacheExtent = _resolvedCacheExtent(resolvedPerformance);

    Widget result;
    if (plan.entryCount == 0) {
      result = widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    } else {
      result = ListView.builder(
        scrollCacheExtent: resolvedCacheExtent == null
            ? null
            : ScrollCacheExtent.pixels(resolvedCacheExtent),
        controller: _controller,
        physics: widget.physics,
        padding: EdgeInsets.fromLTRB(
          resolvedStyle.horizontalPadding,
          resolvedStyle.topPadding,
          resolvedStyle.horizontalPadding,
          resolvedStyle.bottomPadding,
        ),
        itemCount: plan.nodes.length,
        itemBuilder: (context, index) => _buildNode(
          context,
          plan.nodes[index],
          resolvedTheme,
          resolvedStyle,
          animatedKeys,
        ),
        findChildIndexCallback: (key) => plan.indexByKey[key],
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
        clipBehavior: widget.clipBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
      );
    }

    return NeonTimelineTheme(
      data: resolvedTheme,
      child: NeonTimelineMotionScope(
        enabled: widget.motionEnabled && animatedKeys.isNotEmpty,
        duration: resolvedTheme.motionDuration,
        phaseOffset: widget.motionPhaseOffset,
        framesPerSecond:
            resolvedPerformance?.motionFramesPerSecond ??
            widget.motionFramesPerSecond,
        pauseWhenScrolling:
            resolvedPerformance?.pauseMotionWhileScrolling ??
            widget.pauseMotionWhileScrolling,
        startupDelay:
            resolvedPerformance?.motionStartupDelay ??
            const Duration(milliseconds: 120),
        child: result,
      ),
    );
  }

  double? _resolvedCacheExtent(NeonTimelineResolvedPerformance? performance) {
    final configured = widget.cacheExtent ?? performance?.cacheExtent;
    if (configured == null || !configured.isFinite) return null;
    return math.max(0.0, configured);
  }

  _SchedulePlan<T> _resolvePlan() {
    final revisionDriven = widget.dataRevision != null;
    final entriesUnchanged = revisionDriven
        ? _cachedDataRevision == widget.dataRevision &&
              _cachedEntryCount == widget.entries.length
        : _sameEntryObjects(_cachedEntrySnapshot, widget.entries);
    if (_cachedPlan != null &&
        entriesUnchanged &&
        _cachedSelectedDate == widget.selectedDate &&
        _cachedSortEntries == widget.sortEntries) {
      return _cachedPlan!;
    }
    final plan = _buildPlan();
    _cachedPlan = plan;
    _cachedEntrySnapshot = revisionDriven
        ? null
        : List<NeonScheduleEntry<T>>.of(widget.entries, growable: false);
    _cachedEntryCount = widget.entries.length;
    _cachedSelectedDate = widget.selectedDate;
    _cachedSortEntries = widget.sortEntries;
    _cachedDataRevision = widget.dataRevision;
    return plan;
  }

  bool _sameEntryObjects(
    List<NeonScheduleEntry<T>>? left,
    List<NeonScheduleEntry<T>> right,
  ) {
    if (left == null || left.length != right.length) return false;
    for (var index = 0; index < right.length; index++) {
      if (!identical(left[index], right[index])) return false;
    }
    return true;
  }

  _SchedulePlan<T> _buildPlan() {
    final dayStart = _startOfDay(widget.selectedDate);
    final dayEnd = _startOfNextDay(dayStart);
    final normalized = <_NormalizedScheduleEntry<T>>[];

    for (var index = 0; index < widget.entries.length; index++) {
      final entry = widget.entries[index];
      final duration = _positiveDuration(entry.duration);
      final end = entry.start.add(duration);
      if (entry.start.isBefore(dayEnd) && end.isAfter(dayStart)) {
        normalized.add(
          _NormalizedScheduleEntry<T>(
            entry: entry,
            duration: duration,
            end: end,
            originalIndex: index,
          ),
        );
      }
    }

    if (widget.sortEntries) {
      normalized.sort((a, b) {
        final byStart = a.entry.start.compareTo(b.entry.start);
        return byStart != 0
            ? byStart
            : a.originalIndex.compareTo(b.originalIndex);
      });
    }
    if (normalized.isEmpty) {
      return _SchedulePlan<T>(
        entryCount: 0,
        nodes: <_ScheduleNode<T>>[],
        indexByKey: <Key, int>{},
      );
    }

    final records = <_ScheduleRecord<T>>[];
    final idOccurrences = <Object, int>{};
    DateTime? occupiedEnd;
    for (var index = 0; index < normalized.length; index++) {
      final current = normalized[index];
      final previous = index == 0 ? null : normalized[index - 1].entry;
      final next = index == normalized.length - 1
          ? null
          : normalized[index + 1].entry;
      final previousOccupiedEnd = occupiedEnd;
      if (occupiedEnd == null || current.end.isAfter(occupiedEnd)) {
        occupiedEnd = current.end;
      }
      final occupiedThroughCurrent =
          previousOccupiedEnd == null ||
              current.end.isAfter(previousOccupiedEnd)
          ? current.end
          : previousOccupiedEnd;
      final displayStart = current.entry.start.isBefore(dayStart)
          ? dayStart
          : current.entry.start;
      final displayEnd = current.end.isAfter(dayEnd) ? dayEnd : current.end;
      final rawDisplayDuration = displayEnd.difference(displayStart);
      final displayDuration = rawDisplayDuration > Duration.zero
          ? rawDisplayDuration
          : const Duration(minutes: 1);
      final gapBefore =
          previousOccupiedEnd != null &&
              current.entry.start.isAfter(previousOccupiedEnd)
          ? current.entry.start.difference(previousOccupiedEnd)
          : null;
      final gapAfter =
          next != null && next.start.isAfter(occupiedThroughCurrent)
          ? next.start.difference(occupiedThroughCurrent)
          : null;

      final occurrence = idOccurrences.update(
        current.entry.id,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final rowKey = occurrence == 0
          ? ValueKey<Object>(current.entry.id)
          : ValueKey<_ScheduleEntryIdentity>(
              _ScheduleEntryIdentity(current.entry.id, occurrence),
            );

      records.add(
        _ScheduleRecord<T>(
          key: rowKey,
          entry: current.entry,
          index: index,
          itemCount: normalized.length,
          day: dayStart,
          displayStart: displayStart,
          displayDuration: displayDuration,
          occupiedThrough: occupiedThroughCurrent,
          previousEntry: previous,
          nextEntry: next,
          gapBefore: gapBefore,
          gapAfter: gapAfter,
          overlapsPrevious:
              previousOccupiedEnd != null &&
              current.entry.start.isBefore(previousOccupiedEnd),
          overlapsNext:
              next != null && next.start.isBefore(occupiedThroughCurrent),
          backToBackWithPrevious:
              previousOccupiedEnd != null &&
              current.entry.start.isAtSameMomentAs(previousOccupiedEnd),
          backToBackWithNext:
              next != null &&
              next.start.isAtSameMomentAs(occupiedThroughCurrent),
        ),
      );
    }

    final nodes = <_ScheduleNode<T>>[];
    final first = records.first;
    if (first.displayStart.isAfter(dayStart)) {
      nodes.add(
        _ScheduleGapNode<T>(
          key: const ValueKey<String>('neon_schedule_top_gap'),
          start: dayStart,
          duration: first.displayStart.difference(dayStart),
          showLabel: true,
        ),
      );
    }

    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      nodes.add(_ScheduleEntryNode<T>(record));
      if (index == records.length - 1) continue;

      final next = records[index + 1];
      final occupiedEndForDay = record.occupiedThrough.isAfter(dayEnd)
          ? dayEnd
          : record.occupiedThrough;
      final gap = next.displayStart.difference(occupiedEndForDay);
      if (gap > Duration.zero) {
        nodes.add(
          _ScheduleGapNode<T>(
            key: ValueKey<String>('neon_schedule_gap_$index'),
            start: occupiedEndForDay,
            duration: gap,
            showLabel: true,
          ),
        );
      } else if (next.entry.start.isBefore(record.occupiedThrough)) {
        nodes.add(
          _ScheduleConflictNode<T>(
            key: ValueKey<String>('neon_schedule_conflict_$index'),
          ),
        );
      }
    }

    final finalOccupiedEnd = records.last.occupiedThrough.isAfter(dayEnd)
        ? dayEnd
        : records.last.occupiedThrough;
    if (finalOccupiedEnd.isBefore(dayEnd)) {
      nodes.add(
        _ScheduleGapNode<T>(
          key: const ValueKey<String>('neon_schedule_bottom_now_gap'),
          start: finalOccupiedEnd,
          duration: dayEnd.difference(finalOccupiedEnd),
          showLabel: false,
          onlyWhenContainsNow: true,
        ),
      );
    }

    return _SchedulePlan<T>(
      entryCount: records.length,
      nodes: nodes,
      indexByKey: <Key, int>{
        for (var index = 0; index < nodes.length; index++)
          nodes[index].key: index,
      },
    );
  }

  Set<Key> _resolveAnimatedKeys(_SchedulePlan<T> plan, int requestedLimit) {
    final limit = requestedLimit.clamp(0, 1000).toInt();
    if (!widget.motionEnabled || limit == 0) return const <Key>{};

    final current = <Key>[];
    final active = <Key>[];
    for (final node in plan.nodes) {
      if (node is! _ScheduleEntryNode<T>) continue;
      final details = node.record.detailsAt(_now);
      if (details.isCurrent) {
        current.add(node.key);
      } else if (details.entry.status == NeonTimelineStatus.active) {
        active.add(node.key);
      }
    }

    final selected = <Key>{};
    for (final key in <Key>[...current, ...active]) {
      selected.add(key);
      if (selected.length >= limit) break;
    }
    return selected;
  }

  Widget _buildNode(
    BuildContext context,
    _ScheduleNode<T> node,
    NeonTimelineThemeData theme,
    NeonScheduleTimelineStyle style,
    Set<Key> animatedKeys,
  ) {
    if (node is _ScheduleEntryNode<T>) {
      final details = node.record.detailsAt(_now);
      final status = _resolvedStatus(details);
      return _ScheduleEntryRow<T>(
        key: node.key,
        details: details,
        style: style,
        theme: theme,
        scrollController: _controller,
        content: widget.itemBuilder(context, details),
        time: widget.timeBuilder?.call(context, details),
        indicator: widget.indicatorBuilder?.call(context, details),
        startActions:
            widget.startActionsBuilder?.call(context, details) ??
            const <NeonTimelineAction>[],
        endActions:
            widget.endActionsBuilder?.call(context, details) ??
            const <NeonTimelineAction>[],
        onTap: widget.onEntryTap == null
            ? null
            : () => widget.onEntryTap!(context, details),
        onMoved: widget.onEntryMoved == null
            ? null
            : (newStart) => widget.onEntryMoved!(context, details, newStart),
        onStartDismissed: widget.onEntryStartDismissed == null
            ? null
            : () => widget.onEntryStartDismissed!(context, details),
        onEndDismissed: widget.onEntryEndDismissed == null
            ? null
            : () => widget.onEntryEndDismissed!(context, details),
        onOperationError: widget.onOperationError == null
            ? null
            : (error, stackTrace) =>
                  widget.onOperationError!(context, details, error, stackTrace),
        autoActivateCurrent: widget.autoActivateCurrentEntry,
        useDefaultCard: widget.useDefaultCard,
        animateEffects:
            animatedKeys.contains(node.key) &&
            (!widget.animateOnlyCurrentEntry ||
                details.isCurrent ||
                status == NeonTimelineStatus.active),
        enableHaptics: widget.enableDragHaptics,
        slidableMotion: widget.slidableMotion,
        slidableGroupTag: widget.slidableGroupTag,
        closeSlidablesOnScroll: widget.closeSlidablesOnScroll,
        conflictLabelBuilder: widget.conflictLabelBuilder,
      );
    }

    if (node is _ScheduleGapNode<T>) {
      final showNow =
          widget.showNowIndicator &&
          _sameDay(_now, widget.selectedDate) &&
          !_now.isBefore(node.start) &&
          _now.isBefore(node.start.add(node.duration));
      if (node.onlyWhenContainsNow && !showNow) {
        return const SizedBox.shrink();
      }
      return _ScheduleGap(
        key: node.key,
        start: node.start,
        duration: node.duration,
        containsNow: showNow,
        now: _now,
        style: style,
        theme: theme,
        label: node.showLabel ? _gapLabel(context, node.duration) : null,
        nowLabel: _nowLabel(context),
      );
    }

    return _ScheduleConflictBridge(
      key: (node as _ScheduleConflictNode<T>).key,
      style: style,
    );
  }

  NeonTimelineStatus _resolvedStatus(NeonScheduleEntryDetails<T> details) {
    if (!details.entry.enabled) return NeonTimelineStatus.disabled;
    if (widget.autoActivateCurrentEntry &&
        details.isCurrent &&
        details.entry.status == NeonTimelineStatus.pending) {
      return NeonTimelineStatus.active;
    }
    return details.entry.status;
  }

  String? _gapLabel(BuildContext context, Duration gap) {
    if (!widget.style.showGapLabels) return null;
    return widget.gapLabelBuilder?.call(context, gap) ?? _defaultGapLabel(gap);
  }

  String _nowLabel(BuildContext context) {
    return widget.nowLabelBuilder?.call(context, _now) ??
        'NOW ${_formatTime(_now)}';
  }
}

class _SchedulePlan<T> {
  const _SchedulePlan({
    required this.entryCount,
    required this.nodes,
    required this.indexByKey,
  });

  final int entryCount;
  final List<_ScheduleNode<T>> nodes;
  final Map<Key, int> indexByKey;
}

class _NormalizedScheduleEntry<T> {
  const _NormalizedScheduleEntry({
    required this.entry,
    required this.duration,
    required this.end,
    required this.originalIndex,
  });

  final NeonScheduleEntry<T> entry;
  final Duration duration;
  final DateTime end;
  final int originalIndex;
}

class _ScheduleEntryIdentity {
  const _ScheduleEntryIdentity(this.id, this.occurrence);

  final Object id;
  final int occurrence;

  @override
  bool operator ==(Object other) {
    return other is _ScheduleEntryIdentity &&
        other.id == id &&
        other.occurrence == occurrence;
  }

  @override
  int get hashCode => Object.hash(id, occurrence);
}

class _ScheduleRecord<T> {
  const _ScheduleRecord({
    required this.key,
    required this.entry,
    required this.index,
    required this.itemCount,
    required this.day,
    required this.displayStart,
    required this.displayDuration,
    required this.occupiedThrough,
    required this.previousEntry,
    required this.nextEntry,
    required this.gapBefore,
    required this.gapAfter,
    required this.overlapsPrevious,
    required this.overlapsNext,
    required this.backToBackWithPrevious,
    required this.backToBackWithNext,
  });

  final Key key;
  final NeonScheduleEntry<T> entry;
  final int index;
  final int itemCount;
  final DateTime day;
  final DateTime displayStart;
  final Duration displayDuration;
  final DateTime occupiedThrough;
  final NeonScheduleEntry<T>? previousEntry;
  final NeonScheduleEntry<T>? nextEntry;
  final Duration? gapBefore;
  final Duration? gapAfter;
  final bool overlapsPrevious;
  final bool overlapsNext;
  final bool backToBackWithPrevious;
  final bool backToBackWithNext;

  NeonScheduleEntryDetails<T> detailsAt(DateTime now) {
    final entryEnd = entry.start.add(_positiveDuration(entry.duration));
    return NeonScheduleEntryDetails<T>(
      entry: entry,
      index: index,
      itemCount: itemCount,
      day: day,
      displayStart: displayStart,
      displayDuration: displayDuration,
      previousEntry: previousEntry,
      nextEntry: nextEntry,
      gapBefore: gapBefore,
      gapAfter: gapAfter,
      isCurrent: !now.isBefore(entry.start) && now.isBefore(entryEnd),
      overlapsPrevious: overlapsPrevious,
      overlapsNext: overlapsNext,
      backToBackWithPrevious: backToBackWithPrevious,
      backToBackWithNext: backToBackWithNext,
    );
  }
}

sealed class _ScheduleNode<T> {
  const _ScheduleNode();

  Key get key;
}

class _ScheduleEntryNode<T> extends _ScheduleNode<T> {
  const _ScheduleEntryNode(this.record);

  final _ScheduleRecord<T> record;

  @override
  Key get key => record.key;
}

class _ScheduleGapNode<T> extends _ScheduleNode<T> {
  const _ScheduleGapNode({
    required this.key,
    required this.start,
    required this.duration,
    required this.showLabel,
    this.onlyWhenContainsNow = false,
  });

  @override
  final Key key;
  final DateTime start;
  final Duration duration;
  final bool showLabel;
  final bool onlyWhenContainsNow;
}

class _ScheduleConflictNode<T> extends _ScheduleNode<T> {
  const _ScheduleConflictNode({required this.key});

  @override
  final Key key;
}

class _ScheduleEntryRow<T> extends StatefulWidget {
  const _ScheduleEntryRow({
    required this.details,
    required this.style,
    required this.theme,
    required this.scrollController,
    required this.content,
    required this.startActions,
    required this.endActions,
    required this.autoActivateCurrent,
    required this.useDefaultCard,
    required this.animateEffects,
    required this.enableHaptics,
    required this.slidableMotion,
    required this.closeSlidablesOnScroll,
    this.time,
    this.indicator,
    this.conflictLabelBuilder,
    this.onTap,
    this.onMoved,
    this.onStartDismissed,
    this.onEndDismissed,
    this.onOperationError,
    this.slidableGroupTag,
    super.key,
  });

  final NeonScheduleEntryDetails<T> details;
  final NeonScheduleTimelineStyle style;
  final NeonTimelineThemeData theme;
  final ScrollController scrollController;
  final Widget content;
  final Widget? time;
  final Widget? indicator;
  final NeonScheduleConflictLabelBuilder<T>? conflictLabelBuilder;
  final List<NeonTimelineAction> startActions;
  final List<NeonTimelineAction> endActions;
  final VoidCallback? onTap;
  final FutureOr<void> Function(DateTime newStart)? onMoved;
  final NeonTimelineDismissCallback? onStartDismissed;
  final NeonTimelineDismissCallback? onEndDismissed;
  final void Function(Object error, StackTrace stackTrace)? onOperationError;
  final bool autoActivateCurrent;
  final bool useDefaultCard;
  final bool animateEffects;
  final bool enableHaptics;
  final NeonSlidableMotion slidableMotion;
  final Object? slidableGroupTag;
  final bool closeSlidablesOnScroll;

  @override
  State<_ScheduleEntryRow<T>> createState() => _ScheduleEntryRowState<T>();
}

class _ScheduleEntryRowState<T> extends State<_ScheduleEntryRow<T>> {
  bool _dragging = false;
  bool _committing = false;
  double _dragOffset = 0;
  double _initialGlobalY = 0;
  double _initialScrollOffset = 0;
  int _dragMinutes = 0;
  final Stopwatch _autoScrollThrottle = Stopwatch();
  double _viewportTop = 0;
  double _viewportBottom = 0;

  bool get _canMove => widget.details.entry.draggable && widget.onMoved != null;

  void _emitHaptic(Future<void> Function() effect) {
    if (!widget.enableHaptics) return;
    unawaited(effect().catchError((Object _, StackTrace __) {}));
  }

  ScrollPosition? get _scrollPosition {
    final positions = widget.scrollController.positions;
    return positions.length == 1 ? positions.single : null;
  }

  NeonTimelineStatus get _status {
    if (!widget.details.entry.enabled) return NeonTimelineStatus.disabled;
    if (widget.autoActivateCurrent &&
        widget.details.isCurrent &&
        widget.details.entry.status == NeonTimelineStatus.pending) {
      return NeonTimelineStatus.active;
    }
    return widget.details.entry.status;
  }

  void _startDrag(LongPressStartDetails details) {
    if (!_canMove || _committing) return;
    _captureViewportBounds();
    _autoScrollThrottle
      ..reset()
      ..start();
    _emitHaptic(HapticFeedback.heavyImpact);
    setState(() {
      _dragging = true;
      _initialGlobalY = details.globalPosition.dy;
      _initialScrollOffset = _scrollPosition?.pixels ?? 0;
      _dragOffset = 0;
      _dragMinutes = 0;
    });
  }

  void _updateDrag(LongPressMoveUpdateDetails details) {
    if (!_dragging) return;
    _autoScroll(details.globalPosition.dy);
    final scrollDelta =
        (_scrollPosition?.pixels ?? _initialScrollOffset) -
        _initialScrollOffset;
    final rawOffset = details.globalPosition.dy - _initialGlobalY + scrollDelta;
    final pixelsPerMinute = widget.style.resolvedPixelsPerMinute;
    final snapMinutes = widget.style.resolvedSnapMinutes;
    final rawMinutes = rawOffset / pixelsPerMinute;
    final snapped = (rawMinutes / snapMinutes).round() * snapMinutes;
    final clamped = _clampMinutes(snapped);
    if (clamped == _dragMinutes) return;

    setState(() {
      _dragMinutes = clamped;
      _dragOffset = clamped * pixelsPerMinute;
    });
    _emitHaptic(HapticFeedback.selectionClick);
  }

  Future<void> _endDrag(LongPressEndDetails details) async {
    if (!_dragging) return;
    _autoScrollThrottle.stop();
    final movedMinutes = _dragMinutes;
    if (movedMinutes == 0) {
      setState(() {
        _dragging = false;
        _dragOffset = 0;
        _dragMinutes = 0;
      });
      return;
    }

    setState(() {
      _dragging = false;
      _committing = true;
    });
    _emitHaptic(HapticFeedback.mediumImpact);
    final newStart = widget.details.entry.start.add(
      Duration(minutes: movedMinutes),
    );
    try {
      await Future<void>.sync(() => widget.onMoved!(newStart));
    } catch (error, stackTrace) {
      _reportOperationError(error, stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _committing = false;
          _dragOffset = 0;
          _dragMinutes = 0;
        });
      }
    }
  }

  void _cancelDrag() {
    if (!_dragging) return;
    _autoScrollThrottle.stop();
    setState(() {
      _dragging = false;
      _dragOffset = 0;
      _dragMinutes = 0;
    });
  }

  int _clampMinutes(int minutes) {
    if (!widget.style.keepEntriesInsideDay) return minutes;
    final dayStart = _startOfDay(widget.details.day);
    final dayEnd = _startOfNextDay(dayStart);
    final duration = _positiveDuration(widget.details.entry.duration);
    final unclampedLatestStart = dayEnd.subtract(duration);
    final latestStart = unclampedLatestStart.isBefore(dayStart)
        ? dayStart
        : unclampedLatestStart;
    final projected = widget.details.entry.start.add(
      Duration(minutes: minutes),
    );
    if (projected.isBefore(dayStart)) {
      return dayStart.difference(widget.details.entry.start).inMinutes;
    }
    if (projected.isAfter(latestStart)) {
      return latestStart.difference(widget.details.entry.start).inMinutes;
    }
    return minutes;
  }

  void _captureViewportBounds() {
    _viewportTop = 0;
    _viewportBottom = MediaQuery.sizeOf(context).height;
    final scrollable = Scrollable.maybeOf(context);
    final renderObject = scrollable?.context.findRenderObject();
    if (renderObject is RenderBox && renderObject.attached) {
      _viewportTop = renderObject.localToGlobal(Offset.zero).dy;
      _viewportBottom = _viewportTop + renderObject.size.height;
    }
  }

  void _autoScroll(double globalY) {
    final position = _scrollPosition;
    if (position == null || widget.style.resolvedAutoScrollEdge <= 0) {
      return;
    }
    if (_autoScrollThrottle.elapsedMicroseconds < 24000) return;
    _autoScrollThrottle.reset();
    if (!position.hasContentDimensions) return;

    final edge = math.min(
      widget.style.resolvedAutoScrollEdge,
      math.max(1.0, (_viewportBottom - _viewportTop) / 2),
    );
    var delta = 0.0;
    if (globalY < _viewportTop + edge) {
      delta =
          -widget.style.resolvedAutoScrollStep *
          ((_viewportTop + edge - globalY) / edge).clamp(0.15, 1.0);
    } else if (globalY > _viewportBottom - edge) {
      delta =
          widget.style.resolvedAutoScrollStep *
          ((globalY - (_viewportBottom - edge)) / edge).clamp(0.15, 1.0);
    }
    if (delta == 0) return;

    final target = (position.pixels + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (target != position.pixels) position.jumpTo(target);
  }

  void _reportOperationError(Object error, StackTrace stackTrace) {
    final handler = widget.onOperationError;
    if (handler != null) {
      try {
        handler(error, stackTrace);
        return;
      } catch (handlerError, handlerStackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: handlerError,
            stack: handlerStackTrace,
            library: 'neon_timeline_flutter',
            context: ErrorDescription('while reporting a schedule error'),
            informationCollector: () sync* {
              yield ErrorDescription('Original error: $error');
            },
          ),
        );
        return;
      }
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'neon_timeline_flutter',
        context: ErrorDescription('while committing a schedule operation'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final details = widget.details;
    final extent = style.extentFor(details.displayDuration);
    final accent = details.entry.color ?? widget.theme.colorForStatus(_status);
    final overlap = details.overlapsPrevious || details.overlapsNext;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final transition = style.animateLayout && !reduceMotion
        ? const Duration(milliseconds: 220)
        : Duration.zero;

    Widget card = widget.useDefaultCard
        ? NeonTimelineCard(
            variant: style.cardVariant,
            accentColor: accent,
            secondaryAccentColor: widget.theme.secondaryColor,
            borderRadius: style.cardBorderRadius,
            padding: style.cardPadding,
            blurSigma: style.resolvedCardBlurSigma,
            useBackdropFilter: style.useBackdropFilter,
            enableParallax: style.enableCardParallax,
            onTap: details.entry.enabled && !_dragging && !_committing
                ? widget.onTap
                : null,
            semanticLabel: details.entry.semanticLabel,
            animate: widget.animateEffects,
            continuousAnimation: widget.animateEffects,
            child: widget.content,
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: details.entry.enabled && !_dragging && !_committing
                ? widget.onTap
                : null,
            child: widget.content,
          );

    if (widget.startActions.isNotEmpty || widget.endActions.isNotEmpty) {
      card = NeonSlidableTimeline(
        slidableKey: widget.key ?? ValueKey<Object>(details.entry.id),
        startActions: widget.startActions,
        endActions: widget.endActions,
        motion: widget.slidableMotion,
        groupTag: widget.slidableGroupTag,
        closeOnScroll: widget.closeSlidablesOnScroll,
        borderRadius: style.cardBorderRadius,
        enabled: !_dragging && !_committing && details.entry.enabled,
        onStartDismissed: widget.onStartDismissed,
        onEndDismissed: widget.onEndDismissed,
        onError: _reportOperationError,
        child: card,
      );
    }

    final defaultIndicator = NeonTimelineIndicator(
      status: _status,
      animate: widget.animateEffects,
      semanticLabel: details.entry.semanticLabel,
    );

    Widget row = AnimatedContainer(
      duration: transition,
      curve: Curves.easeOutCubic,
      height: extent,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: style.timeColumnWidth,
            top: widget.theme.indicatorStyle.visualExtent * 0.5,
            bottom: 0,
            width: style.railLaneExtent,
            child: style.showDurationRail
                ? NeonTimelineConnector(
                    style: widget.theme.connectorStyle.copyWith(
                      color: accent,
                      endColor: accent.withValues(alpha: 0.18),
                      animated: widget.animateEffects,
                      phaseOffset: (details.index * 0.173) % 1,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            left: 0,
            top: 8,
            width: style.timeColumnWidth,
            child: widget.time ?? _DefaultTimeLabel(details: details),
          ),
          if (extent >= 104)
            Positioned(
              left: 0,
              bottom: 6,
              width: style.timeColumnWidth,
              child: Text(
                _formatTime(details.displayEnd),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.48),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Positioned(
            left: style.timeColumnWidth,
            top: 0,
            width: style.railLaneExtent,
            child: Center(child: widget.indicator ?? defaultIndicator),
          ),
          Positioned(
            left:
                style.timeColumnWidth +
                style.railLaneExtent +
                style.contentGap +
                (overlap ? style.overlapIndent : 0),
            right: 0,
            top: 0,
            child: card,
          ),
          if (overlap)
            Positioned(
              left: style.timeColumnWidth + style.railLaneExtent + 2,
              top: 8,
              child: _ConflictPill(
                color: style.conflictColor,
                label:
                    widget.conflictLabelBuilder?.call(context, details) ??
                    'Conflict',
              ),
            ),
          if (_dragging)
            Positioned(
              left: 0,
              top: 34,
              width: style.timeColumnWidth,
              child: _DragTimeBadge(
                time: details.entry.start.add(Duration(minutes: _dragMinutes)),
                color: accent,
              ),
            ),
          if (_committing)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    row = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: _canMove ? _startDrag : null,
      onLongPressMoveUpdate: _canMove ? _updateDrag : null,
      onLongPressEnd: _canMove ? _endDrag : null,
      onLongPressCancel: _canMove ? _cancelDrag : null,
      child: AnimatedOpacity(
        duration: transition,
        opacity: _dragging ? style.resolvedDragOpacity : 1,
        child: AnimatedScale(
          duration: transition,
          curve: Curves.easeOutCubic,
          scale: _dragging ? style.resolvedDragScale : 1,
          child: row,
        ),
      ),
    );

    return Transform.translate(
      offset: Offset(0, _dragOffset),
      child: Semantics(
        container: true,
        enabled: details.entry.enabled,
        label:
            details.entry.semanticLabel ??
            '${_formatTime(details.displayStart)}, '
                '${details.entry.status.name}, '
                'item ${details.index + 1} of ${details.itemCount}',
        child: RepaintBoundary(child: row),
      ),
    );
  }
}

class _DefaultTimeLabel<T> extends StatelessWidget {
  const _DefaultTimeLabel({required this.details});

  final NeonScheduleEntryDetails<T> details;

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(details.displayStart),
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _ScheduleGap extends StatelessWidget {
  const _ScheduleGap({
    required this.start,
    required this.duration,
    required this.containsNow,
    required this.now,
    required this.style,
    required this.theme,
    required this.nowLabel,
    this.label,
    super.key,
  });

  final DateTime start;
  final Duration duration;
  final bool containsNow;
  final DateTime now;
  final NeonScheduleTimelineStyle style;
  final NeonTimelineThemeData theme;
  final String nowLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final height = style.gapExtentFor(duration);
    if (height <= 0) return const SizedBox.shrink();
    final fraction = duration.inMilliseconds <= 0
        ? 0.5
        : now.difference(start).inMilliseconds / duration.inMilliseconds;
    final availableMarkerTravel = math.max(0.0, height - 24);
    final nowTop = (fraction.clamp(0.0, 1.0) * availableMarkerTravel)
        .toDouble();

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: style.timeColumnWidth,
            top: 0,
            bottom: 0,
            width: style.railLaneExtent,
            child: NeonTimelineConnector(
              style: theme.connectorStyle.copyWith(
                effect: NeonConnectorEffect.classic,
                variant: NeonConnectorVariant.dashed,
                color: theme.pendingColor.withValues(alpha: 0.35),
                endColor: theme.pendingColor.withValues(alpha: 0.12),
                thickness: 1.4,
                glowRadius: 0,
                animated: false,
              ),
            ),
          ),
          if (label != null && height >= 42)
            Positioned(
              left:
                  style.timeColumnWidth +
                  style.railLaneExtent +
                  style.contentGap,
              top: height / 2 - 10,
              child: _GapPill(label: label!),
            ),
          if (containsNow)
            Positioned(
              left: style.timeColumnWidth + style.railLaneExtent / 2 - 4,
              right: 0,
              top: nowTop,
              child: _NowMarker(color: style.nowColor, label: nowLabel),
            ),
        ],
      ),
    );
  }
}

class _ScheduleConflictBridge extends StatelessWidget {
  const _ScheduleConflictBridge({required this.style, super.key});

  final NeonScheduleTimelineStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: style.timeColumnWidth + style.railLaneExtent / 2 - 1.5,
            top: -3,
            bottom: -3,
            width: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: style.conflictColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: style.conflictColor.withValues(alpha: 0.36),
                    blurRadius: 9,
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

class _NowMarker extends StatelessWidget {
  const _NowMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 12),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[color, color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _GapPill extends StatelessWidget {
  const _GapPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.07)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.45),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ConflictPill extends StatelessWidget {
  const _ConflictPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DragTimeBadge extends StatelessWidget {
  const _DragTimeBadge({required this.time, required this.color});

  final DateTime time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _formatTime(time),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Duration _positiveDuration(Duration duration) {
  return duration > Duration.zero ? duration : const Duration(minutes: 30);
}

DateTime _startOfDay(DateTime value) {
  return value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);
}

DateTime _startOfNextDay(DateTime value) {
  return value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + 1)
      : DateTime(value.year, value.month, value.day + 1);
}

DateTime _clockForDay(DateTime value, DateTime day) {
  return day.isUtc ? value.toUtc() : value.toLocal();
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _defaultGapLabel(Duration gap) {
  final totalMinutes = gap.inMinutes;
  if (totalMinutes < 60) return '$totalMinutes min free';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '$hours h free' : '$hours h $minutes min free';
}

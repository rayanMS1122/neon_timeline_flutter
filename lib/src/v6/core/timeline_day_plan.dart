import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_render_plan.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';

enum TimelineDayNodeKind {
  entry,
  gap,
  conflict,
  now,
  startBoundary,
  endBoundary,
}

@immutable
class TimelineDayEntry<T> {
  const TimelineDayEntry({
    required this.normalized,
    required this.index,
    required this.conflictType,
    this.previous,
    this.next,
    this.gapBefore,
    this.gapAfter,
  });

  final TimelineNormalizedEntry<T> normalized;
  final int index;
  final TimelineConflictType conflictType;
  final TimelineNormalizedEntry<T>? previous;
  final TimelineNormalizedEntry<T>? next;
  final Duration? gapBefore;
  final Duration? gapAfter;

  TimelineEntry<T> get entry => normalized.entry;
  DateTime get start => normalized.start;
  DateTime get end => normalized.end;
  Duration get duration => normalized.duration;
  bool get hasConflict => conflictType != TimelineConflictType.none;
  bool get isCurrent => normalized.isCurrent;
}

@immutable
class TimelineDayGap<T> {
  const TimelineDayGap({
    required this.start,
    required this.end,
    this.previous,
    this.next,
    this.containsNow = false,
  });

  final DateTime start;
  final DateTime end;
  final TimelineDayEntry<T>? previous;
  final TimelineDayEntry<T>? next;
  final bool containsNow;

  Duration get duration => end.difference(start);
}

@immutable
class TimelineDayConflict<T> {
  const TimelineDayConflict({
    required this.type,
    required this.entries,
    required this.start,
    required this.end,
  });

  final TimelineConflictType type;
  final List<TimelineDayEntry<T>> entries;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

@immutable
class TimelineDayNode<T> {
  const TimelineDayNode._({
    required this.kind,
    required this.start,
    required this.end,
    this.entry,
    this.gap,
    this.conflict,
  });

  factory TimelineDayNode.entry(TimelineDayEntry<T> value) {
    return TimelineDayNode<T>._(
      kind: TimelineDayNodeKind.entry,
      start: value.start,
      end: value.end,
      entry: value,
    );
  }

  factory TimelineDayNode.gap(TimelineDayGap<T> value) {
    return TimelineDayNode<T>._(
      kind: TimelineDayNodeKind.gap,
      start: value.start,
      end: value.end,
      gap: value,
    );
  }

  factory TimelineDayNode.conflict(TimelineDayConflict<T> value) {
    return TimelineDayNode<T>._(
      kind: TimelineDayNodeKind.conflict,
      start: value.start,
      end: value.end,
      conflict: value,
    );
  }

  factory TimelineDayNode.now(DateTime value) {
    return TimelineDayNode<T>._(
      kind: TimelineDayNodeKind.now,
      start: value,
      end: value,
    );
  }

  factory TimelineDayNode.boundary({
    required TimelineDayNodeKind kind,
    required DateTime value,
  }) {
    assert(
      kind == TimelineDayNodeKind.startBoundary ||
          kind == TimelineDayNodeKind.endBoundary,
    );
    return TimelineDayNode<T>._(kind: kind, start: value, end: value);
  }

  final TimelineDayNodeKind kind;
  final DateTime start;
  final DateTime end;
  final TimelineDayEntry<T>? entry;
  final TimelineDayGap<T>? gap;
  final TimelineDayConflict<T>? conflict;
}

@immutable
class TimelineDayInsight<T> {
  const TimelineDayInsight({
    required this.now,
    required this.currentEntries,
    this.previous,
    this.next,
    this.currentGap,
  });

  final DateTime now;
  final List<TimelineDayEntry<T>> currentEntries;
  final TimelineDayEntry<T>? previous;
  final TimelineDayEntry<T>? next;
  final TimelineDayGap<T>? currentGap;

  TimelineDayEntry<T>? get current =>
      currentEntries.isEmpty ? null : currentEntries.first;
  bool get isBusy => currentEntries.isNotEmpty;
  bool get isFree => !isBusy;
  Duration? get timeUntilNext => next == null || next!.start.isBefore(now)
      ? null
      : next!.start.difference(now);
  Duration? get timeRemainingCurrent {
    final value = current;
    if (value == null || !value.end.isAfter(now)) return null;
    return value.end.difference(now);
  }
}

@immutable
class TimelineDayPlan<T> {
  const TimelineDayPlan({
    required this.selectedDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.entries,
    required this.gaps,
    required this.conflicts,
    required this.nodes,
    required this.insight,
    required this.busyDuration,
    required this.freeDuration,
    required this.completedDuration,
    required this.renderPlan,
  });

  final DateTime selectedDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<TimelineDayEntry<T>> entries;
  final List<TimelineDayGap<T>> gaps;
  final List<TimelineDayConflict<T>> conflicts;
  final List<TimelineDayNode<T>> nodes;
  final TimelineDayInsight<T> insight;
  final Duration busyDuration;
  final Duration freeDuration;
  final Duration completedDuration;
  final TimelineRenderPlan<T> renderPlan;

  Duration get rangeDuration => rangeEnd.difference(rangeStart);
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get isEmpty => entries.isEmpty;
  double get utilization {
    final total = rangeDuration.inMicroseconds;
    if (total <= 0) return 0;
    return (busyDuration.inMicroseconds / total).clamp(0.0, 1.0).toDouble();
  }

  double get completionRatio {
    final busy = busyDuration.inMicroseconds;
    if (busy <= 0) return 0;
    return (completedDuration.inMicroseconds / busy).clamp(0.0, 1.0).toDouble();
  }

  TimelineDayGap<T>? gapAt(DateTime instant) {
    for (final gap in gaps) {
      if (!instant.isBefore(gap.start) && instant.isBefore(gap.end)) return gap;
    }
    return null;
  }
}

@immutable
class TimelineDayPlanConfig {
  const TimelineDayPlanConfig({
    this.minimumGap = const Duration(minutes: 1),
    this.includeBoundaryGaps = true,
    this.includeBoundaryNodes = true,
    this.includeNowNode = true,
    this.timeSemantics = TimelineTimeSemantics.preserveInput,
    this.minimumDuration = const Duration(minutes: 1),
    this.dayStartOffset = Duration.zero,
    this.dayEndOffset = const Duration(days: 1),
  });

  final Duration minimumGap;
  final bool includeBoundaryGaps;
  final bool includeBoundaryNodes;
  final bool includeNowNode;
  final TimelineTimeSemantics timeSemantics;
  final Duration minimumDuration;

  /// Offset from the selected calendar day's midnight.
  final Duration dayStartOffset;

  /// Exclusive offset from midnight. Values beyond 24 hours are allowed for
  /// night-shift planners.
  final Duration dayEndOffset;
}

class TimelineDayPlanBuilder {
  const TimelineDayPlanBuilder._();

  static void _validateConfig(TimelineDayPlanConfig config) {
    if (config.minimumGap < Duration.zero) {
      throw ArgumentError.value(
        config.minimumGap,
        'config.minimumGap',
        'must not be negative',
      );
    }
    if (config.minimumDuration <= Duration.zero) {
      throw ArgumentError.value(
        config.minimumDuration,
        'config.minimumDuration',
        'must be greater than zero',
      );
    }
    if (config.dayEndOffset <= config.dayStartOffset) {
      throw ArgumentError.value(
        config.dayEndOffset,
        'config.dayEndOffset',
        'must be after config.dayStartOffset',
      );
    }
  }

  static TimelineDayPlan<T> build<T>({
    required List<TimelineEntry<T>> entries,
    required DateTime selectedDate,
    DateTime? now,
    TimelineDayPlanConfig config = const TimelineDayPlanConfig(),
  }) {
    _validateConfig(config);
    final normalizedDate = _normalize(selectedDate, config.timeSemantics);
    final midnight = _startOfDay(normalizedDate);
    final rangeStart = _applyDayOffset(midnight, config.dayStartOffset);
    final rangeEnd = _applyDayOffset(midnight, config.dayEndOffset);
    final clock = _normalize(now ?? DateTime.now(), config.timeSemantics);

    final plan = TimelineRenderPlan<T>.build(
      entries: entries,
      selectedDate: null,
      now: clock,
      timeSemantics: config.timeSemantics,
      includeOutsideSelectedDay: false,
      clipToSelectedDay: false,
      minimumDuration: config.minimumDuration,
    );

    final inRange = plan.entries
        .where(
          (item) =>
              item.start.isBefore(rangeEnd) && item.end.isAfter(rangeStart),
        )
        .toList(growable: false);

    final dayEntries = <TimelineDayEntry<T>>[];
    for (var index = 0; index < inRange.length; index++) {
      final item = inRange[index];
      final previous = index == 0 ? null : inRange[index - 1];
      final next = index == inRange.length - 1 ? null : inRange[index + 1];
      final before = previous == null
          ? item.start.difference(rangeStart)
          : item.start.difference(previous.end);
      final after = next == null
          ? rangeEnd.difference(item.end)
          : next.start.difference(item.end);
      dayEntries.add(
        TimelineDayEntry<T>(
          normalized: item,
          index: index,
          conflictType: plan.conflictTypeFor(item.entry.id),
          previous: previous,
          next: next,
          gapBefore: before.isNegative ? Duration.zero : before,
          gapAfter: after.isNegative ? Duration.zero : after,
        ),
      );
    }

    final byNormalized = <TimelineNormalizedEntry<T>, TimelineDayEntry<T>>{
      for (final item in dayEntries) item.normalized: item,
    };
    final gaps = _buildGaps(
      entries: dayEntries,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      now: clock,
      config: config,
    );
    final conflicts = <TimelineDayConflict<T>>[];
    for (final conflict in plan.conflicts) {
      final members = conflict.entries
          .map((entry) => byNormalized[entry])
          .whereType<TimelineDayEntry<T>>()
          .toList(growable: false);
      if (members.isEmpty) continue;
      conflicts.add(
        TimelineDayConflict<T>(
          type: conflict.type,
          entries: List<TimelineDayEntry<T>>.unmodifiable(members),
          start: conflict.start.isBefore(rangeStart)
              ? rangeStart
              : conflict.start,
          end: conflict.end.isAfter(rangeEnd) ? rangeEnd : conflict.end,
        ),
      );
    }

    final current = dayEntries
        .where(
          (entry) => !clock.isBefore(entry.start) && clock.isBefore(entry.end),
        )
        .toList(growable: false);
    TimelineDayEntry<T>? previous;
    TimelineDayEntry<T>? next;
    for (final entry in dayEntries) {
      if (!entry.end.isAfter(clock)) previous = entry;
      if (next == null && !entry.start.isBefore(clock)) next = entry;
    }
    TimelineDayGap<T>? currentGap;
    for (final gap in gaps) {
      if (gap.containsNow) {
        currentGap = gap;
        break;
      }
    }

    final nodes = <TimelineDayNode<T>>[];
    if (config.includeBoundaryNodes) {
      nodes.add(
        TimelineDayNode<T>.boundary(
          kind: TimelineDayNodeKind.startBoundary,
          value: rangeStart,
        ),
      );
    }
    nodes.addAll(dayEntries.map(TimelineDayNode<T>.entry));
    nodes.addAll(gaps.map(TimelineDayNode<T>.gap));
    nodes.addAll(conflicts.map(TimelineDayNode<T>.conflict));
    if (config.includeNowNode &&
        !clock.isBefore(rangeStart) &&
        clock.isBefore(rangeEnd)) {
      nodes.add(TimelineDayNode<T>.now(clock));
    }
    if (config.includeBoundaryNodes) {
      nodes.add(
        TimelineDayNode<T>.boundary(
          kind: TimelineDayNodeKind.endBoundary,
          value: rangeEnd,
        ),
      );
    }
    nodes.sort(_compareNodes);

    final busy = _mergedDuration(dayEntries, rangeStart, rangeEnd);
    final total = rangeEnd.difference(rangeStart);
    final freeMicros = total.inMicroseconds - busy.inMicroseconds;
    final completed = _mergedDuration(
      dayEntries
          .where((entry) => entry.entry.status == TimelineStatus.completed)
          .toList(growable: false),
      rangeStart,
      rangeEnd,
    );

    return TimelineDayPlan<T>(
      selectedDate: normalizedDate,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      entries: List<TimelineDayEntry<T>>.unmodifiable(dayEntries),
      gaps: List<TimelineDayGap<T>>.unmodifiable(gaps),
      conflicts: List<TimelineDayConflict<T>>.unmodifiable(conflicts),
      nodes: List<TimelineDayNode<T>>.unmodifiable(nodes),
      insight: TimelineDayInsight<T>(
        now: clock,
        currentEntries: List<TimelineDayEntry<T>>.unmodifiable(current),
        previous: previous,
        next: next,
        currentGap: currentGap,
      ),
      busyDuration: busy,
      freeDuration: Duration(microseconds: freeMicros < 0 ? 0 : freeMicros),
      completedDuration: completed,
      renderPlan: plan,
    );
  }

  static List<TimelineDayGap<T>> _buildGaps<T>({
    required List<TimelineDayEntry<T>> entries,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required DateTime now,
    required TimelineDayPlanConfig config,
  }) {
    final gaps = <TimelineDayGap<T>>[];
    DateTime cursor = rangeStart;
    TimelineDayEntry<T>? previous;

    for (final entry in entries) {
      final clippedStart = entry.start.isBefore(rangeStart)
          ? rangeStart
          : entry.start;
      if (clippedStart.isAfter(cursor)) {
        final duration = clippedStart.difference(cursor);
        final isBoundary = previous == null;
        if (duration >= config.minimumGap &&
            (config.includeBoundaryGaps || !isBoundary)) {
          gaps.add(
            TimelineDayGap<T>(
              start: cursor,
              end: clippedStart,
              previous: previous,
              next: entry,
              containsNow: !now.isBefore(cursor) && now.isBefore(clippedStart),
            ),
          );
        }
      }
      if (entry.end.isAfter(cursor)) cursor = entry.end;
      if (cursor.isAfter(rangeEnd)) cursor = rangeEnd;
      previous = entry;
    }

    if (cursor.isBefore(rangeEnd) && config.includeBoundaryGaps) {
      final duration = rangeEnd.difference(cursor);
      if (duration >= config.minimumGap) {
        gaps.add(
          TimelineDayGap<T>(
            start: cursor,
            end: rangeEnd,
            previous: previous,
            containsNow: !now.isBefore(cursor) && now.isBefore(rangeEnd),
          ),
        );
      }
    }
    return gaps;
  }

  static Duration _mergedDuration<T>(
    List<TimelineDayEntry<T>> entries,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    if (entries.isEmpty) return Duration.zero;
    var totalMicros = 0;
    DateTime? start;
    DateTime? end;
    for (final entry in entries) {
      final itemStart = entry.start.isBefore(rangeStart)
          ? rangeStart
          : entry.start;
      final itemEnd = entry.end.isAfter(rangeEnd) ? rangeEnd : entry.end;
      if (!itemEnd.isAfter(itemStart)) continue;
      if (start == null) {
        start = itemStart;
        end = itemEnd;
      } else if (!itemStart.isAfter(end!)) {
        if (itemEnd.isAfter(end)) end = itemEnd;
      } else {
        totalMicros += end.difference(start).inMicroseconds;
        start = itemStart;
        end = itemEnd;
      }
    }
    if (start != null && end != null) {
      totalMicros += end.difference(start).inMicroseconds;
    }
    return Duration(microseconds: totalMicros);
  }

  static int _compareNodes<T>(TimelineDayNode<T> a, TimelineDayNode<T> b) {
    final byStart = a.start.compareTo(b.start);
    if (byStart != 0) return byStart;
    return _nodePriority(a.kind).compareTo(_nodePriority(b.kind));
  }

  static int _nodePriority(TimelineDayNodeKind kind) {
    return switch (kind) {
      TimelineDayNodeKind.startBoundary => 0,
      TimelineDayNodeKind.now => 1,
      TimelineDayNodeKind.conflict => 2,
      TimelineDayNodeKind.entry => 3,
      TimelineDayNodeKind.gap => 4,
      TimelineDayNodeKind.endBoundary => 5,
    };
  }

  static DateTime _normalize(DateTime value, TimelineTimeSemantics semantics) {
    return switch (semantics) {
      TimelineTimeSemantics.preserveInput => value,
      TimelineTimeSemantics.local => value.toLocal(),
      TimelineTimeSemantics.utc => value.toUtc(),
    };
  }

  static DateTime _applyDayOffset(DateTime midnight, Duration offset) {
    final wholeDays = offset.inDays;
    final remainder = offset - Duration(days: wholeDays);
    final calendarBase = midnight.isUtc
        ? DateTime.utc(midnight.year, midnight.month, midnight.day + wholeDays)
        : DateTime(midnight.year, midnight.month, midnight.day + wholeDays);
    return calendarBase.add(remainder);
  }

  static DateTime _startOfDay(DateTime value) {
    return value.isUtc
        ? DateTime.utc(value.year, value.month, value.day)
        : DateTime(value.year, value.month, value.day);
  }
}

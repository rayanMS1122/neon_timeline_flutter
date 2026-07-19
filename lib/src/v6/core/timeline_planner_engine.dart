import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v5/core/timeline_recurrence.dart';
import 'timeline_activity_index.dart';
import 'timeline_conflict_solver.dart';
import 'timeline_day_plan.dart';
import 'timeline_entry_adapter.dart';
import 'timeline_planner_window.dart';
import 'timeline_reschedule.dart';
import 'timeline_series.dart';
import 'timeline_week_plan.dart';

@immutable
class TimelineSeriesAdapter<T> {
  const TimelineSeriesAdapter({
    required this.entryAdapter,
    this.seriesId,
    this.recurrence,
    this.originalOccurrenceStart,
    this.isOverride,
    this.isDeleted,
    this.isExternal,
  });

  final TimelineEntryAdapter<T> entryAdapter;
  final TimelineAdapterNullableValue<T, Object>? seriesId;
  final TimelineAdapterNullableValue<T, TimelineRecurrenceRule>? recurrence;
  final TimelineAdapterNullableValue<T, DateTime>? originalOccurrenceStart;
  final TimelineAdapterValue<T, bool>? isOverride;
  final TimelineAdapterValue<T, bool>? isDeleted;
  final TimelineAdapterValue<T, bool>? isExternal;

  TimelineSeriesItem<T> adapt(T value) {
    final entry = entryAdapter.adapt(value);
    final resolvedSeriesId = seriesId?.call(value);
    final rule = recurrence?.call(value);
    final deleted = isDeleted?.call(value) ?? false;
    if (rule != null) {
      return TimelineSeriesItem<T>.recurring(
        entry: entry,
        rule: rule,
        seriesId: resolvedSeriesId,
        deleted: deleted,
      );
    }
    if (isOverride?.call(value) ?? false) {
      if (resolvedSeriesId == null) {
        throw ArgumentError(
          'An override requires a non-null seriesId for ${entry.id}.',
        );
      }
      return TimelineSeriesItem<T>.override(
        entry: entry,
        seriesId: resolvedSeriesId,
        originalOccurrenceStart: originalOccurrenceStart?.call(value),
        deleted: deleted,
      );
    }
    if (isExternal?.call(value) ?? false) {
      return TimelineSeriesItem<T>(
        entry: entry,
        seriesId: resolvedSeriesId,
        deleted: deleted,
        kind: TimelineSeriesItemKind.external,
      );
    }
    return TimelineSeriesItem<T>(
      entry: entry,
      seriesId: resolvedSeriesId,
      deleted: deleted,
      kind: TimelineSeriesItemKind.standalone,
    );
  }

  List<TimelineSeriesItem<T>> adaptAll(Iterable<T> values) {
    final result = <TimelineSeriesItem<T>>[];
    for (final value in values) {
      if (entryAdapter.include != null && !entryAdapter.include!(value)) {
        continue;
      }
      result.add(adapt(value));
    }
    return List<TimelineSeriesItem<T>>.unmodifiable(result);
  }
}

@immutable
class TimelinePlannerDaySnapshot<T> {
  const TimelinePlannerDaySnapshot({
    required this.expansion,
    required this.dayPlan,
  });

  final TimelineSeriesExpansion<T> expansion;
  final TimelineDayPlan<T> dayPlan;
}

/// High-level facade for application integration.
///
/// It combines model adaptation, recurrence overrides, day planning, activity
/// summaries, week lanes, and drag previews without owning application state.
class TimelinePlannerEngine<T> {
  TimelinePlannerEngine({
    required this.adapter,
    TimelineSeriesExpander<T>? seriesExpander,
  }) : seriesExpander = seriesExpander ?? TimelineSeriesExpander<T>();

  final TimelineSeriesAdapter<T> adapter;
  final TimelineSeriesExpander<T> seriesExpander;

  TimelineSeriesExpansion<T> expand({
    required Iterable<T> values,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    return seriesExpander.expand(
      items: adapter.adaptAll(values),
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }

  /// Adapts and expands one bounded source window for reuse by day, week, and
  /// activity surfaces. Rebuild this object only when source data or the
  /// requested date window changes.
  TimelinePlannerWindow<T> prepareWindow({
    required Iterable<T> values,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    final range = TimelineDateRange(windowStart, windowEnd);
    return TimelinePlannerWindow<T>(
      range: range,
      expansion: expand(
        values: values,
        windowStart: range.start,
        windowEnd: range.end,
      ),
    );
  }

  /// Prepares the full calendar grid containing [month], including adjacent
  /// week days by default. This is the recommended source for a month picker,
  /// selected-day timeline, and week strip on the same screen.
  TimelinePlannerWindow<T> prepareMonth({
    required Iterable<T> values,
    required DateTime month,
    int firstWeekday = DateTime.monday,
    bool includeAdjacentWeeks = true,
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    if (firstWeekday < DateTime.monday || firstWeekday > DateTime.sunday) {
      throw ArgumentError.value(firstWeekday, 'firstWeekday');
    }
    final normalized = _normalize(month, dayConfig.timeSemantics);
    final first = normalized.isUtc
        ? DateTime.utc(normalized.year, normalized.month)
        : DateTime(normalized.year, normalized.month);
    final last = normalized.isUtc
        ? DateTime.utc(normalized.year, normalized.month + 1, 0)
        : DateTime(normalized.year, normalized.month + 1, 0);
    final leading = (first.weekday - firstWeekday + 7) % 7;
    final lastWeekday = ((firstWeekday + 5) % 7) + 1;
    final trailing = (lastWeekday - last.weekday + 7) % 7;
    final firstVisible = includeAdjacentWeeks
        ? _addCalendarDays(first, -leading)
        : first;
    final lastVisible = includeAdjacentWeeks
        ? _addCalendarDays(last, trailing)
        : last;
    return prepareWindow(
      values: values,
      windowStart: _applyDayOffset(firstVisible, dayConfig.dayStartOffset),
      windowEnd: _applyDayOffset(lastVisible, dayConfig.dayEndOffset),
    );
  }

  /// Prepares one seven-day planner window using calendar-safe day arithmetic.
  TimelinePlannerWindow<T> prepareWeek({
    required Iterable<T> values,
    required DateTime selectedDate,
    int firstWeekday = DateTime.monday,
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    if (firstWeekday < DateTime.monday || firstWeekday > DateTime.sunday) {
      throw ArgumentError.value(firstWeekday, 'firstWeekday');
    }
    final selected = _startOfDay(
      _normalize(selectedDate, dayConfig.timeSemantics),
    );
    final distance = (selected.weekday - firstWeekday + 7) % 7;
    final first = _addCalendarDays(selected, -distance);
    final last = _addCalendarDays(first, 6);
    return prepareWindow(
      values: values,
      windowStart: _applyDayOffset(first, dayConfig.dayStartOffset),
      windowEnd: _applyDayOffset(last, dayConfig.dayEndOffset),
    );
  }

  TimelinePlannerDaySnapshot<T> buildDay({
    required Iterable<T> values,
    required DateTime selectedDate,
    DateTime? now,
    TimelineDayPlanConfig config = const TimelineDayPlanConfig(),
  }) {
    final bounds = dayBounds(selectedDate, config: config);
    final expansion = expand(
      values: values,
      windowStart: bounds.start,
      windowEnd: bounds.end,
    );
    final dayPlan = TimelineDayPlanBuilder.build<T>(
      entries: expansion.entries,
      selectedDate: selectedDate,
      now: now,
      config: config,
    );
    return TimelinePlannerDaySnapshot<T>(
      expansion: expansion,
      dayPlan: dayPlan,
    );
  }

  TimelineActivityIndex<T> buildActivityIndex({
    required Iterable<T> values,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? now,
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    final start = _startOfDay(_normalize(startDate, dayConfig.timeSemantics));
    final endExclusive = _addCalendarDays(
      _startOfDay(_normalize(endDate, dayConfig.timeSemantics)),
      1,
    );
    final expansion = expand(
      values: values,
      windowStart: _applyDayOffset(start, dayConfig.dayStartOffset),
      windowEnd: _applyDayOffset(
        _addCalendarDays(endExclusive, -1),
        dayConfig.dayEndOffset,
      ),
    );
    return TimelineActivityIndex<T>.build(
      entries: expansion.entries,
      startDate: startDate,
      endDate: endDate,
      now: now,
      dayConfig: dayConfig,
    );
  }

  TimelineWeekPlan<T> buildWeek({
    required Iterable<T> values,
    required DateTime selectedDate,
    DateTime? now,
    int firstWeekday = DateTime.monday,
    Duration anchorOffset = const Duration(hours: 23, minutes: 30),
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    final selectedDay = _startOfDay(
      _normalize(selectedDate, dayConfig.timeSemantics),
    );
    final distance = (selectedDay.weekday - firstWeekday + 7) % 7;
    final start = _addCalendarDays(selectedDay, -distance);
    final expansion = expand(
      values: values,
      windowStart: _applyDayOffset(start, dayConfig.dayStartOffset),
      windowEnd: _applyDayOffset(
        _addCalendarDays(start, 6),
        dayConfig.dayEndOffset,
      ),
    );
    return TimelineWeekPlanBuilder.build<T>(
      entries: expansion.entries,
      selectedDate: selectedDate,
      now: now,
      firstWeekday: firstWeekday,
      anchorOffset: anchorOffset,
      dayConfig: dayConfig,
    );
  }

  TimelineConflictResolution<T> resolveConflicts({
    required Iterable<TimelineEntry<T>> entries,
    required TimelineDateRange bounds,
    Duration spacing = Duration.zero,
    bool respectDraggable = true,
  }) {
    return TimelineConflictSolver.pushForward<T>(
      entries: entries,
      bounds: bounds,
      spacing: spacing,
      respectDraggable: respectDraggable,
    );
  }

  TimelineRescheduleSession<T> beginReschedule({
    required TimelineEntry<T> entry,
    required TimelineDateRange bounds,
    required Iterable<TimelineEntry<T>> candidates,
    TimelineReschedulePolicy policy = const TimelineReschedulePolicy(),
  }) {
    return TimelineRescheduleSession<T>(
      entry: entry,
      bounds: bounds,
      candidates: candidates,
      policy: policy,
    );
  }

  TimelineDateRange dayBounds(
    DateTime selectedDate, {
    TimelineDayPlanConfig config = const TimelineDayPlanConfig(),
  }) {
    final day = _startOfDay(_normalize(selectedDate, config.timeSemantics));
    return TimelineDateRange(
      _applyDayOffset(day, config.dayStartOffset),
      _applyDayOffset(day, config.dayEndOffset),
    );
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

  static DateTime _startOfDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);

  static DateTime _addCalendarDays(DateTime value, int days) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + days)
      : DateTime(value.year, value.month, value.day + days);
}

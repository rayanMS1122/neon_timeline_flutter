import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_types.dart';
import '../../v5/core/timeline_temporal_index.dart';
import 'timeline_activity_index.dart';
import 'timeline_day_plan.dart';
import 'timeline_series.dart';
import 'timeline_week_plan.dart';

/// Reusable recurrence expansion for several planner surfaces.
///
/// Structured-style applications commonly render a day timeline, a week strip,
/// and month activity dots from the same source list. Preparing one bounded
/// window avoids adapting and expanding recurring values separately for every
/// surface. A temporal index also prevents day changes from sorting every entry
/// in the prepared month again.
@immutable
class TimelinePlannerWindow<T> {
  TimelinePlannerWindow({required this.range, required this.expansion})
    : _index = TimelineTemporalIndex<T>.build(expansion.entries);

  final TimelineDateRange range;
  final TimelineSeriesExpansion<T> expansion;
  final TimelineTemporalIndex<T> _index;

  bool contains(DateTime instant) => range.contains(instant);

  TimelineDayPlan<T> buildDay({
    required DateTime selectedDate,
    DateTime? now,
    TimelineDayPlanConfig config = const TimelineDayPlanConfig(),
  }) {
    final normalizedDate = _normalize(selectedDate, config.timeSemantics);
    final midnight = _startOfDay(normalizedDate);
    final start = _applyDayOffset(midnight, config.dayStartOffset);
    final end = _applyDayOffset(midnight, config.dayEndOffset);
    return TimelineDayPlanBuilder.build<T>(
      entries: _index.query(start: start, end: end),
      selectedDate: selectedDate,
      now: now,
      config: config,
    );
  }

  TimelineActivityIndex<T> buildActivityIndex({
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
    return TimelineActivityIndex<T>.build(
      entries: _index.query(
        start: _applyDayOffset(start, dayConfig.dayStartOffset),
        end: _applyDayOffset(
          _addCalendarDays(endExclusive, -1),
          dayConfig.dayEndOffset,
        ),
      ),
      startDate: startDate,
      endDate: endDate,
      now: now,
      dayConfig: dayConfig,
    );
  }

  TimelineWeekPlan<T> buildWeek({
    required DateTime selectedDate,
    DateTime? now,
    int firstWeekday = DateTime.monday,
    Duration anchorOffset = const Duration(hours: 23, minutes: 30),
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    return TimelineWeekPlanBuilder.buildFromIndex<T>(
      index: _index,
      selectedDate: selectedDate,
      now: now,
      firstWeekday: firstWeekday,
      anchorOffset: anchorOffset,
      dayConfig: dayConfig,
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
    return _addCalendarDays(midnight, wholeDays).add(remainder);
  }

  static DateTime _startOfDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);

  static DateTime _addCalendarDays(DateTime value, int days) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + days)
      : DateTime(value.year, value.month, value.day + days);
}

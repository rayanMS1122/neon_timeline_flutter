import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_day_layout.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v5/core/timeline_temporal_index.dart';
import 'timeline_day_plan.dart';

@immutable
class TimelineWeekLane<T> {
  const TimelineWeekLane({
    required this.date,
    required this.dayPlan,
    required this.layoutItems,
    required this.anchorTime,
    required this.anchorFraction,
  });

  final DateTime date;
  final TimelineDayPlan<T> dayPlan;
  final List<TimelineDayLayoutItem<T>> layoutItems;
  final DateTime anchorTime;
  final double anchorFraction;

  bool get hasActivity => dayPlan.entries.isNotEmpty;
  bool get hasConflicts => dayPlan.hasConflicts;
}

@immutable
class TimelineWeekPlan<T> {
  const TimelineWeekPlan({
    required this.startDate,
    required this.endDate,
    required this.lanes,
    required this.busyDuration,
    required this.completedDuration,
    required this.conflictCount,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<TimelineWeekLane<T>> lanes;
  final Duration busyDuration;
  final Duration completedDuration;
  final int conflictCount;

  TimelineWeekLane<T>? laneFor(DateTime date) {
    for (final lane in lanes) {
      if (lane.date.year == date.year &&
          lane.date.month == date.month &&
          lane.date.day == date.day) {
        return lane;
      }
    }
    return null;
  }
}

/// Builds the seven vertical day lanes seen in compact week planners while
/// leaving every visual decision to the consuming application.
class TimelineWeekPlanBuilder {
  const TimelineWeekPlanBuilder._();

  static TimelineWeekPlan<T> build<T>({
    required List<TimelineEntry<T>> entries,
    required DateTime selectedDate,
    DateTime? now,
    int firstWeekday = DateTime.monday,
    Duration anchorOffset = const Duration(hours: 23, minutes: 30),
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    return buildFromIndex<T>(
      index: TimelineTemporalIndex<T>.build(entries),
      selectedDate: selectedDate,
      now: now,
      firstWeekday: firstWeekday,
      anchorOffset: anchorOffset,
      dayConfig: dayConfig,
    );
  }

  static TimelineWeekPlan<T> buildFromIndex<T>({
    required TimelineTemporalIndex<T> index,
    required DateTime selectedDate,
    DateTime? now,
    int firstWeekday = DateTime.monday,
    Duration anchorOffset = const Duration(hours: 23, minutes: 30),
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    if (firstWeekday < DateTime.monday || firstWeekday > DateTime.sunday) {
      throw ArgumentError.value(firstWeekday, 'firstWeekday');
    }
    final selectedDay = _startOfDay(
      _normalize(selectedDate, dayConfig.timeSemantics),
    );
    final distance = (selectedDay.weekday - firstWeekday + 7) % 7;
    final weekStart = _addCalendarDays(selectedDay, -distance);
    final weekEnd = _addCalendarDays(weekStart, 7);
    final lanes = <TimelineWeekLane<T>>[];
    var busyMicros = 0;
    var completedMicros = 0;
    var conflicts = 0;

    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      final date = _addCalendarDays(weekStart, dayIndex);
      final rangeStart = _applyDayOffset(date, dayConfig.dayStartOffset);
      final rangeEnd = _applyDayOffset(date, dayConfig.dayEndOffset);
      final candidates = index.query(start: rangeStart, end: rangeEnd);
      final dayPlan = TimelineDayPlanBuilder.build<T>(
        entries: candidates,
        selectedDate: date,
        now: now,
        config: dayConfig,
      );
      final layout = TimelineDayLayoutEngine.layout<T>(
        plan: dayPlan.renderPlan,
        rangeStart: dayPlan.rangeStart,
        rangeEnd: dayPlan.rangeEnd,
        sourceEntries: dayPlan.entries.map((entry) => entry.normalized),
      );
      final anchorTime = _applyDayOffset(date, anchorOffset);
      final totalMicros = dayPlan.rangeDuration.inMicroseconds;
      final anchorFraction = totalMicros <= 0
          ? 1.0
          : (anchorTime.difference(dayPlan.rangeStart).inMicroseconds /
                    totalMicros)
                .clamp(0.0, 1.0)
                .toDouble();
      lanes.add(
        TimelineWeekLane<T>(
          date: date,
          dayPlan: dayPlan,
          layoutItems: layout,
          anchorTime: anchorTime,
          anchorFraction: anchorFraction,
        ),
      );
      busyMicros += dayPlan.busyDuration.inMicroseconds;
      completedMicros += dayPlan.completedDuration.inMicroseconds;
      conflicts += dayPlan.conflicts.length;
    }

    return TimelineWeekPlan<T>(
      startDate: weekStart,
      endDate: weekEnd,
      lanes: List<TimelineWeekLane<T>>.unmodifiable(lanes),
      busyDuration: Duration(microseconds: busyMicros),
      completedDuration: Duration(microseconds: completedMicros),
      conflictCount: conflicts,
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

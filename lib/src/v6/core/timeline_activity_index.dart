import 'package:flutter/widgets.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v5/core/timeline_temporal_index.dart';
import 'timeline_day_plan.dart';

enum TimelineActivityLevel { none, light, moderate, busy, overbooked }

@immutable
class TimelineDateActivity<T> {
  const TimelineDateActivity({
    required this.date,
    required this.entries,
    required this.busyDuration,
    required this.completedDuration,
    required this.conflictCount,
    required this.colors,
    required this.resourceIds,
    required this.level,
    this.earliestStart,
    this.latestEnd,
  });

  final DateTime date;
  final List<TimelineEntry<T>> entries;
  final Duration busyDuration;
  final Duration completedDuration;
  final int conflictCount;
  final List<Color> colors;
  final Set<Object> resourceIds;
  final TimelineActivityLevel level;
  final DateTime? earliestStart;
  final DateTime? latestEnd;

  int get entryCount => entries.length;
  int get completedCount =>
      entries.where((entry) => entry.status == TimelineStatus.completed).length;
  bool get hasActivity => entries.isNotEmpty;
  bool get hasConflicts => conflictCount > 0;
}

/// Calendar-friendly index used for week strips, month sheets, heatmaps, and
/// activity dots without coupling the package to an application's date picker.
@immutable
class TimelineActivityIndex<T> {
  const TimelineActivityIndex._({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory TimelineActivityIndex.build({
    required List<TimelineEntry<T>> entries,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? now,
    int maxDays = 370,
    int maxColorsPerDay = 3,
    TimelineDayPlanConfig dayConfig = const TimelineDayPlanConfig(),
  }) {
    if (maxDays <= 0) {
      throw ArgumentError.value(maxDays, 'maxDays', 'must be positive');
    }
    if (maxColorsPerDay < 0) {
      throw ArgumentError.value(
        maxColorsPerDay,
        'maxColorsPerDay',
        'must not be negative',
      );
    }
    final start = _startOfDay(_normalize(startDate, dayConfig.timeSemantics));
    final end = _startOfDay(_normalize(endDate, dayConfig.timeSemantics));
    if (end.isBefore(start)) {
      throw ArgumentError.value(
        endDate,
        'endDate',
        'must not precede startDate',
      );
    }
    final dayCount = _calendarDayDifference(start, end) + 1;
    if (dayCount > maxDays) {
      throw ArgumentError(
        'Requested $dayCount days, exceeding maxDays=$maxDays.',
      );
    }

    final temporalIndex = TimelineTemporalIndex<T>.build(entries);

    final result = <int, TimelineDateActivity<T>>{};
    var day = start;
    for (var index = 0; index < dayCount; index++) {
      final rangeStart = _applyDayOffset(day, dayConfig.dayStartOffset);
      final rangeEnd = _applyDayOffset(day, dayConfig.dayEndOffset);
      final plan = TimelineDayPlanBuilder.build<T>(
        entries: temporalIndex.query(start: rangeStart, end: rangeEnd),
        selectedDate: day,
        now: now,
        config: dayConfig,
      );
      final colors = <Color>[];
      final seenColors = <int>{};
      final resourceIds = <Object>{};
      for (final item in plan.entries) {
        final color = item.entry.color;
        if (color != null &&
            colors.length < maxColorsPerDay &&
            seenColors.add(color.toARGB32())) {
          colors.add(color);
        }
        resourceIds.addAll(item.entry.resourceIds);
      }
      final earliest = plan.entries.isEmpty ? null : plan.entries.first.start;
      DateTime? latest;
      for (final item in plan.entries) {
        if (latest == null || item.end.isAfter(latest)) latest = item.end;
      }
      result[_dayKey(day)] = TimelineDateActivity<T>(
        date: day,
        entries: List<TimelineEntry<T>>.unmodifiable(
          plan.entries.map((item) => item.entry),
        ),
        busyDuration: plan.busyDuration,
        completedDuration: plan.completedDuration,
        conflictCount: plan.conflicts.length,
        colors: List<Color>.unmodifiable(colors),
        resourceIds: Set<Object>.unmodifiable(resourceIds),
        level: _levelFor(plan),
        earliestStart: earliest,
        latestEnd: latest,
      );
      day = _nextDay(day);
    }

    return TimelineActivityIndex<T>._(
      startDate: start,
      endDate: end,
      days: Map<int, TimelineDateActivity<T>>.unmodifiable(result),
    );
  }

  final DateTime startDate;
  final DateTime endDate;
  final Map<int, TimelineDateActivity<T>> days;

  TimelineDateActivity<T>? activityFor(DateTime date) => days[_dayKey(date)];
  bool hasActivity(DateTime date) => activityFor(date)?.hasActivity ?? false;

  int get activeDays =>
      days.values.where((activity) => activity.hasActivity).length;
  int get conflictDays =>
      days.values.where((activity) => activity.hasConflicts).length;
  int get totalEntries => days.values.fold<int>(
    0,
    (total, activity) => total + activity.entryCount,
  );
  Duration get totalBusyDuration => Duration(
    microseconds: days.values.fold<int>(
      0,
      (total, activity) => total + activity.busyDuration.inMicroseconds,
    ),
  );

  List<TimelineDateActivity<T>> get orderedDays {
    final values = days.values.toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    return List<TimelineDateActivity<T>>.unmodifiable(values);
  }

  static TimelineActivityLevel _levelFor<T>(TimelineDayPlan<T> plan) {
    if (plan.entries.isEmpty) return TimelineActivityLevel.none;
    if (plan.hasConflicts) return TimelineActivityLevel.overbooked;
    final value = plan.utilization;
    if (value < 0.2) return TimelineActivityLevel.light;
    if (value < 0.5) return TimelineActivityLevel.moderate;
    return TimelineActivityLevel.busy;
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

  static DateTime _addCalendarDays(DateTime value, int days) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + days)
      : DateTime(value.year, value.month, value.day + days);

  static int _dayKey(DateTime value) =>
      value.year * 10000 + value.month * 100 + value.day;

  static int _calendarDayDifference(DateTime a, DateTime b) {
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  static DateTime _startOfDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);

  static DateTime _nextDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + 1)
      : DateTime(value.year, value.month, value.day + 1);
}

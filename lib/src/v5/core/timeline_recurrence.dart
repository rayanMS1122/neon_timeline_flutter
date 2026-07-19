import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';

enum TimelineRecurrenceFrequency { daily, weekly, monthly }

typedef TimelineOccurrenceIdBuilder<T> =
    Object Function(
      TimelineEntry<T> prototype,
      int occurrenceIndex,
      DateTime start,
    );

@immutable
class TimelineRecurrenceRule {
  TimelineRecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    Set<int> weekdays = const <int>{},
    this.monthDay,
    this.maxOccurrences = 10000,
  }) : weekdays = Set<int>.unmodifiable(weekdays),
       assert(interval > 0),
       assert(count == null || count > 0),
       assert(maxOccurrences > 0),
       assert(monthDay == null || (monthDay >= 1 && monthDay <= 31)),
       assert(
         weekdays.every(
           (weekday) =>
               weekday >= DateTime.monday && weekday <= DateTime.sunday,
         ),
       );

  factory TimelineRecurrenceRule.daily({
    int interval = 1,
    int? count,
    DateTime? until,
  }) {
    return TimelineRecurrenceRule(
      frequency: TimelineRecurrenceFrequency.daily,
      interval: interval,
      count: count,
      until: until,
    );
  }

  factory TimelineRecurrenceRule.weekly({
    int interval = 1,
    int? count,
    DateTime? until,
    Set<int> weekdays = const <int>{},
  }) {
    return TimelineRecurrenceRule(
      frequency: TimelineRecurrenceFrequency.weekly,
      interval: interval,
      count: count,
      until: until,
      weekdays: weekdays,
    );
  }

  factory TimelineRecurrenceRule.monthly({
    int interval = 1,
    int? count,
    DateTime? until,
    int? dayOfMonth,
  }) {
    return TimelineRecurrenceRule(
      frequency: TimelineRecurrenceFrequency.monthly,
      interval: interval,
      count: count,
      until: until,
      monthDay: dayOfMonth,
    );
  }

  final TimelineRecurrenceFrequency frequency;
  final int interval;
  final int? count;
  final DateTime? until;
  final Set<int> weekdays;
  final int? monthDay;
  final int maxOccurrences;

  List<TimelineEntry<T>> expand<T>({
    required TimelineEntry<T> prototype,
    required DateTime windowStart,
    required DateTime windowEnd,
    TimelineOccurrenceIdBuilder<T>? idBuilder,
  }) {
    if (!windowEnd.isAfter(windowStart)) {
      return <TimelineEntry<T>>[];
    }
    final duration = prototype.rawDuration;
    final result = <TimelineEntry<T>>[];
    var occurrenceIndex = 0;

    bool canEmit(DateTime start) {
      if (count != null && occurrenceIndex >= count!) return false;
      if (occurrenceIndex >= maxOccurrences) return false;
      if (until != null && start.isAfter(until!)) return false;
      return true;
    }

    void emit(DateTime start) {
      if (!canEmit(start)) return;
      final end = start.add(duration);
      final intersects = start.isBefore(windowEnd) && end.isAfter(windowStart);
      if (intersects) {
        result.add(
          prototype.copyWith(
            id:
                idBuilder?.call(prototype, occurrenceIndex, start) ??
                '${prototype.id}#$occurrenceIndex',
            start: start,
            end: prototype.end == null ? null : end,
          ),
        );
      }
      occurrenceIndex++;
    }

    switch (frequency) {
      case TimelineRecurrenceFrequency.daily:
        final threshold = windowStart.subtract(duration);
        final dayDifference = math.max(
          0,
          _calendarDayDifference(prototype.start, threshold),
        );
        occurrenceIndex = dayDifference ~/ interval;
        var current = _addCalendarDaysAtSameTime(
          prototype.start,
          occurrenceIndex * interval,
        );
        while (current.add(duration).compareTo(windowStart) <= 0 &&
            current.isBefore(windowEnd)) {
          occurrenceIndex++;
          current = _addCalendarDaysAtSameTime(
            prototype.start,
            occurrenceIndex * interval,
          );
        }
        while (canEmit(current) && current.isBefore(windowEnd)) {
          emit(current);
          current = _addCalendarDaysAtSameTime(current, interval);
        }
        break;
      case TimelineRecurrenceFrequency.weekly:
        final allowed =
            (weekdays.isEmpty ? <int>{prototype.start.weekday} : weekdays)
                .toList(growable: false)
              ..sort();
        final anchorWeekStart = _addCalendarDaysAtSameTime(
          prototype.start,
          DateTime.monday - prototype.start.weekday,
        );
        final firstWeekCount = allowed.where((weekday) {
          final candidate = _addCalendarDaysAtSameTime(
            anchorWeekStart,
            weekday - DateTime.monday,
          );
          return !candidate.isBefore(prototype.start);
        }).length;

        // Start no later than the active recurrence week preceding the visible
        // window. The one-block overscan preserves entries whose duration
        // crosses into the window without walking from a historical origin.
        final threshold = windowStart.subtract(duration);
        final weeksFromAnchor = math.max(
          0,
          _calendarDayDifference(anchorWeekStart, threshold) ~/ 7,
        );
        var activeWeekIndex = weeksFromAnchor ~/ interval;
        if (activeWeekIndex > 0) activeWeekIndex--;
        occurrenceIndex = activeWeekIndex == 0
            ? 0
            : firstWeekCount + ((activeWeekIndex - 1) * allowed.length);

        var stop = false;
        while (!stop) {
          final weekStart = _addCalendarDaysAtSameTime(
            anchorWeekStart,
            activeWeekIndex * interval * 7,
          );
          if (!weekStart.isBefore(windowEnd) ||
              occurrenceIndex >= maxOccurrences ||
              (count != null && occurrenceIndex >= count!)) {
            break;
          }
          for (final weekday in allowed) {
            final current = _addCalendarDaysAtSameTime(
              weekStart,
              weekday - DateTime.monday,
            );
            if (current.isBefore(prototype.start)) continue;
            if (!canEmit(current)) {
              stop = true;
              break;
            }
            if (!current.isBefore(windowEnd)) {
              stop = true;
              break;
            }
            emit(current);
          }
          activeWeekIndex++;
        }
        break;
      case TimelineRecurrenceFrequency.monthly:
        final requestedDay = monthDay ?? prototype.start.day;
        var firstMonthIndex = prototype.start.month - 1;
        var firstYear = prototype.start.year;
        var firstMonth = firstMonthIndex + 1;
        var firstDay = math.min(
          requestedDay,
          _daysInMonth(firstYear, firstMonth, prototype.start.isUtc),
        );
        var firstStart = _dateInPrototypeZone(
          prototype.start,
          firstYear,
          firstMonth,
          firstDay,
        );
        if (firstStart.isBefore(prototype.start)) {
          firstMonthIndex++;
          firstYear = prototype.start.year + (firstMonthIndex ~/ 12);
          firstMonth = (firstMonthIndex % 12) + 1;
          firstDay = math.min(
            requestedDay,
            _daysInMonth(firstYear, firstMonth, prototype.start.isUtc),
          );
          firstStart = _dateInPrototypeZone(
            prototype.start,
            firstYear,
            firstMonth,
            firstDay,
          );
        }

        final threshold = windowStart.subtract(duration);
        final monthDifference = math.max(
          0,
          ((threshold.year - firstStart.year) * 12) +
              threshold.month -
              firstStart.month,
        );
        occurrenceIndex = monthDifference ~/ interval;
        var sequenceIndex = occurrenceIndex;
        while (occurrenceIndex < maxOccurrences) {
          final monthIndex = firstStart.month - 1 + (sequenceIndex * interval);
          final year = firstStart.year + (monthIndex ~/ 12);
          final month = (monthIndex % 12) + 1;
          final day = math.min(
            requestedDay,
            _daysInMonth(year, month, prototype.start.isUtc),
          );
          final current = _dateInPrototypeZone(
            prototype.start,
            year,
            month,
            day,
          );
          if (!canEmit(current) || !current.isBefore(windowEnd)) break;
          emit(current);
          sequenceIndex++;
        }
        break;
    }

    return List<TimelineEntry<T>>.unmodifiable(result);
  }

  static int _calendarDayDifference(DateTime a, DateTime b) {
    final start = DateTime.utc(a.year, a.month, a.day);
    final end = DateTime.utc(b.year, b.month, b.day);
    return end.difference(start).inDays;
  }

  static DateTime _addCalendarDaysAtSameTime(DateTime value, int days) {
    return value.isUtc
        ? DateTime.utc(
            value.year,
            value.month,
            value.day + days,
            value.hour,
            value.minute,
            value.second,
            value.millisecond,
            value.microsecond,
          )
        : DateTime(
            value.year,
            value.month,
            value.day + days,
            value.hour,
            value.minute,
            value.second,
            value.millisecond,
            value.microsecond,
          );
  }

  static DateTime _dateInPrototypeZone(
    DateTime prototype,
    int year,
    int month,
    int day,
  ) {
    return prototype.isUtc
        ? DateTime.utc(
            year,
            month,
            day,
            prototype.hour,
            prototype.minute,
            prototype.second,
            prototype.millisecond,
            prototype.microsecond,
          )
        : DateTime(
            year,
            month,
            day,
            prototype.hour,
            prototype.minute,
            prototype.second,
            prototype.millisecond,
            prototype.microsecond,
          );
  }

  static int _daysInMonth(int year, int month, bool utc) {
    final next = month == 12
        ? (utc ? DateTime.utc(year + 1) : DateTime(year + 1))
        : (utc ? DateTime.utc(year, month + 1) : DateTime(year, month + 1));
    return next.subtract(const Duration(days: 1)).day;
  }
}

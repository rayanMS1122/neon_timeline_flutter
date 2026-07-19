import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';

/// Host-defined working hours and immutable blocked ranges.
@immutable
class TimelineWorkConstraints {
  TimelineWorkConstraints({
    this.dayStart = const Duration(hours: 8),
    this.dayEnd = const Duration(hours: 18),
    Iterable<TimelineDateRange> blockedRanges = const [],
    this.allowOutsideWorkingHours = false,
  }) : assert(dayStart >= Duration.zero),
       assert(dayEnd > dayStart),
       _blockedRanges = List<TimelineDateRange>.unmodifiable(blockedRanges);

  final Duration dayStart;
  final Duration dayEnd;
  final bool allowOutsideWorkingHours;
  final List<TimelineDateRange> _blockedRanges;

  List<TimelineDateRange> get blockedRanges => _blockedRanges;

  TimelineConstraintResult validate(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      return const TimelineConstraintResult.invalid('invalidRange');
    }
    if (!allowOutsideWorkingHours) {
      final day = DateTime(start.year, start.month, start.day);
      final allowedStart = day.add(dayStart);
      final allowedEnd = day.add(dayEnd);
      if (start.isBefore(allowedStart) || end.isAfter(allowedEnd)) {
        return const TimelineConstraintResult.invalid('outsideWorkingHours');
      }
    }
    for (final blocked in _blockedRanges) {
      if (start.isBefore(blocked.end) && end.isAfter(blocked.start)) {
        return TimelineConstraintResult.invalid(
          'blockedRange',
          blockedRange: blocked,
        );
      }
    }
    return const TimelineConstraintResult.valid();
  }
}

@immutable
class TimelineConstraintResult {
  const TimelineConstraintResult._({
    required this.isValid,
    this.reason,
    this.blockedRange,
  });

  const TimelineConstraintResult.valid() : this._(isValid: true);

  const TimelineConstraintResult.invalid(
    String reason, {
    TimelineDateRange? blockedRange,
  }) : this._(isValid: false, reason: reason, blockedRange: blockedRange);

  final bool isValid;
  final String? reason;
  final TimelineDateRange? blockedRange;
}

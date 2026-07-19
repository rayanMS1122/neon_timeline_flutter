import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';

/// Working interval for one ISO weekday (`DateTime.monday` … `sunday`).
@immutable
class UltimateTimelineWorkingHours {
  const UltimateTimelineWorkingHours({
    required this.weekday,
    this.start = const Duration(hours: 8),
    this.end = const Duration(hours: 18),
  }) : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday);

  final int weekday;
  final Duration start;
  final Duration end;
}

/// Immutable unavailable range with a user-facing reason.
@immutable
class UltimateTimelineBlockedRange {
  const UltimateTimelineBlockedRange({
    required this.range,
    required this.reason,
    this.resourceId,
    this.locked = true,
  });

  final TimelineDateRange range;
  final String reason;
  final Object? resourceId;
  final bool locked;
}

/// Resource-specific availability windows.
@immutable
class UltimateTimelineResourceAvailability {
  UltimateTimelineResourceAvailability({
    required this.resourceId,
    required Iterable<TimelineDateRange> availableRanges,
  }) : availableRanges = List<TimelineDateRange>.unmodifiable(availableRanges);

  final Object resourceId;
  final List<TimelineDateRange> availableRanges;
}

/// Result shared by drag, resize and slot-suggestion UI.
@immutable
class UltimateTimelineAvailabilityResult {
  const UltimateTimelineAvailabilityResult.allowed()
    : allowed = true,
      reason = null,
      blockedRange = null;

  const UltimateTimelineAvailabilityResult.blocked(
    this.reason, {
    this.blockedRange,
  }) : allowed = false;

  final bool allowed;
  final String? reason;
  final UltimateTimelineBlockedRange? blockedRange;
}

/// Host-owned work, holiday, blocked-time and resource rules.
@immutable
class UltimateTimelineAvailabilityRules {
  UltimateTimelineAvailabilityRules({
    Iterable<UltimateTimelineWorkingHours> workingHours = const [],
    Iterable<UltimateTimelineBlockedRange> blockedRanges = const [],
    Iterable<UltimateTimelineResourceAvailability> resources = const [],
    Iterable<DateTime> holidays = const [],
    this.allowOvertime = false,
  }) : workingHours = List<UltimateTimelineWorkingHours>.unmodifiable(
         workingHours,
       ),
       blockedRanges = List<UltimateTimelineBlockedRange>.unmodifiable(
         blockedRanges,
       ),
       resources = List<UltimateTimelineResourceAvailability>.unmodifiable(
         resources,
       ),
       holidays = Set<int>.unmodifiable(holidays.map(_dateKey));

  final List<UltimateTimelineWorkingHours> workingHours;
  final List<UltimateTimelineBlockedRange> blockedRanges;
  final List<UltimateTimelineResourceAvailability> resources;
  final Set<int> holidays;
  final bool allowOvertime;

  UltimateTimelineAvailabilityResult validate<T>(
    TimelineEntry<T> entry,
    DateTime start,
    DateTime end,
  ) {
    if (!end.isAfter(start)) {
      return const UltimateTimelineAvailabilityResult.blocked('invalidRange');
    }
    if (holidays.contains(_dateKey(start))) {
      return const UltimateTimelineAvailabilityResult.blocked('holiday');
    }
    if (!allowOvertime && workingHours.isNotEmpty) {
      UltimateTimelineWorkingHours? hours;
      for (final candidate in workingHours) {
        if (candidate.weekday == start.weekday) {
          hours = candidate;
          break;
        }
      }
      if (hours == null) {
        return const UltimateTimelineAvailabilityResult.blocked(
          'outsideWorkingHours',
        );
      }
      final day = DateTime(start.year, start.month, start.day);
      if (start.isBefore(day.add(hours.start)) ||
          end.isAfter(day.add(hours.end))) {
        return const UltimateTimelineAvailabilityResult.blocked(
          'outsideWorkingHours',
        );
      }
    }
    for (final blocked in blockedRanges) {
      final appliesToResource =
          blocked.resourceId == null ||
          entry.resourceIds.contains(blocked.resourceId);
      if (appliesToResource &&
          start.isBefore(blocked.range.end) &&
          end.isAfter(blocked.range.start)) {
        return UltimateTimelineAvailabilityResult.blocked(
          blocked.reason,
          blockedRange: blocked,
        );
      }
    }
    for (final resourceId in entry.resourceIds) {
      UltimateTimelineResourceAvailability? availability;
      for (final candidate in resources) {
        if (candidate.resourceId == resourceId) {
          availability = candidate;
          break;
        }
      }
      if (availability == null) continue;
      final contained = availability.availableRanges.any(
        (range) => !start.isBefore(range.start) && !end.isAfter(range.end),
      );
      if (!contained) {
        return const UltimateTimelineAvailabilityResult.blocked(
          'resourceUnavailable',
        );
      }
    }
    return const UltimateTimelineAvailabilityResult.allowed();
  }

  static int _dateKey(DateTime value) =>
      value.year * 10000 + value.month * 100 + value.day;
}

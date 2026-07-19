import 'package:flutter/foundation.dart';

import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';

@immutable
class TimelineNormalizedEntry<T> {
  const TimelineNormalizedEntry({
    required this.entry,
    required this.originalIndex,
    required this.start,
    required this.end,
    required this.originalStart,
    required this.originalEnd,
    required this.invalidRange,
    required this.isCurrent,
  });

  final TimelineEntry<T> entry;
  final int originalIndex;
  final DateTime start;
  final DateTime end;
  final DateTime originalStart;
  final DateTime originalEnd;
  final bool invalidRange;
  final bool isCurrent;

  Duration get duration => end.difference(start);
}

@immutable
class TimelineGap<T> {
  const TimelineGap({
    required this.start,
    required this.end,
    this.previousEntry,
    this.nextEntry,
  });

  final DateTime start;
  final DateTime end;
  final TimelineNormalizedEntry<T>? previousEntry;
  final TimelineNormalizedEntry<T>? nextEntry;

  Duration get duration => end.difference(start);
}

/// A connected overlap cluster produced in linear time after sorting.
@immutable
class TimelineConflictGroup<T> {
  const TimelineConflictGroup({
    required this.type,
    required this.entries,
    required this.start,
    required this.end,
  });

  final TimelineConflictType type;
  final List<TimelineNormalizedEntry<T>> entries;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

/// Immutable, deterministic plan shared by the 4.x view and diagnostics layer.
///
/// Building is O(n log n) because entries are sorted once. Gap generation,
/// overlap clustering, duplicate detection, and conflict indexing are linear.
@immutable
class TimelineRenderPlan<T> {
  const TimelineRenderPlan._({
    required this.entries,
    required this.gaps,
    required this.conflicts,
    required this.activeEntries,
    required this.indexById,
    required this.duplicateIds,
    required this.conflictingEntryIds,
    required this.conflictTypeById,
    required this.selectedDate,
    required this.dayStart,
    required this.dayEnd,
    required this.currentTimePosition,
    required this.timeSemantics,
  });

  factory TimelineRenderPlan.build({
    required List<TimelineEntry<T>> entries,
    DateTime? selectedDate,
    DateTime? now,
    TimelineTimeSemantics timeSemantics = TimelineTimeSemantics.preserveInput,
    bool includeOutsideSelectedDay = false,
    bool clipToSelectedDay = true,
    Duration minimumDuration = const Duration(minutes: 1),
  }) {
    final safeMinimum = minimumDuration > Duration.zero
        ? minimumDuration
        : const Duration(minutes: 1);
    final normalizedNow = _normalizeDate(now ?? DateTime.now(), timeSemantics);
    final normalizedDay = selectedDate == null
        ? null
        : _normalizeDate(selectedDate, timeSemantics);
    final dayStart = normalizedDay == null ? null : _startOfDay(normalizedDay);
    // Construct the following calendar date instead of adding 24 hours. This is
    // required for local days that contain a daylight-saving transition.
    final dayEnd = dayStart == null ? null : _nextDay(dayStart);

    final result = <TimelineNormalizedEntry<T>>[];
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final originalStart = _normalizeDate(entry.start, timeSemantics);
      final originalEnd = _normalizeDate(entry.rawEnd, timeSemantics);
      final invalidRange = !originalEnd.isAfter(originalStart);
      var start = originalStart;
      var end = invalidRange ? start.add(safeMinimum) : originalEnd;

      if (dayStart != null && dayEnd != null) {
        final intersectsDay = start.isBefore(dayEnd) && end.isAfter(dayStart);
        if (!includeOutsideSelectedDay && !intersectsDay) continue;
        if (clipToSelectedDay) {
          if (start.isBefore(dayStart)) start = dayStart;
          if (end.isAfter(dayEnd)) end = dayEnd;
        }
      }

      // An entry can collapse after clipping at a boundary. Preserve a safe
      // paint extent without hiding that the original range was invalid.
      if (!end.isAfter(start)) {
        end = start.add(safeMinimum);
        if (dayEnd != null && end.isAfter(dayEnd)) end = dayEnd;
        if (!end.isAfter(start)) continue;
      }

      result.add(
        TimelineNormalizedEntry<T>(
          entry: entry,
          originalIndex: index,
          start: start,
          end: end,
          originalStart: originalStart,
          originalEnd: originalEnd,
          invalidRange: invalidRange,
          isCurrent:
              !normalizedNow.isBefore(start) && normalizedNow.isBefore(end),
        ),
      );
    }

    result.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      // Longer entries first produces deterministic containment clusters.
      final byEnd = b.end.compareTo(a.end);
      if (byEnd != 0) return byEnd;
      return a.originalIndex.compareTo(b.originalIndex);
    });

    final gaps = <TimelineGap<T>>[];
    final conflicts = <TimelineConflictGroup<T>>[];
    final conflictingEntryIds = <Object>{};
    final conflictTypeById = <Object, TimelineConflictType>{};
    DateTime? occupiedUntil;
    TimelineNormalizedEntry<T>? occupiedBy;
    var cluster = <TimelineNormalizedEntry<T>>[];
    DateTime? clusterEnd;

    void finishCluster() {
      if (cluster.length > 1 || cluster.any((entry) => entry.invalidRange)) {
        final type = _classifyCluster(cluster);
        final immutableEntries = List<TimelineNormalizedEntry<T>>.unmodifiable(
          cluster,
        );
        conflicts.add(
          TimelineConflictGroup<T>(
            type: type,
            entries: immutableEntries,
            start: cluster.first.start,
            end: clusterEnd!,
          ),
        );
        final validEntries = cluster
            .where((entry) => !entry.invalidRange)
            .toList(growable: false);
        final validType = validEntries.length > 1
            ? _classifyCluster(validEntries)
            : TimelineConflictType.partialOverlap;
        for (final item in cluster) {
          conflictingEntryIds.add(item.entry.id);
          final itemType = item.invalidRange
              ? TimelineConflictType.invalidRange
              : validType;
          conflictTypeById.update(
            item.entry.id,
            (current) => _moreSevere(current, itemType),
            ifAbsent: () => itemType,
          );
        }
      }
      cluster = <TimelineNormalizedEntry<T>>[];
      clusterEnd = null;
    }

    for (final item in result) {
      if (occupiedUntil != null && item.start.isAfter(occupiedUntil)) {
        gaps.add(
          TimelineGap<T>(
            start: occupiedUntil,
            end: item.start,
            previousEntry: occupiedBy,
            nextEntry: item,
          ),
        );
      }
      if (occupiedUntil == null || item.end.isAfter(occupiedUntil)) {
        occupiedUntil = item.end;
        occupiedBy = item;
      }

      if (cluster.isEmpty) {
        cluster = <TimelineNormalizedEntry<T>>[item];
        clusterEnd = item.end;
      } else if (item.start.isBefore(clusterEnd!)) {
        cluster.add(item);
        if (item.end.isAfter(clusterEnd!)) clusterEnd = item.end;
      } else {
        finishCluster();
        cluster = <TimelineNormalizedEntry<T>>[item];
        clusterEnd = item.end;
      }
    }
    finishCluster();

    final indexById = <Object, int>{};
    final duplicateIds = <Object>{};
    for (var index = 0; index < result.length; index++) {
      final id = result[index].entry.id;
      if (indexById.containsKey(id)) {
        duplicateIds.add(id);
      } else {
        indexById[id] = index;
      }
    }

    double? currentTimePosition;
    if (dayStart != null && dayEnd != null) {
      final dayMicros = dayEnd.difference(dayStart).inMicroseconds;
      if (dayMicros > 0) {
        final elapsed = normalizedNow.difference(dayStart).inMicroseconds;
        currentTimePosition = (elapsed / dayMicros).clamp(0.0, 1.0).toDouble();
      }
    }

    return TimelineRenderPlan<T>._(
      entries: List<TimelineNormalizedEntry<T>>.unmodifiable(result),
      gaps: List<TimelineGap<T>>.unmodifiable(gaps),
      conflicts: List<TimelineConflictGroup<T>>.unmodifiable(conflicts),
      activeEntries: List<TimelineNormalizedEntry<T>>.unmodifiable(
        result.where((entry) => entry.isCurrent),
      ),
      indexById: Map<Object, int>.unmodifiable(indexById),
      duplicateIds: Set<Object>.unmodifiable(duplicateIds),
      conflictingEntryIds: Set<Object>.unmodifiable(conflictingEntryIds),
      conflictTypeById: Map<Object, TimelineConflictType>.unmodifiable(
        conflictTypeById,
      ),
      selectedDate: normalizedDay,
      dayStart: dayStart,
      dayEnd: dayEnd,
      currentTimePosition: currentTimePosition,
      timeSemantics: timeSemantics,
    );
  }

  final List<TimelineNormalizedEntry<T>> entries;
  final List<TimelineGap<T>> gaps;
  final List<TimelineConflictGroup<T>> conflicts;
  final List<TimelineNormalizedEntry<T>> activeEntries;
  final Map<Object, int> indexById;
  final Set<Object> duplicateIds;

  /// IDs participating in at least one overlap cluster. O(1) lookup.
  final Set<Object> conflictingEntryIds;

  /// Most severe detected conflict type per entry ID. O(1) lookup.
  final Map<Object, TimelineConflictType> conflictTypeById;
  final DateTime? selectedDate;
  final DateTime? dayStart;
  final DateTime? dayEnd;

  /// Normalized position in the selected calendar day, clamped to 0...1.
  final double? currentTimePosition;
  final TimelineTimeSemantics timeSemantics;

  int get entryCount => entries.length;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasDuplicateIds => duplicateIds.isNotEmpty;

  bool entryHasConflict(Object id) => conflictingEntryIds.contains(id);

  TimelineConflictType conflictTypeFor(Object id) {
    return conflictTypeById[id] ?? TimelineConflictType.none;
  }

  TimelineNormalizedEntry<T>? entryById(Object id) {
    final index = indexById[id];
    return index == null ? null : entries[index];
  }

  static DateTime _normalizeDate(
    DateTime value,
    TimelineTimeSemantics semantics,
  ) {
    return switch (semantics) {
      TimelineTimeSemantics.preserveInput => value,
      TimelineTimeSemantics.local => value.toLocal(),
      TimelineTimeSemantics.utc => value.toUtc(),
    };
  }

  static DateTime _startOfDay(DateTime value) {
    return value.isUtc
        ? DateTime.utc(value.year, value.month, value.day)
        : DateTime(value.year, value.month, value.day);
  }

  static DateTime _nextDay(DateTime value) {
    return value.isUtc
        ? DateTime.utc(value.year, value.month, value.day + 1)
        : DateTime(value.year, value.month, value.day + 1);
  }

  /// Classifies a connected cluster in O(k); no pairwise comparisons.
  static TimelineConflictType _classifyCluster<T>(
    List<TimelineNormalizedEntry<T>> cluster,
  ) {
    var hasInvalid = false;
    final first = cluster.first;
    var sameStart = true;
    var sameEnd = true;
    var minimumStart = first.start;
    var maximumEnd = first.end;

    for (final entry in cluster) {
      hasInvalid = hasInvalid || entry.invalidRange;
      sameStart = sameStart && entry.start == first.start;
      sameEnd = sameEnd && entry.end == first.end;
      if (entry.start.isBefore(minimumStart)) minimumStart = entry.start;
      if (entry.end.isAfter(maximumEnd)) maximumEnd = entry.end;
    }

    if (hasInvalid) return TimelineConflictType.invalidRange;
    if (sameStart && sameEnd) return TimelineConflictType.sameRange;
    if (sameStart) return TimelineConflictType.sameStart;
    if (sameEnd) return TimelineConflictType.sameEnd;

    final hasContainer = cluster.any(
      (entry) => entry.start == minimumStart && entry.end == maximumEnd,
    );
    return hasContainer
        ? TimelineConflictType.fullContainment
        : TimelineConflictType.partialOverlap;
  }

  static TimelineConflictType _moreSevere(
    TimelineConflictType a,
    TimelineConflictType b,
  ) {
    int severity(TimelineConflictType type) => switch (type) {
      TimelineConflictType.none => 0,
      TimelineConflictType.partialOverlap => 1,
      TimelineConflictType.sameStart => 2,
      TimelineConflictType.sameEnd => 2,
      TimelineConflictType.fullContainment => 3,
      TimelineConflictType.sameRange => 4,
      TimelineConflictType.resourceConflict => 5,
      TimelineConflictType.capacityConflict => 6,
      TimelineConflictType.dependencyConflict => 7,
      TimelineConflictType.workingHoursConflict => 8,
      TimelineConflictType.invalidRange => 9,
    };
    return severity(a) >= severity(b) ? a : b;
  }
}

/// Reusable render-plan cache with explicit revision-based invalidation.
class TimelineRenderPlanCache<T> {
  TimelineRenderPlan<T>? _value;
  List<TimelineEntry<T>>? _entries;
  Object? _dataRevision;
  DateTime? _selectedDay;
  DateTime? _clockMinute;
  TimelineTimeSemantics? _timeSemantics;
  bool? _includeOutsideSelectedDay;
  bool? _clipToSelectedDay;
  Duration? _minimumDuration;

  int builds = 0;
  int hits = 0;
  int misses = 0;

  TimelineRenderPlan<T> resolve({
    required List<TimelineEntry<T>> entries,
    Object? dataRevision,
    DateTime? selectedDate,
    DateTime? now,
    TimelineTimeSemantics timeSemantics = TimelineTimeSemantics.preserveInput,
    bool includeOutsideSelectedDay = false,
    bool clipToSelectedDay = true,
    Duration minimumDuration = const Duration(minutes: 1),
  }) {
    final normalizedNow = _normalizeForSemantics(
      now ?? DateTime.now(),
      timeSemantics,
    );
    final clockMinute = _toMinute(normalizedNow);
    final selectedDay = selectedDate == null
        ? null
        : _toDay(_normalizeForSemantics(selectedDate, timeSemantics));
    final sameData = dataRevision != null
        ? dataRevision == _dataRevision && entries.length == _entries?.length
        : identical(entries, _entries);
    final canReuse =
        _value != null &&
        sameData &&
        selectedDay == _selectedDay &&
        clockMinute == _clockMinute &&
        timeSemantics == _timeSemantics &&
        includeOutsideSelectedDay == _includeOutsideSelectedDay &&
        clipToSelectedDay == _clipToSelectedDay &&
        minimumDuration == _minimumDuration;
    if (canReuse) {
      hits++;
      return _value!;
    }

    misses++;
    final next = TimelineRenderPlan<T>.build(
      entries: entries,
      selectedDate: selectedDay,
      now: clockMinute,
      timeSemantics: timeSemantics,
      includeOutsideSelectedDay: includeOutsideSelectedDay,
      clipToSelectedDay: clipToSelectedDay,
      minimumDuration: minimumDuration,
    );
    _value = next;
    _entries = entries;
    _dataRevision = dataRevision;
    _selectedDay = selectedDay;
    _clockMinute = clockMinute;
    _timeSemantics = timeSemantics;
    _includeOutsideSelectedDay = includeOutsideSelectedDay;
    _clipToSelectedDay = clipToSelectedDay;
    _minimumDuration = minimumDuration;
    builds++;
    return next;
  }

  void invalidate() {
    _value = null;
    _entries = null;
    _dataRevision = null;
    _selectedDay = null;
    _clockMinute = null;
    _timeSemantics = null;
    _includeOutsideSelectedDay = null;
    _clipToSelectedDay = null;
    _minimumDuration = null;
  }

  DateTime _normalizeForSemantics(
    DateTime value,
    TimelineTimeSemantics semantics,
  ) {
    return switch (semantics) {
      TimelineTimeSemantics.preserveInput => value,
      TimelineTimeSemantics.local => value.toLocal(),
      TimelineTimeSemantics.utc => value.toUtc(),
    };
  }

  DateTime _toMinute(DateTime value) {
    return value.isUtc
        ? DateTime.utc(
            value.year,
            value.month,
            value.day,
            value.hour,
            value.minute,
          )
        : DateTime(
            value.year,
            value.month,
            value.day,
            value.hour,
            value.minute,
          );
  }

  DateTime _toDay(DateTime value) {
    return value.isUtc
        ? DateTime.utc(value.year, value.month, value.day)
        : DateTime(value.year, value.month, value.day);
  }
}

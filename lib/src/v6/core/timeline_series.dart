import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v5/core/timeline_recurrence.dart';

enum TimelineSeriesItemKind { standalone, recurringBase, override, external }

enum TimelineOverrideMatch {
  /// Match an override to the generated occurrence at the exact instant.
  exactStart,

  /// Match by local/UTC calendar date. This mirrors planner applications that
  /// move an occurrence but only persist its series id and target day.
  calendarDay,
}

typedef TimelineSeriesOccurrenceIdBuilder<T> =
    Object Function(
      TimelineSeriesItem<T> base,
      int occurrenceIndex,
      DateTime start,
    );

@immutable
class TimelineSeriesItem<T> {
  const TimelineSeriesItem({
    required this.entry,
    this.seriesId,
    this.recurrence,
    this.originalOccurrenceStart,
    this.deleted = false,
    this.kind = TimelineSeriesItemKind.standalone,
  });

  factory TimelineSeriesItem.standalone(TimelineEntry<T> entry) {
    return TimelineSeriesItem<T>(entry: entry);
  }

  factory TimelineSeriesItem.external(TimelineEntry<T> entry) {
    return TimelineSeriesItem<T>(
      entry: entry,
      kind: TimelineSeriesItemKind.external,
    );
  }

  factory TimelineSeriesItem.recurring({
    required TimelineEntry<T> entry,
    required TimelineRecurrenceRule rule,
    Object? seriesId,
    bool deleted = false,
  }) {
    return TimelineSeriesItem<T>(
      entry: entry,
      seriesId: seriesId ?? entry.id,
      recurrence: rule,
      deleted: deleted,
      kind: TimelineSeriesItemKind.recurringBase,
    );
  }

  factory TimelineSeriesItem.override({
    required TimelineEntry<T> entry,
    required Object seriesId,
    DateTime? originalOccurrenceStart,
    bool deleted = false,
  }) {
    return TimelineSeriesItem<T>(
      entry: entry,
      seriesId: seriesId,
      originalOccurrenceStart: originalOccurrenceStart,
      deleted: deleted,
      kind: TimelineSeriesItemKind.override,
    );
  }

  final TimelineEntry<T> entry;
  final Object? seriesId;
  final TimelineRecurrenceRule? recurrence;

  /// Original generated occurrence represented by an override. When omitted,
  /// the override's own start is used according to [TimelineOverrideMatch].
  final DateTime? originalOccurrenceStart;
  final bool deleted;
  final TimelineSeriesItemKind kind;

  Object get effectiveSeriesId => seriesId ?? entry.id;
  bool get isRecurringBase => recurrence != null;
  bool get isOverride => kind == TimelineSeriesItemKind.override;
}

@immutable
class TimelineSeriesExpansion<T> {
  const TimelineSeriesExpansion({
    required this.entries,
    required this.generatedCount,
    required this.overriddenCount,
    required this.deletedOccurrenceCount,
    required this.orphanOverrides,
    required this.shadowedOverrides,
    required this.duplicateSeriesIds,
    required this.duplicateEntryIds,
  });

  final List<TimelineEntry<T>> entries;
  final int generatedCount;
  final int overriddenCount;
  final int deletedOccurrenceCount;

  /// Overrides that did not correspond to a generated occurrence.
  final List<TimelineSeriesItem<T>> orphanOverrides;

  /// Earlier overrides replaced by another override for the same occurrence.
  /// They are never applied silently.
  final List<TimelineSeriesItem<T>> shadowedOverrides;

  /// More than one recurring base declared the same series id.
  final Set<Object> duplicateSeriesIds;

  /// Duplicate ids in the final expanded entry list.
  final Set<Object> duplicateEntryIds;

  bool get hasDataIntegrityIssues =>
      orphanOverrides.isNotEmpty ||
      shadowedOverrides.isNotEmpty ||
      duplicateSeriesIds.isNotEmpty ||
      duplicateEntryIds.isNotEmpty;
}

/// Expands recurring series and applies single-occurrence overrides.
///
/// Expansion is bounded by the requested window and each recurrence rule's
/// `maxOccurrences`. The engine never mutates application-owned values.
class TimelineSeriesExpander<T> {
  const TimelineSeriesExpander({
    this.overrideMatch = TimelineOverrideMatch.calendarDay,
    this.occurrenceIdBuilder,
  });

  final TimelineOverrideMatch overrideMatch;

  /// Optional bridge for applications that already expose virtual occurrence
  /// ids, for example `v_<series>_<timestamp>`. The default remains a private
  /// immutable id object with structural equality.
  final TimelineSeriesOccurrenceIdBuilder<T>? occurrenceIdBuilder;

  TimelineSeriesExpansion<T> expand({
    required Iterable<TimelineSeriesItem<T>> items,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    if (!windowEnd.isAfter(windowStart)) {
      return TimelineSeriesExpansion<T>(
        entries: List<TimelineEntry<T>>.unmodifiable(<TimelineEntry<T>>[]),
        generatedCount: 0,
        overriddenCount: 0,
        deletedOccurrenceCount: 0,
        orphanOverrides: List<TimelineSeriesItem<T>>.unmodifiable(
          <TimelineSeriesItem<T>>[],
        ),
        shadowedOverrides: List<TimelineSeriesItem<T>>.unmodifiable(
          <TimelineSeriesItem<T>>[],
        ),
        duplicateSeriesIds: const <Object>{},
        duplicateEntryIds: const <Object>{},
      );
    }

    final source = items.toList(growable: false);
    final bases = <Object, TimelineSeriesItem<T>>{};
    final duplicateSeriesIds = <Object>{};
    final overrides = <_OccurrenceKey, TimelineSeriesItem<T>>{};
    final shadowedOverrides = <TimelineSeriesItem<T>>[];
    final direct = <TimelineSeriesItem<T>>[];

    for (final item in source) {
      if (item.isRecurringBase) {
        final id = item.effectiveSeriesId;
        if (bases.containsKey(id)) duplicateSeriesIds.add(id);
        bases.putIfAbsent(id, () => item);
      } else if (item.isOverride) {
        final target = item.originalOccurrenceStart ?? item.entry.start;
        final key = _key(item.effectiveSeriesId, target);
        final previous = overrides[key];
        if (previous != null) shadowedOverrides.add(previous);
        overrides[key] = item;
      } else {
        direct.add(item);
      }
    }

    final result = <TimelineEntry<T>>[];
    final consumedOverrides = <_OccurrenceKey>{};
    var generatedCount = 0;
    var overriddenCount = 0;
    var deletedOccurrenceCount = 0;

    for (final item in direct) {
      if (item.deleted) continue;
      if (_intersects(item.entry, windowStart, windowEnd)) {
        result.add(_tag(item.entry, item.effectiveSeriesId, false, item.kind));
      }
    }

    for (final base in bases.values) {
      if (base.deleted) continue;
      final seriesId = base.effectiveSeriesId;
      final generated = base.recurrence!.expand<T>(
        prototype: base.entry,
        windowStart: windowStart,
        windowEnd: windowEnd,
        idBuilder: (prototype, index, start) =>
            occurrenceIdBuilder?.call(base, index, start) ??
            _GeneratedOccurrenceId(seriesId, start, index),
      );
      for (final occurrence in generated) {
        final key = _key(seriesId, occurrence.start);
        final override = overrides[key];
        if (override != null) {
          consumedOverrides.add(key);
          if (override.deleted) {
            deletedOccurrenceCount++;
            continue;
          }
          overriddenCount++;
          if (_intersects(override.entry, windowStart, windowEnd)) {
            result.add(
              _tag(
                override.entry,
                seriesId,
                false,
                TimelineSeriesItemKind.override,
                originalOccurrenceStart: occurrence.start,
              ),
            );
          }
          continue;
        }
        generatedCount++;
        result.add(
          _tag(
            occurrence,
            seriesId,
            true,
            TimelineSeriesItemKind.recurringBase,
            originalOccurrenceStart: occurrence.start,
          ),
        );
      }
    }

    final orphanOverrides = <TimelineSeriesItem<T>>[];
    for (final entry in overrides.entries) {
      if (consumedOverrides.contains(entry.key)) continue;
      orphanOverrides.add(entry.value);
      if (!entry.value.deleted &&
          _intersects(entry.value.entry, windowStart, windowEnd)) {
        result.add(
          _tag(
            entry.value.entry,
            entry.value.effectiveSeriesId,
            false,
            TimelineSeriesItemKind.override,
            originalOccurrenceStart: entry.value.originalOccurrenceStart,
          ),
        );
      }
    }

    result.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      final byEnd = a.rawEnd.compareTo(b.rawEnd);
      if (byEnd != 0) return byEnd;
      return a.id.hashCode.compareTo(b.id.hashCode);
    });

    final seenEntryIds = <Object>{};
    final duplicateEntryIds = <Object>{};
    for (final entry in result) {
      if (!seenEntryIds.add(entry.id)) duplicateEntryIds.add(entry.id);
    }

    return TimelineSeriesExpansion<T>(
      entries: List<TimelineEntry<T>>.unmodifiable(result),
      generatedCount: generatedCount,
      overriddenCount: overriddenCount,
      deletedOccurrenceCount: deletedOccurrenceCount,
      orphanOverrides: List<TimelineSeriesItem<T>>.unmodifiable(
        orphanOverrides,
      ),
      shadowedOverrides: List<TimelineSeriesItem<T>>.unmodifiable(
        shadowedOverrides,
      ),
      duplicateSeriesIds: Set<Object>.unmodifiable(duplicateSeriesIds),
      duplicateEntryIds: Set<Object>.unmodifiable(duplicateEntryIds),
    );
  }

  TimelineEntry<T> _tag(
    TimelineEntry<T> entry,
    Object seriesId,
    bool generated,
    TimelineSeriesItemKind kind, {
    DateTime? originalOccurrenceStart,
  }) {
    final metadata = <String, Object?>{
      ...entry.metadata,
      'timeline.seriesId': seriesId,
      'timeline.generated': generated,
      'timeline.seriesItemKind': kind.name,
      if (originalOccurrenceStart != null)
        'timeline.originalOccurrenceStart': originalOccurrenceStart,
    };
    return entry.copyWith(
      metadata: Map<String, Object?>.unmodifiable(metadata),
    );
  }

  _OccurrenceKey _key(Object seriesId, DateTime start) {
    return switch (overrideMatch) {
      TimelineOverrideMatch.exactStart => _OccurrenceKey(
        seriesId,
        start.microsecondsSinceEpoch,
      ),
      TimelineOverrideMatch.calendarDay => _OccurrenceKey(
        seriesId,
        DateTime.utc(start.year, start.month, start.day).microsecondsSinceEpoch,
      ),
    };
  }

  static bool _intersects<T>(
    TimelineEntry<T> entry,
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    return entry.start.isBefore(windowEnd) && entry.rawEnd.isAfter(windowStart);
  }
}

@immutable
class _OccurrenceKey {
  const _OccurrenceKey(this.seriesId, this.value);

  final Object seriesId;
  final int value;

  @override
  bool operator ==(Object other) {
    return other is _OccurrenceKey &&
        other.seriesId == seriesId &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(seriesId, value);
}

@immutable
class _GeneratedOccurrenceId {
  const _GeneratedOccurrenceId(this.seriesId, this.start, this.index);

  final Object seriesId;
  final DateTime start;
  final int index;

  @override
  bool operator ==(Object other) {
    return other is _GeneratedOccurrenceId &&
        other.seriesId == seriesId &&
        other.start == start &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(seriesId, start, index);

  @override
  String toString() => '$seriesId@$start#$index';
}

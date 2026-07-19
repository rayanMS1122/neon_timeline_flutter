import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import 'timeline_temporal_index.dart';

enum TimelineQuerySort {
  startAscending,
  startDescending,
  durationLongestFirst,
  durationShortestFirst,
  status,
}

typedef TimelineSearchText<T> = String Function(TimelineEntry<T> entry);
typedef TimelineEntryPredicate<T> = bool Function(TimelineEntry<T> entry);

@immutable
class TimelineQuery<T> {
  const TimelineQuery({
    this.text = '',
    this.statuses = const <TimelineStatus>{},
    this.resourceIds = const <Object>{},
    this.rangeStart,
    this.rangeEnd,
    this.includeDisabled = true,
    this.matchAllResources = false,
    this.sort = TimelineQuerySort.startAscending,
    this.searchText,
    this.predicate,
  }) : assert(
         (rangeStart == null && rangeEnd == null) ||
             (rangeStart != null && rangeEnd != null),
         'rangeStart and rangeEnd must be supplied together',
       );

  final String text;
  final Set<TimelineStatus> statuses;
  final Set<Object> resourceIds;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool includeDisabled;
  final bool matchAllResources;
  final TimelineQuerySort sort;
  final TimelineSearchText<T>? searchText;
  final TimelineEntryPredicate<T>? predicate;

  TimelineQueryResult<T> apply(
    Iterable<TimelineEntry<T>> source, {
    TimelineTemporalIndex<T>? index,
  }) {
    final sourceList = source is List<TimelineEntry<T>>
        ? source
        : source.toList(growable: false);
    final temporalIndex = index ?? TimelineTemporalIndex<T>.build(sourceList);
    final candidates = rangeStart != null
        ? temporalIndex.query(start: rangeStart!, end: rangeEnd!)
        : List<TimelineEntry<T>>.of(sourceList, growable: false);
    final normalizedText = text.trim().toLowerCase();

    final matches = <TimelineEntry<T>>[];
    final statusCounts = <TimelineStatus, int>{
      for (final status in TimelineStatus.values) status: 0,
    };
    final resourceCounts = <Object, int>{};
    var totalMicros = 0;

    for (final entry in candidates) {
      if (!includeDisabled && !entry.enabled) continue;
      if (statuses.isNotEmpty && !statuses.contains(entry.status)) continue;
      if (resourceIds.isNotEmpty) {
        final match = matchAllResources
            ? entry.resourceIds.containsAll(resourceIds)
            : entry.resourceIds.any(resourceIds.contains);
        if (!match) continue;
      }
      if (normalizedText.isNotEmpty) {
        final haystack =
            (searchText?.call(entry) ??
                    '${entry.semanticLabel ?? ''} ${entry.value} '
                        '${entry.metadata.values.join(' ')}')
                .toLowerCase();
        if (!haystack.contains(normalizedText)) continue;
      }
      if (predicate != null && !predicate!(entry)) continue;

      matches.add(entry);
      statusCounts.update(entry.status, (value) => value + 1);
      for (final resourceId in entry.resourceIds) {
        resourceCounts.update(
          resourceId,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      if (entry.hasValidRange) {
        totalMicros += entry.rawDuration.inMicroseconds;
      }
    }

    matches.sort(_comparator);
    return TimelineQueryResult<T>(
      entries: List<TimelineEntry<T>>.unmodifiable(matches),
      statusCounts: Map<TimelineStatus, int>.unmodifiable(statusCounts),
      resourceCounts: Map<Object, int>.unmodifiable(resourceCounts),
      totalDuration: Duration(microseconds: totalMicros),
      sourceCount: sourceList.length,
      candidateCount: candidates.length,
    );
  }

  int _comparator(TimelineEntry<T> a, TimelineEntry<T> b) {
    return switch (sort) {
      TimelineQuerySort.startAscending => _stableStart(a, b),
      TimelineQuerySort.startDescending => _stableStart(b, a),
      TimelineQuerySort.durationLongestFirst => b.rawDuration.compareTo(
        a.rawDuration,
      ),
      TimelineQuerySort.durationShortestFirst => a.rawDuration.compareTo(
        b.rawDuration,
      ),
      TimelineQuerySort.status => _statusOrder(a).compareTo(_statusOrder(b)),
    };
  }

  int _stableStart(TimelineEntry<T> a, TimelineEntry<T> b) {
    final byStart = a.start.compareTo(b.start);
    if (byStart != 0) return byStart;
    return a.id.hashCode.compareTo(b.id.hashCode);
  }

  int _statusOrder(TimelineEntry<T> entry) => entry.status.index;
}

@immutable
class TimelineQueryResult<T> {
  const TimelineQueryResult({
    required this.entries,
    required this.statusCounts,
    required this.resourceCounts,
    required this.totalDuration,
    required this.sourceCount,
    required this.candidateCount,
  });

  final List<TimelineEntry<T>> entries;
  final Map<TimelineStatus, int> statusCounts;
  final Map<Object, int> resourceCounts;
  final Duration totalDuration;
  final int sourceCount;
  final int candidateCount;

  int get matchCount => entries.length;
  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
  double get matchRate => sourceCount == 0 ? 0 : matchCount / sourceCount;

  int countForStatus(TimelineStatus status) => statusCounts[status] ?? 0;
}

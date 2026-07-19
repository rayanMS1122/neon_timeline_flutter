import 'dart:io';

import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  const sizes = <int>[10, 100, 500, 1000, 5000];
  for (final size in sizes) {
    final entries = _entries(size);
    final day = DateTime(2026, 7, 13);
    final rangeEnd = day.add(const Duration(days: 1));

    final temporalSample = _measure(() {
      return TimelineTemporalIndex<int>.build(entries);
    });
    final temporalIndex = temporalSample.value;
    final querySample = _measure(() {
      return TimelineQuery<int>(
        rangeStart: day.add(const Duration(hours: 8)),
        rangeEnd: day.add(const Duration(hours: 18)),
        statuses: const <TimelineStatus>{
          TimelineStatus.pending,
          TimelineStatus.active,
        },
      ).apply(entries, index: temporalIndex);
    });

    final planSample = _measure(() {
      return TimelineRenderPlan<int>.build(
        entries: entries,
        selectedDate: day,
        now: day.add(const Duration(hours: 12)),
      );
    });
    final plan = planSample.value;

    final cache = TimelineRenderPlanCache<int>();
    cache.resolve(
      entries: entries,
      dataRevision: 1,
      selectedDate: day,
      now: day.add(const Duration(hours: 12)),
    );
    final cacheSample = _measure(() {
      return cache.resolve(
        entries: entries,
        dataRevision: 1,
        selectedDate: day,
        now: day.add(const Duration(hours: 12)),
      );
    });

    final layoutSample = _measure(() {
      return TimelineDayLayoutEngine.layout<int>(
        plan: plan,
        rangeStart: day,
        rangeEnd: rangeEnd,
      );
    });
    final analyticsSample = _measure(() {
      return TimelineAnalytics.analyze<int>(
        plan: plan,
        rangeStart: day,
        rangeEnd: rangeEnd,
      );
    });
    final capacitySample = _measure(() {
      return TimelineCapacityEngine.analyze<int>(
        entries: entries,
        resources: const <TimelineResourceCapacity>[
          TimelineResourceCapacity(id: 'team', capacity: 4),
        ],
      );
    });

    stdout.writeln(
      'entries=$size '
      'temporal_index_us=${temporalSample.microseconds} '
      'query_us=${querySample.microseconds} '
      'plan_us=${planSample.microseconds} '
      'cache_hit_us=${cacheSample.microseconds} '
      'layout_us=${layoutSample.microseconds} '
      'analytics_us=${analyticsSample.microseconds} '
      'capacity_us=${capacitySample.microseconds} '
      'query_matches=${querySample.value.matchCount} '
      'normalized=${plan.entryCount} '
      'conflict_groups=${plan.conflicts.length} '
      'layout_items=${layoutSample.value.length} '
      'peak=${analyticsSample.value.peakConcurrency} '
      'capacity_conflicts=${capacitySample.value.length}',
    );
  }
}

_Measurement<T> _measure<T>(T Function() operation) {
  // Warm up the call site before collecting a single reproducible sample.
  operation();
  final watch = Stopwatch()..start();
  final value = operation();
  watch.stop();
  return _Measurement<T>(
    value: value,
    microseconds: watch.elapsedMicroseconds,
  );
}

class _Measurement<T> {
  const _Measurement({required this.value, required this.microseconds});

  final T value;
  final int microseconds;
}

List<TimelineEntry<int>> _entries(int count) {
  final day = DateTime(2026, 7, 13);
  return List<TimelineEntry<int>>.generate(count, (index) {
    final minute = (index * 7) % (24 * 60 - 45);
    return TimelineEntry<int>(
      id: index,
      value: index,
      start: day.add(Duration(minutes: minute)),
      duration: Duration(minutes: 15 + (index % 4) * 10),
      resourceIds: const <Object>{'team'},
    );
  }, growable: false);
}

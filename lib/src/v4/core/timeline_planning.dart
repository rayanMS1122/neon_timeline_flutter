import 'package:flutter/foundation.dart';

import '../models/timeline_entry.dart';

enum TimelineDependencyType {
  finishToStart,
  startToStart,
  finishToFinish,
  startToFinish,
}

@immutable
class TimelineDependency {
  const TimelineDependency({
    required this.id,
    required this.predecessorId,
    required this.successorId,
    this.type = TimelineDependencyType.finishToStart,
    this.lag = Duration.zero,
  });

  final Object id;
  final Object predecessorId;
  final Object successorId;
  final TimelineDependencyType type;
  final Duration lag;
}

enum TimelineDependencyIssueType {
  duplicateEntryId,
  duplicateDependencyId,
  missingPredecessor,
  missingSuccessor,
  selfDependency,
  cycle,
}

@immutable
class TimelineDependencyIssue {
  const TimelineDependencyIssue({
    required this.type,
    this.dependency,
    this.entryIds = const <Object>{},
  });

  final TimelineDependencyIssueType type;
  final TimelineDependency? dependency;
  final Set<Object> entryIds;
}

@immutable
class TimelineDependencyAnalysis<T> {
  const TimelineDependencyAnalysis({
    required this.topologicalEntries,
    required this.earliestStartById,
    required this.criticalPath,
    required this.issues,
    required this.projectEnd,
    this.latestStartById = const <Object, DateTime>{},
    this.slackById = const <Object, Duration>{},
    this.criticalEntryIds = const <Object>{},
    this.criticalDependencyIds = const <Object>{},
  });

  final List<TimelineEntry<T>> topologicalEntries;
  final Map<Object, DateTime> earliestStartById;

  /// One controlling chain ending at the calculated project end.
  final List<TimelineEntry<T>> criticalPath;

  /// Latest starts that preserve the calculated project end.
  final Map<Object, DateTime> latestStartById;

  /// Scheduling flexibility per acyclic entry. Zero marks a critical entry.
  final Map<Object, Duration> slackById;
  final Set<Object> criticalEntryIds;
  final Set<Object> criticalDependencyIds;
  final List<TimelineDependencyIssue> issues;
  final DateTime? projectEnd;

  bool get hasCycle =>
      issues.any((issue) => issue.type == TimelineDependencyIssueType.cycle);
  bool get isValid => issues.isEmpty;
}

/// Dependency analysis with O(V + E) graph traversal after ID indexing.
class TimelineDependencyEngine {
  const TimelineDependencyEngine._();

  static TimelineDependencyAnalysis<T> analyze<T>({
    required List<TimelineEntry<T>> entries,
    required List<TimelineDependency> dependencies,
  }) {
    final issues = <TimelineDependencyIssue>[];
    final byId = <Object, TimelineEntry<T>>{};
    for (final entry in entries) {
      if (byId.containsKey(entry.id)) {
        issues.add(
          TimelineDependencyIssue(
            type: TimelineDependencyIssueType.duplicateEntryId,
            entryIds: <Object>{entry.id},
          ),
        );
        continue;
      }
      byId[entry.id] = entry;
    }

    final outgoing = <Object, List<TimelineDependency>>{};
    final incomingCount = <Object, int>{for (final id in byId.keys) id: 0};
    final dependencyIds = <Object>{};

    for (final dependency in dependencies) {
      if (!dependencyIds.add(dependency.id)) {
        issues.add(
          TimelineDependencyIssue(
            type: TimelineDependencyIssueType.duplicateDependencyId,
            dependency: dependency,
            entryIds: <Object>{
              dependency.predecessorId,
              dependency.successorId,
            },
          ),
        );
        continue;
      }
      final predecessor = byId[dependency.predecessorId];
      final successor = byId[dependency.successorId];
      if (predecessor == null) {
        issues.add(
          TimelineDependencyIssue(
            type: TimelineDependencyIssueType.missingPredecessor,
            dependency: dependency,
            entryIds: <Object>{dependency.predecessorId},
          ),
        );
        continue;
      }
      if (successor == null) {
        issues.add(
          TimelineDependencyIssue(
            type: TimelineDependencyIssueType.missingSuccessor,
            dependency: dependency,
            entryIds: <Object>{dependency.successorId},
          ),
        );
        continue;
      }
      if (dependency.predecessorId == dependency.successorId) {
        issues.add(
          TimelineDependencyIssue(
            type: TimelineDependencyIssueType.selfDependency,
            dependency: dependency,
            entryIds: <Object>{dependency.predecessorId},
          ),
        );
        continue;
      }
      outgoing
          .putIfAbsent(dependency.predecessorId, () => <TimelineDependency>[])
          .add(dependency);
      incomingCount[dependency.successorId] =
          (incomingCount[dependency.successorId] ?? 0) + 1;
    }

    final ready = <Object>[
      for (final entry in entries)
        if ((incomingCount[entry.id] ?? 0) == 0 && byId[entry.id] == entry)
          entry.id,
    ];
    final topologicalIds = <Object>[];
    var cursor = 0;
    while (cursor < ready.length) {
      final id = ready[cursor++];
      topologicalIds.add(id);
      for (final dependency in outgoing[id] ?? const <TimelineDependency>[]) {
        final successorId = dependency.successorId;
        final next = (incomingCount[successorId] ?? 0) - 1;
        incomingCount[successorId] = next;
        if (next == 0) ready.add(successorId);
      }
    }

    final cycleIds = <Object>{
      for (final entry in incomingCount.entries)
        if (entry.value > 0) entry.key,
    };
    if (cycleIds.isNotEmpty) {
      issues.add(
        TimelineDependencyIssue(
          type: TimelineDependencyIssueType.cycle,
          entryIds: Set<Object>.unmodifiable(cycleIds),
        ),
      );
    }

    final earliest = <Object, DateTime>{
      for (final entry in byId.entries) entry.key: entry.value.start,
    };
    final criticalParent = <Object, Object>{};
    for (final predecessorId in topologicalIds) {
      final predecessor = byId[predecessorId]!;
      final predecessorStart = earliest[predecessorId]!;
      for (final dependency
          in outgoing[predecessorId] ?? const <TimelineDependency>[]) {
        final successor = byId[dependency.successorId]!;
        final candidate = _constraintStart(
          predecessor: predecessor,
          predecessorStart: predecessorStart,
          successor: successor,
          dependency: dependency,
        );
        final current = earliest[successor.id]!;
        if (candidate.isAfter(current)) {
          earliest[successor.id] = candidate;
          criticalParent[successor.id] = predecessorId;
        }
      }
    }

    Object? finalId;
    DateTime? projectEnd;
    for (final id in topologicalIds) {
      final entry = byId[id]!;
      final start = earliest[id]!;
      final end = start.add(_safeDuration(entry));
      if (projectEnd == null || end.isAfter(projectEnd)) {
        projectEnd = end;
        finalId = id;
      }
    }

    final latest = <Object, DateTime>{};
    if (projectEnd != null) {
      for (final id in topologicalIds) {
        latest[id] = projectEnd.subtract(_safeDuration(byId[id]!));
      }
      for (final predecessorId in topologicalIds.reversed) {
        final predecessor = byId[predecessorId]!;
        for (final dependency
            in outgoing[predecessorId] ?? const <TimelineDependency>[]) {
          final successorLatest = latest[dependency.successorId];
          if (successorLatest == null) continue;
          final successor = byId[dependency.successorId]!;
          final candidate = successorLatest.subtract(
            _constraintOffset(
              predecessor: predecessor,
              successor: successor,
              dependency: dependency,
            ),
          );
          final current = latest[predecessorId];
          if (current == null || candidate.isBefore(current)) {
            latest[predecessorId] = candidate;
          }
        }
      }
    }

    final slack = <Object, Duration>{};
    final criticalEntryIds = <Object>{};
    for (final id in topologicalIds) {
      final earliestStart = earliest[id]!;
      var latestStart = latest[id] ?? earliestStart;
      if (latestStart.isBefore(earliestStart)) {
        latestStart = earliestStart;
        latest[id] = earliestStart;
      }
      final rawSlack = latestStart.difference(earliestStart);
      final normalizedSlack = rawSlack.isNegative ? Duration.zero : rawSlack;
      slack[id] = normalizedSlack;
      if (normalizedSlack == Duration.zero) criticalEntryIds.add(id);
    }

    final criticalDependencyIds = <Object>{};
    for (final predecessorId in topologicalIds) {
      if (!criticalEntryIds.contains(predecessorId)) continue;
      final predecessor = byId[predecessorId]!;
      final predecessorStart = earliest[predecessorId]!;
      for (final dependency
          in outgoing[predecessorId] ?? const <TimelineDependency>[]) {
        if (!criticalEntryIds.contains(dependency.successorId)) continue;
        final successor = byId[dependency.successorId]!;
        final requiredStart = predecessorStart.add(
          _constraintOffset(
            predecessor: predecessor,
            successor: successor,
            dependency: dependency,
          ),
        );
        if (earliest[dependency.successorId] == requiredStart) {
          criticalDependencyIds.add(dependency.id);
        }
      }
    }

    final criticalIds = <Object>[];
    final visited = <Object>{};
    while (finalId != null && visited.add(finalId)) {
      criticalIds.add(finalId);
      finalId = criticalParent[finalId];
    }
    final criticalPath = criticalIds.reversed
        .map((id) => byId[id]!)
        .toList(growable: false);

    return TimelineDependencyAnalysis<T>(
      topologicalEntries: List<TimelineEntry<T>>.unmodifiable(
        topologicalIds.map((id) => byId[id]!),
      ),
      earliestStartById: Map<Object, DateTime>.unmodifiable(earliest),
      criticalPath: List<TimelineEntry<T>>.unmodifiable(criticalPath),
      latestStartById: Map<Object, DateTime>.unmodifiable(latest),
      slackById: Map<Object, Duration>.unmodifiable(slack),
      criticalEntryIds: Set<Object>.unmodifiable(criticalEntryIds),
      criticalDependencyIds: Set<Object>.unmodifiable(criticalDependencyIds),
      issues: List<TimelineDependencyIssue>.unmodifiable(issues),
      projectEnd: projectEnd,
    );
  }

  static DateTime _constraintStart<T>({
    required TimelineEntry<T> predecessor,
    required DateTime predecessorStart,
    required TimelineEntry<T> successor,
    required TimelineDependency dependency,
  }) {
    return predecessorStart.add(
      _constraintOffset(
        predecessor: predecessor,
        successor: successor,
        dependency: dependency,
      ),
    );
  }

  static Duration _constraintOffset<T>({
    required TimelineEntry<T> predecessor,
    required TimelineEntry<T> successor,
    required TimelineDependency dependency,
  }) {
    final predecessorDuration = _safeDuration(predecessor);
    final successorDuration = _safeDuration(successor);
    final base = switch (dependency.type) {
      TimelineDependencyType.finishToStart => predecessorDuration,
      TimelineDependencyType.startToStart => Duration.zero,
      TimelineDependencyType.finishToFinish =>
        predecessorDuration - successorDuration,
      TimelineDependencyType.startToFinish => -successorDuration,
    };
    return base + dependency.lag;
  }

  static Duration _safeDuration<T>(TimelineEntry<T> entry) {
    return entry.hasValidRange ? entry.rawDuration : const Duration(minutes: 1);
  }
}

@immutable
class TimelineResourceCapacity {
  const TimelineResourceCapacity({required this.id, this.capacity = 1})
    : assert(capacity > 0);

  final Object id;
  final double capacity;
}

typedef TimelineResourceUsageResolver<T> =
    double Function(TimelineEntry<T> entry, Object resourceId);

@immutable
class TimelineCapacityConflict<T> {
  const TimelineCapacityConflict({
    required this.resourceId,
    required this.start,
    required this.end,
    required this.load,
    required this.capacity,
    required this.entries,
  });

  final Object resourceId;
  final DateTime start;
  final DateTime end;
  final double load;
  final double capacity;
  final List<TimelineEntry<T>> entries;

  Duration get duration => end.difference(start);
  double get overload => load - capacity;
}

/// Resource overbooking sweep. Adjacent ranges do not conflict.
///
/// Entries are indexed by resource in one pass. The total work is
/// O(A + Σ Eᵣ log Eᵣ), where A is the number of resource assignments and Eᵣ
/// is the event count for one resource. It never performs an R × N scan.
class TimelineCapacityEngine {
  const TimelineCapacityEngine._();

  static List<TimelineCapacityConflict<T>> analyze<T>({
    required List<TimelineEntry<T>> entries,
    required List<TimelineResourceCapacity> resources,
    TimelineResourceUsageResolver<T>? usageResolver,
  }) {
    final TimelineResourceUsageResolver<T> resolver =
        usageResolver ?? _unitUsage<T>;
    final capacityById = <Object, TimelineResourceCapacity>{};
    for (final resource in resources) {
      capacityById.putIfAbsent(resource.id, () => resource);
    }
    final eventsByResource = <Object, List<_CapacityEvent<T>>>{};

    for (final entry in entries) {
      final end = entry.hasValidRange
          ? entry.rawEnd
          : entry.start.add(const Duration(minutes: 1));
      for (final resourceId in entry.resourceIds) {
        if (!capacityById.containsKey(resourceId)) continue;
        final usage = resolver(entry, resourceId);
        if (!usage.isFinite || usage <= 0) continue;
        final token = Object();
        final events = eventsByResource.putIfAbsent(
          resourceId,
          () => <_CapacityEvent<T>>[],
        );
        events
          ..add(
            _CapacityEvent<T>(
              token: token,
              time: entry.start,
              entry: entry,
              usage: usage,
              isStart: true,
            ),
          )
          ..add(
            _CapacityEvent<T>(
              token: token,
              time: end,
              entry: entry,
              usage: usage,
              isStart: false,
            ),
          );
      }
    }

    final result = <TimelineCapacityConflict<T>>[];
    for (final resource in capacityById.values) {
      final events = eventsByResource[resource.id];
      if (events == null || events.isEmpty) continue;
      _appendResourceConflicts<T>(
        result: result,
        resource: resource,
        events: events,
      );
    }
    return List<TimelineCapacityConflict<T>>.unmodifiable(result);
  }

  static void _appendResourceConflicts<T>({
    required List<TimelineCapacityConflict<T>> result,
    required TimelineResourceCapacity resource,
    required List<_CapacityEvent<T>> events,
  }) {
    events.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      if (byTime != 0) return byTime;
      if (a.isStart == b.isStart) return 0;
      // End events run first, so adjacent ranges do not overlap.
      return a.isStart ? 1 : -1;
    });

    final active = <Object, _ActiveCapacity<T>>{};
    var load = 0.0;
    DateTime? previousTime;
    var index = 0;
    while (index < events.length) {
      final time = events[index].time;
      if (previousTime != null &&
          time.isAfter(previousTime) &&
          load > resource.capacity) {
        result.add(
          TimelineCapacityConflict<T>(
            resourceId: resource.id,
            start: previousTime,
            end: time,
            load: load,
            capacity: resource.capacity,
            entries: List<TimelineEntry<T>>.unmodifiable(
              active.values.map((value) => value.entry),
            ),
          ),
        );
      }

      while (index < events.length && events[index].time == time) {
        final event = events[index++];
        if (event.isStart) {
          active[event.token] = _ActiveCapacity<T>(
            entry: event.entry,
            usage: event.usage,
          );
          load += event.usage;
        } else {
          final removed = active.remove(event.token);
          if (removed != null) load -= removed.usage;
        }
      }
      previousTime = time;
    }
  }

  static double _unitUsage<T>(TimelineEntry<T> _, Object __) => 1;
}

@immutable
class _CapacityEvent<T> {
  const _CapacityEvent({
    required this.token,
    required this.time,
    required this.entry,
    required this.usage,
    required this.isStart,
  });

  final Object token;
  final DateTime time;
  final TimelineEntry<T> entry;
  final double usage;
  final bool isStart;
}

@immutable
class _ActiveCapacity<T> {
  const _ActiveCapacity({required this.entry, required this.usage});

  final TimelineEntry<T> entry;
  final double usage;
}

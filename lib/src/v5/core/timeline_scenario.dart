import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';

enum TimelineScenarioChangeKind { added, removed, modified }

@immutable
class TimelineScenario<T> {
  TimelineScenario({
    required this.id,
    required this.name,
    required Iterable<TimelineEntry<T>> entries,
    this.description,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : entries = List<TimelineEntry<T>>.unmodifiable(entries),
       metadata = Map<String, Object?>.unmodifiable(metadata);

  final Object id;
  final String name;
  final String? description;
  final List<TimelineEntry<T>> entries;
  final Map<String, Object?> metadata;
}

@immutable
class TimelineScenarioChange<T> {
  const TimelineScenarioChange({
    required this.kind,
    required this.id,
    this.before,
    this.after,
    this.moved = false,
    this.resized = false,
    this.statusChanged = false,
    this.resourcesChanged = false,
    this.valueChanged = false,
    this.enabledChanged = false,
  });

  final TimelineScenarioChangeKind kind;
  final Object id;
  final TimelineEntry<T>? before;
  final TimelineEntry<T>? after;
  final bool moved;
  final bool resized;
  final bool statusChanged;
  final bool resourcesChanged;
  final bool valueChanged;
  final bool enabledChanged;

  bool get hasStructuralChange => moved || resized || resourcesChanged;
}

@immutable
class TimelineScenarioComparison<T> {
  const TimelineScenarioComparison({
    required this.base,
    required this.candidate,
    required this.changes,
  });

  final TimelineScenario<T> base;
  final TimelineScenario<T> candidate;
  final List<TimelineScenarioChange<T>> changes;

  Iterable<TimelineScenarioChange<T>> get added => changes.where(
    (change) => change.kind == TimelineScenarioChangeKind.added,
  );
  Iterable<TimelineScenarioChange<T>> get removed => changes.where(
    (change) => change.kind == TimelineScenarioChangeKind.removed,
  );
  Iterable<TimelineScenarioChange<T>> get modified => changes.where(
    (change) => change.kind == TimelineScenarioChangeKind.modified,
  );

  int get addedCount => added.length;
  int get removedCount => removed.length;
  int get modifiedCount => modified.length;
  bool get hasChanges => changes.isNotEmpty;
}

class TimelineScenarioEngine {
  const TimelineScenarioEngine._();

  static TimelineScenarioComparison<T> compare<T>({
    required TimelineScenario<T> base,
    required TimelineScenario<T> candidate,
  }) {
    final beforeById = <Object, TimelineEntry<T>>{};
    final afterById = <Object, TimelineEntry<T>>{};
    for (final entry in base.entries) {
      beforeById.putIfAbsent(entry.id, () => entry);
    }
    for (final entry in candidate.entries) {
      afterById.putIfAbsent(entry.id, () => entry);
    }

    final ids = <Object>{...beforeById.keys, ...afterById.keys}.toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));
    final changes = <TimelineScenarioChange<T>>[];

    for (final id in ids) {
      final before = beforeById[id];
      final after = afterById[id];
      if (before == null && after != null) {
        changes.add(
          TimelineScenarioChange<T>(
            kind: TimelineScenarioChangeKind.added,
            id: id,
            after: after,
          ),
        );
        continue;
      }
      if (before != null && after == null) {
        changes.add(
          TimelineScenarioChange<T>(
            kind: TimelineScenarioChangeKind.removed,
            id: id,
            before: before,
          ),
        );
        continue;
      }
      if (before == null || after == null) continue;

      final moved = before.start != after.start;
      final resized = before.rawEnd != after.rawEnd;
      final statusChanged = before.status != after.status;
      final resourcesChanged = !setEquals(
        before.resourceIds,
        after.resourceIds,
      );
      final valueChanged =
          before.value != after.value ||
          !mapEquals(before.metadata, after.metadata);
      final enabledChanged =
          before.enabled != after.enabled ||
          before.draggable != after.draggable;

      if (moved ||
          resized ||
          statusChanged ||
          resourcesChanged ||
          valueChanged ||
          enabledChanged) {
        changes.add(
          TimelineScenarioChange<T>(
            kind: TimelineScenarioChangeKind.modified,
            id: id,
            before: before,
            after: after,
            moved: moved,
            resized: resized,
            statusChanged: statusChanged,
            resourcesChanged: resourcesChanged,
            valueChanged: valueChanged,
            enabledChanged: enabledChanged,
          ),
        );
      }
    }

    return TimelineScenarioComparison<T>(
      base: base,
      candidate: candidate,
      changes: List<TimelineScenarioChange<T>>.unmodifiable(changes),
    );
  }
}

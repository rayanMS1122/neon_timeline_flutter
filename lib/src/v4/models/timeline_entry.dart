import 'dart:async';

import 'package:flutter/widgets.dart';

import 'timeline_types.dart';

const Object _timelineUnset = Object();

/// Application-owned value adapted to the neutral 4.x timeline engine.
@immutable
class TimelineEntry<T> {
  const TimelineEntry({
    required this.id,
    required this.value,
    required this.start,
    this.end,
    this.duration = const Duration(minutes: 30),
    this.status = TimelineStatus.pending,
    this.color,
    this.semanticLabel,
    this.enabled = true,
    this.draggable = true,
    this.resourceIds = const <Object>{},
    this.metadata = const <String, Object?>{},
  });

  /// Defensively copies collection inputs for hosts that mutate their source
  /// sets or maps after constructing an entry.
  factory TimelineEntry.safe({
    required Object id,
    required T value,
    required DateTime start,
    DateTime? end,
    Duration duration = const Duration(minutes: 30),
    TimelineStatus status = TimelineStatus.pending,
    Color? color,
    String? semanticLabel,
    bool enabled = true,
    bool draggable = true,
    Iterable<Object> resourceIds = const <Object>[],
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return TimelineEntry<T>(
      id: id,
      value: value,
      start: start,
      end: end,
      duration: duration,
      status: status,
      color: color,
      semanticLabel: semanticLabel,
      enabled: enabled,
      draggable: draggable,
      resourceIds: Set<Object>.unmodifiable(resourceIds),
      metadata: Map<String, Object?>.unmodifiable(metadata),
    );
  }

  final Object id;
  final T value;
  final DateTime start;

  /// Explicit end. When null, [duration] is used.
  final DateTime? end;

  /// Fallback duration when [end] is null.
  final Duration duration;
  final TimelineStatus status;
  final Color? color;
  final String? semanticLabel;
  final bool enabled;
  final bool draggable;
  final Set<Object> resourceIds;
  final Map<String, Object?> metadata;

  DateTime get rawEnd => end ?? start.add(duration);
  bool get hasValidRange => rawEnd.isAfter(start);
  Duration get rawDuration => rawEnd.difference(start);

  /// Stable-enough host-side cache key for immutable entries.
  ///
  /// For expensive or mutable values, pass an explicit `dataRevision` to the
  /// view instead of relying on this hash.
  int get revisionHash => Object.hash(
    id,
    value,
    start,
    rawEnd,
    status,
    color,
    semanticLabel,
    enabled,
    draggable,
    Object.hashAllUnordered(resourceIds),
    Object.hashAllUnordered(
      metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  TimelineEntry<T> copyWith({
    Object? id,
    Object? value = _timelineUnset,
    DateTime? start,
    DateTime? end,
    bool clearEnd = false,
    Duration? duration,
    TimelineStatus? status,
    Color? color,
    bool clearColor = false,
    String? semanticLabel,
    bool clearSemanticLabel = false,
    bool? enabled,
    bool? draggable,
    Set<Object>? resourceIds,
    Map<String, Object?>? metadata,
  }) {
    return TimelineEntry<T>(
      id: id ?? this.id,
      value: identical(value, _timelineUnset) ? this.value : value as T,
      start: start ?? this.start,
      end: clearEnd ? null : (end ?? this.end),
      duration: duration ?? this.duration,
      status: status ?? this.status,
      color: clearColor ? null : (color ?? this.color),
      semanticLabel: clearSemanticLabel
          ? null
          : (semanticLabel ?? this.semanticLabel),
      enabled: enabled ?? this.enabled,
      draggable: draggable ?? this.draggable,
      resourceIds: resourceIds ?? this.resourceIds,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Normalized builder context shared by the new view widgets.
@immutable
class TimelineEntryDetails<T> {
  const TimelineEntryDetails({
    required this.entry,
    required this.index,
    required this.itemCount,
    required this.displayStart,
    required this.displayEnd,
    required this.isCurrent,
    required this.hasConflict,
    this.conflictType = TimelineConflictType.none,
    this.selectedDate,
    this.previousEntry,
    this.nextEntry,
    this.gapBefore,
    this.gapAfter,
  });

  final TimelineEntry<T> entry;
  final int index;
  final int itemCount;
  final DateTime displayStart;
  final DateTime displayEnd;
  final DateTime? selectedDate;
  final TimelineEntry<T>? previousEntry;
  final TimelineEntry<T>? nextEntry;
  final Duration? gapBefore;
  final Duration? gapAfter;
  final bool isCurrent;
  final bool hasConflict;
  final TimelineConflictType conflictType;

  Duration get displayDuration => displayEnd.difference(displayStart);
  bool get isFirst => index == 0;
  bool get isLast => index == itemCount - 1;
}

typedef TimelineEntryBuilder<T> =
    Widget Function(BuildContext context, TimelineEntryDetails<T> details);

typedef TimelineEntryCallback<T> =
    void Function(BuildContext context, TimelineEntryDetails<T> details);

typedef TimelineMoveCallback<T> =
    FutureOr<void> Function(
      BuildContext context,
      TimelineEntryDetails<T> details,
      DateTime newStart,
    );

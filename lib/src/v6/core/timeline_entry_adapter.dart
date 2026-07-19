import 'package:flutter/widgets.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';

typedef TimelineAdapterValue<T, R> = R Function(T value);
typedef TimelineAdapterNullableValue<T, R> = R? Function(T value);

/// Maps an application-owned model to the neutral [TimelineEntry] contract.
///
/// The adapter deliberately knows nothing about Bloc, Firebase, Hive, or the
/// consuming application's model classes. It is therefore safe to keep the
/// application's existing persistence and state-management layers unchanged.
@immutable
class TimelineEntryAdapter<T> {
  const TimelineEntryAdapter({
    required this.id,
    required this.start,
    this.end,
    this.duration,
    this.status,
    this.color,
    this.semanticLabel,
    this.enabled,
    this.draggable,
    this.resourceIds,
    this.metadata,
    this.include,
    this.defaultDuration = const Duration(minutes: 30),
  });

  final TimelineAdapterValue<T, Object> id;
  final TimelineAdapterValue<T, DateTime> start;
  final TimelineAdapterNullableValue<T, DateTime>? end;
  final TimelineAdapterNullableValue<T, Duration>? duration;
  final TimelineAdapterValue<T, TimelineStatus>? status;
  final TimelineAdapterNullableValue<T, Color>? color;
  final TimelineAdapterNullableValue<T, String>? semanticLabel;
  final TimelineAdapterValue<T, bool>? enabled;
  final TimelineAdapterValue<T, bool>? draggable;
  final TimelineAdapterValue<T, Iterable<Object>>? resourceIds;
  final TimelineAdapterValue<T, Map<String, Object?>>? metadata;
  final TimelineAdapterValue<T, bool>? include;
  final Duration defaultDuration;

  TimelineEntry<T> adapt(T value) {
    if (defaultDuration <= Duration.zero) {
      throw ArgumentError.value(
        defaultDuration,
        'defaultDuration',
        'must be greater than zero',
      );
    }
    final explicitEnd = end?.call(value);
    final resolvedDuration = duration?.call(value) ?? defaultDuration;
    return TimelineEntry<T>.safe(
      id: id(value),
      value: value,
      start: start(value),
      end: explicitEnd,
      duration: resolvedDuration,
      status: status?.call(value) ?? TimelineStatus.pending,
      color: color?.call(value),
      semanticLabel: semanticLabel?.call(value),
      enabled: enabled?.call(value) ?? true,
      draggable: draggable?.call(value) ?? true,
      resourceIds: resourceIds?.call(value) ?? const <Object>[],
      metadata: metadata?.call(value) ?? const <String, Object?>{},
    );
  }

  List<TimelineEntry<T>> adaptAll(Iterable<T> values) {
    final result = <TimelineEntry<T>>[];
    for (final value in values) {
      if (include != null && !include!(value)) continue;
      result.add(adapt(value));
    }
    return List<TimelineEntry<T>>.unmodifiable(result);
  }
}

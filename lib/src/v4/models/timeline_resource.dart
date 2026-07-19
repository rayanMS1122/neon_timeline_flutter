import 'package:flutter/widgets.dart';

/// A person, room, machine, team, or other schedulable resource.
@immutable
class TimelineResource {
  const TimelineResource({
    required this.id,
    required this.label,
    this.subtitle,
    this.color,
    this.capacity = 1,
    this.enabled = true,
    this.metadata = const <String, Object?>{},
  }) : assert(capacity > 0);

  /// Defensively copies metadata owned by a mutable host model.
  factory TimelineResource.safe({
    required Object id,
    required String label,
    String? subtitle,
    Color? color,
    double capacity = 1,
    bool enabled = true,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return TimelineResource(
      id: id,
      label: label,
      subtitle: subtitle,
      color: color,
      capacity: capacity,
      enabled: enabled,
      metadata: Map<String, Object?>.unmodifiable(metadata),
    );
  }

  final Object id;
  final String label;
  final String? subtitle;
  final Color? color;
  final double capacity;
  final bool enabled;
  final Map<String, Object?> metadata;

  TimelineResource copyWith({
    Object? id,
    String? label,
    String? subtitle,
    bool clearSubtitle = false,
    Color? color,
    bool clearColor = false,
    double? capacity,
    bool? enabled,
    Map<String, Object?>? metadata,
  }) {
    return TimelineResource(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      color: clearColor ? null : (color ?? this.color),
      capacity: capacity ?? this.capacity,
      enabled: enabled ?? this.enabled,
      metadata: metadata ?? this.metadata,
    );
  }
}

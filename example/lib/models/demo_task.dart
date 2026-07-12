import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

@immutable
class DemoTask {
  const DemoTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    this.status = NeonTimelineStatus.pending,
    this.draggable = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final NeonTimelineStatus status;
  final bool draggable;

  DemoTask copyWith({
    DateTime? start,
    Duration? duration,
    NeonTimelineStatus? status,
  }) {
    return DemoTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      status: status ?? this.status,
      draggable: draggable,
    );
  }
}

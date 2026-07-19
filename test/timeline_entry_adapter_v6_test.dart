import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('application values adapt without package-owned models', () {
    final adapter = TimelineEntryAdapter<_Task>(
      id: (task) => task.id,
      start: (task) => task.start,
      duration: (task) => Duration(minutes: task.minutes),
      status: (task) =>
          task.completed ? TimelineStatus.completed : TimelineStatus.pending,
      color: (task) => task.color,
      semanticLabel: (task) => task.title,
      draggable: (task) => !task.external,
      include: (task) => !task.deleted,
      metadata: (task) => <String, Object?>{'priority': task.priority},
    );

    final entries = adapter.adaptAll(<_Task>[
      _Task('a', 'Plan', DateTime(2026, 7, 16, 9), 45),
      _Task('b', 'Deleted', DateTime(2026, 7, 16, 10), 30, deleted: true),
    ]);

    expect(entries, hasLength(1));
    expect(entries.single.semanticLabel, 'Plan');
    expect(entries.single.rawDuration, const Duration(minutes: 45));
    expect(entries.single.metadata['priority'], 1);
  });
}

class _Task {
  const _Task(
    this.id,
    this.title,
    this.start,
    this.minutes, {
    this.deleted = false,
  }) : completed = false,
       external = false,
       priority = 1,
       color = Colors.pink;

  final String id;
  final String title;
  final DateTime start;
  final int minutes;
  final bool completed;
  final bool external;
  final bool deleted;
  final int priority;
  final Color color;
}

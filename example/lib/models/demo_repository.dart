import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import 'demo_task.dart';

/// In-memory example repository. The package remains independent from app data.
class DemoTaskRepository extends ChangeNotifier {
  DemoTaskRepository() {
    _seed();
  }

  final Map<String, DemoTask> _tasks = <String, DemoTask>{};
  int _revision = 0;

  int get revision => _revision;

  List<DemoTask> tasksFor(DateTime day) {
    final values = _tasks.values
        .where((task) => _sameDay(task.start, day))
        .toList(growable: false)
      ..sort((a, b) => a.start.compareTo(b.start));
    return values;
  }

  Future<void> move(String id, DateTime start) async {
    await _simulateStorage();
    final task = _tasks[id];
    if (task == null) return;
    _tasks[id] = task.copyWith(start: start);
    _changed();
  }

  Future<void> complete(String id) => setCompleted(id, true);

  Future<void> setCompleted(String id, bool completed) async {
    await _simulateStorage();
    final task = _tasks[id];
    if (task == null) return;
    _tasks[id] = task.copyWith(
      status: completed
          ? NeonTimelineStatus.completed
          : NeonTimelineStatus.pending,
    );
    _changed();
  }

  Future<void> delete(String id) async {
    await _simulateStorage();
    if (_tasks.remove(id) != null) _changed();
  }

  Future<void> restore(DemoTask task) async {
    _tasks[task.id] = task;
    _changed();
  }

  void addDemoTask(DateTime day) {
    final id = 'new-${DateTime.now().microsecondsSinceEpoch}';
    _tasks[id] = DemoTask(
      id: id,
      title: 'New focus block',
      subtitle: 'Created by the example app',
      start: DateTime(day.year, day.month, day.day, 15, 30),
      duration: const Duration(minutes: 45),
      color: const Color(0xFF62E7C8),
    );
    _changed();
  }

  void reset() {
    _tasks.clear();
    _seed();
    _changed();
  }

  List<NeonScheduleEntry<DemoTask>> entriesFor(DateTime day) {
    return tasksFor(day)
        .map(
          (task) => NeonScheduleEntry<DemoTask>(
            id: task.id,
            value: task,
            start: task.start,
            duration: task.duration,
            status: task.status,
            color: task.color,
            semanticLabel:
                '${task.title}, ${task.status.name}, ${task.duration.inMinutes} minutes',
            draggable: task.draggable,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _simulateStorage() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }

  void _seed() {
    final day = DateTime(2026, 7, 11);
    final seeded = <DemoTask>[
      DemoTask(
        id: 'deep-work',
        title: 'Deep work block',
        subtitle: 'Finish the timeline package API',
        start: DateTime(2026, 7, 11, 8, 30),
        duration: const Duration(minutes: 90),
        color: const Color(0xFFFF66B8),
        status: NeonTimelineStatus.completed,
      ),
      DemoTask(
        id: 'review',
        title: 'Design review',
        subtitle: 'Interaction, accessibility, and motion',
        start: DateTime(2026, 7, 11, 10, 30),
        duration: const Duration(minutes: 55),
        color: const Color(0xFF67D9FF),
        status: NeonTimelineStatus.active,
      ),
      DemoTask(
        id: 'publish',
        title: 'Prepare publication',
        subtitle: 'README, tests, dry run, and release notes',
        start: DateTime(2026, 7, 11, 12),
        duration: const Duration(minutes: 75),
        color: const Color(0xFF9D7BFF),
      ),
      DemoTask(
        id: 'conflict',
        title: 'Intentional overlap',
        subtitle: 'Shows conflict detection and indentation',
        start: DateTime(2026, 7, 11, 12, 45),
        duration: const Duration(minutes: 45),
        color: const Color(0xFFFF8A66),
      ),
      DemoTask(
        id: 'calendar',
        title: 'Calendar event',
        subtitle: 'Non-draggable external event',
        start: DateTime(2026, 7, 11, 14, 20),
        duration: const Duration(minutes: 35),
        color: const Color(0xFFFFD166),
        draggable: false,
      ),
      DemoTask(
        id: 'tomorrow',
        title: 'Tomorrow planning',
        subtitle: 'Swipe to the next day to reveal this entry',
        start: DateTime(2026, 7, 12, 9, 15),
        duration: const Duration(minutes: 60),
        color: const Color(0xFF65C7FF),
        status: NeonTimelineStatus.active,
      ),
    ];
    for (final task in seeded) {
      _tasks[task.id] = task;
    }
    if (tasksFor(day).isEmpty) {
      throw StateError('Demo seed failed.');
    }
  }
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

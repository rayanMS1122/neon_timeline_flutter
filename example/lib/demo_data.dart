import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

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
    this.enabled = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final NeonTimelineStatus status;
  final bool draggable;
  final bool enabled;

  DemoTask copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? start,
    Duration? duration,
    Color? color,
    NeonTimelineStatus? status,
    bool? draggable,
    bool? enabled,
  }) {
    return DemoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color ?? this.color,
      status: status ?? this.status,
      draggable: draggable ?? this.draggable,
      enabled: enabled ?? this.enabled,
    );
  }
}

class DemoTimelineItem {
  const DemoTimelineItem({
    required this.id,
    required this.content,
    this.oppositeContent,
    this.indicator,
    this.status = NeonTimelineStatus.pending,
    this.semanticLabel,
    this.onTap,
    this.connectorStyle,
  });

  final String id;
  final Widget content;
  final Widget? oppositeContent;
  final Widget? indicator;
  final NeonTimelineStatus status;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final NeonTimelineConnectorStyle? connectorStyle;
}

class FakeRepository {
  FakeRepository._();
  static final FakeRepository instance = FakeRepository._();

  final math.Random _random = math.Random(42);

  List<DemoTask> generateTasksForDay(DateTime day, {int count = 8}) {
    final tasks = <DemoTask>[];
    final statuses = NeonTimelineStatus.values;

    for (var i = 0; i < count; i++) {
      final hour = 7 + _random.nextInt(14);
      final minute = _random.nextBool() ? 0 : 30;
      final start = DateTime(day.year, day.month, day.day, hour, minute);
      final duration = Duration(minutes: 30 + _random.nextInt(6) * 15);

      tasks.add(DemoTask(
        id: 'task_${day.day}_$i',
        title: _randomTaskTitle(),
        subtitle: _randomSubtitle(),
        start: start,
        duration: duration,
        color: _randomColor(),
        status: _random.nextBool()
            ? NeonTimelineStatus.pending
            : statuses[_random.nextInt(statuses.length)],
      ));
    }

    tasks.sort((a, b) => a.start.compareTo(b.start));
    return tasks;
  }

  List<DemoTask> generateLargeDataset(int count) {
    final tasks = <DemoTask>[];
    final baseDate = DateTime(2026, 1, 1);
    final statuses = NeonTimelineStatus.values;

    for (var i = 0; i < count; i++) {
      final dayOffset = _random.nextInt(365);
      final hour = 6 + _random.nextInt(16);
      final minute = _random.nextBool() ? 0 : 30;
      final start = baseDate.add(Duration(days: dayOffset, hours: hour, minutes: minute));
      final duration = Duration(minutes: 15 + _random.nextInt(12) * 15);

      tasks.add(DemoTask(
        id: 'task_large_$i',
        title: 'Task ${i + 1}: ${_randomTaskTitle()}',
        subtitle: _randomSubtitle(),
        start: start,
        duration: duration,
        color: _randomColor(),
        status: statuses[_random.nextInt(statuses.length)],
      ));
    }

    return tasks;
  }

  List<DemoTimelineItem> generateTimelineItems(int count) {
    final items = <DemoTimelineItem>[];
    final statuses = NeonTimelineStatus.values;
    final icons = [
      Icons.auto_awesome,
      Icons.bolt,
      Icons.flash_on,
      Icons.star,
      Icons.diamond,
      Icons.hexagon,
      Icons.pentagon,
      Icons.circle,
    ];

    for (var i = 0; i < count; i++) {
      final status = statuses[_random.nextInt(statuses.length)];
      final color = _colorForStatus(status);

      items.add(DemoTimelineItem(
        id: 'item_$i',
        status: status,
        semanticLabel: 'Item ${i + 1}, ${status.name}',
        content: _buildContent(i, color),
        oppositeContent: i % 3 == 0 ? _buildOppositeContent(i, color) : null,
        indicator: i % 5 == 0
            ? NeonTimelineIndicator(
                status: status,
                style: NeonTimelineIndicatorStyle(
                  color: color,
                  effect: _randomIndicatorEffect(),
                  size: 40,
                ),
              )
            : null,
        onTap: () {},
      ));
    }

    return items;
  }

  List<NeonScheduleEntry<DemoTask>> generateScheduleEntries(
    DateTime day, {
    int count = 8,
  }) {
    return generateTasksForDay(day, count: count)
        .map((task) => NeonScheduleEntry<DemoTask>(
              id: task.id,
              value: task,
              start: task.start,
              duration: task.duration,
              status: task.status,
              color: task.color,
              semanticLabel: '${task.title}, ${task.status.name}',
              draggable: task.draggable,
              enabled: task.enabled,
            ))
        .toList(growable: false);
  }

  List<NeonScheduleEntry<DemoTask>> generateLargeScheduleEntries(int count) {
    return generateLargeDataset(count)
        .map((task) => NeonScheduleEntry<DemoTask>(
              id: task.id,
              value: task,
              start: task.start,
              duration: task.duration,
              status: task.status,
              color: task.color,
              semanticLabel: '${task.title}, ${task.status.name}',
              draggable: task.draggable,
              enabled: task.enabled,
            ))
        .toList(growable: false);
  }

  String _randomTaskTitle() {
    const titles = [
      'Deep Work Session',
      'Design Review',
      'Code Review',
      'Team Standup',
      'Client Call',
      'Sprint Planning',
      'Refactoring',
      'Documentation',
      'Testing & QA',
      'Deployment',
      'Architecture Meeting',
      'Pair Programming',
      'Learning Session',
      'Bug Triage',
      'Performance Audit',
    ];
    return titles[_random.nextInt(titles.length)];
  }

  String _randomSubtitle() {
    const subtitles = [
      'Focus on core functionality',
      'Review PR #1234',
      'Sync with backend team',
      'Prepare release notes',
      'Fix critical bug',
      'Update dependencies',
      'Write unit tests',
      'Optimize database queries',
      'Clean up legacy code',
      'Improve accessibility',
    ];
    return subtitles[_random.nextInt(subtitles.length)];
  }

  Color _randomColor() {
    const colors = [
      Color(0xFFFF66B8),
      Color(0xFF67D9FF),
      Color(0xFF9D7BFF),
      Color(0xFFFF8A66),
      Color(0xFF52F0B9),
      Color(0xFFFFA05F),
      Color(0xFFFF4FC8),
      Color(0xFF5BE7FF),
      Color(0xFFFF8D5E),
      Color(0xFF64B7FF),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  Color _colorForStatus(NeonTimelineStatus status) {
    return switch (status) {
      NeonTimelineStatus.pending => const Color(0xFF77718F),
      NeonTimelineStatus.active => const Color(0xFF8B7CFF),
      NeonTimelineStatus.completed => const Color(0xFF29D391),
      NeonTimelineStatus.error => const Color(0xFFFF5D75),
      NeonTimelineStatus.disabled => const Color(0xFF5A5668),
    };
  }

  Widget _buildContent(int index, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Timeline Entry ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Neon timeline with advanced effects',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildOppositeContent(int index, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${(index % 12) + 1}:${(index * 5) % 60}'.padLeft(5, '0'),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  NeonIndicatorEffect _randomIndicatorEffect() {
    const effects = NeonIndicatorEffect.values;
    return effects[_random.nextInt(effects.length)];
  }
}

final FakeRepository demoRepo = FakeRepository.instance;
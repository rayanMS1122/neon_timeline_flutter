import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class DayPagerDemo extends StatefulWidget {
  const DayPagerDemo({super.key});

  @override
  State<DayPagerDemo> createState() => _DayPagerDemoState();
}

class _DayPagerDemoState extends State<DayPagerDemo> {
  DateTime _selectedDate = DateTime(2026, 7, 12);
  List<DemoTask> _tasks = [];
  late List<NeonScheduleEntry<DemoTask>> _entries;
  bool _showConflicts = true;
  bool _enableHaptics = true;
  bool _showNow = true;
  bool _autoActivate = true;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    _tasks = demoRepo.generateTasksForDay(_selectedDate, count: 8);
    _entries = _tasks
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

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _refreshTasks();
    });
  }

  void _completeTask(DemoTask task) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Completed: ${task.title}')));
  }

  void _deleteTask(DemoTask task) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted: ${task.title}')));
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Pager & Conflicts'),
        backgroundColor: Colors.transparent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_formatDate(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'conflicts':
                    _showConflicts = !_showConflicts;
                    break;
                  case 'haptics':
                    _enableHaptics = !_enableHaptics;
                    break;
                  case 'now':
                    _showNow = !_showNow;
                    break;
                  case 'auto':
                    _autoActivate = !_autoActivate;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              _buildItem('conflicts', 'Show Conflicts', _showConflicts),
              _buildItem('haptics', 'Enable Haptics', _enableHaptics),
              _buildItem('now', 'Show Now Indicator', _showNow),
              _buildItem('auto', 'Auto Activate Current', _autoActivate),
            ],
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: NeonTimelineDayPager(
        selectedDate: _selectedDate,
        onDateChanged: _onDateChanged,
        child: NeonScheduleTimeline<DemoTask>(
          entries: _entries,
          selectedDate: _selectedDate,
          now: DateTime(2026, 7, 12, 10, 42),
          showNowIndicator: _showNow,
          autoActivateCurrentEntry: _autoActivate,
          enableDragHaptics: _enableHaptics,
          emptyBuilder: (context) => const _EmptyState(
            icon: Icons.event_available,
            title: 'No events today',
            message: 'Swipe to navigate days',
          ),
          itemBuilder: (context, details) => _TaskCard(task: details.entry.value, details: details),
          style: NeonScheduleTimelineStyle(
            showDurationRail: true,
            overlapIndent: _showConflicts ? 16 : 0,
            cardVariant: NeonTimelineCardVariant.liquidCrystal,
          ),
          startActionsBuilder: (context, details) => [
            NeonTimelineAction(
              icon: Icons.check,
              label: 'DONE',
              color: Colors.green,
              semanticLabel: 'Complete task',
              onPressed: (_) => _completeTask(details.entry.value),
            ),
          ],
          endActionsBuilder: (context, details) => [
            NeonTimelineAction(
              icon: Icons.delete,
              label: 'DELETE',
              color: Colors.red,
              semanticLabel: 'Delete task',
              onPressed: (_) => _deleteTask(details.entry.value),
            ),
          ],
          onEntryEndDismissed: (context, details) => _deleteTask(details.entry.value),
          conflictLabelBuilder: (context, details) => 'CONFLICT: ${details.entry.value.title} overlaps',
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildItem(String value, String title, bool checked) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, size: 20),
        const SizedBox(width: 12),
        Text(title),
      ]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.details});

  final DemoTask task;
  final NeonScheduleEntryDetails<DemoTask> details;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: task.color.withAlpha(33),
            shape: BoxShape.circle,
            border: Border.all(color: task.color.withAlpha(72)),
          ),
          child: Icon(
            task.status == NeonTimelineStatus.completed ? Icons.check_rounded : Icons.bolt_rounded,
            color: task.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              Text(task.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 11)),
              if (details.overlapsPrevious || details.overlapsNext) ...[
                const SizedBox(height: 7),
                Text('OVERLAP DETECTED',
                    style: TextStyle(color: task.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white.withAlpha(100)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withAlpha(150))),
          ],
        ),
      ),
    );
  }
}
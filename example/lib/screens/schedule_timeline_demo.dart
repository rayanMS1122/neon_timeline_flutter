import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class ScheduleTimelineDemo extends StatefulWidget {
  const ScheduleTimelineDemo({super.key});

  @override
  State<ScheduleTimelineDemo> createState() => _ScheduleTimelineDemoState();
}

class _ScheduleTimelineDemoState extends State<ScheduleTimelineDemo> {
  DateTime _selectedDate = DateTime(2026, 7, 12);
  List<DemoTask> _tasks = [];
  late List<NeonScheduleEntry<DemoTask>> _entries;
  bool _showNowIndicator = true;
  bool _autoActivateCurrent = true;
  bool _useDefaultCard = true;
  bool _enableDragHaptics = true;
  bool _motionEnabled = true;
  bool _animateOnlyCurrent = true;
  NeonSlidableMotion _slidableMotion = NeonSlidableMotion.scroll;
  bool _closeSlidablesOnScroll = true;
  int _motionFps = 30;

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

  void _moveTask(DemoTask task, DateTime newStart) {
    setState(() {
      _tasks = _tasks
          .map((item) => item.id == task.id ? item.copyWith(start: newStart) : item)
          .toList(growable: false);
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
    });
  }

  void _completeTask(DemoTask task) {
    setState(() {
      _tasks = _tasks
          .map((item) => item.id == task.id
              ? item.copyWith(status: NeonTimelineStatus.completed)
              : item)
          .toList(growable: false);
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
    });
    _showSnackBar('Completed: ${task.title}');
  }

  void _deleteTask(DemoTask task) {
    setState(() {
      _tasks = _tasks.where((item) => item.id != task.id).toList();
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
    });
    _showSnackBar('Deleted: ${task.title}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Timeline'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Previous day',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              _refreshTasks();
            }),
          ),
          Center(
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
              _refreshTasks();
            }),
          ),
          PopupMenuButton<String>(
            tooltip: 'Options',
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              _buildMenuItem('now', 'Show Now Indicator', _showNowIndicator),
              _buildMenuItem('auto', 'Auto-activate Current', _autoActivateCurrent),
              _buildMenuItem('card', 'Use Default Card', _useDefaultCard),
              _buildMenuItem('haptics', 'Drag Haptics', _enableDragHaptics),
              _buildMenuItem('motion', 'Motion Enabled', _motionEnabled),
              _buildMenuItem('animate', 'Animate Only Current', _animateOnlyCurrent),
              const PopupMenuDivider(),
              _buildMenuItem('fps30', '30 FPS', _motionFps == 30),
              _buildMenuItem('fps60', '60 FPS', _motionFps == 60),
            ],
          ),
        ],
      ),
      body: NeonTimelineDayPager(
        selectedDate: _selectedDate,
        onDateChanged: (date) {
          _selectedDate = date;
          _refreshTasks();
        },
        child: NeonScheduleTimeline<DemoTask>(
          entries: _entries,
          selectedDate: _selectedDate,
          now: DateTime(2026, 7, 12, 10, 42),
          showNowIndicator: _showNowIndicator,
          autoActivateCurrentEntry: _autoActivateCurrent,
          useDefaultCard: _useDefaultCard,
          enableDragHaptics: _enableDragHaptics,
          motionEnabled: _motionEnabled,
          animateOnlyCurrentEntry: _animateOnlyCurrent,
          slidableMotion: _slidableMotion,
          closeSlidablesOnScroll: _closeSlidablesOnScroll,
          motionFramesPerSecond: _motionFps,
          emptyBuilder: (context) => const _EmptyScheduleState(),
          itemBuilder: (context, details) {
            final task = details.entry.value;
            return _TaskCardContent(task: task, details: details);
          },
          onEntryTap: (context, details) {
            _showSnackBar('Opened ${details.entry.value.title}');
          },
          onEntryMoved: (context, details, newStart) {
            _moveTask(details.entry.value, newStart);
          },
          startActionsBuilder: (context, details) => [
            NeonTimelineAction(
              icon: Icons.check_rounded,
              label: 'DONE',
              color: const Color(0xFF22B573),
              semanticLabel: 'Mark as completed',
              onPressed: (_) => _completeTask(details.entry.value),
            ),
            if (details.entry.value.status != NeonTimelineStatus.error)
              NeonTimelineAction(
                icon: Icons.error_outline,
                label: 'ERROR',
                color: const Color(0xFFFF5D75),
                semanticLabel: 'Mark as error',
                onPressed: (_) => setState(() {
                  _tasks = _tasks
                      .map((item) => item.id == details.entry.value.id
                          ? item.copyWith(status: NeonTimelineStatus.error)
                          : item)
                      .toList(growable: false);
                  _refreshTasks();
                }),
              ),
          ],
          endActionsBuilder: (context, details) => [
            NeonTimelineAction(
              icon: Icons.delete_outline_rounded,
              label: 'DELETE',
              color: const Color(0xFFE5485D),
              semanticLabel: 'Delete task',
              onPressed: (_) => _deleteTask(details.entry.value),
            ),
          ],
          onEntryEndDismissed: (context, details) {
            _deleteTask(details.entry.value);
          },
          onOperationError: (context, details, error, stackTrace) {
            _showSnackBar('Operation failed: $error');
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String title, bool checked) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, size: 20),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    setState(() {
      switch (value) {
        case 'now':
          _showNowIndicator = !_showNowIndicator;
          break;
        case 'auto':
          _autoActivateCurrent = !_autoActivateCurrent;
          break;
        case 'card':
          _useDefaultCard = !_useDefaultCard;
          break;
        case 'haptics':
          _enableDragHaptics = !_enableDragHaptics;
          break;
        case 'motion':
          _motionEnabled = !_motionEnabled;
          break;
        case 'animate':
          _animateOnlyCurrent = !_animateOnlyCurrent;
          break;
        case 'fps30':
          _motionFps = 30;
          break;
        case 'fps60':
          _motionFps = 60;
          break;
      }
    });
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}

class _TaskCardContent extends StatelessWidget {
  const _TaskCardContent({
    required this.task,
    required this.details,
  });

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
            task.status == NeonTimelineStatus.completed
                ? Icons.check_rounded
                : Icons.bolt_rounded,
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
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(148),
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
              if (details.overlapsPrevious || details.overlapsNext) ...[
                const SizedBox(height: 7),
                Text(
                  'OVERLAP DETECTED',
                  style: TextStyle(
                    color: task.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 42),
          SizedBox(height: 14),
          Text('No entries for this day'),
          SizedBox(height: 8),
          Text('Swipe to another day or add events',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }
}
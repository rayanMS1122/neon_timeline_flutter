import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() => runApp(const NeonTimelineExampleApp());

class NeonTimelineExampleApp extends StatelessWidget {
  const NeonTimelineExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineTheme = NeonTimelineThemeData.omniverse();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Timeline Flutter',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF08070E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: timelineTheme.primaryColor,
          brightness: Brightness.dark,
        ),
        extensions: <ThemeExtension<dynamic>>[timelineTheme],
      ),
      home: const _ExamplePage(),
    );
  }
}

class _ExamplePage extends StatefulWidget {
  const _ExamplePage();

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  DateTime _selectedDate = DateTime(2026, 7, 11);
  late List<_DemoTask> _tasks = <_DemoTask>[
    _DemoTask(
      id: 'deep-work',
      title: 'Deep work block',
      subtitle: 'Finish the timeline package API',
      start: DateTime(2026, 7, 11, 8, 30),
      duration: const Duration(minutes: 90),
      color: const Color(0xFFFF66B8),
      status: NeonTimelineStatus.completed,
    ),
    _DemoTask(
      id: 'review',
      title: 'Design review',
      subtitle: 'Interaction, accessibility, and motion',
      start: DateTime(2026, 7, 11, 10, 30),
      duration: const Duration(minutes: 55),
      color: const Color(0xFF67D9FF),
      status: NeonTimelineStatus.active,
    ),
    _DemoTask(
      id: 'publish',
      title: 'Prepare publication',
      subtitle: 'README, tests, dry run, and release notes',
      start: DateTime(2026, 7, 11, 12),
      duration: const Duration(minutes: 75),
      color: const Color(0xFF9D7BFF),
    ),
    _DemoTask(
      id: 'conflict',
      title: 'Intentional overlap',
      subtitle: 'Shows conflict detection and indentation',
      start: DateTime(2026, 7, 11, 12, 45),
      duration: const Duration(minutes: 45),
      color: const Color(0xFFFF8A66),
    ),
  ];

  List<NeonScheduleEntry<_DemoTask>> get _entries {
    return _tasks
        .map(
          (task) => NeonScheduleEntry<_DemoTask>(
            id: task.id,
            value: task,
            start: task.start,
            duration: task.duration,
            status: task.status,
            color: task.color,
            semanticLabel: '${task.title}, ${task.status.name}',
          ),
        )
        .toList(growable: false);
  }

  void _moveTask(_DemoTask task, DateTime newStart) {
    setState(() {
      _tasks = _tasks
          .map((item) => item.id == task.id ? item.copyWith(start: newStart) : item)
          .toList(growable: false);
    });
  }

  void _completeTask(_DemoTask task) {
    setState(() {
      _tasks = _tasks
          .map(
            (item) => item.id == task.id
                ? item.copyWith(status: NeonTimelineStatus.completed)
                : item,
          )
          .toList(growable: false);
    });
  }

  void _deleteTask(_DemoTask task) {
    setState(() => _tasks = _tasks.where((item) => item.id != task.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neon Schedule Timeline'),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            tooltip: 'Previous day',
            onPressed: () => setState(
              () => _selectedDate =
                  _selectedDate.subtract(const Duration(days: 1)),
            ),
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
            ),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF08070E),
              Color(0xFF121026),
              Color(0xFF08070E),
            ],
          ),
        ),
        child: NeonTimelineDayPager(
          selectedDate: _selectedDate,
          onDateChanged: (value) => setState(() => _selectedDate = value),
          child: NeonScheduleTimeline<_DemoTask>(
            entries: _entries,
            selectedDate: _selectedDate,
            now: DateTime(2026, 7, 11, 10, 42),
            emptyBuilder: (context) => const _EmptyDay(),
            itemBuilder: (context, details) {
              final task = details.entry.value;
              return _TaskCardContent(task: task, details: details);
            },
            onEntryTap: (context, details) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Opened ${details.entry.value.title}')),
                );
            },
            onEntryMoved: (context, details, newStart) {
              _moveTask(details.entry.value, newStart);
            },
            startActionsBuilder: (context, details) => <NeonTimelineAction>[
              NeonTimelineAction(
                icon: Icons.check_rounded,
                label: 'DONE',
                color: const Color(0xFF22B573),
                onPressed: (_) => _completeTask(details.entry.value),
              ),
            ],
            endActionsBuilder: (context, details) => <NeonTimelineAction>[
              NeonTimelineAction(
                icon: Icons.delete_outline_rounded,
                label: 'DELETE',
                color: const Color(0xFFE5485D),
                onPressed: (_) => _deleteTask(details.entry.value),
              ),
            ],
            onEntryEndDismissed: (context, details) {
              _deleteTask(details.entry.value);
            },
          ),
        ),
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  const _TaskCardContent({required this.task, required this.details});

  final _DemoTask task;
  final NeonScheduleEntryDetails<_DemoTask> details;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: task.color.withOpacity(0.13),
            shape: BoxShape.circle,
            border: Border.all(color: task.color.withOpacity(0.28)),
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
            children: <Widget>[
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.58),
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
              if (details.overlapsPrevious || details.overlapsNext) ...<Widget>[
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

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, size: 42),
          SizedBox(height: 14),
          Text('No entries for this day'),
        ],
      ),
    );
  }
}

class _DemoTask {
  const _DemoTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    this.status = NeonTimelineStatus.pending,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final NeonTimelineStatus status;

  _DemoTask copyWith({
    DateTime? start,
    NeonTimelineStatus? status,
  }) {
    return _DemoTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration,
      color: color,
      status: status ?? this.status,
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

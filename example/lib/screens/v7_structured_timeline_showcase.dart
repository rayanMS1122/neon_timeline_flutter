import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

class V7StructuredTimelineShowcase extends StatefulWidget {
  const V7StructuredTimelineShowcase({super.key});

  @override
  State<V7StructuredTimelineShowcase> createState() =>
      _V7StructuredTimelineShowcaseState();
}

class _V7StructuredTimelineShowcaseState
    extends State<V7StructuredTimelineShowcase> {
  late DateTime _selectedDate;
  late List<_DemoTask> _tasks;
  late final TimelinePlannerEngine<_DemoTask> _engine;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seedTasks(_selectedDate, now);
    _engine = TimelinePlannerEngine<_DemoTask>(
      adapter: TimelineSeriesAdapter<_DemoTask>(
        entryAdapter: TimelineEntryAdapter<_DemoTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => task.duration,
          status: (task) => task.completed
              ? TimelineStatus.completed
              : TimelineStatus.pending,
          color: (task) => task.color,
          semanticLabel: (task) => task.title,
          draggable: (task) => !task.external,
          metadata: (task) => <String, Object?>{
            'structured.subtitle': task.subtitle,
            'structured.progress': task.progress,
            'timeline.external': task.external,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF9F8F6);
    final style = StructuredTimelineStyle.light();
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            _buildWeekStrip(style),
            const SizedBox(height: 8),
            _buildModeSelector(style),
            const SizedBox(height: 8),
            Expanded(
              child: StructuredTimelinePlanner<_DemoTask>(
                values: _tasks,
                engine: _engine,
                selectedDate: _selectedDate,
                dataRevision: Object.hashAll(
                  _tasks.map(
                    (task) => Object.hash(
                      task.id,
                      task.start,
                      task.duration,
                      task.completed,
                    ),
                  ),
                ),
                style: style,
                showBoundaryGaps: false,
                enableDeleteTarget: true,
                initialScroll: StructuredTimelineInitialScroll.current,
                titleBuilder: (entry) => entry.value.title,
                subtitleBuilder: (entry) => entry.value.subtitle,
                progressBuilder: (entry) => entry.value.progress,
                onEntryTap: (context, details) {
                  _showTaskSheet(context, details.value);
                },
                onComplete: (context, details) {
                  setState(() {
                    _tasks = _tasks
                        .map(
                          (task) => task.id == details.value.id
                              ? task.copyWith(completed: !task.completed)
                              : task,
                        )
                        .toList(growable: false);
                  });
                },
                onMove: (context, details) async {
                  final moved = details.preview.start;
                  setState(() {
                    _tasks = _tasks
                        .map(
                          (task) => task.id == details.entry.value.id
                              ? task.copyWith(start: moved)
                              : task,
                        )
                        .toList(growable: false);
                  });
                },
                onDelete: (context, details) {
                  setState(() {
                    _tasks = _tasks
                        .where((task) => task.id != details.entry.value.id)
                        .toList(growable: false);
                  });
                },
                onInsert: (context, gap) {
                  final start = gap.start.add(const Duration(minutes: 10));
                  _addTask(start: start);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(),
        backgroundColor: const Color(0xFF5B2135),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${_selectedDate.day}. ${_monthName(_selectedDate.month)}',
              style: const TextStyle(
                color: Color(0xFF1C1917),
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add task',
            onPressed: () => _addTask(),
            icon: const Icon(Icons.add_rounded),
            color: const Color(0xFF5B2135),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            color: const Color(0xFF5B2135),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(StructuredTimelineStyle style) {
    final monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final day = DateTime(monday.year, monday.month, monday.day + index);
          final selected = _sameDay(day, _selectedDate);
          final hasTasks = _tasks.any((task) => _sameDay(task.start, day));
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? style.primaryColor.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    const <String>[
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][index],
                    style: TextStyle(
                      color: style.mutedTextColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 29,
                    height: 29,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFC4A6B0) : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : style.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (hasTasks)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: style.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeSelector(StructuredTimelineStyle style) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEEC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'DAY',
                  style: TextStyle(
                    color: Color(0xFF5B2135),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'WEEK',
                style: TextStyle(
                  color: style.mutedTextColor.withValues(alpha: 0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask({DateTime? start}) {
    final resolvedStart =
        start ??
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          14,
        );
    final next = _DemoTask(
      id: 'task-${DateTime.now().microsecondsSinceEpoch}',
      title: 'New focus block',
      subtitle: 'Long-press and drag to reschedule',
      start: resolvedStart,
      duration: const Duration(minutes: 30),
      color: const Color(0xFFE11D48),
      progress: 0,
    );
    setState(() => _tasks = <_DemoTask>[..._tasks, next]);
  }

  void _showTaskSheet(BuildContext context, _DemoTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF9F8F6),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(task.subtitle),
              const SizedBox(height: 18),
              const Text(
                'The package owns the timeline interaction. Your app still owns this sheet, persistence, and navigation.',
              ),
            ],
          ),
        );
      },
    );
  }

  static List<_DemoTask> _seedTasks(DateTime day, DateTime now) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    final currentStart = _sameDay(day, now)
        ? now.subtract(const Duration(minutes: 10))
        : at(9, 30);
    return <_DemoTask>[
      _DemoTask(
        id: 'focus',
        title: 'Deep work block',
        subtitle: 'Roadmap and architecture',
        start: currentStart,
        duration: const Duration(minutes: 50),
        color: const Color(0xFFE11D48),
        progress: 0.45,
      ),
      _DemoTask(
        id: 'review',
        title: 'Design review',
        subtitle: 'Interaction and accessibility pass',
        start: currentStart.add(const Duration(hours: 2, minutes: 5)),
        duration: const Duration(minutes: 35),
        color: const Color(0xFF8B5CF6),
        progress: 0.7,
      ),
      _DemoTask(
        id: 'calendar',
        title: 'Calendar event',
        subtitle: 'External events stay locked',
        start: currentStart.add(const Duration(hours: 4, minutes: 25)),
        duration: const Duration(minutes: 45),
        color: const Color(0xFF0EA5E9),
        progress: null,
        external: true,
      ),
      _DemoTask(
        id: 'release',
        title: 'Prepare release notes',
        subtitle: 'Documentation and migration guide',
        start: currentStart.add(const Duration(hours: 6, minutes: 15)),
        duration: const Duration(minutes: 30),
        color: const Color(0xFFF59E0B),
        progress: 0.2,
      ),
    ];
  }

  static bool _sameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static String _monthName(int month) {
    return const <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][month - 1];
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
    required this.progress,
    this.completed = false,
    this.external = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final double? progress;
  final bool completed;
  final bool external;

  _DemoTask copyWith({DateTime? start, bool? completed}) {
    return _DemoTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration,
      color: color,
      progress: progress,
      completed: completed ?? this.completed,
      external: external,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v11.dart';

class V11UltimateTimelineShowcase extends StatefulWidget {
  const V11UltimateTimelineShowcase({super.key});

  @override
  State<V11UltimateTimelineShowcase> createState() =>
      _V11UltimateTimelineShowcaseState();
}

class _V11UltimateTimelineShowcaseState
    extends State<V11UltimateTimelineShowcase> {
  late DateTime _selectedDate;
  late List<_DelightTask> _tasks;
  late final TimelinePlannerEngine<_DelightTask> _engine;
  late final StructuredTimelineController<_DelightTask> _controller;
  late final TimelineMutationCoordinator<_DelightTask> _mutations;
  bool _dark = false;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _controller = StructuredTimelineController<_DelightTask>();
    _mutations = TimelineMutationCoordinator<_DelightTask>();
    _engine = TimelinePlannerEngine<_DelightTask>(
      adapter: TimelineSeriesAdapter<_DelightTask>(
        entryAdapter: TimelineEntryAdapter<_DelightTask>(
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
            'timeline.seriesId': task.recurring ? 'delight-series' : null,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _mutations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _dark
        ? StructuredTimelineStyle.dark()
        : StructuredTimelineStyle.delight();
    final snapshot = _engine.buildDay(
      values: _tasks,
      selectedDate: _selectedDate,
      now: DateTime.now(),
    );
    final metrics = StructuredTimelineMetrics.fromPlan(snapshot.dayPlan);

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: _dark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: style.primaryColor,
          brightness: _dark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: StructuredTimelineScaffold(
        backgroundColor: style.backgroundColor,
        appBar: StructuredTimelineAppBar(
          title: 'Ultimate Structured Timeline',
          subtitle: _dragging
              ? 'Move the task — magnetic slots and conflicts update live'
              : '11.0.0 · stable live drag, semantic zoom, undo and offline feedback',
          backgroundColor: style.surfaceColor,
          actions: <Widget>[
            IconButton(
              tooltip: 'Jump to now',
              onPressed: _controller.jumpToNow,
              icon: const Icon(Icons.my_location_rounded),
            ),
            IconButton(
              tooltip: _dark ? 'Light mode' : 'Dark mode',
              onPressed: () => setState(() => _dark = !_dark),
              icon: Icon(
                _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
            ),
          ],
        ),
        header: StructuredTimelineDayHeader(
          date: _selectedDate,
          style: style,
          metrics: metrics,
          onPrevious: () => _changeDay(-1),
          onNext: () => _changeDay(1),
          onSelectWeekDay: (date) => setState(() => _selectedDate = date),
          controls: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                tooltip: 'Zoom out',
                onPressed: _controller.zoomOut,
                icon: const Icon(Icons.zoom_out_rounded),
              ),
              IconButton(
                tooltip: 'Reset zoom',
                onPressed: _controller.resetZoom,
                icon: const Icon(Icons.center_focus_strong_rounded),
              ),
              IconButton(
                tooltip: 'Zoom in',
                onPressed: _controller.zoomIn,
                icon: const Icon(Icons.zoom_in_rounded),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            UltimateStructuredTimeline<_DelightTask>(
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
              controller: _controller,
              mutationCoordinator: _mutations,
              config: const StructuredTimelineV11Config.production(),
              onEntryTap: (context, details) => _showTask(details.value),
              onComplete: (context, details) async {
                await _saveDelay();
                if (!mounted) return;
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
                await _saveDelay();
                if (!mounted) return;
                setState(() {
                  _tasks = _tasks
                      .map(
                        (task) => task.id == details.value.id
                            ? task.copyWith(start: details.preview.start)
                            : task,
                      )
                      .toList(growable: false);
                });
              },
              onResize: (context, details) async {
                await _saveDelay();
                if (!mounted) return;
                setState(() {
                  _tasks = _tasks
                      .map(
                        (task) => task.id == details.value.id
                            ? task.copyWith(
                                start: details.preview.start,
                                duration: details.preview.duration,
                              )
                            : task,
                      )
                      .toList(growable: false);
                });
              },
              onDelete: (context, details) async {
                await _saveDelay();
                if (!mounted) return;
                setState(() {
                  _tasks = _tasks
                      .where((task) => task.id != details.value.id)
                      .toList(growable: false);
                });
              },
              onInsert: (context, gap) =>
                  _addTask(gap.start.add(const Duration(minutes: 5))),
            ),
            if (!_dragging)
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.surfaceColor.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: style.borderColor),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: style.shadowColor,
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Text(
                          'Long-press a task, then move it between magnetic slots',
                          style: TextStyle(
                            color: style.textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingAction: AnimatedScale(
          scale: _dragging ? 0 : 1,
          duration: const Duration(milliseconds: 140),
          child: StructuredTimelineFloatingAddButton(
            label: 'Add task',
            backgroundColor: style.primaryColor,
            foregroundColor: Colors.white,
            onPressed: _addTask,
          ),
        ),
      ),
    );
  }

  Future<void> _saveDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 180));

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + delta,
      );
      _tasks = _seed(_selectedDate);
    });
  }

  void _addTask([DateTime? start]) {
    final resolved =
        start ??
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          16,
        );
    setState(() {
      _tasks = <_DelightTask>[
        ..._tasks,
        _DelightTask(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
          title: 'New focus block',
          subtitle: 'Drag, resize, complete or connect your own task sheet',
          start: resolved,
          duration: const Duration(minutes: 45),
          color: const Color(0xFF6A2441),
          progress: 0.08,
        ),
      ];
    });
  }

  void _showTask(_DelightTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task.title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(task.subtitle),
            const SizedBox(height: 18),
            const Text(
              'This sheet belongs to the app. The package owns the reusable timeline interaction underneath.',
            ),
          ],
        ),
      ),
    );
  }

  static List<_DelightTask> _seed(DateTime day) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return <_DelightTask>[
      _DelightTask(
        id: 'focus',
        title: 'Deep product work',
        subtitle: 'Magnetic drag snaps cleanly after nearby tasks',
        start: at(8, 30),
        duration: const Duration(minutes: 80),
        color: const Color(0xFFE94F78),
        progress: 0.58,
        recurring: true,
      ),
      _DelightTask(
        id: 'review',
        title: 'Design and accessibility review',
        subtitle: 'Adaptive card content never fights the available height',
        start: at(11, 5),
        duration: const Duration(minutes: 60),
        color: const Color(0xFF7C3AED),
        progress: 0.34,
      ),
      _DelightTask(
        id: 'calendar',
        title: 'External calendar event',
        subtitle: 'Locked, visible and conflict-aware',
        start: at(14, 15),
        duration: const Duration(minutes: 50),
        color: const Color(0xFF0F766E),
        progress: 0,
        external: true,
      ),
      _DelightTask(
        id: 'ship',
        title: 'Ship the release',
        subtitle: 'Resize the end handle or drag into the evening slot',
        start: at(17, 10),
        duration: const Duration(minutes: 70),
        color: const Color(0xFFF59E0B),
        progress: 0.76,
      ),
    ];
  }
}

class _DelightTask {
  const _DelightTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    required this.progress,
    this.completed = false,
    this.external = false,
    this.recurring = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final double progress;
  final bool completed;
  final bool external;
  final bool recurring;

  _DelightTask copyWith({
    DateTime? start,
    Duration? duration,
    bool? completed,
  }) {
    return _DelightTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      progress: progress,
      completed: completed ?? this.completed,
      external: external,
      recurring: recurring,
    );
  }
}

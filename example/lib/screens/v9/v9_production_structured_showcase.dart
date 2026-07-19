import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

import 'v9_component_explorer.dart';

class V9ProductionStructuredShowcase extends StatefulWidget {
  const V9ProductionStructuredShowcase({super.key});

  @override
  State<V9ProductionStructuredShowcase> createState() =>
      _V9ProductionStructuredShowcaseState();
}

class _V9ProductionStructuredShowcaseState
    extends State<V9ProductionStructuredShowcase> {
  late DateTime _selectedDate;
  late List<_V9Task> _tasks;
  late final TimelinePlannerEngine<_V9Task> _engine;
  late final StructuredTimelineController<_V9Task> _controller;
  late final TimelineMutationCoordinator<_V9Task> _mutations;
  bool _dark = false;
  StructuredTimelineZoomLevel _zoomLevel = StructuredTimelineZoomLevel.normal;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _controller = StructuredTimelineController<_V9Task>();
    _mutations = TimelineMutationCoordinator<_V9Task>();
    _engine = TimelinePlannerEngine<_V9Task>(
      adapter: TimelineSeriesAdapter<_V9Task>(
        entryAdapter: TimelineEntryAdapter<_V9Task>(
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
            'timeline.seriesId': task.recurring ? 'daily-focus' : null,
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
        : StructuredTimelineStyle.light();
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
          title: 'Production Structured Timeline',
          subtitle: '9.0.0 · public components, safe cards and compressed gaps',
          backgroundColor: style.surfaceColor,
          actions: <Widget>[
            IconButton(
              tooltip: 'Component explorer',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => V9ComponentExplorer(dark: _dark),
                  ),
                );
              },
              icon: const Icon(Icons.widgets_rounded),
            ),
            IconButton(
              tooltip: _dark ? 'Use light theme' : 'Use dark theme',
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
          controls: StructuredTimelineViewControls(
            zoomLevel: _zoomLevel,
            onZoomOut: () {
              _controller.zoomOut();
              setState(() => _zoomLevel = _controller.zoomLevel);
            },
            onZoomIn: () {
              _controller.zoomIn();
              setState(() => _zoomLevel = _controller.zoomLevel);
            },
            onResetZoom: () {
              _controller.resetZoom();
              setState(() => _zoomLevel = StructuredTimelineZoomLevel.normal);
            },
            additionalActions: <Widget>[
              IconButton(
                tooltip: 'Jump to now',
                onPressed: _controller.jumpToNow,
                icon: const Icon(Icons.my_location_rounded),
              ),
            ],
          ),
        ),
        body: ProductionStructuredTimeline<_V9Task>(
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
          entryStyle: const StructuredTimelineEntryStyle.comfortable(),
          gapLayout: const StructuredTimelineGapLayout.hybrid(
            compressionStartsAt: Duration(hours: 2),
            compressedExtent: 86,
          ),
          showBoundaryGaps: false,
          showGapActions: false,
          enableDeleteTarget: true,
          titleBuilder: (entry) => entry.value.title,
          subtitleBuilder: (entry) => entry.value.subtitle,
          progressBuilder: (entry) => entry.value.progress,
          onEntryTap: (context, details) => _showTask(details.value),
          onComplete: (context, details) async {
            await _simulateSave();
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
            await _simulateSave();
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
            await _simulateSave();
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
            await _simulateSave();
            if (!mounted) return;
            setState(() {
              _tasks = _tasks
                  .where((task) => task.id != details.value.id)
                  .toList(growable: false);
            });
          },
          onInsert: (context, gap) {
            _addTask(gap.start.add(const Duration(minutes: 5)));
          },
          onMutationError: (context, entry, error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not save ${entry.semanticLabel}')),
            );
          },
        ),
        floatingAction: StructuredTimelineFloatingAddButton(
          label: 'Add task',
          backgroundColor: style.primaryColor,
          foregroundColor: Colors.white,
          onPressed: _addTask,
        ),
      ),
    );
  }

  Future<void> _simulateSave() =>
      Future<void>.delayed(const Duration(milliseconds: 220));

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + delta,
      );
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
      _tasks = <_V9Task>[
        ..._tasks,
        _V9Task(
          id: 'new-${DateTime.now().microsecondsSinceEpoch}',
          title: 'New focus block',
          subtitle: 'Long-press to move, use handles to resize',
          start: resolved,
          duration: const Duration(minutes: 40),
          color: const Color(0xFF5B2135),
          progress: 0.1,
        ),
      ];
    });
  }

  void _showTask(_V9Task task) {
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(task.subtitle),
            const SizedBox(height: 16),
            const Text(
              'The app owns this sheet and persistence. The package owns timeline layout and interaction.',
            ),
          ],
        ),
      ),
    );
  }

  static List<_V9Task> _seed(DateTime day) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return <_V9Task>[
      _V9Task(
        id: 'morning',
        title:
            'Deep work and architecture review with a deliberately long title',
        subtitle: 'Overflow-safe card with adaptive information density',
        start: at(8, 30),
        duration: const Duration(minutes: 70),
        color: const Color(0xFFBE123C),
        progress: 0.62,
        recurring: true,
      ),
      _V9Task(
        id: 'review',
        title: 'Design review',
        subtitle: 'Accessibility, drag and resize behavior',
        start: at(11, 10),
        duration: const Duration(minutes: 55),
        color: const Color(0xFF7C3AED),
        progress: 0.35,
      ),
      _V9Task(
        id: 'calendar',
        title: 'External calendar event',
        subtitle: 'Visible, conflict-aware and locked',
        start: at(14, 20),
        duration: const Duration(minutes: 45),
        color: const Color(0xFF0F766E),
        progress: 0,
        external: true,
      ),
      _V9Task(
        id: 'overnight',
        title: 'Late release preparation',
        subtitle: 'Continues into the next day',
        start: at(23, 24),
        duration: const Duration(minutes: 55),
        color: const Color(0xFFE11D48),
        progress: 0.74,
      ),
    ];
  }
}

class _V9Task {
  const _V9Task({
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

  _V9Task copyWith({DateTime? start, Duration? duration, bool? completed}) {
    return _V9Task(
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

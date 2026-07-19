import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v12.dart';

class V12UltimateTimelineShowcase extends StatefulWidget {
  const V12UltimateTimelineShowcase({super.key});

  @override
  State<V12UltimateTimelineShowcase> createState() =>
      _V12UltimateTimelineShowcaseState();
}

class _V12UltimateTimelineShowcaseState
    extends State<V12UltimateTimelineShowcase> {
  late DateTime _selectedDate;
  late List<_PlannerTask> _tasks;
  late final TimelinePlannerEngine<_PlannerTask> _engine;
  late final UltimateStructuredTimelineController<_PlannerTask> _controller;
  late final TimelineMutationCoordinator<_PlannerTask> _mutations;
  StructuredTimelinePersistenceState _persistence =
      StructuredTimelinePersistenceState.idle;
  bool _dark = false;
  bool _rtl = false;
  bool _largeText = false;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _controller = UltimateStructuredTimelineController<_PlannerTask>(
      zoomLevel: UltimateTimelineZoomLevel.comfortable,
    );
    _mutations = TimelineMutationCoordinator<_PlannerTask>();
    _engine = TimelinePlannerEngine<_PlannerTask>(
      adapter: TimelineSeriesAdapter<_PlannerTask>(
        entryAdapter: TimelineEntryAdapter<_PlannerTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => task.duration,
          status: (task) => task.completed
              ? TimelineStatus.completed
              : TimelineStatus.pending,
          color: (task) => task.color,
          semanticLabel: (task) => task.title,
          draggable: (task) => !task.external,
          metadata: (task) => {
            'structured.subtitle': task.subtitle,
            'structured.progress': task.progress,
            'timeline.external': task.external,
            'timeline.locked': task.external,
            'timeline.seriesId': task.recurring ? 'weekly-focus' : null,
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
    final brightness = _dark ? Brightness.dark : Brightness.light;
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D48E8),
          brightness: brightness,
        ),
      ),
      child: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_largeText ? 2 : 1)),
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ultimate Structured Timeline 12.0'),
                  Text(
                    _dragging
                        ? 'Live target, snap and conflict feedback'
                        : 'Adaptive cards · weighted snap · natural auto-scroll',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Undo',
                  onPressed: null,
                  icon: const Icon(Icons.undo_rounded),
                ),
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: _controller.zoomOut,
                  icon: const Icon(Icons.zoom_out_rounded),
                ),
                IconButton(
                  tooltip: 'Zoom in',
                  onPressed: _controller.zoomIn,
                  icon: const Icon(Icons.zoom_in_rounded),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Preview modes',
                  onSelected: _setMode,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'theme', child: Text('Toggle theme')),
                    PopupMenuItem(value: 'rtl', child: Text('Toggle RTL')),
                    PopupMenuItem(
                      value: 'text',
                      child: Text('Toggle 200% text'),
                    ),
                    PopupMenuItem(
                      value: 'offline',
                      child: Text('Simulate offline'),
                    ),
                    PopupMenuItem(
                      value: 'failed',
                      child: Text('Simulate failure'),
                    ),
                  ],
                ),
              ],
            ),
            body: UltimateStructuredTimeline<_PlannerTask>(
              values: _tasks,
              engine: _engine,
              selectedDate: _selectedDate,
              controller: _controller,
              mutationCoordinator: _mutations,
              config: const UltimateStructuredTimelineConfig.production(),
              persistenceState: _persistence,
              persistenceMessage: _persistenceMessage,
              onRetry: () => setState(
                () => _persistence = StructuredTimelinePersistenceState.idle,
              ),
              onDateChanged: (date) => setState(() {
                _selectedDate = DateTime(date.year, date.month, date.day);
                _tasks = _seed(_selectedDate);
              }),
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
              titleBuilder: (entry) => entry.value.title,
              subtitleBuilder: (entry) => entry.value.subtitle,
              progressBuilder: (entry) => entry.value.progress,
              onOpen: (context, details) => _openTask(details.value),
              onComplete: (context, details) => _mutate(
                () => _tasks = _tasks
                    .map(
                      (task) => task.id == details.value.id
                          ? task.copyWith(completed: !task.completed)
                          : task,
                    )
                    .toList(growable: false),
              ),
              onMove: (context, details) => _mutate(
                () => _tasks = _tasks
                    .map(
                      (task) => task.id == details.value.id
                          ? task.copyWith(start: details.preview.start)
                          : task,
                    )
                    .toList(growable: false),
              ),
              onResize: (context, details) => _mutate(
                () => _tasks = _tasks
                    .map(
                      (task) => task.id == details.value.id
                          ? task.copyWith(
                              start: details.preview.start,
                              duration: details.preview.duration,
                            )
                          : task,
                    )
                    .toList(growable: false),
              ),
              onDelete: (context, details) => _mutate(
                () => _tasks = _tasks
                    .where((task) => task.id != details.value.id)
                    .toList(growable: false),
              ),
              onDragStateChanged: (state) {
                final active = state.active;
                if (active != _dragging) setState(() => _dragging = active);
              },
            ),
          ),
        ),
      ),
    );
  }

  String? get _persistenceMessage => switch (_persistence) {
    StructuredTimelinePersistenceState.queuedOffline =>
      'Saved locally. Sync resumes when online.',
    StructuredTimelinePersistenceState.failed =>
      'The server rejected this change. Retry or undo.',
    StructuredTimelinePersistenceState.saving => 'Saving change…',
    _ => null,
  };

  Future<void> _mutate(VoidCallback commit) async {
    setState(() => _persistence = StructuredTimelinePersistenceState.saving);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() {
      commit();
      _persistence = StructuredTimelinePersistenceState.idle;
    });
  }

  void _setMode(String value) {
    setState(() {
      switch (value) {
        case 'theme':
          _dark = !_dark;
          break;
        case 'rtl':
          _rtl = !_rtl;
          break;
        case 'text':
          _largeText = !_largeText;
          break;
        case 'offline':
          _persistence = StructuredTimelinePersistenceState.queuedOffline;
          break;
        case 'failed':
          _persistence = StructuredTimelinePersistenceState.failed;
          break;
      }
    });
  }

  void _openTask(_PlannerTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(task.subtitle),
              const SizedBox(height: 18),
              const Text(
                'This sheet and persistence flow belong to the app. The package owns reusable geometry and interaction.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_PlannerTask> _seed(DateTime day) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return [
      _PlannerTask(
        id: 'micro',
        title: 'Daily check-in',
        subtitle: 'A real twelve-minute task uses the micro layout.',
        start: at(8, 10),
        duration: const Duration(minutes: 12),
        color: const Color(0xFF0D9488),
        progress: 0,
        recurring: true,
      ),
      _PlannerTask(
        id: 'focus',
        title: 'Design the release architecture',
        subtitle:
            'Deep work with adaptive content and a large free gap after it.',
        start: at(8, 35),
        duration: const Duration(minutes: 110),
        color: const Color(0xFF5D48E8),
        progress: 0.62,
      ),
      _PlannerTask(
        id: 'review',
        title: 'Product and accessibility review',
        subtitle:
            'Overlaps the external event to demonstrate conflict language.',
        start: at(13, 30),
        duration: const Duration(minutes: 70),
        color: const Color(0xFFE04F76),
        progress: 0.35,
      ),
      _PlannerTask(
        id: 'external',
        title: 'Customer calendar call',
        subtitle:
            'External and locked, but still visible to snapping and conflicts.',
        start: at(14, 15),
        duration: const Duration(minutes: 50),
        color: const Color(0xFFF59E0B),
        progress: 0,
        external: true,
      ),
      _PlannerTask(
        id: 'overnight',
        title: 'Production migration window',
        subtitle: 'Crosses midnight and renders as connected day segments.',
        start: at(23, 24),
        duration: const Duration(minutes: 55),
        color: const Color(0xFF2563EB),
        progress: 0.18,
      ),
    ];
  }
}

class _PlannerTask {
  const _PlannerTask({
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

  _PlannerTask copyWith({
    DateTime? start,
    Duration? duration,
    bool? completed,
  }) {
    return _PlannerTask(
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

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v15.dart';

class V15UltraTimelineShowcase extends StatefulWidget {
  const V15UltraTimelineShowcase({super.key});

  @override
  State<V15UltraTimelineShowcase> createState() =>
      _V15UltraTimelineShowcaseState();
}

class _V15UltraTimelineShowcaseState
    extends State<V15UltraTimelineShowcase> {
  late DateTime _selectedDate;
  late List<_UltraTask> _tasks;
  late final TimelinePlannerEngine<_UltraTask> _engine;
  late final UltimateStructuredTimelineController<_UltraTask>
      _timelineController;
  late final UltraTimelineController _uiController;
  late final TimelineMutationCoordinator<_UltraTask> _mutations;

  StructuredTimelinePersistenceState _persistence =
      StructuredTimelinePersistenceState.idle;
  String? _editingTaskId;
  bool _dark = false;
  bool _largeText = false;
  bool _diagnostics = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _timelineController =
        UltimateStructuredTimelineController<_UltraTask>();
    _uiController = UltraTimelineController(
      initialZoom: UltraTimelineZoomLevel.comfortable,
      initialSnapStrength: UltraTimelineSnapStrength.balanced,
    );
    _mutations = TimelineMutationCoordinator<_UltraTask>();
    _engine = TimelinePlannerEngine<_UltraTask>(
      adapter: TimelineSeriesAdapter<_UltraTask>(
        entryAdapter: TimelineEntryAdapter<_UltraTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => task.duration,
          status: (task) => task.completed
              ? TimelineStatus.completed
              : TimelineStatus.pending,
          color: (task) => task.color,
          semanticLabel: (task) => task.title,
          draggable: (task) => !task.locked,
          metadata: (task) => <String, Object?>{
            'structured.subtitle': task.subtitle,
            'structured.progress': task.progress,
            'timeline.external': task.locked,
            'timeline.locked': task.locked,
            'ultra.badges': task.badges,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _uiController.dispose();
    _mutations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _dark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5FEF),
      brightness: brightness,
    );
    final appTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          _dark ? const Color(0xFF080B12) : const Color(0xFFF3F5F9),
    );
    final config = UltraTimelineConfig(
      initialZoom: UltraTimelineZoomLevel.comfortable,
      initialSnapStrength: UltraTimelineSnapStrength.balanced,
      showDiagnostics: _diagnostics,
      dragActivation: UltraTimelineDragActivation.longPress,
      enableRangeEditor: true,
      showMetrics: true,
      reducedMotion:
          MediaQuery.maybeOf(context)?.disableAnimations ?? false,
    );

    return Theme(
      data: appTheme,
      child: Builder(
        builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(_largeText ? 2 : 1),
            ),
            child: Scaffold(
              body: AdaptivePlannerTimeline<_UltraTask>(
                values: _tasks,
                engine: _engine,
                selectedDate: _selectedDate,
                title: 'Orbit Ultra Planner',
                subtitle: 'Smooth planning with precise direct manipulation',
                config: config,
                controller: _uiController,
                timelineController: _timelineController,
                mutationCoordinator: _mutations,
                persistenceState: _persistence,
                metrics: _metrics,
                actions: <UltraTimelineAction>[
                  UltraTimelineAction(
                    label: 'Diagnostics',
                    icon: _diagnostics
                        ? Icons.speed_rounded
                        : Icons.speed_outlined,
                    tone: UltraTimelineTone.sky,
                    onPressed: () {
                      setState(() => _diagnostics = !_diagnostics);
                    },
                  ),
                  UltraTimelineAction(
                    label: 'Theme',
                    icon: _dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    tone: UltraTimelineTone.violet,
                    onPressed: () => setState(() => _dark = !_dark),
                  ),
                ],
                avatar: const CircleAvatar(
                  child: Icon(Icons.person_rounded),
                ),
                onSearch: _showSearch,
                onCreate: _createTask,
                onOpenSettings: _showSettings,
                onDateChanged: (value) {
                  setState(() {
                    _selectedDate =
                        DateTime(value.year, value.month, value.day);
                    _tasks = _seed(_selectedDate);
                    _editingTaskId = null;
                  });
                },
                onEntryTap: (context, details) {
                  _editingTaskId = details.value.id;
                  final dayStart = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                  );
                  _uiController.showTimeRangeEditor(
                    range: UltraTimeRange(
                      start: details.item.start,
                      end: details.item.end,
                    ),
                    bounds: UltraTimeRange(
                      start: dayStart.add(const Duration(hours: 6)),
                      end: dayStart.add(const Duration(hours: 22)),
                    ),
                    blockedRanges: _tasks
                        .where((task) => task.id != details.value.id)
                        .map(
                          (task) => UltraTimeRange(
                            start: task.start,
                            end: task.start.add(task.duration),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
                onRangePreview: (_) {},
                onRangeCommit: _commitRange,
                entryPresentationBuilder: (context, details) {
                  final task = details.value;
                  return UltraTimelineEntryPresentation<_UltraTask>(
                    details: details,
                    title: task.title,
                    subtitle: task.subtitle,
                    timeLabel:
                        '${_clock(details.visibleStart)} – ${_clock(details.visibleEnd)}',
                    icon: task.icon,
                    tone: task.tone,
                    progress: task.progress,
                    badges: task.badges,
                    semanticLabel:
                        '${task.title}, ${_clock(details.visibleStart)} to ${_clock(details.visibleEnd)}',
                  );
                },
                onOpen: (context, details) => _showTask(details.value),
                onComplete: (context, details) => _save(() {
                  _tasks = _tasks
                      .map(
                        (task) => task.id == details.value.id
                            ? task.copyWith(completed: !task.completed)
                            : task,
                      )
                      .toList(growable: false);
                }),
                onMove: (context, details) => _save(() {
                  _tasks = _tasks
                      .map(
                        (task) => task.id == details.value.id
                            ? task.copyWith(start: details.preview.start)
                            : task,
                      )
                      .toList(growable: false);
                }),
                onResize: (context, details) => _save(() {
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
                }),
                onDelete: (context, details) => _save(() {
                  _tasks = _tasks
                      .where((task) => task.id != details.value.id)
                      .toList(growable: false);
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
              ),
            ),
          );
        },
      ),
    );
  }

  List<UltraTimelineMetric> get _metrics {
    final planned = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.duration.inMinutes,
    );
    final completed = _tasks.where((task) => task.completed).length;
    final conflicts = _conflictCount(_tasks);
    return <UltraTimelineMetric>[
      UltraTimelineMetric(
        label: 'Planned',
        value: '${planned ~/ 60}h ${planned % 60}m',
        icon: Icons.schedule_rounded,
        tone: UltraTimelineTone.sky,
      ),
      UltraTimelineMetric(
        label: 'Completed',
        value: '$completed / ${_tasks.length}',
        icon: Icons.check_circle_rounded,
        tone: UltraTimelineTone.mint,
      ),
      UltraTimelineMetric(
        label: 'Conflicts',
        value: '$conflicts',
        icon: Icons.warning_amber_rounded,
        tone: conflicts == 0
            ? UltraTimelineTone.mint
            : UltraTimelineTone.amber,
      ),
    ];
  }

  void _commitRange(UltraTimeRange range) {
    final id = _editingTaskId;
    if (id == null) return;
    _save(() {
      _tasks = _tasks
          .map(
            (task) => task.id == id
                ? task.copyWith(start: range.start, duration: range.duration)
                : task,
          )
          .toList(growable: false);
    });
  }

  Future<void> _save(VoidCallback mutation) async {
    setState(() => _persistence = StructuredTimelinePersistenceState.saving);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() {
      mutation();
      _persistence = StructuredTimelinePersistenceState.idle;
    });
  }

  void _createTask() {
    final day = _selectedDate;
    final next = _UltraTask(
      id: 'new-${DateTime.now().microsecondsSinceEpoch}',
      title: 'New ultra task',
      subtitle: 'Created by the host application.',
      start: DateTime(day.year, day.month, day.day, 18),
      duration: const Duration(minutes: 45),
      color: const Color(0xFF5B5FEF),
      progress: 0,
      icon: Icons.auto_awesome_rounded,
      tone: UltraTimelineTone.primary,
      badges: const <String>['New'],
    );
    setState(() => _tasks = <_UltraTask>[..._tasks, next]);
  }

  void _showSearch() {
    showSearch<String?>(
      context: context,
      delegate: _UltraTaskSearchDelegate(_tasks),
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Dark mode'),
              value: _dark,
              onChanged: (value) {
                setState(() => _dark = value);
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.text_increase_rounded),
              title: const Text('200% text scale'),
              value: _largeText,
              onChanged: (value) {
                setState(() => _largeText = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTask(_UltraTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: task.color.withValues(alpha: 0.14),
                foregroundColor: task.color,
                child: Icon(task.icon),
              ),
              const SizedBox(height: 14),
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(task.subtitle),
            ],
          ),
        ),
      ),
    );
  }

  static int _conflictCount(List<_UltraTask> tasks) {
    var conflicts = 0;
    for (var left = 0; left < tasks.length; left += 1) {
      final leftEnd = tasks[left].start.add(tasks[left].duration);
      for (var right = left + 1; right < tasks.length; right += 1) {
        final rightEnd = tasks[right].start.add(tasks[right].duration);
        if (tasks[left].start.isBefore(rightEnd) &&
            tasks[right].start.isBefore(leftEnd)) {
          conflicts += 1;
        }
      }
    }
    return conflicts;
  }

  static String _clock(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  static List<_UltraTask> _seed(DateTime day) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return <_UltraTask>[
      _UltraTask(
        id: 'briefing',
        title: 'Morning command briefing',
        subtitle: 'Review priorities, energy and protected focus blocks.',
        start: at(8, 0),
        duration: const Duration(minutes: 30),
        color: const Color(0xFF169A78),
        progress: 1,
        completed: true,
        icon: Icons.wb_sunny_rounded,
        tone: UltraTimelineTone.mint,
        badges: const <String>['Daily', 'Focus'],
      ),
      _UltraTask(
        id: 'engine',
        title: 'Build the v15 interaction engine',
        subtitle: 'Viewport index, magnetic snapping and isolated overlays.',
        start: at(8, 50),
        duration: const Duration(minutes: 120),
        color: const Color(0xFF6F55E8),
        progress: 0.72,
        icon: Icons.memory_rounded,
        tone: UltraTimelineTone.violet,
        badges: const <String>['Architecture', 'Deep work'],
      ),
      _UltraTask(
        id: 'walk',
        title: 'Walk and reset',
        subtitle: 'A real break before the design review.',
        start: at(11, 20),
        duration: const Duration(minutes: 35),
        color: const Color(0xFF2D83C7),
        progress: 0.15,
        icon: Icons.directions_walk_rounded,
        tone: UltraTimelineTone.sky,
        badges: const <String>['Wellbeing'],
      ),
      _UltraTask(
        id: 'review',
        title: 'Advanced UI review',
        subtitle: 'Check hierarchy, 200% text, keyboard and reduced motion.',
        start: at(13, 0),
        duration: const Duration(minutes: 85),
        color: const Color(0xFFE05F70),
        progress: 0.46,
        icon: Icons.design_services_rounded,
        tone: UltraTimelineTone.coral,
        badges: const <String>['A11y', 'Design'],
      ),
      _UltraTask(
        id: 'partner',
        title: 'Partner calendar block',
        subtitle: 'External and locked, but available to conflict detection.',
        start: at(14, 10),
        duration: const Duration(minutes: 50),
        color: const Color(0xFFC48720),
        progress: 0,
        icon: Icons.video_call_rounded,
        tone: UltraTimelineTone.amber,
        badges: const <String>['External'],
        locked: true,
      ),
      _UltraTask(
        id: 'ship',
        title: 'Profile, polish and ship',
        subtitle: 'Run diagnostics and validate the release package.',
        start: at(16, 0),
        duration: const Duration(minutes: 100),
        color: const Color(0xFF5B5FEF),
        progress: 0.28,
        icon: Icons.rocket_launch_rounded,
        tone: UltraTimelineTone.primary,
        badges: const <String>['Release', 'Performance'],
      ),
    ];
  }
}

class _UltraTaskSearchDelegate extends SearchDelegate<String?> {
  _UltraTaskSearchDelegate(this.tasks);

  final List<_UltraTask> tasks;

  @override
  List<Widget>? buildActions(BuildContext context) => <Widget>[
        IconButton(
          tooltip: 'Clear',
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: 'Back',
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => _results();

  @override
  Widget buildSuggestions(BuildContext context) => _results();

  Widget _results() {
    final normalized = query.trim().toLowerCase();
    final matches = tasks.where((task) {
      return normalized.isEmpty ||
          task.title.toLowerCase().contains(normalized) ||
          task.subtitle.toLowerCase().contains(normalized);
    }).toList(growable: false);
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final task = matches[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: task.color.withValues(alpha: 0.14),
            foregroundColor: task.color,
            child: Icon(task.icon),
          ),
          title: Text(task.title),
          subtitle: Text(task.subtitle),
          onTap: () => close(context, null),
        );
      },
    );
  }
}

class _UltraTask {
  const _UltraTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    required this.progress,
    required this.icon,
    required this.tone,
    required this.badges,
    this.completed = false,
    this.locked = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final double progress;
  final IconData icon;
  final UltraTimelineTone tone;
  final List<String> badges;
  final bool completed;
  final bool locked;

  _UltraTask copyWith({
    DateTime? start,
    Duration? duration,
    bool? completed,
  }) {
    return _UltraTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      progress: progress,
      icon: icon,
      tone: tone,
      badges: badges,
      completed: completed ?? this.completed,
      locked: locked,
    );
  }
}

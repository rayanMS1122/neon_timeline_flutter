import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v14.dart';

class V14FriendlyUiTimelineShowcase extends StatefulWidget {
  const V14FriendlyUiTimelineShowcase({super.key});

  @override
  State<V14FriendlyUiTimelineShowcase> createState() =>
      _V14FriendlyUiTimelineShowcaseState();
}

class _V14FriendlyUiTimelineShowcaseState
    extends State<V14FriendlyUiTimelineShowcase> {
  late DateTime _selectedDate;
  late List<_FriendlyTask> _tasks;
  late final TimelinePlannerEngine<_FriendlyTask> _engine;
  late final UltimateStructuredTimelineController<_FriendlyTask> _controller;
  late final TimelineMutationCoordinator<_FriendlyTask> _mutations;

  StructuredTimelinePersistenceState _persistence =
      StructuredTimelinePersistenceState.idle;
  bool _dark = false;
  bool _largeText = false;
  int _navigationIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _controller = UltimateStructuredTimelineController<_FriendlyTask>();
    _mutations = TimelineMutationCoordinator<_FriendlyTask>();
    _engine = TimelinePlannerEngine<_FriendlyTask>(
      adapter: TimelineSeriesAdapter<_FriendlyTask>(
        entryAdapter: TimelineEntryAdapter<_FriendlyTask>(
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
            'timeline.locked': task.external,
            'timeline.seriesId': task.recurring ? 'friendly-weekly' : null,
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
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7558E8),
      brightness: brightness,
    );
    final appTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: _dark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF7F7FC),
    );
    final workspaceTheme = _dark
        ? FriendlyTimelineUiThemeData.fromColorScheme(scheme)
        : FriendlyTimelineUiThemeData.sunrise(scheme).copyWith(
            density: FriendlyTimelineWorkspaceDensity.comfortable,
          );

    return Theme(
      data: appTheme,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_largeText ? 2 : 1),
        ),
        child: Scaffold(
          body: FriendlyUiStructuredTimeline<_FriendlyTask>(
            values: _tasks,
            engine: _engine,
            selectedDate: _selectedDate,
            title: 'Bloom Day Planner',
            subtitle: 'A calmer, friendlier way to shape your day',
            controller: _controller,
            mutationCoordinator: _mutations,
            config: const UltimateStructuredTimelineConfig.friendly(),
            workspaceTheme: workspaceTheme,
            persistenceState: _persistence,
            metrics: _metrics,
            navigationItems: const <FriendlyTimelineNavigationItem>[
              FriendlyTimelineNavigationItem(
                label: 'Today',
                icon: Icons.today_outlined,
                selectedIcon: Icons.today_rounded,
                tone: FriendlyTimelineIconTone.primary,
              ),
              FriendlyTimelineNavigationItem(
                label: 'Week',
                icon: Icons.calendar_view_week_outlined,
                selectedIcon: Icons.calendar_view_week_rounded,
                tone: FriendlyTimelineIconTone.sky,
              ),
              FriendlyTimelineNavigationItem(
                label: 'Focus',
                icon: Icons.self_improvement_outlined,
                selectedIcon: Icons.self_improvement_rounded,
                badge: '3',
                tone: FriendlyTimelineIconTone.lavender,
              ),
              FriendlyTimelineNavigationItem(
                label: 'Wins',
                icon: Icons.emoji_events_outlined,
                selectedIcon: Icons.emoji_events_rounded,
                tone: FriendlyTimelineIconTone.amber,
              ),
            ],
            selectedNavigationIndex: _navigationIndex,
            onNavigationSelected: (index) {
              setState(() => _navigationIndex = index);
            },
            navigationFooter: FriendlyTimelineIconButton(
              tooltip: 'Help',
              icon: Icons.help_outline_rounded,
              tone: FriendlyTimelineIconTone.sky,
              onPressed: _showHelp,
            ),
            actions: <FriendlyTimelineAction>[
              FriendlyTimelineAction(
                label: 'Zoom in',
                icon: Icons.zoom_in_rounded,
                tone: FriendlyTimelineIconTone.sky,
                onPressed: _controller.zoomIn,
              ),
              FriendlyTimelineAction(
                label: 'Theme',
                icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                tone: FriendlyTimelineIconTone.lavender,
                onPressed: () => setState(() => _dark = !_dark),
              ),
            ],
            avatar: const CircleAvatar(
              child: Icon(Icons.sentiment_satisfied_alt_rounded),
            ),
            onSearch: _showSearch,
            onCreate: _createTask,
            onOpenSettings: _openSettings,
            onRetry: () {
              setState(() {
                _persistence = StructuredTimelinePersistenceState.idle;
              });
            },
            onDateChanged: (value) {
              setState(() {
                _selectedDate = DateTime(value.year, value.month, value.day);
                _tasks = _seed(_selectedDate);
              });
            },
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
            entryPresentationBuilder: (context, details) {
              final task = details.value;
              return FriendlyTimelineEntryPresentation<_FriendlyTask>(
                details: details,
                title: task.title,
                subtitle: task.subtitle,
                timeLabel:
                    '${_formatClock(details.visibleStart)} – '
                    '${_formatClock(details.visibleEnd)}',
                progress: task.progress,
                icon: task.icon,
                tone: task.tone,
                semanticLabel:
                    '${task.title}, ${_formatClock(details.visibleStart)} '
                    'to ${_formatClock(details.visibleEnd)}',
              );
            },
            dragTitleBuilder: (task) => task.title,
            onOpen: (context, details) => _openTask(details.value),
            onComplete: (context, details) => _save(
              () {
                _tasks = _tasks
                    .map(
                      (task) => task.id == details.value.id
                          ? task.copyWith(completed: !task.completed)
                          : task,
                    )
                    .toList(growable: false);
              },
            ),
            onMove: (context, details) => _save(
              () {
                _tasks = _tasks
                    .map(
                      (task) => task.id == details.value.id
                          ? task.copyWith(start: details.preview.start)
                          : task,
                    )
                    .toList(growable: false);
              },
            ),
            onResize: (context, details) => _save(
              () {
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
              },
            ),
            onDelete: (context, details) => _save(
              () {
                _tasks = _tasks
                    .where((task) => task.id != details.value.id)
                    .toList(growable: false);
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<FriendlyTimelineMetric> get _metrics {
    final totalMinutes = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.duration.inMinutes,
    );
    final completed = _tasks.where((task) => task.completed).length;
    final average = _tasks.isEmpty
        ? 0.0
        : _tasks.fold<double>(0, (sum, task) => sum + task.progress) /
              _tasks.length;
    return <FriendlyTimelineMetric>[
      FriendlyTimelineMetric(
        label: 'Planned',
        value: '${totalMinutes ~/ 60}h ${totalMinutes % 60}m',
        icon: Icons.schedule_rounded,
        tone: FriendlyTimelineIconTone.sky,
      ),
      FriendlyTimelineMetric(
        label: 'Finished',
        value: '$completed / ${_tasks.length}',
        icon: Icons.check_circle_rounded,
        progress: _tasks.isEmpty ? 0 : completed / _tasks.length,
        tone: FriendlyTimelineIconTone.mint,
      ),
      FriendlyTimelineMetric(
        label: 'Momentum',
        value: '${(average * 100).round()}%',
        icon: Icons.rocket_launch_rounded,
        progress: average,
        tone: FriendlyTimelineIconTone.lavender,
      ),
      const FriendlyTimelineMetric(
        label: 'Protected focus',
        value: '2 blocks',
        icon: Icons.shield_moon_rounded,
        tone: FriendlyTimelineIconTone.coral,
      ),
    ];
  }

  Future<void> _save(VoidCallback mutation) async {
    setState(() {
      _persistence = StructuredTimelinePersistenceState.saving;
    });
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    setState(() {
      mutation();
      _persistence = StructuredTimelinePersistenceState.idle;
    });
  }

  void _createTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The host app owns task creation.')),
    );
  }

  void _showSearch() {
    showSearch<String?>(
      context: context,
      delegate: _FriendlySearchDelegate(_tasks),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        icon: Icon(Icons.pan_tool_alt_rounded),
        title: Text('Friendly drag and drop'),
        content: Text(
          'Grab a card, follow the live time ribbon and release when the target feels right. Smart snap and conflicts are always shown with icons and text.',
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
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
              ListTile(
                leading: const Icon(Icons.cloud_off_rounded),
                title: const Text('Simulate offline'),
                onTap: () {
                  setState(() {
                    _persistence =
                        StructuredTimelinePersistenceState.queuedOffline;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTask(_FriendlyTask task) {
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
                backgroundColor: task.color.withValues(alpha: 0.15),
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

  static List<_FriendlyTask> _seed(DateTime day) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return <_FriendlyTask>[
      _FriendlyTask(
        id: 'morning',
        title: 'Gentle daily check-in',
        subtitle: 'Review energy, priorities and one small win.',
        start: at(8, 10),
        duration: const Duration(minutes: 20),
        color: const Color(0xFF168F73),
        progress: 1,
        completed: true,
        recurring: true,
        icon: Icons.wb_sunny_rounded,
        tone: FriendlyTimelineIconTone.mint,
      ),
      _FriendlyTask(
        id: 'design',
        title: 'Design the joyful v14 experience',
        subtitle: 'Icons, hierarchy, motion and guided drag feedback.',
        start: at(8, 50),
        duration: const Duration(minutes: 105),
        color: const Color(0xFF7558E8),
        progress: 0.68,
        icon: Icons.palette_rounded,
        tone: FriendlyTimelineIconTone.lavender,
      ),
      _FriendlyTask(
        id: 'walk',
        title: 'Walk and reset',
        subtitle: 'A real break is part of the plan.',
        start: at(11, 20),
        duration: const Duration(minutes: 35),
        color: const Color(0xFF2D7FC1),
        progress: 0.1,
        icon: Icons.directions_walk_rounded,
        tone: FriendlyTimelineIconTone.sky,
      ),
      _FriendlyTask(
        id: 'review',
        title: 'Friendly product review',
        subtitle: 'Check clarity, accessibility and drag behaviour.',
        start: at(13, 30),
        duration: const Duration(minutes: 75),
        color: const Color(0xFFD95368),
        progress: 0.4,
        icon: Icons.favorite_rounded,
        tone: FriendlyTimelineIconTone.coral,
      ),
      _FriendlyTask(
        id: 'external',
        title: 'Partner calendar call',
        subtitle: 'External and locked, but visible to snap and conflicts.',
        start: at(14, 20),
        duration: const Duration(minutes: 50),
        color: const Color(0xFFB7791F),
        progress: 0,
        external: true,
        icon: Icons.video_call_rounded,
        tone: FriendlyTimelineIconTone.amber,
      ),
      _FriendlyTask(
        id: 'ship',
        title: 'Polish and ship the demo',
        subtitle: 'Final pass with keyboard and large-text checks.',
        start: at(16, 10),
        duration: const Duration(minutes: 85),
        color: const Color(0xFF7357D9),
        progress: 0.22,
        icon: Icons.rocket_launch_rounded,
        tone: FriendlyTimelineIconTone.primary,
      ),
    ];
  }
}

class _FriendlySearchDelegate extends SearchDelegate<String?> {
  _FriendlySearchDelegate(this.tasks);

  final List<_FriendlyTask> tasks;

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
    final matches = normalized.isEmpty
        ? tasks
        : tasks
              .where(
                (task) =>
                    task.title.toLowerCase().contains(normalized) ||
                    task.subtitle.toLowerCase().contains(normalized),
              )
              .toList(growable: false);
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

class _FriendlyTask {
  const _FriendlyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    required this.progress,
    required this.icon,
    required this.tone,
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
  final IconData icon;
  final FriendlyTimelineIconTone tone;
  final bool completed;
  final bool external;
  final bool recurring;

  _FriendlyTask copyWith({
    DateTime? start,
    Duration? duration,
    bool? completed,
  }) {
    return _FriendlyTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      progress: progress,
      icon: icon,
      tone: tone,
      completed: completed ?? this.completed,
      external: external,
      recurring: recurring,
    );
  }
}

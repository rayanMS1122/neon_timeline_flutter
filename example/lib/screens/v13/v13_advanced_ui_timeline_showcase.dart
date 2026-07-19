import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v13.dart';

class V13AdvancedUiTimelineShowcase extends StatefulWidget {
  const V13AdvancedUiTimelineShowcase({super.key});

  @override
  State<V13AdvancedUiTimelineShowcase> createState() =>
      _V13AdvancedUiTimelineShowcaseState();
}

class _V13AdvancedUiTimelineShowcaseState
    extends State<V13AdvancedUiTimelineShowcase> {
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
  int _navigationIndex = 0;
  String _dragStatus = 'Drag, resize or open a task';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);
    _controller = UltimateStructuredTimelineController<_PlannerTask>(
      zoomLevel: UltimateTimelineZoomLevel.compact,
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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5CE2),
      brightness: brightness,
    );
    final themeData = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _dark
          ? const Color(0xFF07101D)
          : const Color(0xFFF3F6FB),
    );
    final workspaceTheme = AdvancedTimelineUiThemeData.operations(colorScheme);

    return Theme(
      data: themeData,
      child: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_largeText ? 2 : 1)),
          child: Scaffold(
            body: AdvancedUiStructuredTimeline<_PlannerTask>(
              values: _tasks,
              engine: _engine,
              selectedDate: _selectedDate,
              controller: _controller,
              mutationCoordinator: _mutations,
              title: 'Advanced Timeline UI 13.0',
              subtitle: _dragging
                  ? _dragStatus
                  : 'A focused day without calendar noise',
              config: const UltimateStructuredTimelineConfig.advancedCompact(),
              workspaceTheme: workspaceTheme,
              persistenceState: _persistence,
              persistenceMessage: _persistenceMessage,
              metrics: _metrics,
              navigationItems: const [
                AdvancedTimelineNavigationItem(
                  label: 'Timeline',
                  icon: Icons.view_timeline_outlined,
                  selectedIcon: Icons.view_timeline_rounded,
                ),
                AdvancedTimelineNavigationItem(
                  label: 'Week',
                  icon: Icons.calendar_view_week_outlined,
                  selectedIcon: Icons.calendar_view_week_rounded,
                ),
                AdvancedTimelineNavigationItem(
                  label: 'Focus',
                  icon: Icons.center_focus_weak_outlined,
                  selectedIcon: Icons.center_focus_strong_rounded,
                  badge: '3',
                ),
                AdvancedTimelineNavigationItem(
                  label: 'Insights',
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights_rounded,
                ),
              ],
              selectedNavigationIndex: _navigationIndex,
              onNavigationSelected: (index) => setState(
                () => _navigationIndex = index,
              ),
              navigationFooter: AdvancedTimelineQuickAction(
                tooltip: 'Help and keyboard shortcuts',
                icon: Icons.help_outline_rounded,
                onPressed: _showHelp,
              ),
              avatar: const CircleAvatar(
                child: Text(
                  'RM',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
              onSearch: _showCommandPalette,
              onCreate: _createTask,
              onOpenSettings: _openSettings,
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'View controls',
                  onSelected: _setMode,
                  icon: const Icon(Icons.more_horiz_rounded),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'zoom_in',
                      child: ListTile(
                        leading: Icon(Icons.zoom_in_rounded),
                        title: Text('Zoom in'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'zoom_out',
                      child: ListTile(
                        leading: Icon(Icons.zoom_out_rounded),
                        title: Text('Zoom out'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'offline',
                      child: ListTile(
                        leading: Icon(Icons.cloud_off_rounded),
                        title: Text('Simulate offline'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'failed',
                      child: ListTile(
                        leading: Icon(Icons.error_outline_rounded),
                        title: Text('Simulate failure'),
                      ),
                    ),
                  ],
                ),
              ],
              bottomBar: _PlannerStatusBar(
                dragging: _dragging,
                message: _dragStatus,
                theme: workspaceTheme,
              ),
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
                final status = _dragStatusFor(state);
                if (active != _dragging || status != _dragStatus) {
                  setState(() {
                    _dragging = active;
                    _dragStatus = status;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List<AdvancedTimelineMetric> get _metrics {
    final totalMinutes = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.duration.inMinutes,
    );
    final completed = _tasks.where((task) => task.completed).length;
    final focusProgress = _tasks
        .where((task) => !task.external)
        .fold<double>(0, (sum, task) => sum + task.progress);
    final denominator = _tasks.where((task) => !task.external).length;
    final averageProgress = denominator == 0 ? 0 : focusProgress / denominator;
    return [
      AdvancedTimelineMetric(
        label: 'Scheduled',
        value: '${totalMinutes ~/ 60}h ${totalMinutes % 60}m',
        icon: Icons.schedule_rounded,
        emphasized: true,
      ),
      AdvancedTimelineMetric(
        label: 'Completed',
        value: '$completed / ${_tasks.length}',
        icon: Icons.task_alt_rounded,
        progress: _tasks.isEmpty ? 0 : completed / _tasks.length,
      ),
      AdvancedTimelineMetric(
        label: 'Focus score',
        value: '${(averageProgress * 100).round()}%',
        icon: Icons.track_changes_rounded,
        progress: averageProgress.clamp(0, 1).toDouble(),
      ),
      const AdvancedTimelineMetric(
        label: 'Open conflict',
        value: '1',
        icon: Icons.warning_amber_rounded,
      ),
    ];
  }

  String? get _persistenceMessage => switch (_persistence) {
    StructuredTimelinePersistenceState.queuedOffline => 'Saved locally',
    StructuredTimelinePersistenceState.failed => 'Save failed',
    StructuredTimelinePersistenceState.saving => 'Saving change',
    StructuredTimelinePersistenceState.rollingBack => 'Rolling back',
    _ => null,
  };

  String _dragStatusFor(StructuredTimelineDragState<_PlannerTask> state) {
    if (!state.active) return 'Drag, resize or open a task';
    final conflictSuffix = state.conflictCount == 0
        ? ''
        : ' · ${state.conflictCount} conflict${state.conflictCount == 1 ? '' : 's'}';
    if (state.phase == StructuredTimelineDragPhase.blocked) {
      return 'Drop blocked$conflictSuffix';
    }
    if (state.magnetized) {
      return 'Magnetic target locked$conflictSuffix';
    }
    return state.conflictCount == 0
        ? 'Drop available · release to move'
        : 'Conflict preview$conflictSuffix';
  }

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
        case 'zoom_in':
          _controller.zoomIn();
          break;
        case 'zoom_out':
          _controller.zoomOut();
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
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(task.subtitle),
              const SizedBox(height: 18),
              const Text(
                'Business logic stays in the app. The package owns reusable geometry, interactions and the workspace UI.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommandPalette() {
    showSearch<String?>(
      context: context,
      delegate: _TimelineSearchDelegate(_tasks),
    );
  }

  void _createTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create action belongs to the host app.')),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Planner shortcuts'),
        content: Text(
          'Long press or drag a handle to move. Use Escape to cancel. Use the zoom controls for semantic density.',
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, modalSetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Dark mode'),
                  value: _dark,
                  onChanged: (value) {
                    setState(() => _dark = value);
                    modalSetState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('RTL'),
                  value: _rtl,
                  onChanged: (value) {
                    setState(() => _rtl = value);
                    modalSetState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('200% text scale'),
                  value: _largeText,
                  onChanged: (value) {
                    setState(() => _largeText = value);
                    modalSetState(() {});
                  },
                ),
              ],
            ),
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
        subtitle: 'A twelve-minute task uses the micro layout.',
        start: at(8, 10),
        duration: const Duration(minutes: 12),
        color: const Color(0xFF0D9488),
        progress: 1,
        recurring: true,
        completed: true,
      ),
      _PlannerTask(
        id: 'focus',
        title: 'Design the release architecture',
        subtitle: 'Deep work with adaptive content and a large free gap.',
        start: at(8, 35),
        duration: const Duration(minutes: 110),
        color: const Color(0xFF5B5CE2),
        progress: 0.62,
      ),
      _PlannerTask(
        id: 'review',
        title: 'Product and accessibility review',
        subtitle: 'Overlaps the external event to demonstrate conflicts.',
        start: at(13, 30),
        duration: const Duration(minutes: 70),
        color: const Color(0xFFE04F76),
        progress: 0.35,
      ),
      _PlannerTask(
        id: 'external',
        title: 'Customer calendar call',
        subtitle: 'External and locked, but visible to snap and conflicts.',
        start: at(14, 15),
        duration: const Duration(minutes: 50),
        color: const Color(0xFFF59E0B),
        progress: 0,
        external: true,
      ),
      _PlannerTask(
        id: 'overnight',
        title: 'Production migration window',
        subtitle: 'Crosses midnight and renders as connected segments.',
        start: at(23, 24),
        duration: const Duration(minutes: 55),
        color: const Color(0xFF2563EB),
        progress: 0.18,
      ),
    ];
  }
}


class _PlannerStatusBar extends StatelessWidget {
  const _PlannerStatusBar({
    required this.dragging,
    required this.message,
    required this.theme,
  });

  final bool dragging;
  final String message;
  final AdvancedTimelineUiThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AdvancedTimelinePanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 680 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          return Row(
            children: [
              Icon(
                dragging
                    ? Icons.pan_tool_alt_rounded
                    : Icons.keyboard_command_key_rounded,
                size: 17,
                color: theme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                Text(
                  '⌘K  Search   ·   Esc  Cancel drag',
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimelineSearchDelegate extends SearchDelegate<String?> {
  _TimelineSearchDelegate(this.tasks);

  final List<_PlannerTask> tasks;

  @override
  List<Widget>? buildActions(BuildContext context) => [
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
          leading: CircleAvatar(backgroundColor: task.color),
          title: Text(task.title),
          subtitle: Text(task.subtitle),
          onTap: () => close(context, null),
        );
      },
    );
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

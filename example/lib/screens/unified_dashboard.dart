import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

class UnifiedTimelineDashboard extends StatefulWidget {
  const UnifiedTimelineDashboard({super.key});

  @override
  State<UnifiedTimelineDashboard> createState() => _UnifiedTimelineDashboardState();
}

class _UnifiedTimelineDashboardState extends State<UnifiedTimelineDashboard> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late List<_UnifiedTask> _tasks;
  late final TimelinePlannerEngine<_UnifiedTask> _engine;
  late final UltimateStructuredTimelineController<_UnifiedTask> _ultimateController;
  late final UltraTimelineController _ultraController;
  late final TimelineMutationCoordinator<_UnifiedTask> _mutations;
  late TabController _tabController;

  bool _dark = false;
  StructuredTimelinePersistenceState _persistence = StructuredTimelinePersistenceState.idle;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate);

    _ultimateController = UltimateStructuredTimelineController<_UnifiedTask>();
    _ultraController = UltraTimelineController(
      initialZoom: UltraTimelineZoomLevel.comfortable,
      initialSnapStrength: UltraTimelineSnapStrength.balanced,
    );
    _mutations = TimelineMutationCoordinator<_UnifiedTask>();

    _engine = TimelinePlannerEngine<_UnifiedTask>(
      adapter: TimelineSeriesAdapter<_UnifiedTask>(
        entryAdapter: TimelineEntryAdapter<_UnifiedTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => task.duration,
          status: (task) => task.completed ? TimelineStatus.completed : TimelineStatus.pending,
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

    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _ultimateController.dispose();
    _ultraController.dispose();
    _mutations.dispose();
    _tabController.dispose();
    super.dispose();
  }

  static List<_UnifiedTask> _seed(DateTime day) {
    DateTime at(int hour, int minute) => DateTime(day.year, day.month, day.day, hour, minute);
    return <_UnifiedTask>[
      _UnifiedTask(
        id: 'sleep',
        title: 'Nachtruhe',
        subtitle: 'Erholsamer Schlaf',
        start: at(0, 0),
        duration: const Duration(hours: 7, minutes: 30),
        color: const Color(0xFF3E8EEC),
        icon: Icons.nightlight_round,
        kind: NeonPlannerEntryKind.sleep,
        completed: true,
        badges: const ['Erholung'],
      ),
      _UnifiedTask(
        id: 'briefing',
        title: 'Morning command briefing',
        subtitle: 'Review priorities and protect deep work focus blocks.',
        start: at(8, 0),
        duration: const Duration(minutes: 30),
        color: const Color(0xFF169A78),
        icon: Icons.wb_sunny_rounded,
        kind: NeonPlannerEntryKind.appointment,
        completed: true,
        badges: const ['Daily'],
      ),
      _UnifiedTask(
        id: 'focus',
        title: 'Konzentriert arbeiten',
        subtitle: 'Wichtigste Aufgabe zuerst erledigen.',
        start: at(8, 50),
        duration: const Duration(minutes: 120),
        color: const Color(0xFF6F55E8),
        icon: Icons.center_focus_strong_rounded,
        kind: NeonPlannerEntryKind.focus,
        progress: 0.75,
        badges: const ['Deep work', 'V16 Engine'],
      ),
      _UnifiedTask(
        id: 'walk',
        title: 'Walk and reset',
        subtitle: 'Outdoor break to boost cognitive capacity.',
        start: at(11, 20),
        duration: const Duration(minutes: 35),
        color: const Color(0xFF2D83C7),
        icon: Icons.directions_walk_rounded,
        kind: NeonPlannerEntryKind.breakTime,
        badges: const ['Health'],
      ),
      _UnifiedTask(
        id: 'review',
        title: 'Projektabstimmung',
        subtitle: 'Teamraum - UI und accessibility review.',
        start: at(13, 0),
        duration: const Duration(minutes: 85),
        color: const Color(0xFFE05F70),
        icon: Icons.groups_rounded,
        kind: NeonPlannerEntryKind.appointment,
        progress: 0.5,
        badges: const ['Review', 'A11y'],
      ),
    ];
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

  void _resetData() {
    _save(() {
      _tasks = _seed(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _dark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      brightness: brightness,
    );
    final appTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: _dark ? const Color(0xFF090D16) : const Color(0xFFF3F7FA),
    );

    return Theme(
      data: appTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timeline Generations Hub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Verify & compare legacy and modern widgets with shared data',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Reset Data',
              icon: const Icon(Icons.restore_rounded),
              onPressed: _resetData,
            ),
            IconButton(
              tooltip: 'Toggle Theme',
              icon: Icon(_dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () => setState(() => _dark = !_dark),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'v16 Compact Mobile'),
              Tab(text: 'v15 Ultra Planner'),
              Tab(text: 'v14 Friendly UI'),
              Tab(text: 'v13 Workspace Shell'),
              Tab(text: 'v12 Ultimate Structured'),
              Tab(text: 'v10 Delight Snapping'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildV16(),
            _buildV15(),
            _buildV14(),
            _buildV13(),
            _buildV12(),
            _buildV10(),
          ],
        ),
      ),
    );
  }

  Widget _buildV16() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeonPlannerDayTimeline<_UnifiedTask>(
              entries: _tasks,
              adapter: const _UnifiedV16Adapter(),
              selectedDate: _selectedDate,
              fit: NeonPlannerDayFit.scroll,
              autoResponsiveDensity: true,
              dragMode: NeonPlannerDayDragMode.time,
              overlapPresentation: NeonPlannerOverlapPresentation.stacked,
              snapInterval: const Duration(minutes: 5),
              enableResize: true,
              showAdaptiveTimeLens: true,
              showMoveConfirmation: true,
              showResizeConfirmation: true,
              animateCommittedMove: true,
              borderRadius: 0,
              showGrabber: false,
              showHeader: false,
              backgroundColor: Colors.transparent,
              theme: NeonPlannerTimelineTheme.of(context).copyWith(
                shadowColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
              ),
              onEntryMove: (proposal) {
                _save(() {
                  _tasks = _tasks.map((t) => t.id == proposal.entry.data.id ? t.copyWith(start: proposal.proposedStart, duration: proposal.proposedEnd.difference(proposal.proposedStart)) : t).toList();
                });
                return const NeonPlannerMutationResult.accepted('Verschoben.');
              },
              onEntryResize: (proposal) {
                _save(() {
                  _tasks = _tasks.map((t) => t.id == proposal.entry.data.id ? t.copyWith(start: proposal.proposedStart, duration: proposal.proposedEnd.difference(proposal.proposedStart)) : t).toList();
                });
                return const NeonPlannerMutationResult.accepted('Größe geändert.');
              },
              onFeedback: (msg) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(msg)));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildV15() {
    final workspaceTheme = _dark
        ? UltraTimelineThemeData.fromColorScheme(Theme.of(context).colorScheme)
        : UltraTimelineThemeData.fromColorScheme(Theme.of(context).colorScheme);
    
    final config = UltraTimelineConfig(
      initialZoom: UltraTimelineZoomLevel.comfortable,
      initialSnapStrength: UltraTimelineSnapStrength.balanced,
      dragActivation: UltraTimelineDragActivation.longPress,
      enableRangeEditor: true,
      showMetrics: true,
    );

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AdaptivePlannerTimeline<_UnifiedTask>(
        values: _tasks,
        engine: _engine,
        selectedDate: _selectedDate,
        title: 'Ultra Planner v15',
        subtitle: 'Semantic continuous zoom and snapping',
        config: config,
        controller: _ultraController,
        timelineController: _ultimateController,
        mutationCoordinator: _mutations,
        persistenceState: _persistence,
        workspaceTheme: workspaceTheme,
        metrics: _v15Metrics(),
        entryPresentationBuilder: (context, details) {
          final task = details.value;
          return UltraTimelineEntryPresentation<_UnifiedTask>(
            details: details,
            title: task.title,
            subtitle: task.subtitle,
            timeLabel: '${_clock(details.visibleStart)} – ${_clock(details.visibleEnd)}',
            icon: task.icon,
            tone: _tone(task.kind),
            progress: task.progress,
            badges: task.badges,
          );
        },
        onMove: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start) : t).toList();
        }),
        onResize: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start, duration: details.preview.duration) : t).toList();
        }),
        onDelete: (context, details) => _save(() {
          _tasks = _tasks.where((t) => t.id != details.value.id).toList();
        }),
        dataRevision: Object.hashAll(_tasks.map((t) => Object.hash(t.id, t.start, t.duration))),
      ),
    );
  }

  Widget _buildV14() {
    final workspaceTheme = _dark
        ? FriendlyTimelineUiThemeData.fromColorScheme(Theme.of(context).colorScheme)
        : FriendlyTimelineUiThemeData.sunrise(Theme.of(context).colorScheme);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FriendlyUiStructuredTimeline<_UnifiedTask>(
        values: _tasks,
        engine: _engine,
        selectedDate: _selectedDate,
        title: 'Friendly Planner v14',
        subtitle: 'A joy-led user interface for daily schedules',
        controller: _ultimateController,
        mutationCoordinator: _mutations,
        config: const UltimateStructuredTimelineConfig.friendly(),
        workspaceTheme: workspaceTheme,
        persistenceState: _persistence,
        metrics: _v14Metrics(),
        entryPresentationBuilder: (context, details) {
          final task = details.value;
          return FriendlyTimelineEntryPresentation(
            details: details,
            title: task.title,
            timeLabel: '${_clock(details.visibleStart)} – ${_clock(details.visibleEnd)}',
            icon: task.icon,
            tone: _friendlyTone(task.kind),
          );
        },
        onMove: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start) : t).toList();
        }),
        onResize: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start, duration: details.preview.duration) : t).toList();
        }),
      ),
    );
  }

  Widget _buildV13() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AdvancedUiStructuredTimeline<_UnifiedTask>(
        values: _tasks,
        engine: _engine,
        selectedDate: _selectedDate,
        controller: _ultimateController,
        title: 'Orbit Planner v13',
        subtitle: 'Complete workspace shell and sidebar navigation',
        metrics: _v13Metrics(),
        onMove: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start) : t).toList();
        }),
        onResize: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start, duration: details.preview.duration) : t).toList();
        }),
      ),
    );
  }

  Widget _buildV12() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: UltimateStructuredTimeline<_UnifiedTask>(
        values: _tasks,
        engine: _engine,
        selectedDate: _selectedDate,
        config: const UltimateStructuredTimelineConfig.production(),
        onMove: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start) : t).toList();
        }),
        onResize: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start, duration: details.preview.duration) : t).toList();
        }),
      ),
    );
  }

  Widget _buildV10() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DelightStructuredTimeline<_UnifiedTask>(
        values: _tasks,
        engine: _engine,
        selectedDate: _selectedDate,
        experience: const StructuredTimelineExperience.delight(),
        onMove: (context, details) => _save(() {
          _tasks = _tasks.map((t) => t.id == details.value.id ? t.copyWith(start: details.preview.start) : t).toList();
        }),
      ),
    );
  }

  List<UltraTimelineMetric> _v15Metrics() {
    final planned = _tasks.fold<int>(0, (sum, t) => sum + t.duration.inMinutes);
    final completed = _tasks.where((t) => t.completed).length;
    return [
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
    ];
  }

  List<FriendlyTimelineMetric> _v14Metrics() {
    final planned = _tasks.fold<int>(0, (sum, t) => sum + t.duration.inMinutes);
    final completed = _tasks.where((t) => t.completed).length;
    return [
      FriendlyTimelineMetric(
        label: 'Planned',
        value: '${planned ~/ 60}h ${planned % 60}m',
        icon: Icons.access_time_rounded,
        tone: FriendlyTimelineIconTone.sky,
      ),
      FriendlyTimelineMetric(
        label: 'Completed',
        value: '$completed / ${_tasks.length}',
        icon: Icons.done_all_rounded,
        tone: FriendlyTimelineIconTone.mint,
      ),
    ];
  }

  List<AdvancedTimelineMetric> _v13Metrics() {
    final planned = _tasks.fold<int>(0, (sum, t) => sum + t.duration.inMinutes);
    return [
      AdvancedTimelineMetric(
        label: 'Scheduled Hours',
        value: '${planned ~/ 60}h ${planned % 60}m',
        icon: Icons.calendar_today_rounded,
        emphasized: true,
      ),
    ];
  }

  static String _clock(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  static UltraTimelineTone _tone(NeonPlannerEntryKind kind) {
    return switch (kind) {
      NeonPlannerEntryKind.sleep => UltraTimelineTone.sky,
      NeonPlannerEntryKind.focus => UltraTimelineTone.violet,
      NeonPlannerEntryKind.breakTime => UltraTimelineTone.mint,
      _ => UltraTimelineTone.primary,
    };
  }

  static FriendlyTimelineIconTone _friendlyTone(NeonPlannerEntryKind kind) {
    return switch (kind) {
      NeonPlannerEntryKind.sleep => FriendlyTimelineIconTone.sky,
      NeonPlannerEntryKind.focus => FriendlyTimelineIconTone.lavender,
      NeonPlannerEntryKind.breakTime => FriendlyTimelineIconTone.mint,
      _ => FriendlyTimelineIconTone.primary,
    };
  }
}

class _UnifiedV16Adapter extends NeonPlannerEntryAdapter<_UnifiedTask> {
  const _UnifiedV16Adapter();

  @override
  Object idOf(_UnifiedTask entry) => entry.id;

  @override
  DateTime startOf(_UnifiedTask entry) => entry.start;

  @override
  DateTime endOf(_UnifiedTask entry) => entry.start.add(entry.duration);

  @override
  NeonPlannerEntryPresentation presentationOf(_UnifiedTask entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      subtitle: entry.subtitle,
      metadata: entry.badges.isEmpty ? null : entry.badges.join(', '),
      icon: entry.icon,
      kind: entry.kind,
    );
  }
}

class _UnifiedTask {
  const _UnifiedTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.duration,
    required this.color,
    required this.icon,
    this.completed = false,
    this.locked = false,
    this.progress = 0.0,
    this.kind = NeonPlannerEntryKind.appointment,
    this.badges = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final Duration duration;
  final Color color;
  final IconData icon;
  final bool completed;
  final bool locked;
  final double progress;
  final NeonPlannerEntryKind kind;
  final List<String> badges;

  _UnifiedTask copyWith({
    DateTime? start,
    Duration? duration,
    bool? completed,
  }) {
    return _UnifiedTask(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      icon: icon,
      completed: completed ?? this.completed,
      locked: locked,
      progress: progress,
      kind: kind,
      badges: badges,
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class V4PlatformShowcase extends StatefulWidget {
  const V4PlatformShowcase({super.key});

  @override
  State<V4PlatformShowcase> createState() => _V4PlatformShowcaseState();
}

class _V4PlatformShowcaseState extends State<V4PlatformShowcase> {
  final TimelineController<_StudioTask> _controller =
      TimelineController<_StudioTask>();
  final TimelineCommandHistory _history = TimelineCommandHistory();
  final TextEditingController _searchController = TextEditingController();

  late DateTime _selectedDate;
  late List<TimelineEntry<_StudioTask>> _entries;
  TimelineVisualStyle _style = TimelineVisualStyle.aurora;
  TimelineStatus? _statusFilter;
  int _workspaceIndex = 0;
  int _dataRevision = 0;

  static const List<TimelineResource> _resources = <TimelineResource>[
    TimelineResource(
      id: 'design',
      label: 'Design Studio',
      subtitle: 'Product and visual systems',
      color: Color(0xFF8B7CFF),
      capacity: 2,
    ),
    TimelineResource(
      id: 'engineering',
      label: 'Engineering',
      subtitle: 'Core, rendering, integrations',
      color: Color(0xFF42E8C3),
      capacity: 2,
    ),
    TimelineResource(
      id: 'quality',
      label: 'Quality Lab',
      subtitle: 'Tests, accessibility, release',
      color: Color(0xFFFFB35C),
      capacity: 1,
    ),
    TimelineResource(
      id: 'community',
      label: 'Community',
      subtitle: 'Docs, showcase, adoption',
      color: Color(0xFFFF7188),
      capacity: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _entries = _buildEntries(_selectedDate);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _controller.dispose();
    _history.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  List<TimelineEntry<_StudioTask>> get _visibleEntries {
    final query = _searchController.text.trim().toLowerCase();
    return _entries
        .where((entry) {
          final task = entry.value;
          final matchesQuery =
              query.isEmpty ||
              task.title.toLowerCase().contains(query) ||
              task.subtitle.toLowerCase().contains(query) ||
              task.category.toLowerCase().contains(query);
          final matchesStatus =
              _statusFilter == null || entry.status == _statusFilter;
          return matchesQuery && matchesStatus;
        })
        .toList(growable: false);
  }

  Object get _viewRevision => Object.hash(
    _dataRevision,
    _searchController.text,
    _statusFilter,
    _selectedDate,
  );

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final timelineTheme = _themeFor(_style, brightness);
    final visibleEntries = _visibleEntries;
    final now = _clockForSelectedDay();
    final plan = TimelineRenderPlan<_StudioTask>.build(
      entries: visibleEntries,
      selectedDate: _selectedDate,
      now: now,
    );
    final analytics = TimelineAnalytics.analyze<_StudioTask>(plan: plan);
    final dependencyAnalysis = TimelineDependencyEngine.analyze<_StudioTask>(
      entries: _entries,
      dependencies: _dependencies,
    );

    return TimelineTheme(
      data: timelineTheme,
      child: TimelineBackdrop(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_controller, _history]),
          builder: (_, __) {
            final selectedEntry = _selectedEntry;
            return TimelineWorkspace(
              destinations: const <TimelineWorkspaceDestination>[
                TimelineWorkspaceDestination(
                  label: 'Studio',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Day',
                  icon: Icons.calendar_view_day_outlined,
                  selectedIcon: Icons.calendar_view_day_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Resources',
                  icon: Icons.groups_2_outlined,
                  selectedIcon: Icons.groups_2_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Planner',
                  icon: Icons.view_week_outlined,
                  selectedIcon: Icons.view_week_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Roadmap',
                  icon: Icons.route_outlined,
                  selectedIcon: Icons.route_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Agenda',
                  icon: Icons.view_agenda_outlined,
                  selectedIcon: Icons.view_agenda_rounded,
                ),
              ],
              selectedIndex: _workspaceIndex,
              onDestinationSelected: (index) {
                setState(() => _workspaceIndex = index);
              },
              title: 'Timeline Studio 4.0',
              subtitle:
                  'A production-style workspace, not a single decorative demo.',
              leading: _BrandMark(theme: timelineTheme),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Undo',
                  onPressed: _history.canUndo ? _history.undo : null,
                  icon: const Icon(Icons.undo_rounded),
                ),
                IconButton(
                  tooltip: 'Redo',
                  onPressed: _history.canRedo ? _history.redo : null,
                  icon: const Icon(Icons.redo_rounded),
                ),
                PopupMenuButton<TimelineVisualStyle>(
                  tooltip: 'Visual style',
                  initialValue: _style,
                  onSelected: (style) => setState(() => _style = style),
                  itemBuilder: (context) => _visibleStyles
                      .map(
                        (style) => PopupMenuItem<TimelineVisualStyle>(
                          value: style,
                          child: Row(
                            children: <Widget>[
                              _ThemeDot(theme: _themeFor(style, brightness)),
                              const SizedBox(width: 10),
                              Text(_styleLabel(style)),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                  icon: const Icon(Icons.palette_outlined),
                ),
              ],
              toolbar: _buildToolbar(timelineTheme),
              inspector: _Inspector(
                entry: selectedEntry,
                dependencyAnalysis: dependencyAnalysis,
                theme: timelineTheme,
                onClose: _controller.clearSelection,
              ),
              body: _buildWorkspaceBody(
                timelineTheme,
                visibleEntries,
                analytics,
                dependencyAnalysis,
                now,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbar(TimelineThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _ToolbarGroup(
          children: <Widget>[
            IconButton(
              tooltip: 'Previous day',
              onPressed: () => _changeDay(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            TextButton.icon(
              onPressed: _goToToday,
              icon: const Icon(Icons.today_outlined, size: 18),
              label: Text(_formatDate(_selectedDate)),
            ),
            IconButton(
              tooltip: 'Next day',
              onPressed: () => _changeDay(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks, category…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              isDense: true,
              filled: true,
              fillColor: theme.surfaceVariantColor.withAlpha(120),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
            ),
          ),
        ),
        PopupMenuButton<TimelineStatus?>(
          tooltip: 'Filter by status',
          onSelected: (status) => setState(() => _statusFilter = status),
          itemBuilder: (context) => <PopupMenuEntry<TimelineStatus?>>[
            const PopupMenuItem<TimelineStatus?>(
              value: null,
              child: Text('All statuses'),
            ),
            ...TimelineStatus.values.map(
              (status) => PopupMenuItem<TimelineStatus?>(
                value: status,
                child: Text(_statusLabel(status)),
              ),
            ),
          ],
          child: TimelineStatusBadge(
            label: _statusFilter == null
                ? 'All statuses'
                : _statusLabel(_statusFilter!),
            status: _statusFilter ?? TimelineStatus.active,
            icon: Icons.filter_list_rounded,
          ),
        ),
        FilledButton.icon(
          onPressed: _addEntry,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New block'),
        ),
      ],
    );
  }

  Widget _buildWorkspaceBody(
    TimelineThemeData theme,
    List<TimelineEntry<_StudioTask>> visibleEntries,
    TimelineAnalyticsSnapshot<_StudioTask> analytics,
    TimelineDependencyAnalysis<_StudioTask> dependencyAnalysis,
    DateTime now,
  ) {
    return switch (_workspaceIndex) {
      0 => _StudioOverview(
        entries: visibleEntries,
        selectedDate: _selectedDate,
        now: now,
        analytics: analytics,
        dependencyAnalysis: dependencyAnalysis,
        dependencies: _dependencies,
        controller: _controller,
        dataRevision: _viewRevision,
        onEntryTap: _handleEntryTap,
      ),
      1 => CalendarDayView<_StudioTask>(
        entries: visibleEntries,
        selectedDate: _selectedDate,
        now: now,
        timelineController: _controller,
        dataRevision: _viewRevision,
        startHour: 7,
        endHour: 20,
        pixelsPerMinute: 1.55,
        onEntryTap: _handleEntryTap,
        itemBuilder: (context, details) => _DayTaskCard(
          details: details,
          selected: _controller.isSelected(details.entryDetails.entry.id),
        ),
      ),
      2 => ResourceTimelineView<_StudioTask>(
        resources: _resources,
        entries: visibleEntries,
        selectedDate: _selectedDate,
        now: now,
        timelineController: _controller,
        dataRevision: _viewRevision,
        startHour: 7,
        endHour: 20,
        pixelsPerMinute: 1.35,
        rowHeight: 124,
        onEntryTap: _handleEntryTap,
        itemBuilder: (context, details) => _ResourceTaskBlock(
          details: details,
          selected: _controller.isSelected(details.entryDetails.entry.id),
        ),
      ),
      3 => PlannerView<_StudioTask>(
        entries: visibleEntries,
        selectedDate: _selectedDate,
        now: now,
        timelineController: _controller,
        dataRevision: _viewRevision,
        onEntryTap: _handleEntryTap,
        onEntryMoved: (context, details, newStart) =>
            _moveEntry(details.entry, newStart),
        itemBuilder: (context, details) {
          final task = details.entry.value;
          return TimelineCard(
            title: task.title,
            subtitle: task.subtitle,
            category: task.category,
            timeLabel: _formatTime(details.displayStart),
            status: details.entry.status,
            progress: task.progress,
            selected: _controller.isSelected(details.entry.id),
            semanticLabel: details.entry.semanticLabel ?? task.title,
            trailing: details.hasConflict
                ? Icon(Icons.warning_amber_rounded, color: theme.errorColor)
                : const Icon(Icons.drag_indicator_rounded),
          );
        },
      ),
      4 => _RoadmapStudio(
        entries: visibleEntries,
        controller: _controller,
        onEntryTap: _handleEntryTap,
      ),
      _ => AgendaView<_StudioTask>(
        entries: visibleEntries,
        timelineController: _controller,
        dataRevision: _viewRevision,
        now: now,
        onEntryTap: _handleEntryTap,
        itemBuilder: (context, details) => _AgendaTaskRow(
          details: details,
          selected: _controller.isSelected(details.entry.id),
        ),
      ),
    };
  }

  TimelineEntry<_StudioTask>? get _selectedEntry {
    if (_controller.selectedIds.isEmpty) return null;
    final selectedId = _controller.selectedIds.first;
    for (final entry in _entries) {
      if (entry.id == selectedId) return entry;
    }
    return null;
  }

  void _handleEntryTap(
    BuildContext context,
    TimelineEntryDetails<_StudioTask> details,
  ) {
    _controller.select(details.entry.id, mode: TimelineSelectionMode.single);
  }

  Future<void> _moveEntry(
    TimelineEntry<_StudioTask> entry,
    DateTime newStart,
  ) async {
    final oldStart = entry.start;
    if (oldStart == newStart) return;
    await _history.run(
      _StudioMoveCommand(
        label: 'Move ${entry.value.title}',
        apply: (start) {
          if (!mounted) return;
          setState(() {
            final index = _entries.indexWhere((item) => item.id == entry.id);
            if (index < 0) return;
            _entries[index] = _entries[index].copyWith(start: start);
            _dataRevision++;
          });
        },
        oldStart: oldStart,
        newStart: newStart,
      ),
    );
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
      _entries = _buildEntries(_selectedDate);
      _controller.clearSelection();
      _dataRevision++;
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _entries = _buildEntries(_selectedDate);
      _controller.clearSelection();
      _dataRevision++;
    });
  }

  void _addEntry() {
    final sequence = _entries.length + 1;
    final entry = TimelineEntry<_StudioTask>(
      id: 'custom-$sequence-${_selectedDate.millisecondsSinceEpoch}',
      value: _StudioTask(
        title: 'Custom planning block $sequence',
        subtitle: 'Created from the 4.0 studio toolbar.',
        category: 'Custom',
        progress: 0,
        priority: _StudioPriority.medium,
      ),
      start: _selectedDate.add(Duration(hours: 16, minutes: sequence * 5)),
      duration: const Duration(minutes: 50),
      resourceIds: const <Object>{'engineering'},
    );
    setState(() {
      _entries = <TimelineEntry<_StudioTask>>[..._entries, entry];
      _dataRevision++;
      _controller.selectOnly(entry.id);
    });
  }

  DateTime _clockForSelectedDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate == today) return now;
    return _selectedDate.add(const Duration(hours: 11, minutes: 20));
  }

  TimelineThemeData _themeFor(
    TimelineVisualStyle style,
    Brightness brightness,
  ) {
    return switch (style) {
      TimelineVisualStyle.modern => TimelineThemeData.modern(
        brightness: brightness,
      ),
      TimelineVisualStyle.minimal => TimelineThemeData.minimal(
        brightness: brightness,
      ),
      TimelineVisualStyle.editorial => TimelineThemeData.editorial(
        brightness: brightness,
      ),
      TimelineVisualStyle.glass => TimelineThemeData.glass(
        brightness: brightness,
      ),
      TimelineVisualStyle.enterprise => TimelineThemeData.enterprise(
        brightness: brightness,
      ),
      TimelineVisualStyle.highContrast => TimelineThemeData.highContrast(
        brightness: brightness,
      ),
      TimelineVisualStyle.darkProfessional =>
        TimelineThemeData.darkProfessional(),
      TimelineVisualStyle.neonLegacy => TimelineThemeData.neonLegacy(),
      TimelineVisualStyle.aurora => TimelineThemeData.aurora(
        brightness: brightness,
      ),
      TimelineVisualStyle.softProfessional =>
        TimelineThemeData.softProfessional(brightness: brightness),
      TimelineVisualStyle.horizon => TimelineThemeData.horizon(
        brightness: brightness,
      ),
      TimelineVisualStyle.obsidian => TimelineThemeData.obsidian(),
      TimelineVisualStyle.paper => TimelineThemeData.paper(
        brightness: brightness,
      ),
      TimelineVisualStyle.signal => TimelineThemeData.signal(
        brightness: brightness,
      ),
      TimelineVisualStyle.custom => TimelineThemeData.modern(
        brightness: brightness,
      ),
    };
  }

  static const List<TimelineVisualStyle> _visibleStyles = <TimelineVisualStyle>[
    TimelineVisualStyle.aurora,
    TimelineVisualStyle.modern,
    TimelineVisualStyle.softProfessional,
    TimelineVisualStyle.horizon,
    TimelineVisualStyle.obsidian,
    TimelineVisualStyle.paper,
    TimelineVisualStyle.signal,
    TimelineVisualStyle.minimal,
    TimelineVisualStyle.editorial,
    TimelineVisualStyle.glass,
    TimelineVisualStyle.enterprise,
    TimelineVisualStyle.highContrast,
    TimelineVisualStyle.darkProfessional,
    TimelineVisualStyle.neonLegacy,
  ];

  static const List<TimelineDependency> _dependencies = <TimelineDependency>[
    TimelineDependency(
      id: 'd1',
      predecessorId: 'discovery',
      successorId: 'architecture',
    ),
    TimelineDependency(
      id: 'd2',
      predecessorId: 'architecture',
      successorId: 'render-engine',
    ),
    TimelineDependency(
      id: 'd3',
      predecessorId: 'design-system',
      successorId: 'playground',
    ),
    TimelineDependency(
      id: 'd4',
      predecessorId: 'render-engine',
      successorId: 'quality-gate',
    ),
  ];

  List<TimelineEntry<_StudioTask>> _buildEntries(DateTime day) {
    DateTime at(int hour, [int minute = 0]) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    return <TimelineEntry<_StudioTask>>[
      TimelineEntry<_StudioTask>(
        id: 'discovery',
        value: const _StudioTask(
          title: 'Product discovery',
          subtitle: 'Validate use cases, API boundaries, and measurable value.',
          category: 'Strategy',
          progress: 1,
          priority: _StudioPriority.high,
        ),
        start: at(8),
        duration: const Duration(minutes: 70),
        status: TimelineStatus.completed,
        resourceIds: const <Object>{'design', 'community'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'architecture',
        value: const _StudioTask(
          title: 'Platform architecture',
          subtitle:
              'Separate core, render plan, interaction, and presentation.',
          category: 'Engineering',
          progress: 0.82,
          priority: _StudioPriority.critical,
        ),
        start: at(9, 20),
        duration: const Duration(minutes: 110),
        status: TimelineStatus.active,
        resourceIds: const <Object>{'engineering'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'design-system',
        value: const _StudioTask(
          title: 'Advanced design system',
          subtitle: 'Aurora, modern, soft, enterprise, glass, and legacy.',
          category: 'Design',
          progress: 0.64,
          priority: _StudioPriority.high,
        ),
        start: at(9, 50),
        duration: const Duration(minutes: 95),
        status: TimelineStatus.active,
        resourceIds: const <Object>{'design'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'render-engine',
        value: const _StudioTask(
          title: 'Render engine hardening',
          subtitle: 'O(1) conflict lookup, DST-safe days, static grid layers.',
          category: 'Performance',
          progress: 0.58,
          priority: _StudioPriority.critical,
        ),
        start: at(11, 15),
        duration: const Duration(minutes: 125),
        status: TimelineStatus.active,
        resourceIds: const <Object>{'engineering', 'quality'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'accessibility',
        value: const _StudioTask(
          title: 'Accessibility review',
          subtitle: 'Keyboard, semantics, focus, contrast, and reduced motion.',
          category: 'Quality',
          progress: 0.45,
          priority: _StudioPriority.high,
        ),
        start: at(12),
        duration: const Duration(minutes: 80),
        resourceIds: const <Object>{'quality'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'playground',
        value: const _StudioTask(
          title: 'Interactive playground',
          subtitle: 'A complete studio that demonstrates real product flows.',
          category: 'Experience',
          progress: 0.7,
          priority: _StudioPriority.medium,
        ),
        start: at(14),
        duration: const Duration(minutes: 100),
        status: TimelineStatus.active,
        resourceIds: const <Object>{'design', 'community'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'benchmarks',
        value: const _StudioTask(
          title: 'Benchmark matrix',
          subtitle: '10 to 5,000 entries, overlaps, resources, and web builds.',
          category: 'Performance',
          progress: 0.32,
          priority: _StudioPriority.medium,
        ),
        start: at(14, 30),
        duration: const Duration(minutes: 85),
        resourceIds: const <Object>{'engineering', 'quality'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'quality-gate',
        value: const _StudioTask(
          title: 'Release quality gate',
          subtitle: 'Analyzer, tests, builds, migration, and publish dry-run.',
          category: 'Release',
          progress: 0.18,
          priority: _StudioPriority.critical,
        ),
        start: at(16, 15),
        duration: const Duration(minutes: 90),
        resourceIds: const <Object>{'quality'},
      ),
      TimelineEntry<_StudioTask>(
        id: 'launch-story',
        value: const _StudioTask(
          title: 'Launch story and docs',
          subtitle: 'Explain the engineering, results, and migration honestly.',
          category: 'Community',
          progress: 0.25,
          priority: _StudioPriority.medium,
        ),
        start: at(17),
        duration: const Duration(minutes: 75),
        resourceIds: const <Object>{'community'},
      ),
    ];
  }
}

class _StudioOverview extends StatelessWidget {
  const _StudioOverview({
    required this.entries,
    required this.selectedDate,
    required this.now,
    required this.analytics,
    required this.dependencyAnalysis,
    required this.dependencies,
    required this.controller,
    required this.dataRevision,
    required this.onEntryTap,
  });

  final List<TimelineEntry<_StudioTask>> entries;
  final DateTime selectedDate;
  final DateTime now;
  final TimelineAnalyticsSnapshot<_StudioTask> analytics;
  final TimelineDependencyAnalysis<_StudioTask> dependencyAnalysis;
  final List<TimelineDependency> dependencies;
  final TimelineController<_StudioTask> controller;
  final Object dataRevision;
  final TimelineEntryCallback<_StudioTask> onEntryTap;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final dayWindow = const Duration(hours: 13);
    final utilization = analytics.utilizationFor(dayWindow) * 100;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          sliver: SliverToBoxAdapter(
            child: TimelineSectionHeader(
              title: 'Operational overview',
              subtitle:
                  'Real render-plan metrics and a live day canvas share one screen.',
              actions: <Widget>[
                TimelineStatusBadge(
                  label: dependencyAnalysis.isValid
                      ? 'Dependency graph healthy'
                      : '${dependencyAnalysis.issues.length} graph issues',
                  status: dependencyAnalysis.isValid
                      ? TimelineStatus.completed
                      : TimelineStatus.error,
                  icon: dependencyAnalysis.isValid
                      ? Icons.account_tree_outlined
                      : Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 92,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildListDelegate(<Widget>[
              TimelineMetricCard(
                label: 'Scheduled blocks',
                value: '${analytics.entryCount}',
                trend:
                    '${analytics.countForStatus(TimelineStatus.active)} active',
                icon: Icons.view_timeline_outlined,
              ),
              TimelineMetricCard(
                label: 'Utilization',
                value: '${utilization.toStringAsFixed(0)}%',
                trend: '${analytics.occupiedDuration.inMinutes} min occupied',
                icon: Icons.donut_large_rounded,
                accentColor: theme.secondaryColor,
              ),
              TimelineMetricCard(
                label: 'Peak concurrency',
                value: '${analytics.peakConcurrency}×',
                trend: '${analytics.conflictingEntryCount} conflict IDs',
                icon: Icons.layers_outlined,
                accentColor: theme.warningColor,
              ),
              TimelineMetricCard(
                label: 'Completion',
                value:
                    '${(analytics.completionRate * 100).toStringAsFixed(0)}%',
                trend:
                    '${analytics.countForStatus(TimelineStatus.completed)} done',
                icon: Icons.task_alt_rounded,
                accentColor: theme.successColor,
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 620,
              child: TimelinePanel(
                padding: EdgeInsets.zero,
                child: CalendarDayView<_StudioTask>(
                  entries: entries,
                  selectedDate: selectedDate,
                  now: now,
                  timelineController: controller,
                  dataRevision: dataRevision,
                  startHour: 7,
                  endHour: 20,
                  pixelsPerMinute: 1.2,
                  onEntryTap: onEntryTap,
                  itemBuilder: (context, details) => _DayTaskCard(
                    details: details,
                    selected: controller.isSelected(
                      details.entryDetails.entry.id,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const TimelineSectionHeader(
                  title: 'Dependency architecture',
                  subtitle:
                      'Topological layers, graph issues, and the critical delivery path.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 470,
                  child: TimelinePanel(
                    padding: EdgeInsets.zero,
                    child: DependencyTimelineView<_StudioTask>(
                      entries: entries,
                      dependencies: dependencies,
                      timelineController: controller,
                      onEntryTap: onEntryTap,
                      itemBuilder: (context, details) {
                        final entry = details.entryDetails.entry;
                        final task = entry.value;
                        return TimelineCard(
                          title: task.title,
                          subtitle: task.subtitle,
                          category: details.onCriticalPath
                              ? 'Critical path'
                              : details.slack == null
                              ? 'Layer ${details.depth + 1}'
                              : 'Slack ${_formatDuration(details.slack!)}',
                          timeLabel: _formatTime(
                            details.entryDetails.displayStart,
                          ),
                          status: details.hasGraphIssue
                              ? TimelineStatus.error
                              : entry.status,
                          progress: task.progress,
                          selected: controller.isSelected(entry.id),
                          semanticLabel: entry.semanticLabel ?? task.title,
                          trailing: Icon(
                            details.hasGraphIssue
                                ? Icons.error_outline_rounded
                                : details.onCriticalPath
                                ? Icons.bolt_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoadmapStudio extends StatelessWidget {
  const _RoadmapStudio({
    required this.entries,
    required this.controller,
    required this.onEntryTap,
  });

  final List<TimelineEntry<_StudioTask>> entries;
  final TimelineController<_StudioTask> controller;
  final TimelineEntryCallback<_StudioTask> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return RoadmapView<_StudioTask>(
      entries: entries,
      timelineController: controller,
      itemExtent: 320,
      onEntryTap: onEntryTap,
      oppositeBuilder: (context, details) => Text(
        _formatTime(details.displayStart),
        style: TextStyle(
          color: TimelineTheme.of(context).mutedTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      itemBuilder: (context, details) {
        final task = details.entry.value;
        return TimelinePanel(
          selected: controller.isSelected(details.entry.id),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TimelineStatusBadge(
                label: task.category,
                status: details.entry.status,
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TimelineTheme.of(context).textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TimelineTheme.of(context).mutedTextColor,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: task.progress),
            ],
          ),
        );
      },
    );
  }
}

class _DayTaskCard extends StatelessWidget {
  const _DayTaskCard({required this.details, required this.selected});

  final TimelineDayEntryDetails<_StudioTask> details;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final entry = details.entryDetails.entry;
    final task = entry.value;
    final accent = entry.color ?? _priorityColor(task.priority, theme);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 58 || constraints.maxWidth < 120;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? theme.selectionColor : theme.surfaceColor,
            borderRadius: BorderRadius.circular(
              compact ? 10 : theme.cardRadius,
            ),
            border: Border.all(
              color: details.entryDetails.hasConflict
                  ? theme.errorColor
                  : selected
                  ? theme.focusColor
                  : accent.withAlpha(90),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: theme.elevation <= 0
                ? const <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      color: Colors.black.withAlpha(18),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              compact ? 10 : theme.cardRadius,
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: accent),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 9 : 12,
                    compact ? 6 : 10,
                    compact ? 7 : 10,
                    compact ? 6 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        task.title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: theme.textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (!compact) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          '${_formatTime(details.entryDetails.displayStart)} – '
                          '${_formatTime(details.entryDetails.displayEnd)} · '
                          '${task.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: theme.mutedTextColor),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            minHeight: 4,
                            color: accent,
                            backgroundColor: theme.dividerColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResourceTaskBlock extends StatelessWidget {
  const _ResourceTaskBlock({required this.details, required this.selected});

  final TimelineResourceEntryDetails<_StudioTask> details;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final task = details.entryDetails.entry.value;
    final accent = details.resource.color ?? theme.primaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? theme.selectionColor : accent.withAlpha(34),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: details.isOverbooked
              ? theme.errorColor
              : selected
              ? theme.focusColor
              : accent.withAlpha(120),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: <Widget>[
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: theme.textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _formatTime(details.entryDetails.displayStart),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: theme.mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (details.isOverbooked)
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: theme.errorColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _AgendaTaskRow extends StatelessWidget {
  const _AgendaTaskRow({required this.details, required this.selected});

  final TimelineEntryDetails<_StudioTask> details;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final task = details.entry.value;
    return TimelinePanel(
      selected: selected,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 62,
            child: Column(
              children: <Widget>[
                Text(
                  _formatTime(details.displayStart),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${details.displayDuration.inMinutes} min',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: theme.mutedTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: _priorityColor(task.priority, theme),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.mutedTextColor),
                ),
              ],
            ),
          ),
          TimelineStatusBadge(
            label: task.category,
            status: details.entry.status,
          ),
        ],
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({
    required this.entry,
    required this.dependencyAnalysis,
    required this.theme,
    required this.onClose,
  });

  final TimelineEntry<_StudioTask>? entry;
  final TimelineDependencyAnalysis<_StudioTask> dependencyAnalysis;
  final TimelineThemeData theme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ads_click_rounded, size: 44, color: theme.mutedTextColor),
          const SizedBox(height: 12),
          Text(
            'Select a block',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: theme.textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Details, resources, progress, and dependency timing appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.mutedTextColor),
          ),
        ],
      );
    }

    final task = entry!.value;
    final earliest = dependencyAnalysis.earliestStartById[entry!.id];
    final onCriticalPath = dependencyAnalysis.criticalEntryIds.contains(
      entry!.id,
    );
    final latest = dependencyAnalysis.latestStartById[entry!.id];
    final slack = dependencyAnalysis.slackById[entry!.id];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Inspector',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Clear selection',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TimelineStatusBadge(
            label: _statusLabel(entry!.status),
            status: entry!.status,
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: theme.textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(task.subtitle, style: TextStyle(color: theme.mutedTextColor)),
          const SizedBox(height: 22),
          _InspectorField(
            label: 'Time',
            value:
                '${_formatTime(entry!.start)} – ${_formatTime(entry!.rawEnd)}',
          ),
          _InspectorField(label: 'Category', value: task.category),
          _InspectorField(
            label: 'Priority',
            value: task.priority.name.toUpperCase(),
          ),
          _InspectorField(
            label: 'Resources',
            value: entry!.resourceIds.join(', '),
          ),
          if (earliest != null)
            _InspectorField(
              label: 'Dependency earliest start',
              value: _formatTime(earliest),
            ),
          if (latest != null)
            _InspectorField(
              label: 'Latest safe start',
              value: _formatTime(latest),
            ),
          if (slack != null)
            _InspectorField(
              label: 'Scheduling slack',
              value: _formatDuration(slack),
            ),
          const SizedBox(height: 16),
          TimelineStatusBadge(
            label: onCriticalPath ? 'Critical path' : 'Non-critical',
            status: onCriticalPath
                ? TimelineStatus.error
                : TimelineStatus.completed,
            icon: onCriticalPath
                ? Icons.priority_high_rounded
                : Icons.check_rounded,
          ),
          const SizedBox(height: 18),
          Text(
            'Progress ${(task.progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: task.progress),
        ],
      ),
    );
  }
}

class _InspectorField extends StatelessWidget {
  const _InspectorField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: theme.mutedTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(color: theme.textColor),
          ),
        ],
      ),
    );
  }
}

class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceVariantColor.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.theme});

  final TimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[theme.primaryColor, theme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Icon(Icons.timeline_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({required this.theme});

  final TimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[theme.primaryColor, theme.secondaryColor],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor),
      ),
    );
  }
}

class _StudioMoveCommand implements TimelineCommand {
  const _StudioMoveCommand({
    required this.label,
    required this.apply,
    required this.oldStart,
    required this.newStart,
  });

  @override
  final String label;
  final ValueChanged<DateTime> apply;
  final DateTime oldStart;
  final DateTime newStart;

  @override
  FutureOr<void> execute() {
    apply(newStart);
  }

  @override
  FutureOr<void> undo() {
    apply(oldStart);
  }
}

enum _StudioPriority { low, medium, high, critical }

class _StudioTask {
  const _StudioTask({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.progress,
    required this.priority,
  });

  final String title;
  final String subtitle;
  final String category;
  final double progress;
  final _StudioPriority priority;
}

String _styleLabel(TimelineVisualStyle style) {
  return switch (style) {
    TimelineVisualStyle.modern => 'Modern',
    TimelineVisualStyle.minimal => 'Minimal',
    TimelineVisualStyle.editorial => 'Editorial',
    TimelineVisualStyle.glass => 'Glass',
    TimelineVisualStyle.enterprise => 'Enterprise',
    TimelineVisualStyle.highContrast => 'High contrast',
    TimelineVisualStyle.darkProfessional => 'Dark professional',
    TimelineVisualStyle.neonLegacy => 'Neon legacy',
    TimelineVisualStyle.aurora => 'Aurora',
    TimelineVisualStyle.softProfessional => 'Soft professional',
    TimelineVisualStyle.horizon => 'Horizon',
    TimelineVisualStyle.obsidian => 'Obsidian',
    TimelineVisualStyle.paper => 'Paper',
    TimelineVisualStyle.signal => 'Signal',
    TimelineVisualStyle.custom => 'Custom',
  };
}

String _statusLabel(TimelineStatus status) {
  return switch (status) {
    TimelineStatus.pending => 'Pending',
    TimelineStatus.active => 'Active',
    TimelineStatus.completed => 'Completed',
    TimelineStatus.error => 'Error',
    TimelineStatus.disabled => 'Disabled',
  };
}

String _formatDuration(Duration value) {
  final minutes = value.inMinutes;
  if (minutes == 0) return '0 min';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$minutes min';
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}m';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDate(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

Color _priorityColor(_StudioPriority priority, TimelineThemeData theme) {
  return switch (priority) {
    _StudioPriority.low => theme.mutedTextColor,
    _StudioPriority.medium => theme.primaryColor,
    _StudioPriority.high => theme.warningColor,
    _StudioPriority.critical => theme.errorColor,
  };
}

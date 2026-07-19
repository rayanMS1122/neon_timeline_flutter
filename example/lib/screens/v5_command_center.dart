import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class V5CommandCenter extends StatefulWidget {
  const V5CommandCenter({super.key});

  @override
  State<V5CommandCenter> createState() => _V5CommandCenterState();
}

class _V5CommandCenterState extends State<V5CommandCenter> {
  final TimelineController<_V5Task> _controller = TimelineController<_V5Task>();
  final TextEditingController _searchController = TextEditingController();

  late final DateTime _day;
  late final List<TimelineEntry<_V5Task>> _entries;
  late final TimelineTemporalIndex<_V5Task> _temporalIndex;
  late final TimelineScenarioComparison<_V5Task> _comparison;

  int _destination = 0;
  TimelineVisualStyle _style = TimelineVisualStyle.horizon;
  TimelineStatus? _statusFilter;

  static const List<TimelineResource> _resources = <TimelineResource>[
    TimelineResource(
      id: 'product',
      label: 'Product',
      subtitle: 'Research and direction',
      color: Color(0xFF7C5CFF),
      capacity: 2,
    ),
    TimelineResource(
      id: 'design',
      label: 'Design',
      subtitle: 'Systems and interaction',
      color: Color(0xFFFF8D66),
      capacity: 2,
    ),
    TimelineResource(
      id: 'engineering',
      label: 'Engineering',
      subtitle: 'Core and platform',
      color: Color(0xFF00BFAE),
      capacity: 3,
    ),
    TimelineResource(
      id: 'release',
      label: 'Release',
      subtitle: 'Quality and launch',
      color: Color(0xFFFFC857),
      capacity: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
    _entries = _buildEntries(_day);
    _temporalIndex = TimelineTemporalIndex<_V5Task>.build(_entries);
    final candidate =
        _entries
            .map(
              (entry) => entry.id == 'architecture'
                  ? entry.copyWith(
                      start: entry.start.add(const Duration(minutes: 45)),
                      status: TimelineStatus.completed,
                    )
                  : entry.id == 'docs'
                  ? entry.copyWith(
                      resourceIds: const <Object>{'product', 'release'},
                    )
                  : entry,
            )
            .toList(growable: true)
          ..add(
            TimelineEntry<_V5Task>(
              id: 'launch-rehearsal',
              value: const _V5Task(
                title: 'Launch rehearsal',
                subtitle: 'Validate the complete release path.',
                category: 'Release',
              ),
              start: _day.add(const Duration(hours: 17)),
              duration: const Duration(hours: 1),
              status: TimelineStatus.pending,
              color: const Color(0xFFFFC857),
              resourceIds: const <Object>{'release'},
            ),
          );
    _comparison = TimelineScenarioEngine.compare<_V5Task>(
      base: TimelineScenario<_V5Task>(
        id: 'baseline',
        name: 'Baseline',
        entries: _entries,
      ),
      candidate: TimelineScenario<_V5Task>(
        id: 'accelerated',
        name: 'Accelerated launch',
        entries: candidate,
      ),
    );
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<TimelineEntry<_V5Task>> get _visibleEntries {
    final query = TimelineQuery<_V5Task>(
      text: _searchController.text,
      statuses: _statusFilter == null
          ? const <TimelineStatus>{}
          : <TimelineStatus>{_statusFilter!},
      rangeStart: _day,
      rangeEnd: DateTime(_day.year, _day.month, _day.day + 1),
      searchText: (entry) =>
          '${entry.value.title} ${entry.value.subtitle} ${entry.value.category}',
    );
    return query.apply(_entries, index: _temporalIndex).entries;
  }

  TimelineThemeData _theme(Brightness brightness) {
    return switch (_style) {
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
      _ => TimelineThemeData.horizon(brightness: brightness),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme(Theme.of(context).brightness);
    final visible = _visibleEntries;
    final plan = TimelineRenderPlan<_V5Task>.build(
      entries: visible,
      selectedDate: _day,
      now: _day.add(const Duration(hours: 11, minutes: 25)),
    );

    return TimelineTheme(
      data: theme,
      child: TimelineBackdrop(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return TimelineWorkspace(
              destinations: const <TimelineWorkspaceDestination>[
                TimelineWorkspaceDestination(
                  label: 'Focus',
                  icon: Icons.center_focus_weak_outlined,
                  selectedIcon: Icons.center_focus_strong_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Board',
                  icon: Icons.view_kanban_outlined,
                  selectedIcon: Icons.view_kanban_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Matrix',
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                ),
                TimelineWorkspaceDestination(
                  label: 'Scenarios',
                  icon: Icons.compare_arrows_outlined,
                  selectedIcon: Icons.compare_arrows_rounded,
                ),
              ],
              selectedIndex: _destination,
              onDestinationSelected: (value) {
                setState(() => _destination = value);
              },
              title: 'Timeline Command Center 5.0',
              subtitle:
                  'Fast temporal queries, recurring work, scenarios and modern planning surfaces.',
              leading: _BrandMark(theme: theme),
              actions: <Widget>[
                PopupMenuButton<TimelineVisualStyle>(
                  tooltip: 'Visual system',
                  initialValue: _style,
                  onSelected: (value) => setState(() => _style = value),
                  itemBuilder: (context) =>
                      const <PopupMenuEntry<TimelineVisualStyle>>[
                        PopupMenuItem(
                          value: TimelineVisualStyle.horizon,
                          child: Text('Horizon'),
                        ),
                        PopupMenuItem(
                          value: TimelineVisualStyle.obsidian,
                          child: Text('Obsidian'),
                        ),
                        PopupMenuItem(
                          value: TimelineVisualStyle.paper,
                          child: Text('Paper'),
                        ),
                        PopupMenuItem(
                          value: TimelineVisualStyle.signal,
                          child: Text('Signal'),
                        ),
                      ],
                  icon: const Icon(Icons.palette_outlined),
                ),
                IconButton(
                  tooltip: 'Command palette',
                  onPressed: () => _showCommands(context),
                  icon: const Icon(Icons.bolt_rounded),
                ),
              ],
              toolbar: _Toolbar(
                controller: _searchController,
                status: _statusFilter,
                onStatusChanged: (value) {
                  setState(() => _statusFilter = value);
                },
                entries: visible,
                rangeStart: _day.add(const Duration(hours: 8)),
                rangeEnd: _day.add(const Duration(hours: 19)),
                selectedId: _controller.focusedId,
                onSeek: (instant) {
                  _controller.setVisibleRange(
                    TimelineDateRange(
                      instant.subtract(const Duration(hours: 1)),
                      instant.add(const Duration(hours: 1)),
                    ),
                  );
                },
              ),
              body: _body(plan, visible),
              inspector: _Inspector(
                entry: _selectedEntry,
                style: _style,
                visibleCount: visible.length,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    TimelineRenderPlan<_V5Task> plan,
    List<TimelineEntry<_V5Task>> visible,
  ) {
    return switch (_destination) {
      0 => TimelineFocusView<_V5Task>(
        plan: plan,
        now: _day.add(const Duration(hours: 11, minutes: 25)),
        titleBuilder: (entry) => entry.value.title,
        subtitleBuilder: (entry) => entry.value.subtitle,
        onEntryTap: _select,
      ),
      1 => TimelineBoardView<_V5Task>(
        entries: visible,
        controller: _controller,
        groupBy: (entry) => entry.status,
        groupLabel: (group) => switch (group as TimelineStatus) {
          TimelineStatus.pending => 'Queued',
          TimelineStatus.active => 'In progress',
          TimelineStatus.completed => 'Completed',
          TimelineStatus.error => 'Needs attention',
          TimelineStatus.disabled => 'Disabled',
        },
        groupOrder: const <Object>[
          TimelineStatus.active,
          TimelineStatus.pending,
          TimelineStatus.completed,
          TimelineStatus.error,
        ],
        titleBuilder: (entry) => entry.value.title,
        subtitleBuilder: (entry) => entry.value.subtitle,
        onEntryTap: _select,
      ),
      2 => TimelineMatrixView<_V5Task>(
        entries: visible,
        resources: _resources,
        rangeStart: _day.add(const Duration(hours: 8)),
        rangeEnd: _day.add(const Duration(hours: 19)),
        slotDuration: const Duration(hours: 1),
        titleBuilder: (entry) => entry.value.title,
        onEntryTap: _select,
      ),
      3 => TimelineScenarioCompareView<_V5Task>(
        comparison: _comparison,
        titleBuilder: (entry) => entry.value.title,
        onChangeTap: (change) {
          final entry = change.after ?? change.before;
          if (entry != null) _select(entry);
        },
      ),
      _ => const SizedBox.shrink(),
    };
  }

  TimelineEntry<_V5Task>? get _selectedEntry {
    final id = _controller.focusedId;
    if (id == null) return null;
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  void _select(TimelineEntry<_V5Task> entry) {
    _controller.batch(() {
      _controller.selectOnly(entry.id);
      _controller.setFocusedId(entry.id);
    });
  }

  Future<void> _showCommands(BuildContext context) {
    return showTimelineCommandPalette(
      context: context,
      commands: <TimelinePaletteCommand>[
        TimelinePaletteCommand(
          id: 'focus',
          label: 'Open focus view',
          description: 'Show the current and next task.',
          icon: Icons.center_focus_strong_rounded,
          shortcut: 'F',
          onSelected: () => setState(() => _destination = 0),
        ),
        TimelinePaletteCommand(
          id: 'board',
          label: 'Open status board',
          description: 'Group work by lifecycle status.',
          icon: Icons.view_kanban_rounded,
          shortcut: 'B',
          onSelected: () => setState(() => _destination = 1),
        ),
        TimelinePaletteCommand(
          id: 'matrix',
          label: 'Open resource matrix',
          description: 'Inspect assignments across the day.',
          icon: Icons.grid_view_rounded,
          shortcut: 'M',
          onSelected: () => setState(() => _destination = 2),
        ),
        TimelinePaletteCommand(
          id: 'scenarios',
          label: 'Compare scenarios',
          description: 'Review added, removed and modified work.',
          icon: Icons.compare_arrows_rounded,
          shortcut: 'S',
          onSelected: () => setState(() => _destination = 3),
        ),
        TimelinePaletteCommand(
          id: 'theme-signal',
          label: 'Use Signal theme',
          description: 'Switch to the high-energy 5.0 visual system.',
          icon: Icons.palette_rounded,
          onSelected: () => setState(() => _style = TimelineVisualStyle.signal),
        ),
        TimelinePaletteCommand(
          id: 'clear-filter',
          label: 'Clear filters',
          description: 'Show every scheduled entry.',
          icon: Icons.filter_alt_off_rounded,
          onSelected: () {
            setState(() => _statusFilter = null);
            _searchController.clear();
          },
        ),
      ],
    );
  }

  static List<TimelineEntry<_V5Task>> _buildEntries(DateTime day) {
    final base = <TimelineEntry<_V5Task>>[
      TimelineEntry(
        id: 'research',
        value: const _V5Task(
          title: 'Market signal review',
          subtitle: 'Turn usage evidence into a sharp product direction.',
          category: 'Product',
        ),
        start: day.add(const Duration(hours: 8, minutes: 20)),
        duration: const Duration(hours: 1, minutes: 10),
        status: TimelineStatus.completed,
        color: const Color(0xFF7C5CFF),
        resourceIds: const <Object>{'product'},
      ),
      TimelineEntry(
        id: 'architecture',
        value: const _V5Task(
          title: 'Temporal index architecture',
          subtitle: 'Finalize range-query and cache boundaries.',
          category: 'Engineering',
        ),
        start: day.add(const Duration(hours: 9, minutes: 30)),
        duration: const Duration(hours: 2),
        status: TimelineStatus.active,
        color: const Color(0xFF00BFAE),
        resourceIds: const <Object>{'engineering'},
      ),
      TimelineEntry(
        id: 'design-system',
        value: const _V5Task(
          title: 'Signal design system',
          subtitle: 'Build the new board, focus and matrix language.',
          category: 'Design',
        ),
        start: day.add(const Duration(hours: 10, minutes: 15)),
        duration: const Duration(hours: 2, minutes: 15),
        status: TimelineStatus.active,
        color: const Color(0xFFFF8D66),
        resourceIds: const <Object>{'design', 'product'},
      ),
      TimelineEntry(
        id: 'recurrence',
        value: const _V5Task(
          title: 'Recurrence validation',
          subtitle: 'Exercise daily, weekly and monthly expansion.',
          category: 'Engineering',
        ),
        start: day.add(const Duration(hours: 12, minutes: 45)),
        duration: const Duration(hours: 1),
        status: TimelineStatus.pending,
        color: const Color(0xFF00BFAE),
        resourceIds: const <Object>{'engineering'},
      ),
      TimelineEntry(
        id: 'docs',
        value: const _V5Task(
          title: 'Migration and cookbook',
          subtitle: 'Make 5.0 adoption obvious and safe.',
          category: 'Product',
        ),
        start: day.add(const Duration(hours: 14, minutes: 10)),
        duration: const Duration(hours: 1, minutes: 20),
        status: TimelineStatus.pending,
        color: const Color(0xFF7C5CFF),
        resourceIds: const <Object>{'product'},
      ),
      TimelineEntry(
        id: 'release-check',
        value: const _V5Task(
          title: 'Release quality gate',
          subtitle: 'Run analyzer, tests, builds and dry-run publishing.',
          category: 'Release',
        ),
        start: day.add(const Duration(hours: 16)),
        duration: const Duration(hours: 1, minutes: 15),
        status: TimelineStatus.pending,
        color: const Color(0xFFFFC857),
        resourceIds: const <Object>{'release', 'engineering'},
      ),
    ];

    final recurringPrototype = TimelineEntry<_V5Task>(
      id: 'daily-sync',
      value: const _V5Task(
        title: 'Daily platform sync',
        subtitle: 'Resolve blockers across product, design and engineering.',
        category: 'Operations',
      ),
      start: day.add(const Duration(hours: 11, minutes: 40)),
      duration: const Duration(minutes: 25),
      status: TimelineStatus.pending,
      color: const Color(0xFF8F76FF),
      resourceIds: const <Object>{'product', 'design', 'engineering'},
    );
    final recurring = TimelineRecurrenceRule.daily(count: 1).expand<_V5Task>(
      prototype: recurringPrototype,
      windowStart: day,
      windowEnd: DateTime(day.year, day.month, day.day + 1),
    );
    return <TimelineEntry<_V5Task>>[...base, ...recurring];
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.status,
    required this.onStatusChanged,
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedId,
    required this.onSeek,
  });

  final TextEditingController controller;
  final TimelineStatus? status;
  final ValueChanged<TimelineStatus?> onStatusChanged;
  final List<TimelineEntry<_V5Task>> entries;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Object? selectedId;
  final ValueChanged<DateTime> onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return Column(
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search the command center',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.surfaceVariantColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ChoiceChip(
              label: const Text('All'),
              selected: status == null,
              onSelected: (_) => onStatusChanged(null),
            ),
            for (final value in <TimelineStatus>[
              TimelineStatus.active,
              TimelineStatus.pending,
              TimelineStatus.completed,
            ])
              ChoiceChip(
                label: Text(value.name),
                selected: status == value,
                onSelected: (_) => onStatusChanged(value),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TimelineOverviewStrip<_V5Task>(
          entries: entries,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          selectedId: selectedId,
          height: 42,
          onSeek: onSeek,
        ),
      ],
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({
    required this.entry,
    required this.style,
    required this.visibleCount,
  });

  final TimelineEntry<_V5Task>? entry;
  final TimelineVisualStyle style;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    if (entry == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TimelineSectionHeader(
            title: 'Inspector',
            subtitle: 'Select an entry to inspect it.',
          ),
          const SizedBox(height: 18),
          TimelineMetricCard(
            label: 'Visible entries',
            value: '$visibleCount',
            icon: Icons.visibility_rounded,
          ),
          const SizedBox(height: 10),
          TimelineMetricCard(
            label: 'Visual system',
            value: style.name,
            icon: Icons.palette_rounded,
            accentColor: theme.secondaryColor,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TimelineSectionHeader(
          title: entry!.value.title,
          subtitle: entry!.value.category,
        ),
        const SizedBox(height: 16),
        Text(
          entry!.value.subtitle,
          style: TextStyle(color: theme.mutedTextColor, height: 1.45),
        ),
        const SizedBox(height: 18),
        TimelineStatusBadge(label: entry!.status.name, status: entry!.status),
        const SizedBox(height: 16),
        _InspectorRow(label: 'Start', value: _time(entry!.start)),
        _InspectorRow(
          label: 'Duration',
          value: '${entry!.rawDuration.inMinutes} min',
        ),
        _InspectorRow(label: 'Resources', value: entry!.resourceIds.join(', ')),
      ],
    );
  }

  static String _time(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }
}

class _InspectorRow extends StatelessWidget {
  const _InspectorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: TextStyle(color: theme.mutedTextColor)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
      child: const SizedBox(
        width: 42,
        height: 42,
        child: Icon(Icons.timeline_rounded, color: Colors.white),
      ),
    );
  }
}

class _V5Task {
  const _V5Task({
    required this.title,
    required this.subtitle,
    required this.category,
  });

  final String title;
  final String subtitle;
  final String category;

  @override
  String toString() => title;
}

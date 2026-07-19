import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

class V8AdvancedStructuredShowcase extends StatefulWidget {
  const V8AdvancedStructuredShowcase({super.key});

  @override
  State<V8AdvancedStructuredShowcase> createState() =>
      _V8AdvancedStructuredShowcaseState();
}

class _V8AdvancedStructuredShowcaseState
    extends State<V8AdvancedStructuredShowcase> {
  late DateTime _selectedDate;
  late List<_V8Task> _tasks;
  late final TimelinePlannerEngine<_V8Task> _engine;
  late final StructuredTimelineController<_V8Task> _controller;
  late final TimelineMutationCoordinator<_V8Task> _mutations;
  StructuredTimelineLayout _layout =
      const StructuredTimelineLayout.comfortable();
  bool _dark = false;
  bool _failNextSave = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _tasks = _seed(_selectedDate, now);
    _controller = StructuredTimelineController<_V8Task>();
    _controller.addListener(_onControllerChanged);
    _mutations = TimelineMutationCoordinator<_V8Task>();
    _engine = TimelinePlannerEngine<_V8Task>(
      adapter: TimelineSeriesAdapter<_V8Task>(
        entryAdapter: TimelineEntryAdapter<_V8Task>(
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

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _mutations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _dark
        ? StructuredTimelineStyle.dark()
        : StructuredTimelineStyle.light();
    final visible = _tasks.where((task) => _sameDay(task.start, _selectedDate));
    final stats = _engine
        .buildDay(
          values: visible,
          selectedDate: _selectedDate,
          now: DateTime.now(),
        )
        .dayPlan;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: _dark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B2135),
          brightness: _dark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Scaffold(
        backgroundColor: style.backgroundColor,
        appBar: AppBar(
          backgroundColor: style.backgroundColor,
          titleSpacing: 8,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Advanced Structured Timeline',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              Text(
                '8.0.0 · drag, resize, controller and mutation locks',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Jump to now',
              onPressed: _controller.jumpToNow,
              icon: const Icon(Icons.my_location_rounded),
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
              tooltip: 'Timeline settings',
              onSelected: _handleMenu,
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'comfortable',
                  child: Text('Comfortable layout'),
                ),
                const PopupMenuItem<String>(
                  value: 'compact',
                  child: Text('Compact layout'),
                ),
                const PopupMenuItem<String>(
                  value: 'dense',
                  child: Text('Dense layout'),
                ),
                const PopupMenuItem<String>(
                  value: 'absolute',
                  child: Text('Absolute-time layout'),
                ),
                PopupMenuItem<String>(
                  value: 'theme',
                  child: Text(_dark ? 'Use light theme' : 'Use dark theme'),
                ),
                PopupMenuItem<String>(
                  value: 'fail',
                  child: Text(
                    _failNextSave
                        ? 'Save failure armed'
                        : 'Simulate next save failure',
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'slots',
                  child: Text('Suggest a 45-minute slot'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _Header(
              selectedDate: _selectedDate,
              style: style,
              entries: stats.entries.length,
              conflicts: stats.conflicts.length,
              busy: stats.busyDuration,
              zoom: _controller.zoom,
              layout: _layout.density.name,
              onPrevious: () => _changeDay(-1),
              onNext: () => _changeDay(1),
              onSelectDay: _selectDay,
            ),
            Expanded(
              child: AdvancedStructuredTimelinePlanner<_V8Task>(
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
                layout: _layout,
                controller: _controller,
                mutationCoordinator: _mutations,
                showBoundaryGaps: false,
                enableDeleteTarget: true,
                enableResizing: true,
                titleBuilder: (entry) => entry.value.title,
                subtitleBuilder: (entry) => entry.value.subtitle,
                progressBuilder: (entry) => entry.value.progress,
                onEntryTap: (context, details) {
                  _showTaskSheet(details.value);
                },
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
                    SnackBar(
                      content: Text('Save failed for ${entry.semanticLabel}'),
                    ),
                  );
                },
                conflictBridgeBuilder: (context, item, overlap, valueStyle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: valueStyle.conflictColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${overlap.inMinutes}m overlap',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
                dragPlaceholderBuilder: (context, details, child) {
                  return Opacity(
                    opacity: 0.22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: details.style.primaryColor,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(
                          details.style.cardRadius,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addTask(),
          backgroundColor: style.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add task'),
        ),
      ),
    );
  }

  Future<void> _simulateSave() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (_failNextSave) {
      if (mounted) {
        setState(() => _failNextSave = false);
      } else {
        _failNextSave = false;
      }
      throw StateError('Simulated repository failure');
    }
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'comfortable':
        setState(() => _layout = const StructuredTimelineLayout.comfortable());
        break;
      case 'compact':
        setState(() => _layout = const StructuredTimelineLayout.compact());
        break;
      case 'dense':
        setState(() => _layout = const StructuredTimelineLayout.dense());
        break;
      case 'absolute':
        setState(() => _layout = const StructuredTimelineLayout.absoluteTime());
        break;
      case 'theme':
        setState(() => _dark = !_dark);
        break;
      case 'fail':
        setState(() => _failNextSave = true);
        break;
      case 'slots':
        _showSlotSuggestions();
        break;
    }
  }

  void _showSlotSuggestions() {
    final plan = _engine
        .buildDay(
          values: _tasks,
          selectedDate: _selectedDate,
          now: DateTime.now(),
        )
        .dayPlan;
    final suggestions = TimelineSlotSuggestionEngine.suggest<_V8Task>(
      plan: plan,
      requestedDuration: const Duration(minutes: 45),
      policy: const TimelineSlotSuggestionPolicy(maximumSuggestions: 4),
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Suggested 45-minute slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              if (suggestions.isEmpty)
                const Text('No free slot is available in this day.')
              else
                for (final suggestion in suggestions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.schedule_rounded),
                    ),
                    title: Text(
                      '${_formatTime(suggestion.start)}–${_formatTime(suggestion.end)}',
                    ),
                    subtitle: Text(
                      'Score ${suggestion.score.toStringAsFixed(1)} · ${suggestion.reasons.join(', ')}',
                    ),
                    trailing: const Icon(Icons.add_rounded),
                    onTap: () {
                      Navigator.pop(context);
                      _addTask(suggestion.start);
                    },
                  ),
            ],
          ),
        );
      },
    );
  }

  void _showTaskSheet(_V8Task task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(task.subtitle),
              const SizedBox(height: 18),
              const Text(
                'Long-press the card to move it. Drag the small top or bottom handle to resize it. Your app still owns this sheet and persistence.',
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask([DateTime? start]) {
    final resolved =
        start ??
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          15,
        );
    setState(() {
      _tasks = <_V8Task>[
        ..._tasks,
        _V8Task(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
          title: 'New focus block',
          subtitle: 'Drag or resize this task',
          start: resolved,
          duration: const Duration(minutes: 35),
          color: const Color(0xFFE11D48),
          progress: 0.15,
        ),
      ];
    });
  }

  void _changeDay(int days) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + days,
      );
    });
  }

  void _selectDay(DateTime value) {
    setState(() => _selectedDate = value);
  }

  static List<_V8Task> _seed(DateTime day, DateTime now) {
    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);
    final activeStart = _sameDay(day, now)
        ? now.subtract(const Duration(minutes: 18))
        : at(9, 20);
    return <_V8Task>[
      _V8Task(
        id: 'deep-work',
        title: 'Deep work block',
        subtitle: 'Roadmap and architecture',
        start: activeStart,
        duration: const Duration(minutes: 55),
        color: const Color(0xFFE11D48),
        progress: 0.58,
      ),
      _V8Task(
        id: 'review',
        title: 'Design review',
        subtitle: 'Interaction and accessibility',
        start: at(11, 0),
        duration: const Duration(minutes: 70),
        color: const Color(0xFF7C3AED),
        progress: 0.35,
      ),
      _V8Task(
        id: 'overlap',
        title: 'Prepare release notes',
        subtitle: 'Intentional conflict preview',
        start: at(11, 45),
        duration: const Duration(minutes: 50),
        color: const Color(0xFFEA580C),
        progress: 0.7,
      ),
      _V8Task(
        id: 'calendar',
        title: 'External calendar event',
        subtitle: 'Visible but locked',
        start: at(14, 20),
        duration: const Duration(minutes: 45),
        color: const Color(0xFF0F766E),
        progress: 0,
        external: true,
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedDate,
    required this.style,
    required this.entries,
    required this.conflicts,
    required this.busy,
    required this.zoom,
    required this.layout,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDay,
  });

  final DateTime selectedDate;
  final StructuredTimelineStyle style;
  final int entries;
  final int conflicts;
  final Duration busy;
  final double zoom;
  final String layout;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.surfaceColor,
        border: Border(bottom: BorderSide(color: style.borderColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            SizedBox(
              height: 50,
              child: Row(
                children: <Widget>[
                  for (var index = 0; index < 7; index++)
                    Expanded(
                      child: _DayButton(
                        day: DateTime(
                          monday.year,
                          monday.month,
                          monday.day + index,
                        ),
                        selectedDate: selectedDate,
                        style: style,
                        onTap: onSelectDay,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _Metric(label: 'Entries', value: '$entries', style: style),
                  _Metric(
                    label: 'Busy',
                    value: '${busy.inMinutes}m',
                    style: style,
                  ),
                  _Metric(
                    label: 'Conflicts',
                    value: '$conflicts',
                    style: style,
                  ),
                  _Metric(
                    label: 'Zoom',
                    value: '${zoom.toStringAsFixed(2)}×',
                    style: style,
                  ),
                  _Metric(label: 'Layout', value: layout, style: style),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.selectedDate,
    required this.style,
    required this.onTap,
  });

  final DateTime day;
  final DateTime selectedDate;
  final StructuredTimelineStyle style;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = _sameDay(day, selectedDate);
    return InkWell(
      onTap: () => onTap(day),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? style.primaryColor.withValues(alpha: 0.13) : null,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday -
                  1],
              style: TextStyle(
                color: style.mutedTextColor,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected ? style.primaryColor : style.textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final StructuredTimelineStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: style.textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _V8Task {
  const _V8Task({
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
  final double progress;
  final bool completed;
  final bool external;

  _V8Task copyWith({DateTime? start, Duration? duration, bool? completed}) {
    return _V8Task(
      id: id,
      title: title,
      subtitle: subtitle,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      progress: progress,
      completed: completed ?? this.completed,
      external: external,
    );
  }
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _formatTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.hour)}:${two(value.minute)}';
}

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

class V6StructuredPlannerLab extends StatefulWidget {
  const V6StructuredPlannerLab({super.key});

  @override
  State<V6StructuredPlannerLab> createState() => _V6StructuredPlannerLabState();
}

class _V6StructuredPlannerLabState extends State<V6StructuredPlannerLab> {
  late final TimelinePlannerEngine<_DemoTask> _engine;
  late List<_DemoTask> _tasks;
  DateTime _selectedDate = DateTime(2026, 7, 16);
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _engine = TimelinePlannerEngine<_DemoTask>(
      seriesExpander: TimelineSeriesExpander<_DemoTask>(
        occurrenceIdBuilder: (series, index, start) =>
            'v_${series.effectiveSeriesId}_${start.millisecondsSinceEpoch}',
      ),
      adapter: TimelineSeriesAdapter<_DemoTask>(
        entryAdapter: TimelineEntryAdapter<_DemoTask>(
          id: (task) => task.id,
          start: (task) => task.start,
          duration: (task) => Duration(minutes: task.minutes),
          status: (task) => task.completed
              ? TimelineStatus.completed
              : TimelineStatus.pending,
          color: (task) => task.color,
          semanticLabel: (task) => task.title,
          draggable: (task) => !task.external,
          metadata: (task) => <String, Object?>{
            'category': task.category,
            'external': task.external,
          },
        ),
        seriesId: (task) => task.seriesId,
        recurrence: (task) => switch (task.recurrence) {
          _DemoRecurrence.none => null,
          _DemoRecurrence.daily => TimelineRecurrenceRule.daily(),
          _DemoRecurrence.weekly => TimelineRecurrenceRule.weekly(
            weekdays: <int>{task.start.weekday},
          ),
        },
        originalOccurrenceStart: (task) => task.originalOccurrenceStart,
        isOverride: (task) =>
            task.seriesId != null && task.recurrence == _DemoRecurrence.none,
        isDeleted: (task) => task.deleted,
        isExternal: (task) => task.external,
      ),
    );
    _tasks = <_DemoTask>[
      _DemoTask(
        id: 'drive',
        title: 'Drive to appointment',
        category: 'Travel',
        start: DateTime(2026, 7, 16, 9),
        minutes: 45,
        color: const Color(0xFFE78392),
      ),
      _DemoTask(
        id: 'meeting',
        title: 'Team appointment',
        category: 'Shared',
        start: DateTime(2026, 7, 16, 9, 30),
        minutes: 60,
        color: const Color(0xFF6E8FB2),
      ),
      _DemoTask(
        id: 'focus-series',
        title: 'Daily focus block',
        category: 'Focus',
        start: DateTime(2026, 7, 13, 13),
        minutes: 50,
        color: const Color(0xFF9B79C6),
        recurrence: _DemoRecurrence.daily,
      ),
      _DemoTask(
        id: 'calendar',
        title: 'External calendar event',
        category: 'Calendar',
        start: DateTime(2026, 7, 16, 16, 5),
        minutes: 15,
        color: const Color(0xFF5C89A7),
        external: true,
      ),
      _DemoTask(
        id: 'sleep',
        title: 'Sleep',
        category: 'Routine',
        start: DateTime(2026, 7, 16, 23, 5),
        minutes: 55,
        color: const Color(0xFF526E8D),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1);
    return TimelinePlannerWindowBuilder<_DemoTask>(
      values: _tasks,
      engine: _engine,
      windowStart: monthStart,
      windowEnd: monthEnd,
      dataRevision: _revision,
      builder: (context, window) {
        final now = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          10,
          45,
        );
        final plan = window.buildDay(selectedDate: _selectedDate, now: now);
        final week = window.buildWeek(selectedDate: _selectedDate, now: now);
        final activity = window.buildActivityIndex(
          startDate: monthStart,
          endDate: monthEnd.subtract(const Duration(days: 1)),
          now: now,
        );
        final snapshot = TimelinePlannerDaySnapshot<_DemoTask>(
          expansion: window.expansion,
          dayPlan: plan,
        );
        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _header(context, snapshot, week, activity),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList.builder(
                itemCount: plan.entries.length,
                itemBuilder: (context, index) =>
                    _entryCard(context, snapshot, plan.entries[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(
    BuildContext context,
    TimelinePlannerDaySnapshot<_DemoTask> snapshot,
    TimelineWeekPlan<_DemoTask> week,
    TimelineActivityIndex<_DemoTask> activity,
  ) {
    final plan = snapshot.dayPlan;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => _moveDay(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _moveDay(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: week.lanes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final lane = week.lanes[index];
                final selected = _sameDay(lane.date, _selectedDate);
                final dayActivity = activity.activityFor(lane.date);
                return ChoiceChip(
                  selected: selected,
                  avatar: dayActivity == null || dayActivity.entryCount == 0
                      ? null
                      : CircleAvatar(
                          radius: 4,
                          backgroundColor: dayActivity.colors.isEmpty
                              ? null
                              : dayActivity.colors.first,
                        ),
                  onSelected: (_) => setState(() => _selectedDate = lane.date),
                  label: Text(
                    '${lane.date.day}\n${lane.dayPlan.entries.length}',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _metric('Entries', '${plan.entries.length}'),
              _metric('Free', _duration(plan.freeDuration)),
              _metric('Busy', _duration(plan.busyDuration)),
              _metric('Conflicts', '${plan.conflicts.length}'),
              _metric('Generated', '${snapshot.expansion.generatedCount}'),
              _metric('Active days', '${activity.activeDays}'),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.schedule_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plan.insight.current != null
                          ? 'Current: ${plan.insight.current!.entry.semanticLabel}'
                          : plan.insight.next != null
                          ? 'Next in ${_duration(plan.insight.timeUntilNext ?? Duration.zero)}: ${plan.insight.next!.entry.semanticLabel}'
                          : 'No next entry in this range',
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: plan.hasConflicts
                        ? () => _showResolution(context, snapshot)
                        : null,
                    child: const Text('Resolve'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(
    BuildContext context,
    TimelinePlannerDaySnapshot<_DemoTask> snapshot,
    TimelineDayEntry<_DemoTask> item,
  ) {
    final entry = item.entry;
    final task = entry.value;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 48,
              decoration: BoxDecoration(
                color: entry.color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_time(item.start)}–${_time(item.end)} · ${_duration(item.duration)}'
                    '${item.hasConflict ? ' · conflict' : ''}'
                    '${entry.metadata['timeline.generated'] == true ? ' · recurring' : ''}',
                  ),
                  if (item.gapAfter != null && item.gapAfter! > Duration.zero)
                    Text('Free after: ${_duration(item.gapAfter!)}'),
                ],
              ),
            ),
            if (entry.draggable) ...<Widget>[
              IconButton(
                tooltip: 'Move five minutes earlier',
                onPressed: () => _moveEntry(snapshot, item, -5),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                tooltip: 'Move five minutes later',
                onPressed: () => _moveEntry(snapshot, item, 5),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Chip(label: Text('$label: $value'));
  }

  void _moveDay(int days) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + days,
      );
    });
  }

  void _moveEntry(
    TimelinePlannerDaySnapshot<_DemoTask> snapshot,
    TimelineDayEntry<_DemoTask> item,
    int minutes,
  ) {
    final session = _engine.beginReschedule(
      entry: item.entry,
      bounds: _engine.dayBounds(_selectedDate),
      candidates: snapshot.dayPlan.entries.map((value) => value.entry),
    );
    final preview = session.previewForDelta(Duration(minutes: minutes));
    final result = session.resolveDrop(preview: preview);
    if (result.disposition != TimelineDropDisposition.move) return;

    final generated = item.entry.metadata['timeline.generated'] == true;
    if (generated) {
      final seriesId = item.entry.metadata['timeline.seriesId'];
      setState(() {
        _tasks = <_DemoTask>[
          ..._tasks,
          item.entry.value.copyWith(
            id: 'override-${DateTime.now().microsecondsSinceEpoch}',
            start: preview.start,
            recurrence: _DemoRecurrence.none,
            seriesId: seriesId,
            originalOccurrenceStart:
                item.entry.metadata['timeline.originalOccurrenceStart']
                    as DateTime?,
          ),
        ];
        _revision++;
      });
    } else {
      setState(() {
        _tasks = _tasks
            .map(
              (task) => task.id == item.entry.id
                  ? task.copyWith(start: preview.start)
                  : task,
            )
            .toList(growable: false);
        _revision++;
      });
    }
  }

  void _showResolution(
    BuildContext context,
    TimelinePlannerDaySnapshot<_DemoTask> snapshot,
  ) {
    final resolution = _engine.resolveConflicts(
      entries: snapshot.dayPlan.entries.map((entry) => entry.entry),
      bounds: _engine.dayBounds(_selectedDate),
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Persistence proposals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...resolution.proposals
              .where((proposal) => proposal.changed)
              .map(
                (proposal) => ListTile(
                  title: Text(
                    proposal.entry.semanticLabel ?? '${proposal.entry.id}',
                  ),
                  subtitle: Text(
                    '${_time(proposal.originalStart)} → ${_time(proposal.proposedStart)}',
                  ),
                ),
              ),
          const SizedBox(height: 12),
          const Text(
            'The package returns proposals. Your Cubit or repository decides whether to create a recurring override and persist it.',
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  static String _duration(Duration value) {
    final minutes = value.inMinutes;
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }
}

enum _DemoRecurrence { none, daily, weekly }

@immutable
class _DemoTask {
  const _DemoTask({
    required this.id,
    required this.title,
    required this.category,
    required this.start,
    required this.minutes,
    required this.color,
    this.completed = false,
    this.external = false,
    this.deleted = false,
    this.recurrence = _DemoRecurrence.none,
    this.seriesId,
    this.originalOccurrenceStart,
  });

  final String id;
  final String title;
  final String category;
  final DateTime start;
  final int minutes;
  final Color color;
  final bool completed;
  final bool external;
  final bool deleted;
  final _DemoRecurrence recurrence;
  final Object? seriesId;
  final DateTime? originalOccurrenceStart;

  _DemoTask copyWith({
    String? id,
    DateTime? start,
    _DemoRecurrence? recurrence,
    Object? seriesId,
    DateTime? originalOccurrenceStart,
  }) {
    return _DemoTask(
      id: id ?? this.id,
      title: title,
      category: category,
      start: start ?? this.start,
      minutes: minutes,
      color: color,
      completed: completed,
      external: external,
      deleted: deleted,
      recurrence: recurrence ?? this.recurrence,
      seriesId: seriesId ?? this.seriesId,
      originalOccurrenceStart:
          originalOccurrenceStart ?? this.originalOccurrenceStart,
    );
  }
}

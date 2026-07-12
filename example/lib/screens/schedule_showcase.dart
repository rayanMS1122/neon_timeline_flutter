import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../models/demo_repository.dart';
import '../models/demo_task.dart';
import '../widgets/demo_task_card.dart';

class ScheduleShowcase extends StatefulWidget {
  const ScheduleShowcase({required this.performance, super.key});

  final NeonTimelinePerformanceConfig performance;

  @override
  State<ScheduleShowcase> createState() => _ScheduleShowcaseState();
}

class _ScheduleShowcaseState extends State<ScheduleShowcase> {
  late final DemoTaskRepository _repository;
  DateTime _selectedDate = DateTime(2026, 7, 11);
  bool _compactPlanner = true;

  @override
  void initState() {
    super.initState();
    _repository = DemoTaskRepository();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NeonTimelineHeader(
          title: 'Neon Schedule Timeline',
          subtitle: 'Drag, slide, dismiss, conflicts, gaps, and day paging',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                tooltip: 'Previous day',
                onPressed: () => _changeDay(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              IconButton(
                tooltip: 'Next day',
                onPressed: () => _changeDay(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: const Text('Compact planner'),
                selected: _compactPlanner,
                onSelected: (_) => setState(() => _compactPlanner = true),
              ),
              ChoiceChip(
                label: const Text('Original package UI'),
                selected: !_compactPlanner,
                onSelected: (_) => setState(() => _compactPlanner = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _repository,
            builder: (context, _) {
              final entries = _repository.entriesFor(_selectedDate);
              final scheduleStyle = _compactPlanner
                  ? const NeonScheduleTimelineStyle(
                      showDurationRail: true,
                      overlapIndent: 12,
                      cardVariant: NeonTimelineCardVariant.liquidCrystal,
                    )
                  : const NeonScheduleTimelineStyle(
                      showDurationRail: false,
                      overlapIndent: 0,
                      cardVariant: NeonTimelineCardVariant.glass,
                    );
              return NeonTimelineDayPager(
                selectedDate: _selectedDate,
                onDateChanged: (value) =>
                    setState(() => _selectedDate = value),
                child: NeonScheduleTimeline<DemoTask>(
                  entries: entries,
                  dataRevision: _repository.revision,
                  selectedDate: _selectedDate,
                  now: DateTime(2026, 7, 11, 10, 42),
                  performance: widget.performance,
                  style: scheduleStyle,
                  slidableGroupTag: 'schedule-showcase',
                  emptyBuilder: (context) => NeonTimelineEmptyState(
                    title: 'No entries for ${_formatDate(_selectedDate)}',
                    message: 'Swipe to another day or create a demo block.',
                    action: FilledButton.icon(
                      onPressed: () =>
                          _repository.addDemoTask(_selectedDate),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add demo task'),
                    ),
                  ),
                  useDefaultCard: !_compactPlanner,
                  itemBuilder: (context, details) {
                    final task = details.entry.value;
                    final content = DemoTaskCardContent(
                      task: task,
                      details: details,
                    );
                    if (_compactPlanner) {
                      return content;
                    }
                    return NeonTimelineCard(
                      variant: NeonTimelineCardVariant.glass,
                      accentColor: task.color,
                      semanticLabel: details.entry.semanticLabel,
                      child: content,
                    );
                  },
                  gapLabelBuilder: (context, gap) =>
                      '${gap.inMinutes} min available',
                  conflictLabelBuilder: (context, details) =>
                      'Conflict: ${details.entry.value.title}',
                  onEntryTap: (context, details) {
                    _message('Opened ${details.entry.value.title}');
                  },
                  onEntryMoved: (context, details, newStart) async {
                    await _repository.move(details.entry.value.id, newStart);
                    if (mounted) {
                      _message(
                        '${details.entry.value.title} moved to ${_formatTime(newStart)}',
                      );
                    }
                  },
                  startActionsBuilder: (context, details) =>
                      <NeonTimelineAction>[
                    NeonTimelineAction(
                      icon: Icons.check_rounded,
                      label: 'DONE',
                      tooltip: 'Mark task complete',
                      color: const Color(0xFF22B573),
                      onPressed: (_) async {
                        await _repository.complete(details.entry.value.id);
                      },
                    ),
                  ],
                  endActionsBuilder: (context, details) =>
                      <NeonTimelineAction>[
                    NeonTimelineAction(
                      icon: Icons.delete_outline_rounded,
                      label: 'DELETE',
                      tooltip: 'Delete task',
                      color: const Color(0xFFE5485D),
                      onPressed: (_) => _deleteWithUndo(details.entry.value),
                    ),
                  ],
                  onEntryEndDismissed: (context, details) =>
                      _deleteWithUndo(details.entry.value),
                  onOperationError: (context, details, error, stackTrace) {
                    _message('Operation failed: $error');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _changeDay(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
    });
  }

  Future<void> _deleteWithUndo(DemoTask task) async {
    await _repository.delete(task.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${task.title} deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _repository.restore(task),
          ),
        ),
      );
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

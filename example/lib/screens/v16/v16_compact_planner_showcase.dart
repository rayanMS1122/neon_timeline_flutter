import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

class V16CompactPlannerShowcase extends StatefulWidget {
  const V16CompactPlannerShowcase({super.key});

  @override
  State<V16CompactPlannerShowcase> createState() =>
      _V16CompactPlannerShowcaseState();
}

class _V16CompactPlannerShowcaseState
    extends State<V16CompactPlannerShowcase> {
  static const _adapter = _V16TaskAdapter();
  late final DateTime _day;
  late List<_V16Task> _tasks;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
    _tasks = <_V16Task>[
      _V16Task(
        id: 'sleep',
        title: 'Nachtschlaf',
        subtitle: 'Erholsamer Schlaf',
        start: _day.add(const Duration(hours: 0)),
        end: _day.add(const Duration(hours: 7, minutes: 30)),
        icon: Icons.nightlight_round,
        kind: NeonPlannerEntryKind.sleep,
      ),
      _V16Task(
        id: 'focus',
        title: 'Konzentriert arbeiten',
        subtitle: 'Wichtigste Aufgabe zuerst',
        start: _day.add(const Duration(hours: 8, minutes: 30)),
        end: _day.add(const Duration(hours: 9, minutes: 20)),
        icon: Icons.center_focus_strong_rounded,
        kind: NeonPlannerEntryKind.focus,
      ),
      _V16Task(
        id: 'meeting',
        title: 'Projektabstimmung',
        metadata: 'Teamraum',
        start: _day.add(const Duration(hours: 10, minutes: 15)),
        end: _day.add(const Duration(hours: 10, minutes: 45)),
        icon: Icons.groups_rounded,
        kind: NeonPlannerEntryKind.appointment,
      ),
      _V16Task(
        id: 'review',
        title: 'Tagesreview und nächste Schritte',
        start: _day.add(const Duration(hours: 14)),
        end: _day.add(const Duration(hours: 14, minutes: 25)),
        icon: Icons.fact_check_rounded,
        kind: NeonPlannerEntryKind.reminder,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: NeonPlannerDayTimeline<_V16Task>(
                entries: _tasks,
                adapter: _adapter,
                selectedDate: _day,
                fit: NeonPlannerDayFit.scroll,
                autoResponsiveDensity: true,
                microBreakpoint: 360,
                compactBreakpoint: 480,
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
                showHeader: true,
                backgroundColor: Colors.transparent,
                theme: NeonPlannerTimelineTheme.of(context).copyWith(
                  shadowColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                ),
                onEntryMove: _move,
                onEntryResize: _resize,
                onUndoMove: _undo,
                onFeedback: _feedback,
              ),
            ),
          ),
        ),
      ),
    );
  }

  NeonPlannerMutationResult _move(
    NeonPlannerMoveProposal<_V16Task> proposal,
  ) {
    setState(() {
      _tasks = _tasks
          .map(
            (task) => task.id == proposal.entry.data.id
                ? task.copyWith(
                    start: proposal.proposedStart,
                    end: proposal.proposedEnd,
                  )
                : task,
          )
          .toList(growable: false);
    });
    return const NeonPlannerMutationResult.accepted('Termin verschoben.');
  }

  NeonPlannerMutationResult _resize(
    NeonPlannerResizeProposal<_V16Task> proposal,
  ) {
    setState(() {
      _tasks = _tasks
          .map(
            (task) => task.id == proposal.entry.data.id
                ? task.copyWith(
                    start: proposal.proposedStart,
                    end: proposal.proposedEnd,
                  )
                : task,
          )
          .toList(growable: false);
    });
    return const NeonPlannerMutationResult.accepted('Dauer geändert.');
  }

  NeonPlannerMutationResult _undo(
    NeonPlannerMoveProposal<_V16Task> proposal,
  ) {
    setState(() {
      _tasks = _tasks
          .map(
            (task) => task.id == proposal.entry.data.id
                ? task.copyWith(
                    start: proposal.originalStart,
                    end: proposal.originalEnd,
                  )
                : task,
          )
          .toList(growable: false);
    });
    return const NeonPlannerMutationResult.accepted('Verschieben rückgängig.');
  }

  void _feedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

@immutable
class _V16Task {
  const _V16Task({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.icon,
    required this.kind,
    this.subtitle,
    this.metadata,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? metadata;
  final DateTime start;
  final DateTime end;
  final IconData icon;
  final NeonPlannerEntryKind kind;

  _V16Task copyWith({DateTime? start, DateTime? end}) {
    return _V16Task(
      id: id,
      title: title,
      subtitle: subtitle,
      metadata: metadata,
      start: start ?? this.start,
      end: end ?? this.end,
      icon: icon,
      kind: kind,
    );
  }
}

class _V16TaskAdapter extends NeonPlannerEntryAdapter<_V16Task> {
  const _V16TaskAdapter();

  @override
  Object idOf(_V16Task entry) => entry.id;

  @override
  DateTime startOf(_V16Task entry) => entry.start;

  @override
  DateTime endOf(_V16Task entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_V16Task entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      subtitle: entry.subtitle,
      metadata: entry.metadata,
      icon: entry.icon,
      kind: entry.kind,
    );
  }
}

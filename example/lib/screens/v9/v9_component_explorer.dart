import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

class V9ComponentExplorer extends StatelessWidget {
  const V9ComponentExplorer({required this.dark, super.key});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final style = dark
        ? StructuredTimelineStyle.dark()
        : StructuredTimelineStyle.light();
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: style.primaryColor,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Scaffold(
        backgroundColor: style.backgroundColor,
        appBar: StructuredTimelineAppBar(
          title: 'Structured Component Explorer',
          subtitle: 'Every visible building block is public and reusable',
          backgroundColor: style.surfaceColor,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: <Widget>[
            _Section(
              title: 'Navigation and metrics',
              child: Column(
                children: <Widget>[
                  StructuredTimelineDateNavigator(
                    date: DateTime(2026, 7, 16),
                    style: style,
                  ),
                  StructuredTimelineWeekStrip(
                    selectedDate: DateTime(2026, 7, 16),
                    style: style,
                  ),
                  StructuredTimelineMetricsBar(
                    metrics: const StructuredTimelineMetrics(
                      entries: 4,
                      conflicts: 1,
                      busy: Duration(hours: 3, minutes: 5),
                      free: Duration(hours: 8, minutes: 10),
                      utilization: 0.27,
                    ),
                    style: style,
                    showUtilization: true,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Rail and indicators',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  StructuredTimelineRailMarker(
                    style: style,
                    color: style.primaryColor,
                    semanticLabel: 'Task marker',
                  ),
                  StructuredTimelineLockIndicator(color: style.mutedTextColor),
                  StructuredTimelineRecurringIndicator(
                    color: style.mutedTextColor,
                  ),
                  StructuredTimelineSelectionControl(
                    selected: true,
                    color: style.primaryColor,
                  ),
                  StructuredTimelineCompletionControl(
                    completed: true,
                    color: style.primaryColor,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Conflicts and current time',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StructuredTimelineConflictBadge(
                    label: '20m overlap',
                    color: style.conflictColor,
                  ),
                  const SizedBox(height: 14),
                  StructuredTimelineConflictBridge(
                    color: style.conflictColor,
                    overlap: const Duration(minutes: 20),
                    durationFormatter: _duration,
                  ),
                  const SizedBox(height: 18),
                  StructuredTimelineCurrentTimeIndicator(
                    color: style.primaryColor,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'States and actions',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  StructuredTimelineGapAction(
                    label: 'Add task',
                    color: style.primaryColor,
                  ),
                  StructuredTimelineDeleteTarget<Object>(
                    active: false,
                    style: style,
                  ),
                  StructuredTimelineFloatingAddButton(
                    label: 'Add task',
                    backgroundColor: style.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Empty and error states',
              child: SizedBox(
                height: 260,
                child: PageView(
                  children: <Widget>[
                    StructuredTimelineEmptyState(style: style),
                    const StructuredTimelineErrorState(
                      message: 'The repository rejected the update.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _duration(Duration value) => '${value.inMinutes}m';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

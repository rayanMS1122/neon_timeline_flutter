import 'package:flutter/material.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v4/theme/timeline_theme.dart';
import '../../v4/views/timeline_components.dart';
import '../core/timeline_scenario.dart';

class TimelineScenarioCompareView<T> extends StatelessWidget {
  const TimelineScenarioCompareView({
    required this.comparison,
    required this.titleBuilder,
    this.onChangeTap,
    this.emptyLabel = 'Scenarios are identical',
    super.key,
  });

  final TimelineScenarioComparison<T> comparison;
  final String Function(TimelineEntry<T> entry) titleBuilder;
  final ValueChanged<TimelineScenarioChange<T>>? onChangeTap;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cards = <Widget>[
                TimelineMetricCard(
                  label: 'Added',
                  value: '${comparison.addedCount}',
                  icon: Icons.add_circle_outline_rounded,
                  accentColor: theme.successColor,
                ),
                TimelineMetricCard(
                  label: 'Modified',
                  value: '${comparison.modifiedCount}',
                  icon: Icons.tune_rounded,
                  accentColor: theme.warningColor,
                ),
                TimelineMetricCard(
                  label: 'Removed',
                  value: '${comparison.removedCount}',
                  icon: Icons.remove_circle_outline_rounded,
                  accentColor: theme.errorColor,
                ),
              ];
              if (constraints.maxWidth < 700) {
                return Column(
                  children: cards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: card,
                        ),
                      )
                      .toList(growable: false),
                );
              }
              return Row(
                children: <Widget>[
                  for (
                    var index = 0;
                    index < cards.length;
                    index++
                  ) ...<Widget>[
                    Expanded(child: cards[index]),
                    if (index != cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
        ),
        Expanded(
          child: comparison.changes.isEmpty
              ? Center(
                  child: Text(
                    emptyLabel,
                    style: TextStyle(color: theme.mutedTextColor),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: comparison.changes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final change = comparison.changes[index];
                    return TimelinePanel(
                      onTap: () => onChangeTap?.call(change),
                      child: _ScenarioChangeTile<T>(
                        change: change,
                        titleBuilder: titleBuilder,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ScenarioChangeTile<T> extends StatelessWidget {
  const _ScenarioChangeTile({required this.change, required this.titleBuilder});

  final TimelineScenarioChange<T> change;
  final String Function(TimelineEntry<T>) titleBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final entry = change.after ?? change.before!;
    final (icon, color, label) = switch (change.kind) {
      TimelineScenarioChangeKind.added => (
        Icons.add_rounded,
        theme.successColor,
        'Added',
      ),
      TimelineScenarioChangeKind.removed => (
        Icons.remove_rounded,
        theme.errorColor,
        'Removed',
      ),
      TimelineScenarioChangeKind.modified => (
        Icons.tune_rounded,
        theme.warningColor,
        'Modified',
      ),
    };
    final details = <String>[
      if (change.moved) 'moved',
      if (change.resized) 'resized',
      if (change.statusChanged) 'status',
      if (change.resourcesChanged) 'resources',
      if (change.valueChanged) 'content',
      if (change.enabledChanged) 'availability',
    ];

    return Row(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withAlpha(24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titleBuilder(entry),
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details.isEmpty ? label : '$label · ${details.join(', ')}',
                style: TextStyle(color: theme.mutedTextColor),
              ),
            ],
          ),
        ),
        TimelineStatusBadge(
          label: label,
          status: switch (change.kind) {
            TimelineScenarioChangeKind.added => entry.status,
            TimelineScenarioChangeKind.removed => TimelineStatus.error,
            TimelineScenarioChangeKind.modified => TimelineStatus.active,
          },
        ),
      ],
    );
  }
}

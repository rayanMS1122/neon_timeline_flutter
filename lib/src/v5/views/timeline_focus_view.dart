import 'package:flutter/material.dart';

import '../../v4/core/timeline_analytics.dart';
import '../../v4/core/timeline_render_plan.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v4/theme/timeline_theme.dart';
import '../../v4/views/timeline_components.dart';

class TimelineFocusView<T> extends StatelessWidget {
  const TimelineFocusView({
    required this.plan,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.now,
    this.onEntryTap,
    this.emptyTitle = 'Nothing scheduled',
    this.emptySubtitle = 'The selected window is clear.',
    super.key,
  });

  final TimelineRenderPlan<T> plan;
  final String Function(TimelineEntry<T> entry) titleBuilder;
  final String Function(TimelineEntry<T> entry)? subtitleBuilder;
  final DateTime? now;
  final ValueChanged<TimelineEntry<T>>? onEntryTap;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final clock = now ?? DateTime.now();
    TimelineNormalizedEntry<T>? active;
    TimelineNormalizedEntry<T>? next;
    for (final entry in plan.entries) {
      if (!clock.isBefore(entry.start) && clock.isBefore(entry.end)) {
        active ??= entry;
      } else if (!entry.start.isBefore(clock)) {
        next ??= entry;
      }
    }
    final analytics = TimelineAnalytics.analyze<T>(plan: plan);

    if (active == null && next == null) {
      return Center(
        child: TimelinePanel(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.done_all_rounded, size: 42, color: theme.successColor),
              const SizedBox(height: 14),
              Text(
                emptyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: theme.textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                style: TextStyle(color: theme.mutedTextColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 3 : 1;
            final cards = <Widget>[
              TimelineMetricCard(
                label: 'Scheduled',
                value: '${analytics.entryCount}',
                icon: Icons.event_note_rounded,
              ),
              TimelineMetricCard(
                label: 'Conflicts',
                value: '${analytics.conflictingEntryCount}',
                icon: Icons.warning_amber_rounded,
                accentColor: theme.warningColor,
              ),
              TimelineMetricCard(
                label: 'Peak concurrency',
                value: '${analytics.peakConcurrency}',
                icon: Icons.stacked_bar_chart_rounded,
                accentColor: theme.secondaryColor,
              ),
            ];
            if (columns == 1) {
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
                for (var index = 0; index < cards.length; index++) ...<Widget>[
                  Expanded(child: cards[index]),
                  if (index != cards.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        if (active != null)
          _FocusHero<T>(
            label: 'IN FOCUS',
            entry: active,
            titleBuilder: titleBuilder,
            subtitleBuilder: subtitleBuilder,
            onTap: onEntryTap,
            primary: true,
          ),
        if (active != null && next != null) const SizedBox(height: 14),
        if (next != null)
          _FocusHero<T>(
            label: active == null ? 'UP NEXT' : 'NEXT',
            entry: next,
            titleBuilder: titleBuilder,
            subtitleBuilder: subtitleBuilder,
            onTap: onEntryTap,
            primary: false,
          ),
        const SizedBox(height: 18),
        const TimelineSectionHeader(
          title: 'Upcoming flow',
          subtitle: 'The next scheduled entries in chronological order.',
        ),
        const SizedBox(height: 10),
        for (final entry
            in plan.entries.where((item) => item.start.isAfter(clock)).take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TimelinePanel(
              onTap: () => onEntryTap?.call(entry.entry),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 62,
                    child: Text(
                      _time(entry.start),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          entry.entry.color ??
                          theme.colorForStatus(entry.entry.status),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleBuilder(entry.entry),
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.mutedTextColor,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _time(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }
}

class _FocusHero<T> extends StatelessWidget {
  const _FocusHero({
    required this.label,
    required this.entry,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final TimelineNormalizedEntry<T> entry;
  final String Function(TimelineEntry<T>) titleBuilder;
  final String Function(TimelineEntry<T>)? subtitleBuilder;
  final ValueChanged<TimelineEntry<T>>? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final accent =
        entry.entry.color ?? theme.colorForStatus(entry.entry.status);
    return TimelinePanel(
      onTap: () => onTap?.call(entry.entry),
      padding: const EdgeInsets.all(22),
      selected: primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            titleBuilder(entry.entry),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: theme.textColor,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          if (subtitleBuilder != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              subtitleBuilder!(entry.entry),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: theme.mutedTextColor,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              TimelineStatusBadge(
                label: entry.entry.status.name,
                status: entry.entry.status,
              ),
              _FocusChip(
                icon: Icons.schedule_rounded,
                label:
                    '${TimelineFocusView._time(entry.start)}–'
                    '${TimelineFocusView._time(entry.end)}',
              ),
              _FocusChip(
                icon: Icons.timelapse_rounded,
                label: '${entry.duration.inMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceVariantColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: theme.mutedTextColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: theme.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

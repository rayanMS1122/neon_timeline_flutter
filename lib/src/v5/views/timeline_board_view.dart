import 'package:flutter/material.dart';

import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_types.dart';
import '../../v4/theme/timeline_theme.dart';
import '../../v4/views/timeline_components.dart';

typedef TimelineBoardGroupKey<T> = Object Function(TimelineEntry<T> entry);
typedef TimelineBoardGroupLabel = String Function(Object group);
typedef TimelineBoardEntryBuilder<T> =
    Widget Function(BuildContext context, TimelineEntry<T> entry);

class TimelineBoardView<T> extends StatelessWidget {
  const TimelineBoardView({
    required this.entries,
    required this.groupBy,
    required this.groupLabel,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.entryBuilder,
    this.groupOrder = const <Object>[],
    this.controller,
    this.onEntryTap,
    this.columnWidth = 320,
    this.emptyLabel = 'No entries',
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : assert(columnWidth >= 220);

  final List<TimelineEntry<T>> entries;
  final TimelineBoardGroupKey<T> groupBy;
  final TimelineBoardGroupLabel groupLabel;
  final String Function(TimelineEntry<T> entry) titleBuilder;
  final String Function(TimelineEntry<T> entry)? subtitleBuilder;
  final TimelineBoardEntryBuilder<T>? entryBuilder;
  final List<Object> groupOrder;
  final TimelineController<T>? controller;
  final ValueChanged<TimelineEntry<T>>? onEntryTap;
  final double columnWidth;
  final String emptyLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final grouped = <Object, List<TimelineEntry<T>>>{};
    for (final entry in entries) {
      grouped
          .putIfAbsent(groupBy(entry), () => <TimelineEntry<T>>[])
          .add(entry);
    }
    for (final values in grouped.values) {
      values.sort((a, b) => a.start.compareTo(b.start));
    }

    final keys = <Object>[
      ...groupOrder.where(grouped.containsKey),
      ...grouped.keys.where((key) => !groupOrder.contains(key)),
    ];

    if (keys.isEmpty) {
      final theme = TimelineTheme.of(context);
      return Center(
        child: Text(
          emptyLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: theme.mutedTextColor),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 640.0;
        final resolvedPadding = padding.resolve(Directionality.of(context));
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: padding,
          child: SizedBox(
            height: (availableHeight - resolvedPadding.vertical)
                .clamp(120.0, availableHeight)
                .toDouble(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var index = 0; index < keys.length; index++) ...<Widget>[
                  SizedBox(
                    width: columnWidth,
                    child: _TimelineBoardColumn<T>(
                      group: keys[index],
                      label: groupLabel(keys[index]),
                      entries: grouped[keys[index]]!,
                      titleBuilder: titleBuilder,
                      subtitleBuilder: subtitleBuilder,
                      entryBuilder: entryBuilder,
                      controller: controller,
                      onEntryTap: onEntryTap,
                      emptyLabel: emptyLabel,
                    ),
                  ),
                  if (index != keys.length - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimelineBoardColumn<T> extends StatelessWidget {
  const _TimelineBoardColumn({
    required this.group,
    required this.label,
    required this.entries,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.entryBuilder,
    required this.controller,
    required this.onEntryTap,
    required this.emptyLabel,
  });

  final Object group;
  final String label;
  final List<TimelineEntry<T>> entries;
  final String Function(TimelineEntry<T>) titleBuilder;
  final String Function(TimelineEntry<T>)? subtitleBuilder;
  final TimelineBoardEntryBuilder<T>? entryBuilder;
  final TimelineController<T>? controller;
  final ValueChanged<TimelineEntry<T>>? onEntryTap;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return TimelinePanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 12, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: theme.textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    child: Text(
                      '${entries.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: theme.mutedTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      emptyLabel,
                      style: TextStyle(color: theme.mutedTextColor),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final selected =
                          controller?.isSelected(entry.id) ?? false;
                      final content =
                          entryBuilder?.call(context, entry) ??
                          _DefaultBoardCard<T>(
                            entry: entry,
                            title: titleBuilder(entry),
                            subtitle: subtitleBuilder?.call(entry),
                          );
                      return TimelinePanel(
                        selected: selected,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          controller?.select(
                            entry.id,
                            mode: TimelineSelectionMode.single,
                          );
                          onEntryTap?.call(entry);
                        },
                        child: content,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBoardCard<T> extends StatelessWidget {
  const _DefaultBoardCard({
    required this.entry,
    required this.title,
    required this.subtitle,
  });

  final TimelineEntry<T> entry;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final accent = entry.color ?? theme.colorForStatus(entry.status);
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 7),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: theme.mutedTextColor),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: theme.mutedTextColor,
              ),
              const SizedBox(width: 5),
              Text(
                _timeLabel(entry.start),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: theme.mutedTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TimelineStatusBadge(
                label: entry.status.name,
                status: entry.status,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeLabel(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }
}

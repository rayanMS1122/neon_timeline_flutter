import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/models/timeline_resource.dart';
import '../../v4/theme/timeline_theme.dart';

class TimelineMatrixView<T> extends StatelessWidget {
  const TimelineMatrixView({
    required this.entries,
    required this.resources,
    required this.rangeStart,
    required this.rangeEnd,
    required this.titleBuilder,
    this.slotDuration = const Duration(hours: 1),
    this.slotWidth = 88,
    this.rowHeight = 84,
    this.resourceHeaderWidth = 190,
    this.onEntryTap,
    this.timeLabelBuilder,
    this.padding = const EdgeInsets.all(14),
    super.key,
  }) : assert(slotWidth >= 44),
       assert(rowHeight >= 58),
       assert(resourceHeaderWidth >= 120);

  final List<TimelineEntry<T>> entries;
  final List<TimelineResource> resources;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final String Function(TimelineEntry<T> entry) titleBuilder;
  final Duration slotDuration;
  final double slotWidth;
  final double rowHeight;
  final double resourceHeaderWidth;
  final ValueChanged<TimelineEntry<T>>? onEntryTap;
  final String Function(DateTime value)? timeLabelBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (slotDuration <= Duration.zero) {
      throw ArgumentError.value(
        slotDuration,
        'slotDuration',
        'must be greater than zero',
      );
    }
    assert(rangeEnd.isAfter(rangeStart), 'rangeEnd must be after rangeStart');
    if (!rangeEnd.isAfter(rangeStart)) {
      throw ArgumentError.value(
        rangeEnd,
        'rangeEnd',
        'must be after rangeStart',
      );
    }
    final totalMicros = rangeEnd.difference(rangeStart).inMicroseconds;
    final slotCount = math.max(
      1,
      (totalMicros / slotDuration.inMicroseconds).ceil(),
    );
    assert(slotCount <= 1000, 'Use a larger slotDuration for this range.');
    final timelineWidth = slotCount * slotWidth;
    final resourceEntries = <Object, List<TimelineEntry<T>>>{};
    for (final entry in entries) {
      for (final resourceId in entry.resourceIds) {
        resourceEntries
            .putIfAbsent(resourceId, () => <TimelineEntry<T>>[])
            .add(entry);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 640.0;
        final resolvedPadding = padding.resolve(Directionality.of(context));
        return Padding(
          padding: padding,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: resourceHeaderWidth + timelineWidth,
              height: (height - resolvedPadding.vertical)
                  .clamp(160.0, height)
                  .toDouble(),
              child: Column(
                children: <Widget>[
                  _MatrixHeader(
                    rangeStart: rangeStart,
                    slotCount: slotCount,
                    slotDuration: slotDuration,
                    slotWidth: slotWidth,
                    resourceHeaderWidth: resourceHeaderWidth,
                    timeLabelBuilder: timeLabelBuilder,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: resources.length,
                      itemExtent: rowHeight,
                      itemBuilder: (context, index) {
                        final resource = resources[index];
                        return _MatrixRow<T>(
                          resource: resource,
                          entries:
                              resourceEntries[resource.id] ??
                              <TimelineEntry<T>>[],
                          rangeStart: rangeStart,
                          rangeEnd: rangeEnd,
                          slotCount: slotCount,
                          slotWidth: slotWidth,
                          rowHeight: rowHeight,
                          resourceHeaderWidth: resourceHeaderWidth,
                          titleBuilder: titleBuilder,
                          onEntryTap: onEntryTap,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader({
    required this.rangeStart,
    required this.slotCount,
    required this.slotDuration,
    required this.slotWidth,
    required this.resourceHeaderWidth,
    required this.timeLabelBuilder,
  });

  final DateTime rangeStart;
  final int slotCount;
  final Duration slotDuration;
  final double slotWidth;
  final double resourceHeaderWidth;
  final String Function(DateTime)? timeLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return SizedBox(
      height: 52,
      child: Row(
        children: <Widget>[
          Container(
            width: resourceHeaderWidth,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              border: Border(
                right: BorderSide(color: theme.dividerColor),
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Text(
              'Resources',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          for (var index = 0; index < slotCount; index++)
            Container(
              width: slotWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                border: Border(
                  right: BorderSide(color: theme.dividerColor),
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Text(
                timeLabelBuilder?.call(rangeStart.add(slotDuration * index)) ??
                    _time(rangeStart.add(slotDuration * index)),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: theme.mutedTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _time(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }
}

class _MatrixRow<T> extends StatelessWidget {
  const _MatrixRow({
    required this.resource,
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    required this.slotCount,
    required this.slotWidth,
    required this.rowHeight,
    required this.resourceHeaderWidth,
    required this.titleBuilder,
    required this.onEntryTap,
  });

  final TimelineResource resource;
  final List<TimelineEntry<T>> entries;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int slotCount;
  final double slotWidth;
  final double rowHeight;
  final double resourceHeaderWidth;
  final String Function(TimelineEntry<T>) titleBuilder;
  final ValueChanged<TimelineEntry<T>>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final timelineWidth = slotCount * slotWidth;
    final totalMicros = rangeEnd.difference(rangeStart).inMicroseconds;
    final visible =
        entries
            .where((entry) {
              return entry.start.isBefore(rangeEnd) &&
                  entry.rawEnd.isAfter(rangeStart);
            })
            .toList(growable: false)
          ..sort((a, b) => a.start.compareTo(b.start));

    return Row(
      children: <Widget>[
        Container(
          width: resourceHeaderWidth,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            border: Border(
              right: BorderSide(color: theme.dividerColor),
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: (resource.color ?? theme.primaryColor)
                    .withAlpha(28),
                child: Text(
                  resource.label.isEmpty
                      ? '?'
                      : resource.label[0].toUpperCase(),
                  style: TextStyle(
                    color: resource.color ?? theme.primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      resource.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (resource.subtitle != null)
                      Text(
                        resource.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: theme.mutedTextColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: timelineWidth,
          height: rowHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Row(
                children: <Widget>[
                  for (var index = 0; index < slotCount; index++)
                    Container(
                      width: slotWidth,
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? theme.surfaceVariantColor.withAlpha(60)
                            : theme.backgroundColor,
                        border: Border(
                          right: BorderSide(color: theme.dividerColor),
                          bottom: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                ],
              ),
              for (var index = 0; index < visible.length; index++)
                _entryBar(
                  context,
                  visible[index],
                  index,
                  totalMicros,
                  timelineWidth,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _entryBar(
    BuildContext context,
    TimelineEntry<T> entry,
    int index,
    int totalMicros,
    double timelineWidth,
  ) {
    final theme = TimelineTheme.of(context);
    final clippedStart = entry.start.isBefore(rangeStart)
        ? rangeStart
        : entry.start;
    final clippedEnd = entry.rawEnd.isAfter(rangeEnd) ? rangeEnd : entry.rawEnd;
    final left =
        clippedStart.difference(rangeStart).inMicroseconds /
        totalMicros *
        timelineWidth;
    final width =
        (clippedEnd.difference(clippedStart).inMicroseconds /
                totalMicros *
                timelineWidth)
            .clamp(10.0, timelineWidth)
            .toDouble();
    final accent = entry.color ?? theme.colorForStatus(entry.status);
    final top = 10.0 + (index % 2) * 28;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: 24,
      child: Tooltip(
        message: titleBuilder(entry),
        child: Material(
          color: accent.withAlpha(220),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onEntryTap?.call(entry),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  titleBuilder(entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

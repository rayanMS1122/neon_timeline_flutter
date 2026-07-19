import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_day_layout.dart';
import '../core/timeline_planning.dart';
import '../core/timeline_render_plan.dart';
import '../core/timeline_render_plan_builder.dart';
import '../localization/timeline_localization.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_resource.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

@immutable
class TimelineResourceEntryDetails<T> {
  const TimelineResourceEntryDetails({
    required this.resource,
    required this.entryDetails,
    required this.layout,
    required this.capacityConflicts,
  });

  final TimelineResource resource;
  final TimelineEntryDetails<T> entryDetails;
  final TimelineDayLayoutItem<T> layout;
  final List<TimelineCapacityConflict<T>> capacityConflicts;

  bool get isOverbooked => capacityConflicts.isNotEmpty;
}

typedef TimelineResourceHeaderBuilder =
    Widget Function(BuildContext context, TimelineResource resource);

typedef TimelineResourceEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineResourceEntryDetails<T> details,
    );

/// Multi-resource planning board for people, rooms, machines, and teams.
///
/// Entries are indexed by resource once. Each row uses the O(n log n) overlap
/// layout engine and a static grid painter. No animation or timer is created.
class ResourceTimelineView<T> extends StatelessWidget {
  const ResourceTimelineView({
    required this.resources,
    required this.entries,
    required this.selectedDate,
    required this.itemBuilder,
    this.resourceHeaderBuilder,
    this.theme,
    this.timelineController,
    this.onEntryTap,
    this.interactions = const TimelineInteractionConfig(),
    this.dataRevision,
    this.startHour = 6,
    this.endHour = 22,
    this.pixelsPerMinute = 1.2,
    this.rowHeight = 112,
    this.resourceColumnWidth = 190,
    this.minimumEntryHeight = 28,
    this.entryGap = 4,
    this.showCapacityConflicts = true,
    this.showHalfHourLines = true,
    this.showTimeHeader = true,
    this.timeHeaderHeight = 48,
    this.resourceHeaderLabel,
    this.verticalController,
    this.horizontalController,
    this.emptyBuilder,
    this.now,
    super.key,
  }) : assert(startHour >= 0 && startHour < 24),
       assert(endHour > startHour && endHour <= 24),
       assert(pixelsPerMinute > 0),
       assert(rowHeight >= 64),
       assert(resourceColumnWidth >= 120),
       assert(minimumEntryHeight > 0),
       assert(entryGap >= 0),
       assert(timeHeaderHeight >= 36),
       assert(minimumEntryHeight + entryGap <= rowHeight);

  final List<TimelineResource> resources;
  final List<TimelineEntry<T>> entries;
  final DateTime selectedDate;
  final TimelineResourceEntryBuilder<T> itemBuilder;
  final TimelineResourceHeaderBuilder? resourceHeaderBuilder;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineInteractionConfig interactions;
  final Object? dataRevision;
  final int startHour;
  final int endHour;
  final double pixelsPerMinute;
  final double rowHeight;
  final double resourceColumnWidth;
  final double minimumEntryHeight;
  final double entryGap;
  final bool showCapacityConflicts;
  final bool showHalfHourLines;
  final bool showTimeHeader;
  final double timeHeaderHeight;
  final String? resourceHeaderLabel;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  final WidgetBuilder? emptyBuilder;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? TimelineTheme.of(context);
    final localization = TimelineLocalization.of(context);
    if (resources.isEmpty) {
      return TimelineTheme(
        data: resolvedTheme,
        child:
            emptyBuilder?.call(context) ??
            Center(
              child: Text(
                localization.noResourcesConfigured,
                style: TextStyle(color: resolvedTheme.mutedTextColor),
              ),
            ),
      );
    }

    final rangeStart = _atHour(selectedDate, startHour);
    final rangeEnd = _atHour(selectedDate, endHour);
    final canvasWidth =
        rangeEnd.difference(rangeStart).inMinutes * pixelsPerMinute;

    return TimelineRenderPlanBuilder<T>(
      entries: entries,
      dataRevision: dataRevision,
      selectedDate: selectedDate,
      now: now,
      builder: (context, plan) {
        final byResource = <Object, List<TimelineNormalizedEntry<T>>>{};
        for (final normalized in plan.entries) {
          for (final resourceId in normalized.entry.resourceIds) {
            byResource
                .putIfAbsent(resourceId, () => <TimelineNormalizedEntry<T>>[])
                .add(normalized);
          }
        }

        final capacityConflicts = showCapacityConflicts
            ? TimelineCapacityEngine.analyze<T>(
                entries: plan.entries
                    .map((normalized) => normalized.entry)
                    .toList(growable: false),
                resources: resources
                    .where((resource) => resource.enabled)
                    .map(
                      (resource) => TimelineResourceCapacity(
                        id: resource.id,
                        capacity: resource.capacity,
                      ),
                    )
                    .toList(growable: false),
              )
            : <TimelineCapacityConflict<T>>[];
        final conflictsByResource =
            <Object, List<TimelineCapacityConflict<T>>>{};
        for (final conflict in capacityConflicts) {
          conflictsByResource
              .putIfAbsent(
                conflict.resourceId,
                () => <TimelineCapacityConflict<T>>[],
              )
              .add(conflict);
        }
        final conflictsByResourceEntry =
            <
              Object,
              Map<TimelineEntry<T>, List<TimelineCapacityConflict<T>>>
            >{};
        for (final conflict in capacityConflicts) {
          final byEntry = conflictsByResourceEntry.putIfAbsent(
            conflict.resourceId,
            () =>
                Map<
                  TimelineEntry<T>,
                  List<TimelineCapacityConflict<T>>
                >.identity(),
          );
          for (final entry in conflict.entries) {
            byEntry
                .putIfAbsent(entry, () => <TimelineCapacityConflict<T>>[])
                .add(conflict);
          }
        }

        Widget buildBoard() {
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : resources.length * rowHeight;
              return Scrollbar(
                controller: horizontalController,
                thumbVisibility: horizontalController != null,
                notificationPredicate: (notification) =>
                    notification.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: resourceColumnWidth + canvasWidth,
                    height: viewportHeight,
                    child: Column(
                      children: <Widget>[
                        if (showTimeHeader && viewportHeight > timeHeaderHeight)
                          _ResourceTimeHeader(
                            theme: resolvedTheme,
                            startHour: startHour,
                            endHour: endHour,
                            pixelsPerMinute: pixelsPerMinute,
                            resourceColumnWidth: resourceColumnWidth,
                            canvasWidth: canvasWidth,
                            height: timeHeaderHeight,
                            resourceHeaderLabel:
                                resourceHeaderLabel ??
                                localization.resourcesLabel,
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: verticalController,
                            itemExtent: rowHeight,
                            itemCount: resources.length,
                            itemBuilder: (context, resourceIndex) {
                              final resource = resources[resourceIndex];
                              final sourceEntries =
                                  byResource[resource.id] ??
                                  <TimelineNormalizedEntry<T>>[];
                              final layoutItems =
                                  TimelineDayLayoutEngine.layout<T>(
                                    plan: plan,
                                    rangeStart: rangeStart,
                                    rangeEnd: rangeEnd,
                                    sourceEntries: sourceEntries,
                                  );
                              return _ResourceRow<T>(
                                resource: resource,
                                resourceIndex: resourceIndex,
                                layoutItems: layoutItems,
                                plan: plan,
                                conflicts:
                                    conflictsByResource[resource.id] ??
                                    <TimelineCapacityConflict<T>>[],
                                conflictsByEntry:
                                    conflictsByResourceEntry[resource.id] ??
                                    Map<
                                      TimelineEntry<T>,
                                      List<TimelineCapacityConflict<T>>
                                    >.identity(),
                                itemBuilder: itemBuilder,
                                resourceHeaderBuilder: resourceHeaderBuilder,
                                timelineController: timelineController,
                                onEntryTap: onEntryTap,
                                interactions: interactions,
                                theme: resolvedTheme,
                                selectedDate: selectedDate,
                                rangeStart: rangeStart,
                                rangeEnd: rangeEnd,
                                canvasWidth: canvasWidth,
                                resourceColumnWidth: resourceColumnWidth,
                                rowHeight: rowHeight,
                                minimumEntryHeight: minimumEntryHeight,
                                entryGap: entryGap,
                                pixelsPerMinute: pixelsPerMinute,
                                showHalfHourLines: showHalfHourLines,
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

        final controller = timelineController;
        return TimelineTheme(
          data: resolvedTheme,
          child: ColoredBox(
            color: resolvedTheme.backgroundColor,
            child: controller == null
                ? buildBoard()
                : AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) => buildBoard(),
                  ),
          ),
        );
      },
    );
  }

  DateTime _atHour(DateTime date, int hour) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, hour)
        : DateTime(date.year, date.month, date.day, hour);
  }
}

class _ResourceTimeHeader extends StatelessWidget {
  const _ResourceTimeHeader({
    required this.theme,
    required this.startHour,
    required this.endHour,
    required this.pixelsPerMinute,
    required this.resourceColumnWidth,
    required this.canvasWidth,
    required this.height,
    required this.resourceHeaderLabel,
  });

  final TimelineThemeData theme;
  final int startHour;
  final int endHour;
  final double pixelsPerMinute;
  final double resourceColumnWidth;
  final double canvasWidth;
  final double height;
  final String resourceHeaderLabel;

  String _formatHour(int hour) {
    final value = (hour % 24).toString().padLeft(2, '0');
    return '$value:00';
  }

  @override
  Widget build(BuildContext context) {
    final hours = endHour - startHour;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: resourceColumnWidth,
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  resourceHeaderLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: theme.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: canvasWidth,
            height: height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                for (var offset = 0; offset <= hours; offset++) ...<Widget>[
                  Positioned(
                    left: offset * 60 * pixelsPerMinute,
                    top: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: theme.dividerColor,
                      child: const SizedBox(width: 1),
                    ),
                  ),
                  Positioned(
                    left: offset * 60 * pixelsPerMinute + 7,
                    top: 8,
                    child: Text(
                      _formatHour(startHour + offset),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: theme.mutedTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceRow<T> extends StatelessWidget {
  const _ResourceRow({
    required this.resource,
    required this.resourceIndex,
    required this.layoutItems,
    required this.plan,
    required this.conflicts,
    required this.conflictsByEntry,
    required this.itemBuilder,
    required this.resourceHeaderBuilder,
    required this.timelineController,
    required this.onEntryTap,
    required this.interactions,
    required this.theme,
    required this.selectedDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.canvasWidth,
    required this.resourceColumnWidth,
    required this.rowHeight,
    required this.minimumEntryHeight,
    required this.entryGap,
    required this.pixelsPerMinute,
    required this.showHalfHourLines,
  });

  final TimelineResource resource;
  final int resourceIndex;
  final List<TimelineDayLayoutItem<T>> layoutItems;
  final TimelineRenderPlan<T> plan;
  final List<TimelineCapacityConflict<T>> conflicts;
  final Map<TimelineEntry<T>, List<TimelineCapacityConflict<T>>>
  conflictsByEntry;
  final TimelineResourceEntryBuilder<T> itemBuilder;
  final TimelineResourceHeaderBuilder? resourceHeaderBuilder;
  final TimelineController<T>? timelineController;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineInteractionConfig interactions;
  final TimelineThemeData theme;
  final DateTime selectedDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double canvasWidth;
  final double resourceColumnWidth;
  final double rowHeight;
  final double minimumEntryHeight;
  final double entryGap;
  final double pixelsPerMinute;
  final bool showHalfHourLines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: resourceIndex.isEven
            ? theme.surfaceColor.withAlpha(70)
            : theme.surfaceVariantColor.withAlpha(45),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: resourceColumnWidth,
            height: rowHeight,
            child:
                resourceHeaderBuilder?.call(context, resource) ??
                _DefaultResourceHeader(resource: resource, theme: theme),
          ),
          SizedBox(
            width: canvasWidth,
            height: rowHeight,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ResourceGridPainter(
                        theme: theme,
                        startHour: rangeStart.hour,
                        endHour: rangeEnd.hour == 0 ? 24 : rangeEnd.hour,
                        pixelsPerMinute: pixelsPerMinute,
                        showHalfHourLines: showHalfHourLines,
                      ),
                    ),
                  ),
                ),
                for (final conflict in conflicts)
                  _buildConflictOverlay(conflict),
                for (var index = 0; index < layoutItems.length; index++)
                  _buildEntry(context, index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictOverlay(TimelineCapacityConflict<T> conflict) {
    final clippedStart = conflict.start.isBefore(rangeStart)
        ? rangeStart
        : conflict.start;
    final clippedEnd = conflict.end.isAfter(rangeEnd) ? rangeEnd : conflict.end;
    if (!clippedEnd.isAfter(clippedStart)) return const SizedBox.shrink();
    final left =
        clippedStart.difference(rangeStart).inMinutes * pixelsPerMinute;
    final width =
        clippedEnd.difference(clippedStart).inMinutes * pixelsPerMinute;
    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.errorColor.withAlpha(24),
            border: Border(
              top: BorderSide(color: theme.errorColor.withAlpha(110)),
              bottom: BorderSide(color: theme.errorColor.withAlpha(110)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, int index) {
    final item = layoutItems[index];
    final normalized = item.normalizedEntry;
    final columnHeight = rowHeight / item.columnCount;
    final top = item.column * columnHeight + entryGap * 0.5;
    final height = (columnHeight - entryGap)
        .clamp(minimumEntryHeight, rowHeight - entryGap)
        .toDouble();
    final left = item.startFraction * canvasWidth + entryGap * 0.5;
    final rawWidth = item.extentFraction * canvasWidth - entryGap;
    final availableWidth = math.max(1.0, canvasWidth - left).toDouble();
    final width = math.min(math.max(1.0, rawWidth), availableWidth).toDouble();
    final overlappingCapacity =
        conflictsByEntry[normalized.entry] ?? <TimelineCapacityConflict<T>>[];
    final details = TimelineEntryDetails<T>(
      entry: normalized.entry,
      index: index,
      itemCount: layoutItems.length,
      selectedDate: selectedDate,
      displayStart: normalized.start,
      displayEnd: normalized.end,
      previousEntry: index > 0 ? layoutItems[index - 1].entry : null,
      nextEntry: index + 1 < layoutItems.length
          ? layoutItems[index + 1].entry
          : null,
      isCurrent: normalized.isCurrent,
      hasConflict:
          plan.entryHasConflict(normalized.entry.id) ||
          overlappingCapacity.isNotEmpty,
      conflictType: overlappingCapacity.isNotEmpty
          ? TimelineConflictType.capacityConflict
          : plan.conflictTypeFor(normalized.entry.id),
    );
    final selected =
        timelineController?.isSelected(normalized.entry.id) ?? false;

    return Positioned(
      left: left,
      width: width,
      top: top,
      height: height,
      child: RepaintBoundary(
        child: Semantics(
          selected: selected,
          button: timelineController != null || onEntryTap != null,
          label: normalized.entry.semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(theme.cardRadius),
              onTap: timelineController == null && onEntryTap == null
                  ? null
                  : () {
                      timelineController?.select(
                        normalized.entry.id,
                        mode: interactions.selectionMode,
                      );
                      onEntryTap?.call(context, details);
                    },
              child: itemBuilder(
                context,
                TimelineResourceEntryDetails<T>(
                  resource: resource,
                  entryDetails: details,
                  layout: item,
                  capacityConflicts: overlappingCapacity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultResourceHeader extends StatelessWidget {
  const _DefaultResourceHeader({required this.resource, required this.theme});

  final TimelineResource resource;
  final TimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    final accent = resource.color ?? theme.primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withAlpha(30),
            foregroundColor: accent,
            child: Text(
              resource.label.isEmpty ? '?' : resource.label[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
          Text(
            '${resource.capacity.toStringAsFixed(resource.capacity % 1 == 0 ? 0 : 1)}×',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: theme.mutedTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceGridPainter extends CustomPainter {
  const _ResourceGridPainter({
    required this.theme,
    required this.startHour,
    required this.endHour,
    required this.pixelsPerMinute,
    required this.showHalfHourLines,
  });

  final TimelineThemeData theme;
  final int startHour;
  final int endHour;
  final double pixelsPerMinute;
  final bool showHalfHourLines;

  @override
  void paint(Canvas canvas, Size size) {
    final hourPaint = Paint()
      ..color = theme.dividerColor
      ..strokeWidth = 1;
    final halfPaint = Paint()
      ..color = theme.dividerColor.withAlpha(65)
      ..strokeWidth = 0.5;
    final hours = endHour - startHour;
    for (var offset = 0; offset <= hours; offset++) {
      final x = offset * 60 * pixelsPerMinute;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hourPaint);
      if (showHalfHourLines && offset < hours) {
        final halfX = x + 30 * pixelsPerMinute;
        canvas.drawLine(
          Offset(halfX, 0),
          Offset(halfX, size.height),
          halfPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ResourceGridPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.startHour != startHour ||
        oldDelegate.endHour != endHour ||
        oldDelegate.pixelsPerMinute != pixelsPerMinute ||
        oldDelegate.showHalfHourLines != showHalfHourLines;
  }
}

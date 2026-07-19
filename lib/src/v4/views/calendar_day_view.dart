import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_day_layout.dart';
import '../core/timeline_render_plan.dart';
import '../core/timeline_render_plan_builder.dart';
import '../localization/timeline_localization.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

@immutable
class TimelineDayEntryDetails<T> {
  const TimelineDayEntryDetails({
    required this.entryDetails,
    required this.layout,
  });

  final TimelineEntryDetails<T> entryDetails;
  final TimelineDayLayoutItem<T> layout;
}

typedef TimelineDayEntryBuilder<T> =
    Widget Function(BuildContext context, TimelineDayEntryDetails<T> details);

/// Modern absolute-positioned day canvas with overlap columns and a static
/// grid layer. It creates no ticker and performs no work while idle.
class CalendarDayView<T> extends StatelessWidget {
  const CalendarDayView({
    required this.entries,
    required this.selectedDate,
    required this.itemBuilder,
    this.theme,
    this.timelineController,
    this.onEntryTap,
    this.interactions = const TimelineInteractionConfig(),
    this.dataRevision,
    this.now,
    this.startHour = 6,
    this.endHour = 22,
    this.pixelsPerMinute = 1.4,
    this.timeColumnWidth = 64,
    this.minimumEntryHeight = 30,
    this.entryGap = 4,
    this.padding = const EdgeInsets.fromLTRB(8, 16, 16, 32),
    this.showHalfHourLines = true,
    this.showNowIndicator = true,
    this.scrollController,
    this.physics,
    this.emptyBuilder,
    super.key,
  }) : assert(startHour >= 0 && startHour < 24),
       assert(endHour > startHour && endHour <= 24),
       assert(pixelsPerMinute > 0),
       assert(timeColumnWidth >= 40),
       assert(minimumEntryHeight > 0),
       assert(entryGap >= 0);

  final List<TimelineEntry<T>> entries;
  final DateTime selectedDate;
  final TimelineDayEntryBuilder<T> itemBuilder;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineInteractionConfig interactions;
  final Object? dataRevision;
  final DateTime? now;
  final int startHour;
  final int endHour;
  final double pixelsPerMinute;
  final double timeColumnWidth;
  final double minimumEntryHeight;
  final double entryGap;
  final EdgeInsets padding;
  final bool showHalfHourLines;
  final bool showNowIndicator;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? TimelineTheme.of(context);
    final rangeStart = _atHour(selectedDate, startHour);
    final rangeEnd = _atHour(selectedDate, endHour);

    return TimelineRenderPlanBuilder<T>(
      entries: entries,
      dataRevision: dataRevision,
      selectedDate: selectedDate,
      now: now,
      builder: (context, plan) {
        final layoutItems = TimelineDayLayoutEngine.layout<T>(
          plan: plan,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
        );
        if (layoutItems.isEmpty) {
          return TimelineTheme(
            data: resolvedTheme,
            child: ColoredBox(
              color: resolvedTheme.backgroundColor,
              child:
                  emptyBuilder?.call(context) ??
                  _DefaultDayEmptyState(
                    theme: resolvedTheme,
                    label: TimelineLocalization.of(
                      context,
                    ).noEntriesInTimeRange,
                  ),
            ),
          );
        }

        Widget buildCanvas() {
          final minuteCount = rangeEnd.difference(rangeStart).inMinutes;
          final canvasHeight = minuteCount * pixelsPerMinute;
          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 720.0;
              final viewportWidth = (availableWidth - padding.horizontal)
                  .clamp(1.0, double.infinity)
                  .toDouble();
              final contentWidth = (viewportWidth - timeColumnWidth)
                  .clamp(1.0, double.infinity)
                  .toDouble();
              final currentTop = _currentTop(
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                canvasHeight: canvasHeight,
              );

              return SingleChildScrollView(
                controller: scrollController,
                physics: physics,
                padding: padding,
                child: SizedBox(
                  height: canvasHeight,
                  width: timeColumnWidth + contentWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        left: timeColumnWidth,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _TimelineDayGridPainter(
                              theme: resolvedTheme,
                              startHour: startHour,
                              endHour: endHour,
                              pixelsPerMinute: pixelsPerMinute,
                              showHalfHourLines: showHalfHourLines,
                            ),
                          ),
                        ),
                      ),
                      ..._buildTimeLabels(context, resolvedTheme, canvasHeight),
                      for (var index = 0; index < layoutItems.length; index++)
                        _buildEntry(
                          context,
                          plan,
                          layoutItems,
                          index,
                          contentWidth,
                          canvasHeight,
                          resolvedTheme,
                        ),
                      if (currentTop != null)
                        Positioned(
                          top: currentTop,
                          left: timeColumnWidth - 5,
                          right: 0,
                          child: IgnorePointer(
                            child: _NowLine(theme: resolvedTheme),
                          ),
                        ),
                    ],
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
                ? buildCanvas()
                : AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) => buildCanvas(),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTimeLabels(
    BuildContext context,
    TimelineThemeData theme,
    double canvasHeight,
  ) {
    final labels = <Widget>[];
    final hours = endHour - startHour;
    for (var offset = 0; offset <= hours; offset++) {
      final hour = startHour + offset;
      final top = (offset * 60 * pixelsPerMinute)
          .clamp(0.0, canvasHeight)
          .toDouble();
      labels.add(
        Positioned(
          top: top - 9,
          left: 0,
          width: timeColumnWidth - 10,
          child: Text(
            _formatHour(hour),
            textAlign: TextAlign.right,
            style: (theme.metaStyle ?? Theme.of(context).textTheme.labelSmall)
                ?.copyWith(
                  color: theme.mutedTextColor,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
          ),
        ),
      );
    }
    return labels;
  }

  Widget _buildEntry(
    BuildContext context,
    TimelineRenderPlan<T> plan,
    List<TimelineDayLayoutItem<T>> layoutItems,
    int index,
    double contentWidth,
    double canvasHeight,
    TimelineThemeData theme,
  ) {
    final item = layoutItems[index];
    final normalized = item.normalizedEntry;
    final columnWidth = contentWidth / item.columnCount;
    final left = timeColumnWidth + item.column * columnWidth + entryGap * 0.5;
    final width = math.max(1.0, columnWidth - entryGap).toDouble();
    final top = item.startFraction * canvasHeight + entryGap * 0.5;
    final availableHeight = math.max(1.0, canvasHeight - top).toDouble();
    final rawHeight = item.extentFraction * canvasHeight - entryGap;
    final requestedHeight = math.max(minimumEntryHeight, rawHeight).toDouble();
    final height = math.min(requestedHeight, availableHeight).toDouble();
    final previous = index > 0 ? layoutItems[index - 1].entry : null;
    final next = index + 1 < layoutItems.length
        ? layoutItems[index + 1].entry
        : null;
    final details = TimelineEntryDetails<T>(
      entry: normalized.entry,
      index: index,
      itemCount: layoutItems.length,
      selectedDate: selectedDate,
      displayStart: normalized.start,
      displayEnd: normalized.end,
      previousEntry: previous,
      nextEntry: next,
      isCurrent: normalized.isCurrent,
      hasConflict: plan.entryHasConflict(normalized.entry.id),
      conflictType: plan.conflictTypeFor(normalized.entry.id),
    );
    final selected =
        timelineController?.isSelected(normalized.entry.id) ?? false;

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: RepaintBoundary(
        child: Semantics(
          selected: selected,
          button: onEntryTap != null || timelineController != null,
          label: normalized.entry.semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(theme.cardRadius),
              onTap: onEntryTap == null && timelineController == null
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
                TimelineDayEntryDetails<T>(entryDetails: details, layout: item),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? _currentTop({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required double canvasHeight,
  }) {
    if (!showNowIndicator) return null;
    final clock = now ?? DateTime.now();
    if (clock.isBefore(rangeStart) || !clock.isBefore(rangeEnd)) return null;
    final total = rangeEnd.difference(rangeStart).inMicroseconds;
    final elapsed = clock.difference(rangeStart).inMicroseconds;
    return elapsed / total * canvasHeight;
  }

  String _formatHour(int hour) {
    final value = (hour % 24).toString().padLeft(2, '0');
    return '$value:00';
  }

  DateTime _atHour(DateTime date, int hour) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, hour)
        : DateTime(date.year, date.month, date.day, hour);
  }
}

class _TimelineDayGridPainter extends CustomPainter {
  const _TimelineDayGridPainter({
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
    final halfHourPaint = Paint()
      ..color = theme.dividerColor.withAlpha(90)
      ..strokeWidth = 0.5;
    final hours = endHour - startHour;
    for (var offset = 0; offset <= hours; offset++) {
      final y = offset * 60 * pixelsPerMinute;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hourPaint);
      if (showHalfHourLines && offset < hours) {
        final halfY = y + 30 * pixelsPerMinute;
        canvas.drawLine(
          Offset(0, halfY),
          Offset(size.width, halfY),
          halfHourPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineDayGridPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.startHour != startHour ||
        oldDelegate.endHour != endHour ||
        oldDelegate.pixelsPerMinute != pixelsPerMinute ||
        oldDelegate.showHalfHourLines != showHalfHourLines;
  }
}

class _NowLine extends StatelessWidget {
  const _NowLine({required this.theme});

  final TimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.errorColor,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 10),
        ),
        Expanded(child: Container(height: 2, color: theme.errorColor)),
      ],
    );
  }
}

class _DefaultDayEmptyState extends StatelessWidget {
  const _DefaultDayEmptyState({required this.theme, required this.label});

  final TimelineThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_view_day_outlined,
              size: 44,
              color: theme.mutedTextColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

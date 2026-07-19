import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../models/neon_schedule_entry.dart';
import '../../models/neon_timeline_types.dart';
import '../../widgets/neon_schedule_timeline.dart';
import '../core/timeline_controller.dart';
import '../core/timeline_performance_config.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

/// Planner-grade schedule using neutral entries, themes, and interaction policy.
class ScheduleView<T> extends StatelessWidget {
  const ScheduleView({
    required this.entries,
    required this.selectedDate,
    required this.itemBuilder,
    this.timeBuilder,
    this.indicatorBuilder,
    this.onEntryTap,
    this.onEntryMoved,
    this.theme,
    this.timelineController,
    this.scrollController,
    this.interactions = const TimelineInteractionConfig(),
    this.motion = const TimelineMotionConfig(),
    this.performance = const TimelinePerformanceConfig.adaptive(),
    this.sortEntries = true,
    this.dataRevision,
    this.showNowIndicator = true,
    this.autoActivateCurrentEntry = true,
    this.useDefaultCard = true,
    this.emptyBuilder,
    this.physics = const BouncingScrollPhysics(),
    this.now,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final DateTime selectedDate;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineEntryBuilder<T>? timeBuilder;
  final TimelineEntryBuilder<T>? indicatorBuilder;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineMoveCallback<T>? onEntryMoved;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final ScrollController? scrollController;
  final TimelineInteractionConfig interactions;
  final TimelineMotionConfig motion;
  final TimelinePerformanceConfig performance;
  final bool sortEntries;
  final Object? dataRevision;
  final bool showNowIndicator;
  final bool autoActivateCurrentEntry;
  final bool useDefaultCard;
  final WidgetBuilder? emptyBuilder;
  final ScrollPhysics? physics;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final baseTheme = theme ?? TimelineTheme.of(context);
    final reduceMotion =
        motion.respectReducedMotion &&
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    final resolvedPerformance = performance.resolve(
      isWeb: kIsWeb,
      entryCount: entries.length,
      reduceMotion: reduceMotion,
    );
    final resolvedTheme = baseTheme.copyWith(
      useBlur:
          baseTheme.useBlur &&
          (resolvedPerformance.enableBackdropBlur ?? false),
    );
    final motionEnabled = motion.enabled && !reduceMotion;
    final motionFramesPerSecond = math
        .min(
          motion.framesPerSecond,
          resolvedPerformance.motionFramesPerSecond ?? motion.framesPerSecond,
        )
        .toInt();
    final maxAnimatedEntries = math
        .min(
          motion.maxAnimatedEntries,
          resolvedPerformance.maxAnimatedEntries ?? motion.maxAnimatedEntries,
        )
        .toInt();
    final effectiveDataRevision =
        dataRevision ??
        Object.hashAll(entries.map((entry) => entry.revisionHash));
    final legacyEntries = entries
        .map(
          (entry) => NeonScheduleEntry<TimelineEntry<T>>(
            id: entry.id,
            value: entry,
            start: entry.start,
            duration: entry.hasValidRange
                ? entry.rawDuration
                : const Duration(minutes: 1),
            status: _legacyStatus(entry.status),
            color: entry.color,
            semanticLabel: entry.semanticLabel,
            draggable:
                interactions.enabled &&
                interactions.enableDragging &&
                entry.draggable,
            enabled: interactions.enabled && entry.enabled,
          ),
        )
        .toList(growable: false);

    TimelineEntryDetails<T> convert(
      NeonScheduleEntryDetails<TimelineEntry<T>> details,
    ) {
      return TimelineEntryDetails<T>(
        entry: details.entry.value,
        index: details.index,
        itemCount: details.itemCount,
        selectedDate: details.day,
        displayStart: details.displayStart,
        displayEnd: details.displayEnd,
        previousEntry: details.previousEntry?.value,
        nextEntry: details.nextEntry?.value,
        gapBefore: details.gapBefore,
        gapAfter: details.gapAfter,
        isCurrent: details.isCurrent,
        hasConflict: details.overlapsPrevious || details.overlapsNext,
        conflictType: details.overlapsPrevious || details.overlapsNext
            ? TimelineConflictType.partialOverlap
            : TimelineConflictType.none,
      );
    }

    Widget buildSchedule() {
      return NeonScheduleTimeline<TimelineEntry<T>>(
        entries: legacyEntries,
        selectedDate: selectedDate,
        itemBuilder: (context, details) =>
            itemBuilder(context, convert(details)),
        timeBuilder: timeBuilder == null
            ? null
            : (context, details) => timeBuilder!(context, convert(details)),
        indicatorBuilder: indicatorBuilder == null
            ? null
            : (context, details) =>
                  indicatorBuilder!(context, convert(details)),
        theme: resolvedTheme.toLegacyTheme(),
        style: resolvedTheme.toLegacyScheduleStyle(
          snapMinutes: interactions.snapMinutes,
        ),
        controller: scrollController,
        physics: physics,
        emptyBuilder: emptyBuilder,
        onEntryTap: onEntryTap == null && timelineController == null
            ? null
            : (context, details) {
                final converted = convert(details);
                timelineController?.select(
                  converted.entry.id,
                  mode: interactions.selectionMode,
                );
                onEntryTap?.call(context, converted);
              },
        onEntryMoved: onEntryMoved == null
            ? null
            : (context, details, newStart) async {
                await onEntryMoved!(context, convert(details), newStart);
              },
        sortEntries: sortEntries,
        showNowIndicator: showNowIndicator,
        autoActivateCurrentEntry: autoActivateCurrentEntry,
        useDefaultCard: useDefaultCard,
        enableDragHaptics: interactions.enableHaptics,
        motionEnabled: motionEnabled,
        motionFramesPerSecond: motionFramesPerSecond,
        pauseMotionWhileScrolling:
            motion.pauseWhileScrolling ||
            (resolvedPerformance.pauseMotionWhileScrolling ?? false),
        maxAnimatedEntries: maxAnimatedEntries,
        performance: resolvedPerformance.toLegacy(),
        dataRevision: effectiveDataRevision,
        cacheExtent: resolvedPerformance.cacheExtent,
        now: now,
      );
    }

    final controller = timelineController;
    return TimelineTheme(
      data: resolvedTheme,
      child: controller == null
          ? buildSchedule()
          : AnimatedBuilder(
              animation: controller,
              builder: (_, __) => buildSchedule(),
            ),
    );
  }
}

NeonTimelineStatus _legacyStatus(TimelineStatus status) {
  return switch (status) {
    TimelineStatus.pending => NeonTimelineStatus.pending,
    TimelineStatus.active => NeonTimelineStatus.active,
    TimelineStatus.completed => NeonTimelineStatus.completed,
    TimelineStatus.error => NeonTimelineStatus.error,
    TimelineStatus.disabled => NeonTimelineStatus.disabled,
  };
}

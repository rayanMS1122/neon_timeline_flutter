import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../models/neon_timeline_types.dart';
import '../../widgets/neon_timeline.dart';
import '../core/timeline_controller.dart';
import '../core/timeline_performance_config.dart';
import '../core/timeline_render_plan.dart';
import '../core/timeline_render_plan_builder.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

/// Neutral, lazy timeline view backed by the proven 3.x renderer.
class TimelineView<T> extends StatelessWidget {
  const TimelineView({
    required this.entries,
    required this.itemBuilder,
    this.oppositeBuilder,
    this.indicatorBuilder,
    this.onEntryTap,
    this.theme,
    this.timelineController,
    this.scrollController,
    this.layout = const TimelineLayoutConfig(),
    this.motion = const TimelineMotionConfig(),
    this.performance = const TimelinePerformanceConfig.adaptive(),
    this.sortEntries = false,
    this.dataRevision,
    this.now,
    this.padding,
    this.physics,
    this.emptyBuilder,
    this.cacheExtent,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineEntryBuilder<T>? oppositeBuilder;
  final TimelineEntryBuilder<T>? indicatorBuilder;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final ScrollController? scrollController;
  final TimelineLayoutConfig layout;
  final TimelineMotionConfig motion;
  final TimelinePerformanceConfig performance;
  final bool sortEntries;
  final Object? dataRevision;
  final DateTime? now;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final WidgetBuilder? emptyBuilder;
  final double? cacheExtent;

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
    return TimelineRenderPlanBuilder<T>(
      entries: entries,
      dataRevision: dataRevision,
      now: now,
      builder: (context, plan) {
        final visibleEntries = sortEntries
            ? plan.entries.map((entry) => entry.entry).toList(growable: false)
            : entries;
        final normalizedByEntry =
            Map<TimelineEntry<T>, TimelineNormalizedEntry<T>>.identity()
              ..addEntries(
                plan.entries.map((item) => MapEntry(item.entry, item)),
              );

        Widget buildTimeline() {
          return NeonTimeline.builder(
            itemCount: visibleEntries.length,
            contentBuilder: (context, legacyDetails) {
              return itemBuilder(
                context,
                _detailsFor(
                  visibleEntries,
                  legacyDetails.index,
                  plan,
                  normalizedByEntry,
                ),
              );
            },
            oppositeContentBuilder: oppositeBuilder == null
                ? null
                : (context, legacyDetails) => oppositeBuilder!(
                    context,
                    _detailsFor(
                      visibleEntries,
                      legacyDetails.index,
                      plan,
                      normalizedByEntry,
                    ),
                  ),
            indicatorBuilder: indicatorBuilder == null
                ? null
                : (context, legacyDetails) => indicatorBuilder!(
                    context,
                    _detailsFor(
                      visibleEntries,
                      legacyDetails.index,
                      plan,
                      normalizedByEntry,
                    ),
                  ),
            statusBuilder: (index) =>
                _legacyStatus(visibleEntries[index].status),
            semanticLabelBuilder: (_, details) =>
                visibleEntries[details.index].semanticLabel,
            onItemTap: onEntryTap == null && timelineController == null
                ? null
                : (context, legacyDetails) {
                    final details = _detailsFor(
                      visibleEntries,
                      legacyDetails.index,
                      plan,
                      normalizedByEntry,
                    );
                    timelineController?.select(details.entry.id);
                    onEntryTap?.call(context, details);
                  },
            keyBuilder: (_, details) {
              final entry = visibleEntries[details.index];
              return plan.duplicateIds.contains(entry.id)
                  ? ValueKey<(Object, int)>((entry.id, details.index))
                  : ValueKey<Object>(entry.id);
            },
            axis: layout.axis,
            layout: _legacyLayout(layout.layout),
            theme: resolvedTheme.toLegacyTheme(),
            controller: scrollController,
            physics: physics,
            padding: padding,
            reverse: layout.reverse,
            shrinkWrap: layout.shrinkWrap,
            itemExtent: layout.itemExtent,
            indicatorPosition: layout.indicatorPosition,
            animate: motionEnabled,
            motionEnabled: motionEnabled,
            motionFramesPerSecond: motionFramesPerSecond,
            pauseMotionWhileScrolling:
                motion.pauseWhileScrolling ||
                (resolvedPerformance.pauseMotionWhileScrolling ?? false),
            maxAnimatedItems: maxAnimatedEntries,
            performance: resolvedPerformance.toLegacy(),
            emptyBuilder: emptyBuilder,
            cacheExtent: cacheExtent ?? resolvedPerformance.cacheExtent,
          );
        }

        final controller = timelineController;
        return TimelineTheme(
          data: resolvedTheme,
          child: controller == null
              ? buildTimeline()
              : AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => buildTimeline(),
                ),
        );
      },
    );
  }

  TimelineEntryDetails<T> _detailsFor(
    List<TimelineEntry<T>> source,
    int index,
    TimelineRenderPlan<T> plan,
    Map<TimelineEntry<T>, TimelineNormalizedEntry<T>> normalizedByEntry,
  ) {
    final entry = source[index];
    final normalized = normalizedByEntry[entry];
    return TimelineEntryDetails<T>(
      entry: entry,
      index: index,
      itemCount: source.length,
      displayStart: normalized?.start ?? entry.start,
      displayEnd: normalized?.end ?? entry.rawEnd,
      previousEntry: index > 0 ? source[index - 1] : null,
      nextEntry: index + 1 < source.length ? source[index + 1] : null,
      isCurrent: normalized?.isCurrent ?? false,
      hasConflict: plan.entryHasConflict(entry.id),
      conflictType: plan.conflictTypeFor(entry.id),
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

NeonTimelineLayout _legacyLayout(TimelineLayout layout) {
  return switch (layout) {
    TimelineLayout.start => NeonTimelineLayout.start,
    TimelineLayout.center => NeonTimelineLayout.center,
    TimelineLayout.end => NeonTimelineLayout.end,
    TimelineLayout.alternating => NeonTimelineLayout.alternating,
    TimelineLayout.adaptive => NeonTimelineLayout.adaptive,
  };
}

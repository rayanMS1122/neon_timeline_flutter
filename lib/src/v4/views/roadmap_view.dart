import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_performance_config.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';
import 'timeline_view.dart';

/// Horizontal milestone-oriented timeline with stable lazy rendering.
class RoadmapView<T> extends StatelessWidget {
  const RoadmapView({
    required this.entries,
    required this.itemBuilder,
    this.oppositeBuilder,
    this.onEntryTap,
    this.theme,
    this.timelineController,
    this.scrollController,
    this.performance = const TimelinePerformanceConfig.balanced(),
    this.itemExtent = 300,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineEntryBuilder<T>? oppositeBuilder;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final ScrollController? scrollController;
  final TimelinePerformanceConfig performance;
  final double itemExtent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TimelineView<T>(
      entries: entries,
      itemBuilder: itemBuilder,
      oppositeBuilder: oppositeBuilder,
      onEntryTap: onEntryTap,
      theme: theme,
      timelineController: timelineController,
      scrollController: scrollController,
      layout: TimelineLayoutConfig(
        axis: Axis.horizontal,
        layout: TimelineLayout.alternating,
        itemExtent: itemExtent,
      ),
      performance: performance,
      sortEntries: true,
      padding: padding,
    );
  }
}

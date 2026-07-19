import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_performance_config.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';
import 'schedule_view.dart';

/// Dense schedule preset for task, shift, and resource planning surfaces.
class PlannerView<T> extends StatelessWidget {
  const PlannerView({
    required this.entries,
    required this.selectedDate,
    required this.itemBuilder,
    this.onEntryTap,
    this.onEntryMoved,
    this.theme,
    this.timelineController,
    this.scrollController,
    this.interactions = const TimelineInteractionConfig(),
    this.performance = const TimelinePerformanceConfig.balanced(),
    this.dataRevision,
    this.emptyBuilder,
    this.now,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final DateTime selectedDate;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineMoveCallback<T>? onEntryMoved;
  final TimelineThemeData? theme;
  final TimelineController<T>? timelineController;
  final ScrollController? scrollController;
  final TimelineInteractionConfig interactions;
  final TimelinePerformanceConfig performance;
  final Object? dataRevision;
  final WidgetBuilder? emptyBuilder;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final inherited = TimelineTheme.of(context);
    final resolved = (theme ?? inherited).copyWith(compact: true);
    return ScheduleView<T>(
      entries: entries,
      selectedDate: selectedDate,
      itemBuilder: itemBuilder,
      onEntryTap: onEntryTap,
      onEntryMoved: onEntryMoved,
      theme: resolved,
      timelineController: timelineController,
      scrollController: scrollController,
      interactions: interactions,
      performance: performance,
      dataRevision: dataRevision,
      emptyBuilder: emptyBuilder,
      now: now,
    );
  }
}

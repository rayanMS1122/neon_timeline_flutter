import 'package:flutter/material.dart';

import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';
import 'timeline_view.dart';

/// Read-only timeline preset for reports, screenshots, and presentations.
class PresentationTimelineView<T> extends StatelessWidget {
  const PresentationTimelineView({
    required this.entries,
    required this.itemBuilder,
    this.oppositeBuilder,
    this.theme,
    this.axis = Axis.vertical,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineEntryBuilder<T>? oppositeBuilder;
  final TimelineThemeData? theme;
  final Axis axis;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TimelineView<T>(
      entries: entries,
      itemBuilder: itemBuilder,
      oppositeBuilder: oppositeBuilder,
      theme: theme,
      layout: TimelineLayoutConfig(
        axis: axis,
        layout: TimelineLayout.alternating,
        shrinkWrap: true,
      ),
      motion: const TimelineMotionConfig.disabled(),
      sortEntries: true,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_render_plan_builder.dart';
import '../models/timeline_entry.dart';
import '../theme/timeline_theme.dart';

/// Text-first chronological view with lazy rows and optional day headers.
class AgendaView<T> extends StatelessWidget {
  const AgendaView({
    required this.entries,
    required this.itemBuilder,
    this.timelineController,
    this.theme,
    this.onEntryTap,
    this.dataRevision,
    this.now,
    this.padding = const EdgeInsets.all(16),
    this.controller,
    this.physics,
    this.emptyBuilder,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final TimelineEntryBuilder<T> itemBuilder;
  final TimelineController<T>? timelineController;
  final TimelineThemeData? theme;
  final TimelineEntryCallback<T>? onEntryTap;
  final Object? dataRevision;
  final DateTime? now;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? TimelineTheme.of(context);
    return TimelineRenderPlanBuilder<T>(
      entries: entries,
      dataRevision: dataRevision,
      now: now,
      builder: (context, plan) {
        Widget buildList() {
          if (plan.entries.isEmpty) {
            return emptyBuilder?.call(context) ?? const SizedBox.shrink();
          }
          return ListView.separated(
            controller: controller,
            physics: physics,
            padding: padding,
            itemCount: plan.entries.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: resolvedTheme.itemSpacing),
            itemBuilder: (context, index) {
              final current = plan.entries[index];
              final previous = index > 0 ? plan.entries[index - 1] : null;
              final next = index + 1 < plan.entries.length
                  ? plan.entries[index + 1]
                  : null;
              final details = TimelineEntryDetails<T>(
                entry: current.entry,
                index: index,
                itemCount: plan.entryCount,
                displayStart: current.start,
                displayEnd: current.end,
                previousEntry: previous?.entry,
                nextEntry: next?.entry,
                gapBefore: _positiveGap(previous?.end, current.start),
                gapAfter: _positiveGap(current.end, next?.start),
                isCurrent: current.isCurrent,
                hasConflict: plan.entryHasConflict(current.entry.id),
                conflictType: plan.conflictTypeFor(current.entry.id),
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEntryTap == null && timelineController == null
                    ? null
                    : () {
                        timelineController?.select(current.entry.id);
                        onEntryTap?.call(context, details);
                      },
                child: itemBuilder(context, details),
              );
            },
          );
        }

        final selection = timelineController;
        return TimelineTheme(
          data: resolvedTheme,
          child: ColoredBox(
            color: resolvedTheme.backgroundColor,
            child: selection == null
                ? buildList()
                : AnimatedBuilder(
                    animation: selection,
                    builder: (_, __) => buildList(),
                  ),
          ),
        );
      },
    );
  }

  Duration? _positiveGap(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final gap = end.difference(start);
    return gap > Duration.zero ? gap : null;
  }
}

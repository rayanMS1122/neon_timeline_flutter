import 'package:flutter/widgets.dart';

import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import 'timeline_render_plan.dart';

typedef TimelineRenderPlanWidgetBuilder<T> =
    Widget Function(BuildContext context, TimelineRenderPlan<T> plan);

/// Stateful cache boundary for widgets that consume a render plan.
class TimelineRenderPlanBuilder<T> extends StatefulWidget {
  const TimelineRenderPlanBuilder({
    required this.entries,
    required this.builder,
    this.dataRevision,
    this.selectedDate,
    this.now,
    this.timeSemantics = TimelineTimeSemantics.preserveInput,
    this.includeOutsideSelectedDay = false,
    this.clipToSelectedDay = true,
    this.minimumDuration = const Duration(minutes: 1),
    this.detectInPlaceMutations = true,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final TimelineRenderPlanWidgetBuilder<T> builder;
  final Object? dataRevision;
  final DateTime? selectedDate;
  final DateTime? now;
  final TimelineTimeSemantics timeSemantics;
  final bool includeOutsideSelectedDay;
  final bool clipToSelectedDay;
  final Duration minimumDuration;

  /// Computes a linear entry fingerprint when [dataRevision] is omitted.
  /// Disable only when the host guarantees immutable list identity.
  final bool detectInPlaceMutations;

  @override
  State<TimelineRenderPlanBuilder<T>> createState() =>
      _TimelineRenderPlanBuilderState<T>();
}

class _TimelineRenderPlanBuilderState<T>
    extends State<TimelineRenderPlanBuilder<T>> {
  final TimelineRenderPlanCache<T> _cache = TimelineRenderPlanCache<T>();

  @override
  Widget build(BuildContext context) {
    final effectiveRevision =
        widget.dataRevision ??
        (widget.detectInPlaceMutations
            ? Object.hashAll(widget.entries.map((entry) => entry.revisionHash))
            : null);
    final plan = _cache.resolve(
      entries: widget.entries,
      dataRevision: effectiveRevision,
      selectedDate: widget.selectedDate,
      now: widget.now,
      timeSemantics: widget.timeSemantics,
      includeOutsideSelectedDay: widget.includeOutsideSelectedDay,
      clipToSelectedDay: widget.clipToSelectedDay,
      minimumDuration: widget.minimumDuration,
    );
    return widget.builder(context, plan);
  }
}

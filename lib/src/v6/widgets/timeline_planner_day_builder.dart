import 'package:flutter/widgets.dart';

import '../core/timeline_day_plan.dart';
import '../core/timeline_planner_engine.dart';

typedef TimelinePlannerDayWidgetBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelinePlannerDaySnapshot<T> snapshot,
    );

/// Cached builder that feeds application-owned UI with a complete day plan.
///
/// It renders no package UI. Structured-style applications can keep their
/// existing cards, date selector, bottom sheets, and state management while
/// moving recurrence, gaps, conflicts, and now/next calculations into the
/// package.
class TimelinePlannerDayBuilder<T> extends StatefulWidget {
  const TimelinePlannerDayBuilder({
    required this.values,
    required this.engine,
    required this.selectedDate,
    required this.builder,
    this.now,
    this.config = const TimelineDayPlanConfig(),
    this.dataRevision,
    super.key,
  });

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime selectedDate;
  final TimelinePlannerDayWidgetBuilder<T> builder;
  final DateTime? now;
  final TimelineDayPlanConfig config;
  final Object? dataRevision;

  @override
  State<TimelinePlannerDayBuilder<T>> createState() =>
      _TimelinePlannerDayBuilderState<T>();
}

class _TimelinePlannerDayBuilderState<T>
    extends State<TimelinePlannerDayBuilder<T>> {
  TimelinePlannerDaySnapshot<T>? _snapshot;
  Object? _revision;
  DateTime? _selectedDate;
  DateTime? _now;
  TimelineDayPlanConfig? _config;
  TimelinePlannerEngine<T>? _engine;

  @override
  Widget build(BuildContext context) {
    final revision =
        widget.dataRevision ??
        Object.hashAll(widget.values.map((value) => identityHashCode(value)));
    if (_snapshot == null ||
        _revision != revision ||
        _selectedDate != widget.selectedDate ||
        _now != widget.now ||
        !identical(_config, widget.config) ||
        !identical(_engine, widget.engine)) {
      _snapshot = widget.engine.buildDay(
        values: widget.values,
        selectedDate: widget.selectedDate,
        now: widget.now,
        config: widget.config,
      );
      _revision = revision;
      _selectedDate = widget.selectedDate;
      _now = widget.now;
      _config = widget.config;
      _engine = widget.engine;
    }
    return widget.builder(context, _snapshot!);
  }
}

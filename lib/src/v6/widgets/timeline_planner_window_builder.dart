import 'package:flutter/widgets.dart';

import '../core/timeline_planner_engine.dart';
import '../core/timeline_planner_window.dart';

typedef TimelinePlannerWindowWidgetBuilder<T> =
    Widget Function(BuildContext context, TimelinePlannerWindow<T> window);

/// Caches one bounded planner expansion for several application-owned views.
///
/// Use this bridge when a screen renders a day timeline, week selector, and
/// month activity markers from the same task state.
class TimelinePlannerWindowBuilder<T> extends StatefulWidget {
  const TimelinePlannerWindowBuilder({
    required this.values,
    required this.engine,
    required this.windowStart,
    required this.windowEnd,
    required this.builder,
    this.dataRevision,
    super.key,
  });

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime windowStart;
  final DateTime windowEnd;
  final TimelinePlannerWindowWidgetBuilder<T> builder;
  final Object? dataRevision;

  @override
  State<TimelinePlannerWindowBuilder<T>> createState() =>
      _TimelinePlannerWindowBuilderState<T>();
}

class _TimelinePlannerWindowBuilderState<T>
    extends State<TimelinePlannerWindowBuilder<T>> {
  TimelinePlannerWindow<T>? _window;
  Object? _revision;
  DateTime? _windowStart;
  DateTime? _windowEnd;
  TimelinePlannerEngine<T>? _engine;

  @override
  Widget build(BuildContext context) {
    final revision =
        widget.dataRevision ??
        Object.hashAll(widget.values.map((value) => identityHashCode(value)));
    if (_window == null ||
        _revision != revision ||
        _windowStart != widget.windowStart ||
        _windowEnd != widget.windowEnd ||
        !identical(_engine, widget.engine)) {
      _window = widget.engine.prepareWindow(
        values: widget.values,
        windowStart: widget.windowStart,
        windowEnd: widget.windowEnd,
      );
      _revision = revision;
      _windowStart = widget.windowStart;
      _windowEnd = widget.windowEnd;
      _engine = widget.engine;
    }
    return widget.builder(context, _window!);
  }
}

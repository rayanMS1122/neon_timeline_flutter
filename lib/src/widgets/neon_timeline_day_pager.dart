import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/neon_timeline_duration.dart';

/// Adds polished previous/next-day horizontal swipe navigation around a child.
///
/// This extracts the day-switching gesture used by planner applications into a
/// reusable, model-agnostic widget. It never stores the selected date itself.
class NeonTimelineDayPager extends StatefulWidget {
  /// Creates a day pager.
  const NeonTimelineDayPager({
    required this.selectedDate,
    required this.onDateChanged,
    required this.child,
    this.enabled = true,
    this.velocityThreshold = 400,
    this.distanceThreshold = 72,
    this.maximumVisualOffset = 52,
    this.transitionDuration = const Duration(milliseconds: 220),
    this.haptics = true,
    super.key,
  })  : assert(velocityThreshold >= 0),
        assert(distanceThreshold >= 0),
        assert(maximumVisualOffset >= 0);

  /// Currently selected calendar date.
  final DateTime selectedDate;

  /// Called with the previous or next date after a completed swipe.
  final ValueChanged<DateTime> onDateChanged;

  /// Timeline or schedule content.
  final Widget child;

  /// Whether horizontal day navigation is enabled.
  final bool enabled;

  /// Absolute pixels-per-second threshold for a fling.
  final double velocityThreshold;

  /// Drag-distance threshold for a slow swipe.
  final double distanceThreshold;

  /// Maximum visual translation while dragging.
  final double maximumVisualOffset;

  /// Snap-back animation duration.
  final Duration transitionDuration;

  /// Whether successful navigation emits light haptic feedback.
  final bool haptics;

  @override
  State<NeonTimelineDayPager> createState() => _NeonTimelineDayPagerState();
}

class _NeonTimelineDayPagerState extends State<NeonTimelineDayPager> {
  double _dragDistance = 0;
  bool _dragging = false;

  double get _velocityThreshold =>
      widget.velocityThreshold.isFinite && widget.velocityThreshold >= 0
          ? widget.velocityThreshold
          : 400;

  double get _distanceThreshold =>
      widget.distanceThreshold.isFinite && widget.distanceThreshold >= 0
          ? widget.distanceThreshold
          : 72;

  double get _maximumVisualOffset =>
      widget.maximumVisualOffset.isFinite && widget.maximumVisualOffset >= 0
          ? widget.maximumVisualOffset
          : 52;

  void _handleUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _dragging = true;
      _dragDistance += details.delta.dx;
    });
  }

  void _handleEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    final velocity = details.primaryVelocity ?? 0;
    final moveNext = velocity <= -_velocityThreshold ||
        _dragDistance <= -_distanceThreshold;
    final movePrevious = velocity >= _velocityThreshold ||
        _dragDistance >= _distanceThreshold;

    if (moveNext || movePrevious) {
      if (widget.haptics) {
        unawaited(
          HapticFeedback.lightImpact().catchError((Object _, StackTrace __) {}),
        );
      }
      final delta = moveNext ? 1 : -1;
      widget.onDateChanged(_shiftCalendarDay(widget.selectedDate, delta));
    }
    _reset();
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _dragDistance = 0;
      _dragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final maximumVisualOffset = _maximumVisualOffset;
    final visualOffset = _dragDistance
        .clamp(-maximumVisualOffset, maximumVisualOffset)
        .toDouble();
    final progress = maximumVisualOffset == 0
        ? 0.0
        : (visualOffset.abs() / maximumVisualOffset)
            .clamp(0.0, 1.0)
            .toDouble();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: widget.enabled ? _handleUpdate : null,
      onHorizontalDragEnd: widget.enabled ? _handleEnd : null,
      onHorizontalDragCancel: widget.enabled ? _reset : null,
      child: AnimatedContainer(
        duration: _dragging || reduceMotion
            ? Duration.zero
            : neonNonNegativeDuration(
                widget.transitionDuration,
                debugLabel: 'NeonTimelineDayPager.transitionDuration',
              ),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(visualOffset, 0, 0),
        child: Opacity(
          opacity: 1 - progress * 0.08,
          child: widget.child,
        ),
      ),
    );
  }
}

DateTime _shiftCalendarDay(DateTime value, int dayDelta) {
  if (value.isUtc) {
    return DateTime.utc(
      value.year,
      value.month,
      value.day + dayDelta,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }
  return DateTime(
    value.year,
    value.month,
    value.day + dayDelta,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

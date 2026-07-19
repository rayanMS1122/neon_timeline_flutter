import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/timeline_theme.dart';

/// Immutable blocked or emphasized section on a time range track.
@immutable
class NeonPlannerTimeRangeSegment {
  /// Creates a segment.
  const NeonPlannerTimeRangeSegment({
    required this.start,
    required this.end,
    this.isBlocked = true,
  });

  /// Segment start relative to the same day origin as the slider.
  final Duration start;

  /// Segment end.
  final Duration end;

  /// Whether the segment represents unavailable time.
  final bool isBlocked;
}

/// Custom two-thumb time-range slider.
class NeonPlannerTimeRangeSlider extends StatefulWidget {
  /// Creates a range slider.
  NeonPlannerTimeRangeSlider({
    required this.minimum,
    required this.maximum,
    required this.start,
    required this.end,
    required this.onChanged,
    this.onChangeEnd,
    this.minimumDuration = const Duration(minutes: 15),
    this.maximumDuration,
    this.snapInterval = const Duration(minutes: 5),
    this.segments = const <NeonPlannerTimeRangeSegment>[],
    this.onStartTap,
    this.onEndTap,
    this.height = 86,
    super.key,
  }) : assert(maximum > minimum),
       assert(start >= minimum),
       assert(end <= maximum),
       assert(end > start),
       assert(minimumDuration > Duration.zero),
       assert(maximumDuration == null || maximumDuration >= minimumDuration),
       assert(snapInterval > Duration.zero),
       assert(
         segments.every((segment) => segment.end > segment.start),
         'Every time-range segment must end after it starts.',
       );

  /// Earliest selectable time.
  final Duration minimum;

  /// Latest selectable time.
  final Duration maximum;

  /// Selected start.
  final Duration start;

  /// Selected end.
  final Duration end;

  /// Called with a changed range.
  final void Function(Duration start, Duration end) onChanged;

  /// Called after a gesture or keyboard edit ends.
  final void Function(Duration start, Duration end)? onChangeEnd;

  /// Smallest allowed duration.
  final Duration minimumDuration;

  /// Optional largest allowed duration.
  final Duration? maximumDuration;

  /// Snap grid.
  final Duration snapInterval;

  /// Blocked or emphasized track segments.
  final List<NeonPlannerTimeRangeSegment> segments;

  /// Direct start-time action.
  final VoidCallback? onStartTap;

  /// Direct end-time action.
  final VoidCallback? onEndTap;

  /// Total control height.
  final double height;

  @override
  State<NeonPlannerTimeRangeSlider> createState() =>
      _NeonPlannerTimeRangeSliderState();
}

enum _ActiveThumb { start, end }

class _NeonPlannerTimeRangeSliderState
    extends State<NeonPlannerTimeRangeSlider> {
  _ActiveThumb _activeThumb = _ActiveThumb.start;

  @override
  Widget build(BuildContext context) {
    final theme = NeonPlannerTimelineTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          container: true,
          label: 'Zeitbereich ${_clock(widget.start)} bis ${_clock(widget.end)}, '
              '${(widget.end - widget.start).inMinutes} Minuten',
          child: Focus(
            onKeyEvent: _onKeyEvent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _beginAt(details.localPosition.dx, width),
              onHorizontalDragStart: (details) =>
                  _beginAt(details.localPosition.dx, width),
              onHorizontalDragUpdate: (details) =>
                  _updateAt(details.localPosition.dx, width),
              onHorizontalDragEnd: (_) =>
                  widget.onChangeEnd?.call(widget.start, widget.end),
              child: SizedBox(
                height: widget.height,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RangePainter(
                          minimum: widget.minimum,
                          maximum: widget.maximum,
                          start: widget.start,
                          end: widget.end,
                          segments: widget.segments,
                          activeColor: theme.dayAccentColor,
                          inactiveColor: theme.gridColor,
                          blockedColor: theme.errorColor,
                          surfaceColor: theme.surfaceColor,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 4,
                      child: Semantics(
                        button: widget.onStartTap != null,
                        label: 'Startzeit ${_clock(widget.start)}',
                        onTap: widget.onStartTap,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.onStartTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              _clock(widget.start),
                              style: theme.timeStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 4,
                      child: Semantics(
                        button: widget.onEndTap != null,
                        label: 'Endzeit ${_clock(widget.end)}',
                        onTap: widget.onEndTap,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.onEndTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              _clock(widget.end),
                              style: theme.timeStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 3,
                      child: Text(
                        '${(widget.end - widget.start).inMinutes} Minuten',
                        textAlign: TextAlign.center,
                        style: theme.metadataStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      setState(() {
        _activeThumb = _activeThumb == _ActiveThumb.start
            ? _ActiveThumb.end
            : _ActiveThumb.start;
      });
      return KeyEventResult.handled;
    }
    final decrement = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown;
    final increment = event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp;
    if (!decrement && !increment) {
      return KeyEventResult.ignored;
    }
    final delta = increment ? widget.snapInterval : -widget.snapInterval;
    if (_activeThumb == _ActiveThumb.start) {
      _emit(widget.start + delta, widget.end);
    } else {
      _emit(widget.start, widget.end + delta);
    }
    widget.onChangeEnd?.call(widget.start, widget.end);
    return KeyEventResult.handled;
  }

  void _beginAt(double x, double width) {
    final time = _timeAt(x, width);
    final startDistance = (time - widget.start).abs();
    final endDistance = (time - widget.end).abs();
    setState(() {
      _activeThumb = startDistance <= endDistance
          ? _ActiveThumb.start
          : _ActiveThumb.end;
    });
    _updateAt(x, width);
  }

  void _updateAt(double x, double width) {
    final time = _timeAt(x, width);
    if (_activeThumb == _ActiveThumb.start) {
      _emit(time, widget.end);
    } else {
      _emit(widget.start, time);
    }
  }

  Duration _timeAt(double x, double width) {
    const horizontalPadding = 24.0;
    final trackWidth = (width - horizontalPadding * 2)
        .clamp(1.0, width)
        .toDouble();
    final normalized = ((x - horizontalPadding) / trackWidth)
        .clamp(0.0, 1.0)
        .toDouble();
    final rangeMicros = (widget.maximum - widget.minimum).inMicroseconds;
    final raw = widget.minimum +
        Duration(microseconds: (rangeMicros * normalized).round());
    return _snap(raw);
  }

  Duration _snap(Duration value) {
    final step = widget.snapInterval.inMicroseconds;
    final offset = value.inMicroseconds - widget.minimum.inMicroseconds;
    final snapped = (offset / step).round() * step;
    return Duration(microseconds: widget.minimum.inMicroseconds + snapped);
  }

  void _emit(Duration start, Duration end) {
    var nextStart = _clampDuration(start, widget.minimum, widget.maximum);
    var nextEnd = _clampDuration(end, widget.minimum, widget.maximum);

    if (nextEnd - nextStart < widget.minimumDuration) {
      if (_activeThumb == _ActiveThumb.start) {
        nextStart = nextEnd - widget.minimumDuration;
      } else {
        nextEnd = nextStart + widget.minimumDuration;
      }
    }
    final maxDuration = widget.maximumDuration;
    if (maxDuration != null && nextEnd - nextStart > maxDuration) {
      if (_activeThumb == _ActiveThumb.start) {
        nextStart = nextEnd - maxDuration;
      } else {
        nextEnd = nextStart + maxDuration;
      }
    }

    nextStart = _clampDuration(nextStart, widget.minimum, widget.maximum);
    nextEnd = _clampDuration(nextEnd, widget.minimum, widget.maximum);
    if (nextStart == widget.start && nextEnd == widget.end) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onChanged(nextStart, nextEnd);
  }
}

class _RangePainter extends CustomPainter {
  const _RangePainter({
    required this.minimum,
    required this.maximum,
    required this.start,
    required this.end,
    required this.segments,
    required this.activeColor,
    required this.inactiveColor,
    required this.blockedColor,
    required this.surfaceColor,
  });

  final Duration minimum;
  final Duration maximum;
  final Duration start;
  final Duration end;
  final List<NeonPlannerTimeRangeSegment> segments;
  final Color activeColor;
  final Color inactiveColor;
  final Color blockedColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 24.0;
    final y = size.height * 0.55;
    const left = padding;
    final right = size.width - padding;
    final track = Rect.fromLTRB(left, y - 3, right, y + 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(99)),
      Paint()..color = inactiveColor,
    );

    for (final segment in segments) {
      final segmentLeft = _xFor(segment.start, left, right);
      final segmentRight = _xFor(segment.end, left, right);
      final rect = Rect.fromLTRB(segmentLeft, y - 7, segmentRight, y + 7);
      if (segment.isBlocked) {
        _paintHatched(canvas, rect);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = activeColor.withValues(alpha: 0.18),
        );
      }
    }

    final startX = _xFor(start, left, right);
    final endX = _xFor(end, left, right);
    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      Paint()
        ..color = activeColor
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    _paintThumb(canvas, Offset(startX, y), false);
    _paintThumb(canvas, Offset(endX, y), true);
  }

  double _xFor(Duration value, double left, double right) {
    final total = (maximum - minimum).inMicroseconds;
    final offset = (value - minimum).inMicroseconds;
    return left + (right - left) * offset / total;
  }

  void _paintThumb(Canvas canvas, Offset center, bool endThumb) {
    canvas.drawCircle(center, 11, Paint()..color = surfaceColor);
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      center.translate(endThumb ? -2 : 2, -4),
      center.translate(endThumb ? -2 : 2, 4),
      Paint()
        ..color = activeColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintHatched(Canvas canvas, Rect rect) {
    canvas.save();
    canvas.clipRect(rect);
    final background = Paint()..color = blockedColor.withValues(alpha: 0.10);
    canvas.drawRect(rect, background);
    final line = Paint()
      ..color = blockedColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    for (var x = rect.left - rect.height; x < rect.right; x += 8) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x + rect.height, rect.top),
        line,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RangePainter oldDelegate) {
    return minimum != oldDelegate.minimum ||
        maximum != oldDelegate.maximum ||
        start != oldDelegate.start ||
        end != oldDelegate.end ||
        segments != oldDelegate.segments ||
        activeColor != oldDelegate.activeColor ||
        inactiveColor != oldDelegate.inactiveColor ||
        blockedColor != oldDelegate.blockedColor ||
        surfaceColor != oldDelegate.surfaceColor;
  }
}

Duration _clampDuration(Duration value, Duration minimum, Duration maximum) {
  if (value < minimum) {
    return minimum;
  }
  if (value > maximum) {
    return maximum;
  }
  return value;
}

String _clock(Duration value) {
  final totalMinutes = value.inMinutes;
  final hour = (totalMinutes ~/ 60) % 24;
  final minute = totalMinutes % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

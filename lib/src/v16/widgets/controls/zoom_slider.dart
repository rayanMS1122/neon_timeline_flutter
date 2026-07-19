import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/models.dart';
import '../../theme/timeline_theme.dart';

/// Custom continuous zoom control with semantic zoom thresholds.
class NeonPlannerZoomSlider extends StatefulWidget {
  /// Creates a zoom slider.
  const NeonPlannerZoomSlider({
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.showButtons = true,
    this.height = 54,
    super.key,
  });

  /// Current semantic zoom level.
  final NeonPlannerZoomLevel value;

  /// Called whenever the semantic level changes.
  final ValueChanged<NeonPlannerZoomLevel> onChanged;

  /// Called after a pointer interaction ends.
  final ValueChanged<NeonPlannerZoomLevel>? onChangeEnd;

  /// Whether minus and plus buttons are shown.
  final bool showButtons;

  /// Control height.
  final double height;

  @override
  State<NeonPlannerZoomSlider> createState() => _NeonPlannerZoomSliderState();
}

class _NeonPlannerZoomSliderState extends State<NeonPlannerZoomSlider> {
  late double _continuous;

  @override
  void initState() {
    super.initState();
    _continuous = _indexOf(widget.value).toDouble();
  }

  @override
  void didUpdateWidget(covariant NeonPlannerZoomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _continuous = _indexOf(widget.value).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeonPlannerTimelineTheme.of(context);
    final track = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          label: 'Timeline-Zoom',
          value: _label(widget.value),
          increasedValue: _label(_step(widget.value, 1)),
          decreasedValue: _label(_step(widget.value, -1)),
          onIncrease: () => _changeBy(1),
          onDecrease: () => _changeBy(-1),
          child: Focus(
            onKeyEvent: _onKeyEvent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () => _setLevel(NeonPlannerZoomLevel.balanced),
              onHorizontalDragStart: (details) =>
                  _updateFromLocal(details.localPosition.dx, width),
              onHorizontalDragUpdate: (details) =>
                  _updateFromLocal(details.localPosition.dx, width),
              onHorizontalDragEnd: (_) =>
                  widget.onChangeEnd?.call(widget.value),
              onTapDown: (details) =>
                  _updateFromLocal(details.localPosition.dx, width),
              child: SizedBox(
                height: widget.height,
                child: CustomPaint(
                  painter: _SegmentedSliderPainter(
                    normalized: _continuous /
                        (NeonPlannerZoomLevel.values.length - 1),
                    activeColor: theme.dayAccentColor,
                    inactiveColor: theme.gridColor,
                    thumbColor: theme.surfaceColor,
                    outlineColor: theme.dayAccentColor,
                    divisions: NeonPlannerZoomLevel.values.length - 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!widget.showButtons) {
      return track;
    }
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Weniger Details',
          onPressed: () => _changeBy(-1),
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(child: track),
        IconButton(
          tooltip: 'Mehr Details',
          onPressed: () => _changeBy(1),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _changeBy(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _changeBy(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _setLevel(NeonPlannerZoomLevel.overview);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      _setLevel(NeonPlannerZoomLevel.cinematic);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _updateFromLocal(double x, double width) {
    const horizontalPadding = 16.0;
    final trackWidth = (width - horizontalPadding * 2)
        .clamp(1.0, width)
        .toDouble();
    final normalized = ((x - horizontalPadding) / trackWidth)
        .clamp(0.0, 1.0)
        .toDouble();
    final nextContinuous =
        normalized * (NeonPlannerZoomLevel.values.length - 1);
    final nextLevel = NeonPlannerZoomLevel.values[nextContinuous.round()];
    setState(() => _continuous = nextContinuous);
    if (nextLevel != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(nextLevel);
    }
  }

  void _changeBy(int delta) => _setLevel(_step(widget.value, delta));

  void _setLevel(NeonPlannerZoomLevel level) {
    if (level == widget.value) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _continuous = _indexOf(level).toDouble());
    widget.onChanged(level);
    widget.onChangeEnd?.call(level);
  }
}

int _indexOf(NeonPlannerZoomLevel value) =>
    NeonPlannerZoomLevel.values.indexOf(value);

NeonPlannerZoomLevel _step(NeonPlannerZoomLevel value, int delta) {
  final index = (_indexOf(value) + delta)
      .clamp(0, NeonPlannerZoomLevel.values.length - 1)
      .toInt();
  return NeonPlannerZoomLevel.values[index];
}

String _label(NeonPlannerZoomLevel value) {
  return switch (value) {
    NeonPlannerZoomLevel.overview => 'Übersicht',
    NeonPlannerZoomLevel.compact => 'Kompakt',
    NeonPlannerZoomLevel.balanced => 'Ausgewogen',
    NeonPlannerZoomLevel.comfortable => 'Komfortabel',
    NeonPlannerZoomLevel.detailed => 'Detailliert',
    NeonPlannerZoomLevel.cinematic => 'Maximal',
  };
}

class _SegmentedSliderPainter extends CustomPainter {
  const _SegmentedSliderPainter({
    required this.normalized,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.outlineColor,
    required this.divisions,
  });

  final double normalized;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Color outlineColor;
  final int divisions;

  @override
  void paint(Canvas canvas, Size size) {
    const horizontalPadding = 16.0;
    final centerY = size.height / 2;
    const start = horizontalPadding;
    final end = size.width - horizontalPadding;
    final thumbX = start + (end - start) * normalized;
    final inactive = Paint()
      ..color = inactiveColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = activeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(start, centerY), Offset(end, centerY), inactive);
    canvas.drawLine(Offset(start, centerY), Offset(thumbX, centerY), active);

    final tickPaint = Paint()..color = inactiveColor;
    for (var index = 0; index <= divisions; index += 1) {
      final x = start + (end - start) * index / divisions;
      canvas.drawCircle(Offset(x, centerY), 2, tickPaint);
    }

    canvas.drawCircle(
      Offset(thumbX, centerY),
      10,
      Paint()..color = thumbColor,
    );
    canvas.drawCircle(
      Offset(thumbX, centerY),
      10,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _SegmentedSliderPainter oldDelegate) {
    return normalized != oldDelegate.normalized ||
        activeColor != oldDelegate.activeColor ||
        inactiveColor != oldDelegate.inactiveColor ||
        thumbColor != oldDelegate.thumbColor ||
        outlineColor != oldDelegate.outlineColor ||
        divisions != oldDelegate.divisions;
  }
}

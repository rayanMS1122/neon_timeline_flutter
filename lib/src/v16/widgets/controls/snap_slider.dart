import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/models.dart';
import '../../theme/timeline_theme.dart';

/// Compact custom snap-strength control.
class NeonPlannerSnapSlider extends StatelessWidget {
  /// Creates a snap slider.
  const NeonPlannerSnapSlider({
    required this.value,
    required this.onChanged,
    this.height = 48,
    super.key,
  });

  /// Current snap strength.
  final NeonPlannerSnapStrength value;

  /// Called when the strength changes.
  final ValueChanged<NeonPlannerSnapStrength> onChanged;

  /// Control height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = NeonPlannerTimelineTheme.of(context);
    final index = NeonPlannerSnapStrength.values.indexOf(value);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          label: 'Magnetisches Einrasten',
          value: _label(value),
          onIncrease: () => _step(1),
          onDecrease: () => _step(-1),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) {
                return KeyEventResult.ignored;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                _step(1);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _step(-1);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _updateFromPosition(details.localPosition.dx, width),
              onHorizontalDragUpdate: (details) =>
                  _updateFromPosition(details.localPosition.dx, width),
              child: SizedBox(
                height: height,
                child: CustomPaint(
                  painter: _SnapPainter(
                    normalized: index /
                        (NeonPlannerSnapStrength.values.length - 1),
                    activeColor: theme.nightAccentColor,
                    inactiveColor: theme.gridColor,
                    surfaceColor: theme.surfaceColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Aus', style: theme.metadataStyle),
                        Text('Stark', style: theme.metadataStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateFromPosition(double x, double width) {
    const padding = 48.0;
    final trackWidth = (width - padding * 2).clamp(1.0, width).toDouble();
    final normalized = ((x - padding) / trackWidth)
        .clamp(0.0, 1.0)
        .toDouble();
    final next = NeonPlannerSnapStrength.values[
        (normalized * (NeonPlannerSnapStrength.values.length - 1)).round()];
    _set(next);
  }

  void _step(int delta) {
    final index = NeonPlannerSnapStrength.values.indexOf(value);
    final nextIndex = (index + delta)
        .clamp(0, NeonPlannerSnapStrength.values.length - 1)
        .toInt();
    _set(NeonPlannerSnapStrength.values[nextIndex]);
  }

  void _set(NeonPlannerSnapStrength next) {
    if (next == value) {
      return;
    }
    HapticFeedback.selectionClick();
    onChanged(next);
  }
}

String _label(NeonPlannerSnapStrength value) {
  return switch (value) {
    NeonPlannerSnapStrength.off => 'Aus',
    NeonPlannerSnapStrength.soft => 'Leicht',
    NeonPlannerSnapStrength.balanced => 'Normal',
    NeonPlannerSnapStrength.strong => 'Stark',
  };
}

class _SnapPainter extends CustomPainter {
  const _SnapPainter({
    required this.normalized,
    required this.activeColor,
    required this.inactiveColor,
    required this.surfaceColor,
  });

  final double normalized;
  final Color activeColor;
  final Color inactiveColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 48.0;
    final y = size.height / 2;
    const start = padding;
    final end = size.width - padding;
    final x = start + (end - start) * normalized;
    final base = Paint()
      ..color = inactiveColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = activeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(start, y), Offset(end, y), base);
    canvas.drawLine(Offset(start, y), Offset(x, y), active);
    for (var i = 0; i < 4; i += 1) {
      final tickX = start + (end - start) * i / 3;
      canvas.drawCircle(Offset(tickX, y), 2.2, base);
    }
    canvas.drawCircle(Offset(x, y), 9, Paint()..color = surfaceColor);
    canvas.drawCircle(
      Offset(x, y),
      9,
      Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _SnapPainter oldDelegate) {
    return normalized != oldDelegate.normalized ||
        activeColor != oldDelegate.activeColor ||
        inactiveColor != oldDelegate.inactiveColor ||
        surfaceColor != oldDelegate.surfaceColor;
  }
}

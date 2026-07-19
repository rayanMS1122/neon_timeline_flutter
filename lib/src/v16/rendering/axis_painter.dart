import 'package:flutter/material.dart';

import '../api/timeline_config.dart';
import '../domain/time_scale.dart';
import '../theme/timeline_theme.dart';

/// Lightweight geometry used by the axis painter.
final class NeonPlannerPaintedEntry {
  /// Creates painted entry geometry.
  const NeonPlannerPaintedEntry({
    required this.top,
    required this.bottom,
    required this.color,
  });

  /// Top pixel.
  final double top;

  /// Bottom pixel.
  final double bottom;

  /// Segment color.
  final Color color;
}

/// Paints hour labels, the central dashed axis, and active event segments.
final class NeonPlannerAxisPainter extends CustomPainter {
  /// Creates an axis painter.
  NeonPlannerAxisPainter({
    required this.scale,
    required this.config,
    required this.theme,
    required this.axisX,
    required this.totalHeight,
    required this.entries,
    required this.textDirection,
  });

  /// Time scale.
  final NeonPlannerTimeScale scale;

  /// Timeline configuration.
  final NeonPlannerTimelineConfig config;

  /// Timeline theme.
  final NeonPlannerTimelineThemeData theme;

  /// X coordinate of the axis.
  final double axisX;

  /// Full content height.
  final double totalHeight;

  /// Visible event segments.
  final List<NeonPlannerPaintedEntry> entries;

  /// Text direction.
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final clippedHeight = totalHeight.clamp(0.0, size.height).toDouble();
    _paintHourGrid(canvas, size.width, clippedHeight);
    _paintDashedAxis(canvas, clippedHeight);
    _paintEntrySegments(canvas, clippedHeight);
  }

  void _paintHourGrid(Canvas canvas, double width, double height) {
    final start = scale.origin;
    final end = scale.origin.add(config.visibleEnd - config.visibleStart);
    var cursor = DateTime(start.year, start.month, start.day, start.hour);
    if (cursor.isBefore(start)) {
      cursor = cursor.add(const Duration(hours: 1));
    }
    final paint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = 1;

    while (!cursor.isAfter(end)) {
      final y = scale.timeToPixels(cursor);
      if (y >= 0 && y <= height) {
        canvas.drawLine(
          Offset(axisX + 36, y),
          Offset(width - config.statusColumnWidth - 8, y),
          paint,
        );
      }
      cursor = cursor.add(const Duration(hours: 1));
    }
  }

  void _paintDashedAxis(Canvas canvas, double height) {
    const dash = 8.0;
    const gap = 7.0;
    var y = 0.0;
    while (y < height) {
      final midpoint = scale.pixelsToTime(y + dash / 2);
      final color = _isNight(midpoint)
          ? theme.nightAccentColor.withValues(alpha: 0.72)
          : theme.dayAccentColor.withValues(alpha: 0.72);
      final paint = Paint()
        ..color = color
        ..strokeWidth = theme.lineWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(axisX, y),
        Offset(axisX, (y + dash).clamp(0.0, height).toDouble()),
        paint,
      );
      y += dash + gap;
    }
  }

  void _paintEntrySegments(Canvas canvas, double height) {
    for (final entry in entries) {
      final top = entry.top.clamp(0.0, height).toDouble();
      final bottom = entry.bottom.clamp(0.0, height).toDouble();
      if (bottom <= top) {
        continue;
      }
      final paint = Paint()
        ..color = entry.color
        ..strokeWidth = theme.lineWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(axisX, top), Offset(axisX, bottom), paint);
    }
  }

  bool _isNight(DateTime time) {
    final offset = Duration(hours: time.hour, minutes: time.minute);
    return offset < config.dayStartsAt || offset >= config.nightStartsAt;
  }

  @override
  bool shouldRepaint(covariant NeonPlannerAxisPainter oldDelegate) {
    return scale.origin != oldDelegate.scale.origin ||
        scale.pixelsPerMinute != oldDelegate.scale.pixelsPerMinute ||
        config != oldDelegate.config ||
        theme != oldDelegate.theme ||
        axisX != oldDelegate.axisX ||
        totalHeight != oldDelegate.totalHeight ||
        entries != oldDelegate.entries ||
        textDirection != oldDelegate.textDirection;
  }
}

/// Paints the current-time rule independently of the static timeline.
final class NeonPlannerCurrentTimePainter extends CustomPainter {
  /// Creates a current-time painter.
  NeonPlannerCurrentTimePainter({
    required this.currentTime,
    required this.scale,
    required this.color,
    required this.axisX,
    required this.rightInset,
  });

  /// Current time.
  final DateTime currentTime;

  /// Time scale.
  final NeonPlannerTimeScale scale;

  /// Marker color.
  final Color color;

  /// Axis x coordinate.
  final double axisX;

  /// Right inset.
  final double rightInset;

  @override
  void paint(Canvas canvas, Size size) {
    final y = scale.timeToPixels(currentTime);
    if (y < 0 || y > size.height) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(axisX, y), 4.5, paint);
    canvas.drawLine(Offset(axisX + 8, y), Offset(size.width - rightInset, y), paint);
  }

  @override
  bool shouldRepaint(covariant NeonPlannerCurrentTimePainter oldDelegate) {
    return currentTime != oldDelegate.currentTime ||
        scale.origin != oldDelegate.scale.origin ||
        scale.pixelsPerMinute != oldDelegate.scale.pixelsPerMinute ||
        color != oldDelegate.color ||
        axisX != oldDelegate.axisX ||
        rightInset != oldDelegate.rightInset;
  }
}

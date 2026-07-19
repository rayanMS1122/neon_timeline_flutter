import 'package:flutter/material.dart';

import '../../v4/models/timeline_entry.dart';
import '../../v4/theme/timeline_theme.dart';

typedef TimelineOverviewSeek = void Function(DateTime instant);

class TimelineOverviewStrip<T> extends StatelessWidget {
  const TimelineOverviewStrip({
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    this.height = 72,
    this.selectedId,
    this.onSeek,
    this.padding = const EdgeInsets.all(10),
    super.key,
  }) : assert(height > 0);

  final List<TimelineEntry<T>> entries;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double height;
  final Object? selectedId;
  final TimelineOverviewSeek? onSeek;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    assert(rangeEnd.isAfter(rangeStart), 'rangeEnd must be after rangeStart');
    if (!rangeEnd.isAfter(rangeStart)) {
      throw ArgumentError.value(
        rangeEnd,
        'rangeEnd',
        'must be after rangeStart',
      );
    }
    final theme = TimelineTheme.of(context);
    return Semantics(
      label: 'Timeline overview',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: onSeek == null
            ? null
            : (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null || box.size.width <= 0) return;
                final resolved = padding.resolve(Directionality.of(context));
                final contentWidth = (box.size.width - resolved.horizontal)
                    .clamp(1.0, double.infinity)
                    .toDouble();
                final x = (details.localPosition.dx - resolved.left)
                    .clamp(0.0, contentWidth)
                    .toDouble();
                final progress = x / contentWidth;
                final micros = rangeEnd.difference(rangeStart).inMicroseconds;
                onSeek!(
                  rangeStart.add(
                    Duration(microseconds: (micros * progress).round()),
                  ),
                );
              },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(theme.cardRadius),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Padding(
            padding: padding,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: CustomPaint(
                painter: _TimelineOverviewPainter<T>(
                  entries: entries,
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  selectedId: selectedId,
                  theme: theme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineOverviewPainter<T> extends CustomPainter {
  const _TimelineOverviewPainter({
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedId,
    required this.theme,
  });

  final List<TimelineEntry<T>> entries;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Object? selectedId;
  final TimelineThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.16),
      const Radius.circular(999),
    );
    canvas.drawRRect(track, Paint()..color = theme.surfaceVariantColor);

    final totalMicros = rangeEnd.difference(rangeStart).inMicroseconds;
    if (totalMicros <= 0) return;
    final laneHeight = (size.height - 8) / 3;

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      if (!entry.rawEnd.isAfter(rangeStart) ||
          !entry.start.isBefore(rangeEnd)) {
        continue;
      }
      final clippedStart = entry.start.isBefore(rangeStart)
          ? rangeStart
          : entry.start;
      final clippedEnd = entry.rawEnd.isAfter(rangeEnd)
          ? rangeEnd
          : entry.rawEnd;
      final startFraction =
          clippedStart.difference(rangeStart).inMicroseconds / totalMicros;
      final endFraction =
          clippedEnd.difference(rangeStart).inMicroseconds / totalMicros;
      final left = startFraction * size.width;
      final width = ((endFraction - startFraction) * size.width)
          .clamp(2.0, size.width)
          .toDouble();
      final lane = index % 3;
      final top = 4 + lane * laneHeight;
      final selected = entry.id == selectedId;
      final color = entry.color ?? theme.colorForStatus(entry.status);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          top,
          width,
          (laneHeight - 5).clamp(4.0, laneHeight).toDouble(),
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = selected ? color : color.withAlpha(170),
      );
      if (selected) {
        canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = theme.focusColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineOverviewPainter<T> oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.rangeStart != rangeStart ||
        oldDelegate.rangeEnd != rangeEnd ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.theme != theme;
  }
}

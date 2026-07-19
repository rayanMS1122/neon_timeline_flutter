import 'package:flutter/material.dart';

import '../../domain/ultra_time_range.dart';
import '../../theme/ultra_timeline_theme.dart';

/// Accessible two-thumb time editor with blocked-range preview.
class UltraTimeRangeSlider extends StatelessWidget {
  const UltraTimeRangeSlider({
    required this.range,
    required this.bounds,
    required this.onChanged,
    this.onChangeEnd,
    this.blockedRanges = const <UltraTimeRange>[],
    this.minimumDuration = const Duration(minutes: 10),
    this.step = const Duration(minutes: 5),
    super.key,
  });

  final UltraTimeRange range;
  final UltraTimeRange bounds;
  final ValueChanged<UltraTimeRange> onChanged;
  final ValueChanged<UltraTimeRange>? onChangeEnd;
  final List<UltraTimeRange> blockedRanges;
  final Duration minimumDuration;
  final Duration step;

  @override
  Widget build(BuildContext context) {
    assert(range.debugAssertIsValid());
    assert(bounds.debugAssertIsValid());
    final theme = UltraTimelineTheme.of(context);
    final total = bounds.duration.inMinutes.toDouble();
    final start = range.start.difference(bounds.start).inMinutes.toDouble();
    final end = range.end.difference(bounds.start).inMinutes.toDouble();
    final divisions = step.inMinutes <= 0
        ? null
        : (total / step.inMinutes).round().clamp(1, 10000).toInt();

    return Semantics(
      container: true,
      label: 'Time range editor',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(theme.radiusLarge),
          border: Border.all(color: theme.outline),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadow,
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final compact = constraints.maxWidth < 520 || textScale > 1.35;
                final summary = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(range.duration),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: theme.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Drag either handle or choose a time',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: theme.mutedText,
                          ),
                    ),
                  ],
                );
                final startButton = _TimeButton(
                  label: 'Start',
                  value: range.start,
                  color: theme.sky,
                  onPressed: () => _pickStart(context),
                );
                final endButton = _TimeButton(
                  label: 'End',
                  value: range.end,
                  color: theme.coral,
                  onPressed: () => _pickEnd(context),
                );
                if (compact) {
                  return Column(
                    children: [
                      summary,
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: startButton),
                          const SizedBox(width: 8),
                          Expanded(child: endButton),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    startButton,
                    Expanded(child: summary),
                    endButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 12,
              width: double.infinity,
              child: CustomPaint(
                painter: _BlockedRangePainter(
                  bounds: bounds,
                  blockedRanges: blockedRanges,
                  trackColor: theme.outline.withValues(alpha: 0.6),
                  blockedColor: theme.coral.withValues(alpha: 0.55),
                ),
              ),
            ),
            RangeSlider(
              values: RangeValues(
                start.clamp(0, total).toDouble(),
                end.clamp(0, total).toDouble(),
              ),
              min: 0,
              max: total,
              divisions: divisions,
              labels: RangeLabels(
                _formatClock(range.start),
                _formatClock(range.end),
              ),
              semanticFormatterCallback: (value) {
                return _formatClock(
                  bounds.start.add(Duration(minutes: value.round())),
                );
              },
              onChanged: (values) {
                onChanged(_rangeFromValues(values, total));
              },
              onChangeEnd: onChangeEnd == null
                  ? null
                  : (values) => onChangeEnd!(_rangeFromValues(values, total)),
            ),
          ],
        ),
      ),
    );
  }

  UltraTimeRange _rangeFromValues(RangeValues values, double total) {
    var startMinutes = values.start.clamp(0, total).round();
    var endMinutes = values.end.clamp(0, total).round();
    final minimum = minimumDuration.inMinutes;
    if (endMinutes - startMinutes < minimum) {
      if (startMinutes + minimum <= total) {
        endMinutes = startMinutes + minimum;
      } else {
        startMinutes = endMinutes - minimum;
      }
    }
    return UltraTimeRange(
      start: bounds.start.add(Duration(minutes: startMinutes)),
      end: bounds.start.add(Duration(minutes: endMinutes)),
    );
  }

  Future<void> _pickStart(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(range.start),
      helpText: 'Select start time',
    );
    if (picked == null || !context.mounted) return;
    var next = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
      picked.hour,
      picked.minute,
    );
    if (next.isBefore(bounds.start)) next = bounds.start;
    final latest = range.end.subtract(minimumDuration);
    if (next.isAfter(latest)) next = latest;
    onChanged(range.copyWith(start: next));
  }

  Future<void> _pickEnd(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(range.end),
      helpText: 'Select end time',
    );
    if (picked == null || !context.mounted) return;
    var next = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      picked.hour,
      picked.minute,
    );
    if (next.isAfter(bounds.end)) next = bounds.end;
    final earliest = range.start.add(minimumDuration);
    if (next.isBefore(earliest)) next = earliest;
    onChanged(range.copyWith(end: next));
  }

  static String _formatClock(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '$rest min';
    if (rest == 0) return '${hours}h';
    return '${hours}h ${rest}m';
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final DateTime value;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.schedule_rounded, size: 18, color: color),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            UltraTimeRangeSlider._formatClock(value),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _BlockedRangePainter extends CustomPainter {
  const _BlockedRangePainter({
    required this.bounds,
    required this.blockedRanges,
    required this.trackColor,
    required this.blockedColor,
  });

  final UltraTimeRange bounds;
  final List<UltraTimeRange> blockedRanges;
  final Color trackColor;
  final Color blockedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );
    final total = bounds.duration.inMicroseconds;
    if (total <= 0) return;
    for (final blocked in blockedRanges) {
      final start = blocked.start.isBefore(bounds.start)
          ? bounds.start
          : blocked.start;
      final end = blocked.end.isAfter(bounds.end) ? bounds.end : blocked.end;
      if (!end.isAfter(start)) continue;
      final left =
          start.difference(bounds.start).inMicroseconds / total * size.width;
      final right =
          end.difference(bounds.start).inMicroseconds / total * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, 0, right, size.height),
          radius,
        ),
        Paint()..color = blockedColor,
      );
    }
  }

  @override
  bool shouldRepaint(_BlockedRangePainter oldDelegate) {
    return bounds != oldDelegate.bounds ||
        blockedRanges != oldDelegate.blockedRanges ||
        trackColor != oldDelegate.trackColor ||
        blockedColor != oldDelegate.blockedColor;
  }
}

part of 'day_timeline_view.dart';

class _TimeDragScrubber<T> extends StatelessWidget {
  const _TimeDragScrubber({
    required this.preview,
    required this.theme,
    required this.conflictPolicy,
    required this.layout,
  });

  final _DayDragPreview<T> preview;
  final NeonPlannerTimelineThemeData theme;
  final NeonPlannerConflictPolicy conflictPolicy;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final blocked = preview.hasConflict &&
        conflictPolicy == NeonPlannerConflictPolicy.block;
    final accent = preview.hasConflict
        ? (blocked ? theme.errorColor : theme.warningColor)
        : theme.focusColor;
    final status = preview.hasConflict
        ? (blocked
            ? 'Blockiert'
            : preview.conflictCount == 1
            ? '1 Überlappung'
            : '${preview.conflictCount} Überlappungen')
        : preview.snapLabel;

    return Row(
      children: <Widget>[
        SizedBox(
          width: layout.timeColumnWidth,
          child: Text(
            _clock(preview.proposedStart),
            style: theme.timeStyle.copyWith(
              color: accent,
              fontSize: layout.timeFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: layout.axisColumnWidth,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: layout.isRegular ? 14 : 4,
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: layout.isRegular ? 11 : 6,
              ),
            ),
          ),
        ),
        SizedBox(width: layout.columnGap),
        Expanded(
          child: CustomPaint(
            painter: _TimeRulePainter(color: accent),
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: layout.isRegular ? 12 : 4,
                      offset: Offset(0, layout.isRegular ? 5 : 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.isRegular ? 12 : 5,
                    vertical: layout.isRegular ? 7 : 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        preview.hasConflict
                            ? Icons.warning_amber_rounded
                            : Icons.center_focus_strong_rounded,
                        size: layout.isRegular ? 15 : 10,
                        color: accent,
                      ),
                      SizedBox(width: layout.isRegular ? 6 : 3),
                      Flexible(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.metadataStyle.copyWith(
                            color: accent,
                            fontSize: layout.metadataFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: layout.statusColumnWidth),
      ],
    );
  }
}

class _ResizeDragScrubber<T> extends StatelessWidget {
  const _ResizeDragScrubber({
    required this.preview,
    required this.theme,
    required this.conflictPolicy,
    required this.layout,
  });

  final _DayResizePreview<T> preview;
  final NeonPlannerTimelineThemeData theme;
  final NeonPlannerConflictPolicy conflictPolicy;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final blocked = preview.hasConflict &&
        conflictPolicy == NeonPlannerConflictPolicy.block;
    final accent = preview.hasConflict
        ? (blocked ? theme.errorColor : theme.warningColor)
        : theme.successColor;
    final edgeLabel = preview.edge == NeonPlannerResizeEdge.start
        ? 'Start'
        : 'Ende';
    final edgeTime = preview.edge == NeonPlannerResizeEdge.start
        ? preview.proposedStart
        : preview.proposedEnd;
    final duration = preview.proposedEnd.difference(preview.proposedStart);
    final status = preview.hasConflict
        ? (blocked
            ? 'Blockiert'
            : '${preview.conflictCount} Überschneidung'
                '${preview.conflictCount == 1 ? '' : 'en'}')
        : preview.snapLabel;

    return Row(
      children: <Widget>[
        SizedBox(
          width: layout.timeColumnWidth,
          child: Text(
            _clock(edgeTime),
            style: theme.timeStyle.copyWith(
              color: accent,
              fontSize: layout.timeFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: layout.axisColumnWidth,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: layout.isRegular ? 11 : 6,
              ),
            ),
          ),
        ),
        SizedBox(width: layout.columnGap),
        Expanded(
          child: CustomPaint(
            painter: _TimeRulePainter(color: accent),
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.isRegular ? 12 : 5,
                    vertical: layout.isRegular ? 7 : 2,
                  ),
                  child: Text(
                    '$edgeLabel · ${_compactDuration(duration)} · $status',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.metadataStyle.copyWith(
                      color: accent,
                      fontSize: layout.metadataFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: layout.statusColumnWidth),
      ],
    );
  }
}

class _TimeRulePainter extends CustomPainter {
  const _TimeRulePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 8.0;
    const gap = 6.0;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.58)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0.0, size.width).toDouble(), y),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TimeRulePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

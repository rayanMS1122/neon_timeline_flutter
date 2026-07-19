part of 'day_timeline_view.dart';

class _CompactDropTarget<T> extends StatefulWidget {
  const _CompactDropTarget({
    required this.windowStart,
    required this.windowEnd,
    required this.dayStart,
    required this.dayEnd,
    required this.snapInterval,
    required this.theme,
    required this.layout,
    required this.dragVisible,
    required this.isActive,
    required this.activeStart,
    required this.hasConflict,
    required this.labelBuilder,
    required this.onHover,
    required this.onLeave,
    required this.onAccept,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final DateTime dayStart;
  final DateTime dayEnd;
  final Duration snapInterval;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  final bool dragVisible;
  final bool isActive;
  final DateTime? activeStart;
  final bool hasConflict;
  final String Function(DateTime proposedStart, bool hasConflict)? labelBuilder;
  final void Function(_DayDragPayload<T> payload, DateTime proposedStart)
  onHover;
  final VoidCallback onLeave;
  final void Function(_DayDragPayload<T> payload, DateTime proposedStart)
  onAccept;

  @override
  State<_CompactDropTarget<T>> createState() =>
      _CompactDropTargetState<T>();
}

class _CompactDropTargetState<T> extends State<_CompactDropTarget<T>> {
  DateTime? _lastProposedStart;

  @override
  Widget build(BuildContext context) {
    final height = !widget.dragVisible
        ? 0.0
        : widget.isActive
        ? widget.layout.isRegular
            ? 64.0
            : 52.0
        : widget.layout.isRegular
        ? 24.0
        : 18.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      height: height,
      child: DragTarget<_DayDragPayload<T>>(
        onWillAcceptWithDetails: (_) => true,
        onMove: (details) {
          final proposed = _proposedStart(details.data, details.offset);
          _lastProposedStart = proposed;
          widget.onHover(details.data, proposed);
        },
        onLeave: (_) => widget.onLeave(),
        onAcceptWithDetails: (details) {
          final payload = details.data;
          final fallback = _lastProposedStart ??
              _defaultProposedStart(payload.snapshot.duration);
          widget.onAccept(payload, fallback);
        },
        builder: (context, candidates, rejected) {
          if (!widget.dragVisible) {
            return const SizedBox.shrink();
          }
          if (!widget.isActive) {
            return _CollapsedDropHint(
              theme: widget.theme,
              layout: widget.layout,
              visible: candidates.isNotEmpty,
            );
          }
          final start =
              widget.activeStart ?? _lastProposedStart ?? widget.windowStart;
          final label = widget.labelBuilder?.call(
                start,
                widget.hasConflict,
              ) ??
              (widget.hasConflict
                  ? 'Zeitraum belegt'
                  : 'Ziehen & hier ablegen');
          return _DropZoneSurface(
            theme: widget.theme,
            proposedStart: start,
            label: label,
            hasConflict: widget.hasConflict,
            layout: widget.layout,
          );
        },
      ),
    );
  }

  DateTime _proposedStart(
    _DayDragPayload<T> payload,
    Offset globalOffset,
  ) {
    final box = context.findRenderObject();
    final localY = box is RenderBox && box.hasSize
        ? box.globalToLocal(globalOffset).dy
        : 0.0;
    final height = box is RenderBox && box.hasSize ? box.size.height : 1.0;
    final fraction = (localY / height).clamp(0.0, 1.0);
    final duration = payload.snapshot.duration;
    final earliest = widget.windowStart.isBefore(widget.dayStart)
        ? widget.dayStart
        : widget.windowStart;
    final absoluteLatest = widget.dayEnd.subtract(duration);
    var latest = widget.windowEnd.subtract(duration);
    if (latest.isAfter(absoluteLatest)) {
      latest = absoluteLatest;
    }
    if (latest.isBefore(earliest)) {
      latest = earliest;
    }
    final span = latest.difference(earliest).inMicroseconds;
    final raw = earliest.add(
      Duration(microseconds: (span * fraction).round()),
    );
    final snapped = _snapDateTime(raw, widget.snapInterval, widget.dayStart);
    if (snapped.isBefore(earliest)) {
      return earliest;
    }
    if (snapped.isAfter(latest)) {
      return latest;
    }
    return snapped;
  }

  DateTime _defaultProposedStart(Duration duration) {
    final earliest = widget.windowStart.isBefore(widget.dayStart)
        ? widget.dayStart
        : widget.windowStart;
    final absoluteLatest = widget.dayEnd.subtract(duration);
    var latest = widget.windowEnd.subtract(duration);
    if (latest.isAfter(absoluteLatest)) {
      latest = absoluteLatest;
    }
    if (latest.isBefore(earliest)) {
      latest = earliest;
    }
    final snapped = _snapDateTime(latest, widget.snapInterval, widget.dayStart);
    if (snapped.isBefore(earliest)) {
      return earliest;
    }
    if (snapped.isAfter(latest)) {
      return latest;
    }
    return snapped;
  }
}

class _CollapsedDropHint extends StatelessWidget {
  const _CollapsedDropHint({
    required this.theme,
    required this.layout,
    required this.visible,
  });

  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: layout.timeColumnWidth),
        SizedBox(
          width: layout.axisColumnWidth,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.focusColor.withValues(alpha: visible ? 0.9 : 0.35),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 6),
            ),
          ),
        ),
        SizedBox(width: layout.columnGap),
        Expanded(
          child: Divider(
            color: theme.focusColor.withValues(alpha: visible ? 0.55 : 0.16),
            thickness: 1.2,
          ),
        ),
        SizedBox(width: layout.statusColumnWidth),
      ],
    );
  }
}

class _DropZoneSurface extends StatelessWidget {
  const _DropZoneSurface({
    required this.theme,
    required this.proposedStart,
    required this.label,
    required this.hasConflict,
    required this.layout,
  });

  final NeonPlannerTimelineThemeData theme;
  final DateTime proposedStart;
  final String label;
  final bool hasConflict;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final accent = hasConflict ? theme.errorColor : theme.focusColor;
    return Row(
      children: <Widget>[
        SizedBox(
          width: layout.timeColumnWidth,
          child: Text(
            _clock(proposedStart),
            style: theme.timeStyle.copyWith(
              fontSize: layout.timeFontSize,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: layout.axisColumnWidth,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: SizedBox(width: layout.isRegular ? 3 : 2),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.24),
                      blurRadius: layout.isRegular ? 12 : 4,
                    ),
                  ],
                ),
                child: SizedBox.square(
                  dimension: layout.isRegular ? 10 : 8,
                ),
              ),
              Positioned(
                right: layout.isRegular ? -5 : -3,
                bottom: layout.isRegular ? 2 : 1,
                child: Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: accent.withValues(alpha: 0.85),
                  size: layout.isRegular ? 31 : 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: layout.columnGap),
        Expanded(
          child: CustomPaint(
            painter: _DashedRoundedRectPainter(
              color: accent,
              compact: !layout.isRegular,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(
                  layout.isRegular ? 20 : 10,
                ),
              ),
              child: SizedBox(
                height: layout.isRegular ? 56 : layout.isCompact ? 38 : 34,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(
                        layout.isRegular ? 9 : 7,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: accent.withValues(alpha: 0.20),
                          blurRadius: layout.isRegular ? 12 : 4,
                          offset: Offset(0, layout.isRegular ? 4 : 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.isRegular ? 13 : 6,
                        vertical: layout.isRegular ? 7 : 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            hasConflict
                                ? Icons.warning_amber_rounded
                                : Icons.south_rounded,
                            color: Colors.white,
                            size: layout.isRegular ? 16 : 12,
                          ),
                          SizedBox(width: layout.isRegular ? 7 : 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: layout.isRegular ? 13 : 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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


class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({
    required this.color,
    required this.compact,
  });

  final Color color;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(1.2),
          Radius.circular(compact ? 10 : 20),
        ),
      );
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.2 : 2
      ..strokeCap = StrokeCap.round;
    final dash = compact ? 5.0 : 8.0;
    final gap = compact ? 4.0 : 6.0;
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            (distance + dash).clamp(0.0, metric.length).toDouble(),
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return color != oldDelegate.color || compact != oldDelegate.compact;
  }
}


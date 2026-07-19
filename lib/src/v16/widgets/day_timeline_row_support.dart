part of 'day_timeline_view.dart';

class _EntryRail extends StatelessWidget {
  const _EntryRail({
    required this.accent,
    required this.icon,
    required this.showTop,
    required this.showBottom,
    required this.theme,
    required this.layout,
    required this.overlapPresentation,
    required this.lane,
    required this.laneCount,
    required this.isCurrent,
    required this.isSelected,
  });

  final Color accent;
  final IconData icon;
  final bool showTop;
  final bool showBottom;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  final NeonPlannerOverlapPresentation overlapPresentation;
  final int lane;
  final int laneCount;
  final bool isCurrent;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final nodeSize = layout.nodeSize;
    final nodeTop = layout.isRegular ? 4.0 : 1.0;
    final useOffset = laneCount > 1 &&
        overlapPresentation == NeonPlannerOverlapPresentation.stacked;
    final centeredLane = lane - (laneCount - 1) / 2;
    final laneOffset = useOffset
        ? centeredLane * (layout.isRegular ? 10.0 : 4.0)
        : 0.0;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: showTop ? 0 : nodeTop + nodeSize / 2,
          bottom: showBottom ? 0 : null,
          height: showBottom ? null : nodeTop + nodeSize / 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isCurrent ? 0.95 : 0.72),
              borderRadius: BorderRadius.circular(99),
            ),
            child: SizedBox(
              width: layout.isRegular ? (isCurrent ? 4 : 3) : 2,
            ),
          ),
        ),
        if (useOffset)
          Positioned(
            top: nodeTop + (layout.isRegular ? 8 : 4),
            left: layout.isRegular ? 8 : 2,
            child: _LaneDots(
              activeLane: lane,
              laneCount: laneCount,
              accent: accent,
            ),
          ),
        Positioned(
          top: nodeTop,
          left: layout.axisColumnWidth / 2 - nodeSize / 2 + laneOffset,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accent.withValues(alpha: 0.86),
                  accent,
                ],
              ),
              border: Border.all(
                color: isCurrent || isSelected
                    ? theme.focusColor
                    : theme.surfaceColor,
                width: layout.isRegular
                    ? (isCurrent || isSelected ? 2.5 : 1.5)
                    : (isCurrent || isSelected ? 1.8 : 1.2),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(
                    alpha: isCurrent || isSelected ? 0.24 : 0.14,
                  ),
                  blurRadius: layout.isRegular ? 14 : 4,
                  offset: Offset(0, layout.isRegular ? 4 : 1),
                ),
              ],
            ),
            child: SizedBox.square(
              dimension: nodeSize,
              child: Icon(
                icon,
                color: Colors.white,
                size: layout.nodeIconSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LaneDots extends StatelessWidget {
  const _LaneDots({
    required this.activeLane,
    required this.laneCount,
    required this.accent,
  });

  final int activeLane;
  final int laneCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var index = 0; index < laneCount.clamp(0, 4).toInt(); index += 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: index == activeLane
                    ? accent
                    : accent.withValues(alpha: 0.24),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 4),
            ),
          ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.topColor, required this.bottomColor});

  final Color topColor;
  final Color bottomColor;

  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const gap = 6.0;
    var y = 0.0;
    while (y < size.height) {
      final t = size.height == 0 ? 0.0 : y / size.height;
      final color =
          Color.lerp(topColor, bottomColor, t)!.withValues(alpha: 0.75);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(
          size.width / 2,
          (y + dashHeight).clamp(0.0, size.height).toDouble(),
        ),
        paint,
      );
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return topColor != oldDelegate.topColor ||
        bottomColor != oldDelegate.bottomColor;
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.theme,
    this.fontSize = 12,
  });

  final String label;
  final NeonPlannerTimelineThemeData theme;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceColor.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: theme.gridColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize < 12 ? 6 : 9,
          vertical: fontSize < 12 ? 3 : 4,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.metadataStyle.copyWith(fontSize: fontSize, height: 1),
        ),
      ),
    );
  }
}

class _OverlapChip extends StatelessWidget {
  const _OverlapChip({
    required this.lane,
    required this.laneCount,
    required this.accent,
    required this.theme,
    this.compact = false,
    this.micro = false,
  });

  final int lane;
  final int laneCount;
  final Color accent;
  final NeonPlannerTimelineThemeData theme;
  final bool compact;
  final bool micro;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$laneCount parallele Termine',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: micro ? 3 : compact ? 4 : 7,
            vertical: compact ? 2 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!compact) ...<Widget>[
                Icon(Icons.layers_rounded, size: 12, color: accent),
                const SizedBox(width: 4),
              ],
              Text(
                micro ? '+${laneCount - 1}' : '${lane + 1}/$laneCount',
                style: theme.metadataStyle.copyWith(
                  color: accent,
                  fontSize: micro ? 8.5 : compact ? 9.5 : 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPill extends StatelessWidget {
  const _NowPill({
    required this.accent,
    required this.theme,
    this.compact = false,
  });

  final Color accent;
  final NeonPlannerTimelineThemeData theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
          vertical: compact ? 2 : 4,
        ),
        child: Text(
          'Jetzt',
          style: theme.metadataStyle.copyWith(
            color: accent,
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _StatusRing extends StatelessWidget {
  const _StatusRing({
    required this.accent,
    required this.value,
    required this.theme,
    this.size = 30,
  });

  final Color accent;
  final double? value;
  final NeonPlannerTimelineThemeData theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: value == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent,
                  width: size < 26 ? 2 : 2.3,
                ),
              ),
            )
          : CircularProgressIndicator(
              value: value!.clamp(0.0, 1.0).toDouble(),
              strokeWidth: size < 26 ? 2 : 2.5,
              backgroundColor: theme.gridColor,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
    );
  }
}

NeonPlannerCompressedGap _defaultGap<T>(
  Duration duration,
  int index,
  NeonPlannerEntrySnapshot<T> previous,
  NeonPlannerEntrySnapshot<T> next,
  NeonPlannerTimelineThemeData theme,
) {
  if (previous.presentation.kind == NeonPlannerEntryKind.sleep) {
    return NeonPlannerCompressedGap(
      title: 'Nachtruhe',
      icon: Icons.bedtime_rounded,
      color: theme.nightAccentColor,
    );
  }
  if (next.presentation.kind == NeonPlannerEntryKind.sleep) {
    return NeonPlannerCompressedGap(
      title: 'Abend & Reflexion',
      icon: Icons.auto_awesome_rounded,
      color: theme.warningColor,
    );
  }
  if (duration >= const Duration(hours: 3)) {
    return NeonPlannerCompressedGap(
      title: 'Fokuszeit',
      icon: Icons.center_focus_strong_rounded,
      color: theme.successColor,
    );
  }
  return NeonPlannerCompressedGap(
    title: 'Pause',
    icon: Icons.spa_outlined,
    color: theme.warningColor,
  );
}

Color _entryAccent<T>(
  NeonPlannerEntrySnapshot<T> snapshot,
  NeonPlannerTimelineThemeData theme,
) {
  final override = snapshot.presentation.accentColor;
  if (override != null) {
    return override;
  }
  return switch (snapshot.presentation.kind) {
    NeonPlannerEntryKind.sleep => theme.nightAccentColor,
    NeonPlannerEntryKind.focus => theme.successColor,
    NeonPlannerEntryKind.breakTime => theme.warningColor,
    _ => theme.dayAccentColor,
  };
}

IconData _metadataIcon(String metadata) {
  final lower = metadata.toLowerCase();
  if (lower.contains('reflekt')) {
    return Icons.bedtime_outlined;
  }
  if (lower.contains('erledigt') || lower.contains('genutzt')) {
    return Icons.check_circle_outline_rounded;
  }
  if (lower.contains('erinner')) {
    return Icons.schedule_rounded;
  }
  return Icons.notes_rounded;
}

String _clock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _timeRange(DateTime start, DateTime end) {
  return '${_clock(start)}–${_clock(end)}';
}

String _compactDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) {
    return '$minutes Min.';
  }
  return '${hours}h ${remainder.toString().padLeft(2, '0')}m';
}

String _germanDate(DateTime date) {
  const weekdays = <String>['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  const months = <String>[
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  final weekday = weekdays[date.weekday - 1];
  final day = date.day.toString().padLeft(2, '0');
  return '$weekday, $day. ${months[date.month - 1]} ${date.year}';
}

part of 'entry_tile.dart';

class _Node extends StatelessWidget {
  const _Node({
    required this.accent,
    required this.icon,
    required this.theme,
    required this.selected,
  });

  final Color accent;
  final IconData icon;
  final NeonPlannerTimelineThemeData theme;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.92),
            accent,
          ],
        ),
        border: Border.all(
          color: selected
              ? theme.surfaceColor
              : theme.surfaceColor.withValues(alpha: 0.88),
          width: selected ? 3 : 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _EntryCopy<T> extends StatelessWidget {
  const _EntryCopy({
    required this.snapshot,
    required this.theme,
    required this.compact,
    required this.micro,
    required this.hasConflict,
  });

  final NeonPlannerEntrySnapshot<T> snapshot;
  final NeonPlannerTimelineThemeData theme;
  final bool compact;
  final bool micro;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    final presentation = snapshot.presentation;
    if (micro) {
      return Text(
        '${_clock(snapshot.start)}  ${presentation.title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.titleStyle.copyWith(fontSize: 14),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _timeRange(snapshot.start, snapshot.end),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.timeStyle,
              ),
            ),
            const SizedBox(width: 8),
            _MetaPill(
              label: _durationLabel(snapshot.duration),
              color: theme.secondaryTextColor,
              background: theme.gridColor.withValues(alpha: 0.65),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          presentation.title,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.titleStyle,
        ),
        if (!compact && presentation.subtitle != null) ...<Widget>[
          const SizedBox(height: 5),
          Text(
            presentation.subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.metadataStyle.copyWith(
              color: theme.focusColor.withValues(alpha: 0.85),
            ),
          ),
        ],
        if (!compact && presentation.metadata != null) ...<Widget>[
          const SizedBox(height: 5),
          Text(
            presentation.metadata!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.metadataStyle,
          ),
        ],
        if (hasConflict) ...<Widget>[
          const SizedBox(height: 6),
          _MetaPill(
            label: 'Zeitkonflikt',
            color: theme.errorColor,
            background: theme.errorColor.withValues(alpha: 0.10),
          ),
        ],
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.09)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.value,
    required this.color,
    required this.background,
  });

  final double? value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final normalized = value?.clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: 28,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.4),
            ),
          ),
          if (normalized != null)
            Padding(
              padding: const EdgeInsets.all(1.2),
              child: CircularProgressIndicator(
                value: normalized,
                strokeWidth: 2.4,
                backgroundColor: background,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const SizedBox(width: 42, height: 4),
    );
  }
}

String _clock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _timeRange(DateTime start, DateTime end) {
  return '${_clock(start)}–${_clock(end)}';
}

String _durationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) {
    return '$minutes Min.';
  }
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '$hours Std.' : '$hours Std. $remainder Min.';
}

Color _kindColor(
  NeonPlannerEntryKind kind,
  NeonPlannerTimelineThemeData theme,
) {
  return switch (kind) {
    NeonPlannerEntryKind.sleep => theme.nightAccentColor,
    NeonPlannerEntryKind.breakTime => theme.warningColor,
    NeonPlannerEntryKind.focus => theme.successColor,
    _ => theme.dayAccentColor,
  };
}

double _nodeDiameter(double entryHeight, double radius) {
  final preferred = radius * 2;
  return entryHeight.clamp(44.0, preferred).toDouble();
}

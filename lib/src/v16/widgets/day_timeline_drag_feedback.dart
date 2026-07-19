part of 'day_timeline_view.dart';

class _CompactDragFeedback<T> extends StatelessWidget {
  const _CompactDragFeedback({
    required this.fallback,
    required this.preview,
    required this.theme,
    required this.accent,
    required this.width,
    required this.conflictPolicy,
    required this.layout,
  });

  final NeonPlannerEntrySnapshot<T> fallback;
  final ValueListenable<_DayDragPreview<T>?> preview;
  final NeonPlannerTimelineThemeData theme;
  final Color accent;
  final double width;
  final NeonPlannerConflictPolicy conflictPolicy;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_DayDragPreview<T>?>(
      valueListenable: preview,
      builder: (context, value, child) {
        final current = value ??
            _DayDragPreview<T>(
              snapshot: fallback,
              proposedStart: fallback.start,
              proposedEnd: fallback.end,
              hasConflict: false,
              conflictCount: 0,
              snapLabel: 'Zeit frei verschieben',
              viewportY: null,
              feedbackCorrection: Offset.zero,
            );
        final conflictBlocked = current.hasConflict &&
            conflictPolicy == NeonPlannerConflictPolicy.block;
        final currentAccent = current.hasConflict
            ? (conflictBlocked ? theme.errorColor : theme.warningColor)
            : accent;
        final status = current.hasConflict
            ? conflictBlocked
                ? 'Blockiert'
                : current.conflictCount == 1
                ? '1 Überschneidung'
                : '${current.conflictCount} Überschneidungen'
            : 'Frei';
        final nodeSize =
            layout.isRegular ? 40.0 : layout.isCompact ? 26.0 : 24.0;

        return Transform.translate(
          offset: current.feedbackCorrection,
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              key: const ValueKey<String>('neon-drag-feedback'),
              width: width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withValues(alpha: 0.99),
                  borderRadius: BorderRadius.circular(
                    layout.isRegular ? 18 : 10,
                  ),
                  border: Border.all(
                    color: currentAccent.withValues(alpha: 0.22),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.56),
                      blurRadius: layout.isRegular ? 14 : 5,
                      offset: Offset(0, layout.isRegular ? 6 : 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.isRegular ? 11 : 6,
                    vertical: layout.isRegular ? 9 : 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentAccent,
                          border: Border.all(
                            color: theme.surfaceColor,
                            width: layout.isRegular ? 2 : 1.2,
                          ),
                        ),
                        child: SizedBox.square(
                          dimension: nodeSize,
                          child: Icon(
                            current.snapshot.presentation.icon,
                            color: Colors.white,
                            size: layout.isRegular ? 20 : layout.isCompact ? 14 : 13,
                          ),
                        ),
                      ),
                      SizedBox(width: layout.isRegular ? 9 : 5),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${_timeRange(
                                current.proposedStart,
                                current.proposedEnd,
                              )} · '
                              '${_compactDuration(current.snapshot.duration)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.timeStyle.copyWith(
                                color: currentAccent,
                                fontSize: layout.isRegular
                                    ? 12.5
                                    : layout.isCompact
                                    ? 10.5
                                    : 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: layout.isRegular ? 4 : 1),
                            Text(
                              current.snapshot.presentation.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.titleStyle.copyWith(
                                fontSize: layout.isRegular
                                    ? 15.5
                                    : layout.isCompact
                                    ? 13
                                    : 12.5,
                                height: 1.12,
                              ),
                            ),
                            SizedBox(height: layout.isRegular ? 4 : 1),
                            Row(
                              children: <Widget>[
                                Icon(
                                  current.hasConflict
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: layout.isRegular ? 14 : 10,
                                  color: currentAccent,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    status,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.metadataStyle.copyWith(
                                      color: currentAccent,
                                      fontSize: layout.isRegular
                                          ? 11.5
                                          : layout.isCompact
                                          ? 9.5
                                          : 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

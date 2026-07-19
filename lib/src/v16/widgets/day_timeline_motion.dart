// ignore_for_file: invalid_use_of_protected_member
part of 'day_timeline_view.dart';

extension _DayTimelineMotion<T> on _NeonPlannerDayTimelineState<T> {
  void _freezeInteractionLayout(
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    final frozen = List<NeonPlannerEntrySnapshot<T>>.unmodifiable(snapshots);
    _frozenSnapshots = frozen;
    _frozenLayoutMetrics = _layoutMetrics;
    _frozenPlacements = Map<Object,
        NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>.unmodifiable(
      _DayTimelineModel<T>(this)._overlapPlacements(frozen),
    );
    _interactionConflictIndex =
        NeonPlannerIntervalIndex<_DayIndexedSnapshot<T>>(
      frozen.map(_DayIndexedSnapshot<T>.new),
    );
  }

  void _releaseInteractionLayout() {
    _frozenSnapshots = null;
    _frozenLayoutMetrics = null;
    _frozenPlacements = null;
    _interactionConflictIndex = null;
  }

  void _queueInteractionUpdate(Offset globalPosition) {
    if (!mounted) {
      return;
    }
    _pendingInteractionGlobalPosition = globalPosition;
    _lastDragGlobalPosition = globalPosition;
    _DayTimelineDrag<T>(this)._updateAutoScroll(globalPosition);
    if (_interactionFrameScheduled) {
      return;
    }
    _interactionFrameScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _interactionFrameScheduled = false;
      _processPendingInteractionUpdate();
    });
  }

  void _flushInteractionUpdate() {
    _processPendingInteractionUpdate();
  }

  void _processPendingInteractionUpdate() {
    if (!mounted) {
      _pendingInteractionGlobalPosition = null;
      return;
    }
    final globalPosition = _pendingInteractionGlobalPosition;
    _pendingInteractionGlobalPosition = null;
    if (globalPosition == null) {
      return;
    }
    if (_resizingId != null) {
      _DayTimelineResize<T>(this)._updateResizeProposal(globalPosition);
    } else if (_draggingId != null) {
      if (widget.dragMode == NeonPlannerDayDragMode.slots) {
        _DayTimelineDrag<T>(this)._updateFeedbackCorrection(globalPosition);
      } else {
        _DayTimelineDrag<T>(this)._updateTimeProposal(globalPosition);
      }
    }
  }

  void _showCommittedMove(
    NeonPlannerMoveProposal<T> proposal, {
    required String message,
    double? viewportY,
  }) {
    _showCommitVisual(
      snapshot: proposal.entry,
      start: proposal.proposedStart,
      end: proposal.proposedEnd,
      message: message,
      viewportY: viewportY,
      resized: false,
    );
  }

  void _showCommittedResize(
    NeonPlannerResizeProposal<T> proposal, {
    required String message,
    double? viewportY,
  }) {
    _showCommitVisual(
      snapshot: proposal.entry,
      start: proposal.proposedStart,
      end: proposal.proposedEnd,
      message: message,
      viewportY: viewportY,
      resized: true,
    );
  }

  void _showCommitVisual({
    required NeonPlannerEntrySnapshot<T> snapshot,
    required DateTime start,
    required DateTime end,
    required String message,
    required bool resized,
    double? viewportY,
  }) {
    _commitVisualTimer?.cancel();
    _recentlyMovedTimer?.cancel();
    _commitVisualSequence += 1;
    final showConfirmation = resized
        ? widget.showResizeConfirmation
        : widget.showMoveConfirmation;
    if (showConfirmation &&
        widget.moveConfirmationDuration > Duration.zero) {
      _commitVisual.value = _DayCommitVisual<T>(
        sequence: _commitVisualSequence,
        snapshot: snapshot,
        start: start,
        end: end,
        message: message,
        viewportY: viewportY,
        resized: resized,
        visibleDuration: widget.moveConfirmationDuration,
      );
      _commitVisualTimer = Timer(widget.moveConfirmationDuration, () {
        if (mounted) {
          _commitVisual.value = null;
        }
      });
    }

    if (widget.animateCommittedMove &&
        widget.settleAnimationDuration > Duration.zero &&
        mounted) {
      setState(() => _recentlyMovedId = snapshot.id);
      _recentlyMovedTimer = Timer(widget.settleAnimationDuration, () {
        if (mounted && _recentlyMovedId == snapshot.id) {
          setState(() => _recentlyMovedId = null);
        }
      });
    }
  }
}

@immutable
class _DayCommitVisual<T> {
  const _DayCommitVisual({
    required this.sequence,
    required this.snapshot,
    required this.start,
    required this.end,
    required this.message,
    required this.viewportY,
    required this.resized,
    required this.visibleDuration,
  });

  final int sequence;
  final NeonPlannerEntrySnapshot<T> snapshot;
  final DateTime start;
  final DateTime end;
  final String message;
  final double? viewportY;
  final bool resized;
  final Duration visibleDuration;
}

class _MoveCommitOverlay<T> extends StatefulWidget {
  const _MoveCommitOverlay({
    required this.visual,
    required this.theme,
    required this.layout,
    super.key,
  });

  final _DayCommitVisual<T> visual;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;

  @override
  State<_MoveCommitOverlay<T>> createState() =>
      _MoveCommitOverlayState<T>();
}

class _MoveCommitOverlayState<T> extends State<_MoveCommitOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _reverseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scale = Tween<double>(begin: 0.98, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
    final delay = widget.visual.visibleDuration -
        const Duration(milliseconds: 190);
    if (delay > Duration.zero) {
      _reverseTimer = Timer(delay, () {
        if (mounted) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.visual.resized
        ? widget.theme.successColor
        : widget.theme.focusColor;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return FadeTransition(
      opacity: reducedMotion
          ? const AlwaysStoppedAnimation<double>(1)
          : _opacity,
      child: SlideTransition(
        position: reducedMotion
            ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
            : _slide,
        child: ScaleTransition(
          scale: reducedMotion
              ? const AlwaysStoppedAnimation<double>(1)
              : _scale,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.layout.feedbackMaxWidth,
              ),
              child: DecoratedBox(
                key: const ValueKey<String>('neon-move-confirmation'),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceColor.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(
                    widget.layout.isRegular ? 20 : 12,
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.theme.shadowColor.withValues(alpha: 0.72),
                      blurRadius: widget.layout.isRegular ? 18 : 7,
                      offset: Offset(0, widget.layout.isRegular ? 8 : 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.layout.isRegular ? 14 : 8,
                    vertical: widget.layout.isRegular ? 11 : 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox.square(
                          dimension: widget.layout.isRegular ? 36 : 24,
                          child: Icon(
                            widget.visual.resized
                                ? Icons.height_rounded
                                : Icons.check_rounded,
                            color: accent,
                            size: widget.layout.isRegular ? 21 : 14,
                          ),
                        ),
                      ),
                      SizedBox(width: widget.layout.isRegular ? 11 : 7),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.visual.message.isEmpty
                                  ? widget.visual.resized
                                      ? 'Dauer geändert'
                                      : 'Termin verschoben'
                                  : widget.visual.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.theme.metadataStyle.copyWith(
                                color: accent,
                                fontSize: widget.layout.metadataFontSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: widget.layout.isRegular ? 2 : 1),
                            Text(
                              '${_timeRange(
                                widget.visual.start,
                                widget.visual.end,
                              )} · '
                              '${widget.visual.snapshot.presentation.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.theme.metadataStyle.copyWith(
                                color: widget.theme.primaryTextColor,
                                fontSize: widget.layout.metadataFontSize,
                                fontWeight: FontWeight.w600,
                              ),
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
        ),
      ),
    );
  }
}

class _AdaptiveTimeLens extends StatelessWidget {
  const _AdaptiveTimeLens({
    required this.center,
    required this.interval,
    required this.theme,
    required this.hasConflict,
    required this.blocked,
    required this.markCount,
    required this.labelOnly,
  });

  final DateTime center;
  final Duration interval;
  final NeonPlannerTimelineThemeData theme;
  final bool hasConflict;
  final bool blocked;
  final int markCount;
  final bool labelOnly;

  @override
  Widget build(BuildContext context) {
    final accent = hasConflict
        ? (blocked ? theme.errorColor : theme.warningColor)
        : theme.focusColor;
    if (labelOnly) {
      return DecoratedBox(
        key: const ValueKey<String>('neon-adaptive-time-lens'),
        decoration: BoxDecoration(
          color: theme.surfaceColor.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.28),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _clock(center),
            style: theme.timeStyle.copyWith(
              color: accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final step = interval <= Duration.zero
        ? const Duration(minutes: 5)
        : interval;
    final safeCount = markCount.isOdd ? markCount : markCount + 1;
    final middle = safeCount ~/ 2;
    return DecoratedBox(
      key: const ValueKey<String>('neon-adaptive-time-lens'),
      decoration: BoxDecoration(
        color: theme.surfaceColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(safeCount, (index) {
            final delta = index - middle;
            final time = center.add(
              Duration(microseconds: step.inMicroseconds * delta),
            );
            final active = delta == 0;
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 42,
                  child: Text(
                    _clock(time),
                    textAlign: TextAlign.right,
                    style: theme.timeStyle.copyWith(
                      color: active ? accent : theme.secondaryTextColor,
                      fontSize: active ? 12 : 10,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: active ? 2.2 : 1,
                    decoration: BoxDecoration(
                      color: active
                          ? accent
                          : theme.gridColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: active ? accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: active
                        ? null
                        : Border.all(color: theme.gridColor, width: 1),
                  ),
                  child: SizedBox.square(dimension: active ? 7 : 4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SettledEntryPulse extends StatefulWidget {
  const _SettledEntryPulse({
    required this.child,
    required this.duration,
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  State<_SettledEntryPulse> createState() => _SettledEntryPulseState();
}

class _SettledEntryPulseState extends State<_SettledEntryPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
    _scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 1.018)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 48,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.018, end: 1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 52,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return ScaleTransition(
      scale: _scale,
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}

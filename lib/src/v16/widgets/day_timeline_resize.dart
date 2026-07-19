// ignore_for_file: invalid_use_of_protected_member
part of 'day_timeline_view.dart';

extension _DayTimelineResize<T> on _NeonPlannerDayTimelineState<T> {
  List<Widget> _buildResizeHandles(
    NeonPlannerEntrySnapshot<T> snapshot,
    NeonPlannerTimelineThemeData theme,
    Color accent,
    _DayLayoutMetrics layout,
  ) {
    Widget handle(NeonPlannerResizeEdge edge) {
      final isStart = edge == NeonPlannerResizeEdge.start;
      return Positioned(
        left: layout.timelineLeadingWidth + layout.columnGap,
        right: layout.statusColumnWidth,
        top: isStart ? -10 : null,
        bottom: isStart ? null : -10,
        height: 48,
        child: MouseRegion(
          cursor: isStart
              ? SystemMouseCursors.resizeUp
              : SystemMouseCursors.resizeDown,
          child: GestureDetector(
            key: ValueKey<String>(
              'neon-resize-${isStart ? 'start' : 'end'}-${snapshot.id}',
            ),
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) => _beginResize(
              snapshot,
              edge,
              details.globalPosition,
            ),
            onPanUpdate: (details) {
              _DayTimelineMotion<T>(this)._queueInteractionUpdate(
                details.globalPosition,
              );
            },
            onPanEnd: (_) => unawaited(_endResize()),
            onPanCancel: _finishResize,
            child: Align(
              alignment: isStart
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.65),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.10),
                      blurRadius: layout.isRegular ? 5 : 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.isRegular ? 6 : 4,
                    vertical: layout.isRegular ? 2 : 1.5,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: SizedBox(
                      width: layout.isRegular ? 24 : 20,
                      height: layout.isRegular ? 2.5 : 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return <Widget>[
      handle(NeonPlannerResizeEdge.start),
      handle(NeonPlannerResizeEdge.end),
    ];
  }

  void _beginResize(
    NeonPlannerEntrySnapshot<T> snapshot,
    NeonPlannerResizeEdge edge,
    Offset globalPosition,
  ) {
    HapticFeedback.mediumImpact();
    _DayTimelineDrag<T>(this)._stopAutoScroll();
    _latchedSnap = null;
    _resizeSnapshots = _snapshotsForDay();
    _DayTimelineMotion<T>(this)._freezeInteractionLayout(_resizeSnapshots);
    _resizeOriginal = snapshot;
    _activeResizeEdge = edge;
    _resizeAnchorGlobalY = globalPosition.dy;
    _resizeAnchorScrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;
    _lastDragGlobalPosition = globalPosition;
    _lastHapticSnapToken = null;
    setState(() {
      _selectedId = snapshot.id;
      _resizingId = snapshot.id;
    });
    _resizePreview.value = _DayResizePreview<T>(
      snapshot: snapshot,
      edge: edge,
      proposedStart: snapshot.start,
      proposedEnd: snapshot.end,
      hasConflict: false,
      conflictCount: 0,
      snapLabel: '${widget.snapInterval.inMinutes}-Minuten-Raster',
      viewportY: null,
    );
  }

  void _updateResizeProposal(Offset globalPosition) {
    final original = _resizeOriginal;
    final edge = _activeResizeEdge;
    final current = _resizePreview.value;
    if (original == null || edge == null || current == null) {
      return;
    }
    final renderObject = _listKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }
    final anchorY = _resizeAnchorGlobalY ?? globalPosition.dy;
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;
    final deltaPixels = globalPosition.dy - anchorY +
        (scrollOffset - _resizeAnchorScrollOffset);
    final deltaMinutes = deltaPixels * widget.dragMinutesPerPixel;
    final delta = Duration(
      microseconds:
          (deltaMinutes * const Duration(minutes: 1).inMicroseconds).round(),
    );

    final rawEdge = edge == NeonPlannerResizeEdge.start
        ? original.start.add(delta)
        : original.end.add(delta);
    final snap = _DayTimelineSnap<T>(this)._resolveEdgeSnap(
      rawEdge,
      original,
      edge,
      _resizeSnapshots,
    );
    final proposedStart = edge == NeonPlannerResizeEdge.start
        ? snap.time
        : original.start;
    final proposedEnd = edge == NeonPlannerResizeEdge.end
        ? snap.time
        : original.end;
    final conflicts = _DayTimelineSnap<T>(this)._conflicts(
      original.id,
      proposedStart,
      proposedEnd,
      _resizeSnapshots,
    );
    final layout = _layoutMetrics;
    final lensInset = layout != null && _showTimeLens(layout)
        ? layout.timeLensVerticalInset
        : 24.0;
    final maximumY = (renderObject.size.height - lensInset)
        .clamp(lensInset, renderObject.size.height)
        .toDouble();
    final localY = renderObject
        .globalToLocal(globalPosition)
        .dy
        .clamp(lensInset, maximumY)
        .toDouble();

    final hapticToken = snap.kind == _DaySnapKind.grid
        ? null
        : '${snap.kind.name}:${snap.anchorId}:'
            '${snap.time.microsecondsSinceEpoch}';
    if (hapticToken != null && hapticToken != _lastHapticSnapToken) {
      HapticFeedback.selectionClick();
    }
    _lastHapticSnapToken = hapticToken;
    _resizePreview.value = _DayResizePreview<T>(
      snapshot: original,
      edge: edge,
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
      hasConflict: conflicts.hasConflict,
      conflictCount: conflicts.count,
      snapLabel: snap.label,
      viewportY: localY,
    );
  }

  Future<void> _endResize() async {
    _DayTimelineMotion<T>(this)._flushInteractionUpdate();
    final preview = _resizePreview.value;
    final snapshots = List<NeonPlannerEntrySnapshot<T>>.of(_resizeSnapshots);
    _finishResize();
    if (preview == null) {
      return;
    }
    if (preview.proposedStart == preview.snapshot.start &&
        preview.proposedEnd == preview.snapshot.end) {
      return;
    }
    await _commitResize(preview, snapshots);
  }

  void _finishResize() {
    _DayTimelineDrag<T>(this)._stopAutoScroll();
    if (mounted) {
      setState(() => _resizingId = null);
    }
    _resizeSnapshots = <NeonPlannerEntrySnapshot<T>>[];
    _resizeOriginal = null;
    _activeResizeEdge = null;
    _resizeAnchorGlobalY = null;
    _resizeAnchorScrollOffset = 0;
    _lastDragGlobalPosition = null;
    _pendingInteractionGlobalPosition = null;
    _latchedSnap = null;
    _lastHapticSnapToken = null;
    _resizePreview.value = null;
    _DayTimelineMotion<T>(this)._releaseInteractionLayout();
  }


  Future<void> _keyboardResize(
    NeonPlannerEntrySnapshot<T> snapshot,
    int direction, {
    required bool fast,
  }) async {
    final callback = widget.onEntryResize;
    if (callback == null || direction == 0) {
      return;
    }
    final multiplier = fast ? widget.keyboardFastStepMultiplier : 1;
    final delta = Duration(
      microseconds: widget.snapInterval.inMicroseconds * direction * multiplier,
    );
    final rawEnd = snapshot.end.add(delta);
    final snap = _DayTimelineSnap<T>(this)._resolveEdgeSnap(
      rawEnd,
      snapshot,
      NeonPlannerResizeEdge.end,
      _snapshotsForDay(),
    );
    final preview = _DayResizePreview<T>(
      snapshot: snapshot,
      edge: NeonPlannerResizeEdge.end,
      proposedStart: snapshot.start,
      proposedEnd: snap.time,
      hasConflict: false,
      conflictCount: 0,
      snapLabel: snap.label,
      viewportY: null,
    );
    await _commitResize(preview, _snapshotsForDay());
  }

  Future<void> _commitResize(
    _DayResizePreview<T> preview,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) async {
    if (_committing) {
      return;
    }
    final conflicts = _DayTimelineSnap<T>(this)._conflicts(
      preview.snapshot.id,
      preview.proposedStart,
      preview.proposedEnd,
      snapshots,
    );
    if (widget.conflictPolicy == NeonPlannerConflictPolicy.block &&
        conflicts.hasConflict) {
      HapticFeedback.heavyImpact();
      widget.onFeedback?.call(
        conflicts.count == 1
            ? 'Die neue Dauer überschneidet einen Termin.'
            : 'Die neue Dauer überschneidet ${conflicts.count} Termine.',
      );
      return;
    }

    final callback = widget.onEntryResize;
    if (callback == null) {
      return;
    }
    final proposal = NeonPlannerResizeProposal<T>(
      entry: preview.snapshot,
      edge: preview.edge,
      originalStart: preview.snapshot.start,
      originalEnd: preview.snapshot.end,
      proposedStart: preview.proposedStart,
      proposedEnd: preview.proposedEnd,
      hasConflict: conflicts.hasConflict,
    );

    _committing = true;
    try {
      final result = await Future<NeonPlannerMutationResult>.sync(
        () => callback(proposal),
      );
      if (result.accepted) {
        HapticFeedback.lightImpact();
        _DayTimelineMotion<T>(this)._showCommittedResize(
          proposal,
          message: result.message ??
              'Dauer auf '
              '${_compactDuration(
                proposal.proposedEnd.difference(proposal.proposedStart),
              )} '
              'geändert.',
          viewportY: preview.viewportY,
        );
      } else {
        HapticFeedback.heavyImpact();
      }
      if (result.message != null) {
        widget.onFeedback?.call(result.message!);
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      widget.onFeedback?.call('Daueränderung fehlgeschlagen: $error');
    } finally {
      _committing = false;
    }
  }
}

@immutable
class _DayResizePreview<T> {
  const _DayResizePreview({
    required this.snapshot,
    required this.edge,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
    required this.conflictCount,
    required this.snapLabel,
    required this.viewportY,
  });

  final NeonPlannerEntrySnapshot<T> snapshot;
  final NeonPlannerResizeEdge edge;
  final DateTime proposedStart;
  final DateTime proposedEnd;
  final bool hasConflict;
  final int conflictCount;
  final String snapLabel;
  final double? viewportY;
}

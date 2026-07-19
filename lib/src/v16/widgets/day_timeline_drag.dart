// ignore_for_file: invalid_use_of_protected_member
part of 'day_timeline_view.dart';

extension _DayTimelineDrag<T> on _NeonPlannerDayTimelineState<T> {
  Widget _buildDraggableEntry({
    required NeonPlannerEntrySnapshot<T> snapshot,
    required NeonPlannerTimelineThemeData theme,
    required Color accent,
    required bool isFirst,
    required bool isLast,
    required bool isCurrent,
    required int lane,
    required int laneCount,
    required _DayLayoutMetrics layout,
  }) {
    _CompactEntryRow<T> row({required bool dragging}) => _CompactEntryRow<T>(
      key: ValueKey<Object>(snapshot.id),
      snapshot: snapshot,
      theme: theme,
      accent: accent,
      isFirst: isFirst,
      isLast: isLast,
      isCurrent: isCurrent,
      isDragging: dragging || _resizingId == snapshot.id,
      isSelected: _selectedId == snapshot.id,
      isRecentlyMoved: _recentlyMovedId == snapshot.id,
      settleAnimationDuration: widget.settleAnimationDuration,
      showDragHandle: _dragEnabled &&
          widget.dragActivation == NeonPlannerDragActivation.handleOnly,
      timeLabel: widget.entryTimeLabelBuilder?.call(
            snapshot.data,
            snapshot.start,
          ) ??
          _clock(snapshot.start),
      durationLabel: widget.entryDurationLabelBuilder?.call(
            snapshot.data,
            snapshot.duration,
          ) ??
          _compactDuration(snapshot.duration),
      overlapPresentation: widget.overlapPresentation,
      lane: lane,
      laneCount: laneCount,
      layout: layout,
      keyboardEnabled: widget.enableKeyboardMovement &&
          widget.onEntryMove != null,
      onTap: () {
        setState(() => _selectedId = snapshot.id);
        widget.onEntryTap?.call(snapshot.data);
      },
      onStatusTap: widget.onEntryStatusTap == null
          ? null
          : () => widget.onEntryStatusTap!(snapshot.data),
      onTimeEdit: widget.onEntryTimeEdit == null
          ? null
          : () => widget.onEntryTimeEdit!(snapshot.data),
      onKeyboardMove: (direction, fast) => unawaited(
        _keyboardMove(snapshot, direction, fast: fast),
      ),
      onKeyboardResize: _resizeEnabled
          ? (direction, fast) => unawaited(
                _DayTimelineResize<T>(this)._keyboardResize(
                  snapshot,
                  direction,
                  fast: fast,
                ),
              )
          : null,
    );

    final base = row(
      dragging: _draggingId == snapshot.id || _resizingId == snapshot.id,
    );

    Widget movable = base;
    if (_dragEnabled && snapshot.presentation.isEnabled) {
      final payload = _DayDragPayload<T>(snapshot);
      final feedback = _CompactDragFeedback<T>(
        fallback: snapshot,
        preview: _dragPreview,
        theme: theme,
        accent: accent,
        width: layout.feedbackWidth,
        conflictPolicy: widget.conflictPolicy,
        layout: layout,
      );
      final childWhenDragging = row(dragging: true);
      final semanticsLabel =
          'Termin verschieben: ${snapshot.presentation.title}';
      final semanticsHint = widget.dragMode == NeonPlannerDayDragMode.slots
          ? 'Lange drücken und zu einem Ablagebereich ziehen.'
          : 'Lange drücken und frei ziehen. Die vertikale Bewegung '
              'ändert die Uhrzeit.';

      Widget draggable;
      if (widget.dragActivation == NeonPlannerDragActivation.immediate) {
        draggable = Draggable<_DayDragPayload<T>>(
          data: payload,
          rootOverlay: true,
          dragAnchorStrategy: (_, context, position) =>
              _boundedFeedbackAnchor(context, position, layout),
          feedback: feedback,
          childWhenDragging: childWhenDragging,
          onDragStarted: () => _beginDrag(snapshot),
          onDragUpdate: _handleDragUpdate,
          onDragEnd: (details) => unawaited(
            _handleDragEnd(payload, wasAccepted: details.wasAccepted),
          ),
          child: base,
        );
      } else {
        draggable = LongPressDraggable<_DayDragPayload<T>>(
          data: payload,
          rootOverlay: true,
          dragAnchorStrategy: (_, context, position) =>
              _boundedFeedbackAnchor(context, position, layout),
          delay: const Duration(milliseconds: 240),
          hapticFeedbackOnStart: false,
          feedback: feedback,
          childWhenDragging: childWhenDragging,
          onDragStarted: () => _beginDrag(snapshot),
          onDragUpdate: _handleDragUpdate,
          onDragEnd: (details) => unawaited(
            _handleDragEnd(payload, wasAccepted: details.wasAccepted),
          ),
          child: base,
        );
      }

      movable = Listener(
        onPointerDown: (event) => _pendingDragAnchorGlobalY = event.position.dy,
        child: Semantics(
          label: semanticsLabel,
          hint: semanticsHint,
          child: draggable,
        ),
      );
    }

    final showResize = _resizeEnabled &&
        snapshot.presentation.isEnabled &&
        _selectedId == snapshot.id &&
        _draggingId == null;
    if (!showResize) {
      return movable;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        movable,
        ..._DayTimelineResize<T>(this)._buildResizeHandles(
          snapshot,
          theme,
          accent,
          layout,
        ),
      ],
    );
  }

  Widget _buildDropTarget({
    required Object slotId,
    required DateTime windowStart,
    required DateTime windowEnd,
    required List<NeonPlannerEntrySnapshot<T>> snapshots,
    required NeonPlannerTimelineThemeData theme,
    required _DayLayoutMetrics layout,
  }) {
    return _CompactDropTarget<T>(
      windowStart: windowStart,
      windowEnd: windowEnd,
      dayStart: _dayStart,
      dayEnd: _dayEnd,
      snapInterval: widget.snapInterval,
      theme: theme,
      layout: layout,
      dragVisible: _draggingId != null,
      isActive: _activeDropSlot == slotId,
      activeStart: _activeDropSlot == slotId ? _activeDropStart : null,
      hasConflict: _activeDropSlot == slotId && _activeDropConflict,
      labelBuilder: widget.dropZoneLabelBuilder,
      onHover: (payload, proposedStart) => _setDropTarget(
        slotId,
        payload,
        proposedStart,
        snapshots,
      ),
      onLeave: () {
        if (_activeDropSlot == slotId && mounted) {
          setState(() => _activeDropSlot = null);
        }
      },
      onAccept: (payload, proposedStart) {
        _dropAccepted = true;
        unawaited(_acceptDrop(payload, proposedStart, snapshots));
      },
    );
  }

  void _beginDrag(NeonPlannerEntrySnapshot<T> snapshot) {
    HapticFeedback.mediumImpact();
    _dragSnapshots = _snapshotsForDay();
    _DayTimelineMotion<T>(this)._freezeInteractionLayout(_dragSnapshots);
    _dropAccepted = false;
    _latchedSnap = null;
    _lastHapticSnapToken = null;
    _dragAnchorGlobalY = _pendingDragAnchorGlobalY;
    _dragAnchorScrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;
    _lastDragGlobalPosition = null;
    setState(() {
      _selectedId = snapshot.id;
      _draggingId = snapshot.id;
      _activeDropSlot = null;
      _activeDropStart = snapshot.start;
      _activeDropConflict = false;
    });
    _dragPreview.value = _DayDragPreview<T>(
      snapshot: snapshot,
      proposedStart: snapshot.start,
      proposedEnd: snapshot.end,
      hasConflict: false,
      conflictCount: 0,
      snapLabel: '${widget.snapInterval.inMinutes}-Minuten-Raster',
      viewportY: null,
      feedbackCorrection: Offset.zero,
    );
  }

  void _finishDrag() {
    if (!mounted) {
      return;
    }
    _stopAutoScroll();
    setState(() {
      _draggingId = null;
      _activeDropSlot = null;
      _activeDropStart = null;
      _activeDropConflict = false;
    });
    _dropAccepted = false;
    _pendingDragAnchorGlobalY = null;
    _dragAnchorGlobalY = null;
    _dragAnchorScrollOffset = 0;
    _lastDragGlobalPosition = null;
    _dragSnapshots = <NeonPlannerEntrySnapshot<T>>[];
    _pendingInteractionGlobalPosition = null;
    _latchedSnap = null;
    _lastHapticSnapToken = null;
    _dragFeedbackGeometry = null;
    _dragPreview.value = null;
    _DayTimelineMotion<T>(this)._releaseInteractionLayout();
  }

  Future<void> _handleDragEnd(
    _DayDragPayload<T> payload, {
    required bool wasAccepted,
  }) async {
    _DayTimelineMotion<T>(this)._flushInteractionUpdate();
    final preview = _dragPreview.value;
    final snapshots = List<NeonPlannerEntrySnapshot<T>>.of(_dragSnapshots);
    final shouldCommitTime =
        widget.dragMode == NeonPlannerDayDragMode.time ||
        (widget.dragMode == NeonPlannerDayDragMode.hybrid &&
            !wasAccepted &&
            !_dropAccepted);
    _finishDrag();

    if (!shouldCommitTime || preview == null) {
      return;
    }
    if (preview.proposedStart == payload.snapshot.start) {
      return;
    }
    await _commitMove(
      payload,
      preview.proposedStart,
      snapshots,
      viewportY: preview.viewportY,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _DayTimelineMotion<T>(this)._queueInteractionUpdate(
      details.globalPosition,
    );
  }

  void _updateFeedbackCorrection(Offset globalPosition) {
    final current = _dragPreview.value;
    final geometry = _dragFeedbackGeometry;
    if (current == null || geometry == null) {
      return;
    }
    final correction = geometry.correctionFor(globalPosition);
    if (correction == current.feedbackCorrection) {
      return;
    }
    _dragPreview.value = _DayDragPreview<T>(
      snapshot: current.snapshot,
      proposedStart: current.proposedStart,
      proposedEnd: current.proposedEnd,
      hasConflict: current.hasConflict,
      conflictCount: current.conflictCount,
      snapLabel: current.snapLabel,
      viewportY: current.viewportY,
      feedbackCorrection: correction,
    );
  }

  void _updateTimeProposal(Offset globalPosition) {
    final current = _dragPreview.value;
    if (current == null) {
      return;
    }
    final renderObject = _listKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }
    final anchorY = _dragAnchorGlobalY ?? globalPosition.dy;
    _dragAnchorGlobalY ??= anchorY;
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;
    final deltaPixels = globalPosition.dy - anchorY +
        (scrollOffset - _dragAnchorScrollOffset);
    final deltaMinutes = deltaPixels * widget.dragMinutesPerPixel;
    final raw = current.snapshot.start.add(
      Duration(
        microseconds:
            (deltaMinutes * const Duration(minutes: 1).inMicroseconds).round(),
      ),
    );
    final snap = _DayTimelineSnap<T>(this)
        ._resolveMoveSnap(raw, current.snapshot, _dragSnapshots);
    final proposedEnd = snap.time.add(current.snapshot.duration);
    final conflicts = _DayTimelineSnap<T>(this)._conflicts(
      current.snapshot.id,
      snap.time,
      proposedEnd,
      _dragSnapshots,
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
    _activeDropStart = snap.time;
    _activeDropConflict = conflicts.hasConflict;
    _dragPreview.value = _DayDragPreview<T>(
      snapshot: current.snapshot,
      proposedStart: snap.time,
      proposedEnd: proposedEnd,
      hasConflict: conflicts.hasConflict,
      conflictCount: conflicts.count,
      snapLabel: snap.label,
      viewportY: localY,
      feedbackCorrection:
          _dragFeedbackGeometry?.correctionFor(globalPosition) ?? Offset.zero,
    );
  }

  void _setDropTarget(
    Object slotId,
    _DayDragPayload<T> payload,
    DateTime proposedStart,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    final snap = _DayTimelineSnap<T>(this)
        ._resolveMoveSnap(proposedStart, payload.snapshot, snapshots);
    final proposedEnd = snap.time.add(payload.snapshot.duration);
    final conflicts = _DayTimelineSnap<T>(this)._conflicts(
      payload.snapshot.id,
      snap.time,
      proposedEnd,
      snapshots,
    );
    final changed = _activeDropSlot != slotId ||
        _activeDropStart != snap.time ||
        _activeDropConflict != conflicts.hasConflict;
    if (!changed) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _activeDropSlot = slotId;
      _activeDropStart = snap.time;
      _activeDropConflict = conflicts.hasConflict;
    });
    _dragPreview.value = _DayDragPreview<T>(
      snapshot: payload.snapshot,
      proposedStart: snap.time,
      proposedEnd: proposedEnd,
      hasConflict: conflicts.hasConflict,
      conflictCount: conflicts.count,
      snapLabel: snap.label,
      viewportY: _dragPreview.value?.viewportY,
      feedbackCorrection:
          _dragPreview.value?.feedbackCorrection ?? Offset.zero,
    );
  }

  Future<void> _acceptDrop(
    _DayDragPayload<T> payload,
    DateTime proposedStart,
    List<NeonPlannerEntrySnapshot<T>> snapshots,
  ) {
    return _commitMove(payload, proposedStart, snapshots);
  }

  Future<void> _keyboardMove(
    NeonPlannerEntrySnapshot<T> snapshot,
    int direction, {
    required bool fast,
  }) async {
    if (widget.onEntryMove == null) {
      return;
    }
    final multiplier = fast ? widget.keyboardFastStepMultiplier : 1;
    final delta = Duration(
      microseconds: widget.snapInterval.inMicroseconds * direction * multiplier,
    );
    await _commitMove(
      _DayDragPayload<T>(snapshot),
      snapshot.start.add(delta),
      _snapshotsForDay(),
    );
  }

  Future<void> _commitMove(
    _DayDragPayload<T> payload,
    DateTime proposedStart,
    List<NeonPlannerEntrySnapshot<T>> snapshots, {
    double? viewportY,
  }) async {
    if (_committing) {
      return;
    }
    _latchedSnap = null;
    final snap = _DayTimelineSnap<T>(this)
        ._resolveMoveSnap(proposedStart, payload.snapshot, snapshots);
    final proposedEnd = snap.time.add(payload.snapshot.duration);
    final conflicts = _DayTimelineSnap<T>(this)._conflicts(
      payload.snapshot.id,
      snap.time,
      proposedEnd,
      snapshots,
    );

    if (widget.conflictPolicy == NeonPlannerConflictPolicy.block &&
        conflicts.hasConflict) {
      HapticFeedback.heavyImpact();
      widget.onFeedback?.call(
        conflicts.count == 1
            ? 'Dieser Zeitraum überschneidet einen Termin.'
            : 'Dieser Zeitraum überschneidet ${conflicts.count} Termine.',
      );
      return;
    }

    final callback = widget.onEntryMove;
    if (callback == null) {
      return;
    }

    final proposal = NeonPlannerMoveProposal<T>(
      entry: payload.snapshot,
      originalStart: payload.snapshot.start,
      originalEnd: payload.snapshot.end,
      proposedStart: snap.time,
      proposedEnd: proposedEnd,
      hasConflict: conflicts.hasConflict,
    );

    _committing = true;
    try {
      final result = await Future<NeonPlannerMutationResult>.sync(
        () => callback(proposal),
      );
      if (result.accepted) {
        HapticFeedback.lightImpact();
        final message =
            result.message ?? 'Auf ${_clock(snap.time)} verschoben.';
        _DayTimelineMotion<T>(this)._showCommittedMove(
          proposal,
          message: message,
          viewportY: viewportY,
        );
        _DayTimelineUndo<T>(this)._showUndoForMove(
          proposal,
          message,
        );
      } else {
        HapticFeedback.heavyImpact();
      }
      if (result.message != null) {
        widget.onFeedback?.call(result.message!);
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      widget.onFeedback?.call('Verschieben fehlgeschlagen: $error');
    } finally {
      _committing = false;
      _latchedSnap = null;
    }
  }

  void _updateAutoScroll(Offset globalPosition) {
    if (!widget.enableAutoScroll || !_scrollController.hasClients) {
      _stopAutoScroll();
      return;
    }
    final renderObject = _listKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      _stopAutoScroll();
      return;
    }
    final local = renderObject.globalToLocal(globalPosition);
    const edge = 88.0;
    double direction;
    double distance;
    if (local.dy < edge) {
      direction = -1;
      distance = edge - local.dy;
    } else if (local.dy > renderObject.size.height - edge) {
      direction = 1;
      distance = local.dy - (renderObject.size.height - edge);
    } else {
      _stopAutoScroll();
      return;
    }
    final normalized = (distance / edge).clamp(0.0, 1.0).toDouble();
    final eased = normalized * normalized * normalized;
    _autoScrollVelocity = direction * (90 + 910 * eased);
    _scheduleAutoScrollFrame();
  }

  void _scheduleAutoScrollFrame() {
    if (_autoScrollFrameScheduled || _autoScrollVelocity == 0) {
      return;
    }
    _autoScrollFrameScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback(_performAutoScrollFrame);
  }

  void _performAutoScrollFrame(Duration timeStamp) {
    _autoScrollFrameScheduled = false;
    if (!mounted ||
        (_draggingId == null && _resizingId == null) ||
        _autoScrollVelocity == 0 ||
        !_scrollController.hasClients) {
      _stopAutoScroll();
      return;
    }
    final previous = _lastAutoScrollFrameTime;
    _lastAutoScrollFrameTime = timeStamp;
    final elapsed = previous == null
        ? 1 / 60
        : (timeStamp - previous).inMicroseconds / 1000000;
    final dt = elapsed.clamp(1 / 120, 1 / 30).toDouble();
    final position = _scrollController.position;
    final target = (_scrollController.offset + _autoScrollVelocity * dt)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (target == _scrollController.offset) {
      _stopAutoScroll();
      return;
    }
    _scrollController.jumpTo(target);
    final globalPosition = _lastDragGlobalPosition;
    if (globalPosition != null) {
      _pendingInteractionGlobalPosition = globalPosition;
      _DayTimelineMotion<T>(this)._flushInteractionUpdate();
    }
    _scheduleAutoScrollFrame();
  }

  void _stopAutoScroll() {
    _autoScrollVelocity = 0;
    _lastAutoScrollFrameTime = null;
  }

  DateTime _clampStart(DateTime value, Duration duration) {
    final latest = _dayEnd.subtract(duration);
    if (latest.isBefore(_dayStart)) {
      return _dayStart;
    }
    if (value.isBefore(_dayStart)) {
      return _dayStart;
    }
    if (value.isAfter(latest)) {
      return latest;
    }
    return value;
  }
}

@immutable
class _DayDragPayload<T> {
  const _DayDragPayload(this.snapshot);

  final NeonPlannerEntrySnapshot<T> snapshot;
}

@immutable
class _DayDragPreview<T> {
  const _DayDragPreview({
    required this.snapshot,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
    required this.conflictCount,
    required this.snapLabel,
    required this.viewportY,
    required this.feedbackCorrection,
  });

  final NeonPlannerEntrySnapshot<T> snapshot;
  final DateTime proposedStart;
  final DateTime proposedEnd;
  final bool hasConflict;
  final int conflictCount;
  final String snapLabel;
  final double? viewportY;
  final Offset feedbackCorrection;
}

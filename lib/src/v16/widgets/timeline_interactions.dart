part of 'timeline.dart';

extension _TimelineInteractions<T> on _NeonPlannerTimelineState<T> {
  void _startDrag(NeonPlannerEntrySnapshot<T> entry, double globalY) {
    _resize.value = null;
    _snapEngine.reset();
    _controller.selectEntry(entry.id);
    _drag.value = NeonPlannerDragSession<T>(
      entry: entry,
      pointerOrigin: globalY,
      scrollOrigin: _scrollController.hasClients ? _scrollController.offset : 0,
      proposedStart: entry.start,
      proposedEnd: entry.end,
      hasConflict: false,
      lastPointerY: globalY,
    );
    HapticFeedback.selectionClick();
  }

  void _updateDrag(double globalY) {
    final session = _drag.value;
    if (session == null) {
      return;
    }
    _autoScroll(globalY);
    final scrollDelta = _scrollController.hasClients
        ? _scrollController.offset - session.scrollOrigin
        : 0.0;
    final delta = globalY - session.pointerOrigin + scrollDelta;
    final rawStart = session.entry.start.add(_scale.pixelsToDuration(delta));
    final targets = _nearbySnapTargets(rawStart, session.entry.id);
    final result = _snapEngine.resolve(
      candidate: rawStart,
      targets: targets,
      velocityPixelsPerSecond: 0,
    );
    final start = _clampStart(result.time, session.entry.duration);
    final end = start.add(session.entry.duration);
    final conflict = _hasConflict(start, end, session.entry.id);
    _drag.value = session.copyWith(
      proposedStart: start,
      proposedEnd: end,
      hasConflict: conflict,
      lastPointerY: globalY,
    );
  }

  Future<void> _endDrag() async {
    final session = _drag.value;
    if (session == null) {
      return;
    }
    _snapEngine.reset();
    final proposal = NeonPlannerMoveProposal<T>(
      entry: session.entry,
      originalStart: session.entry.start,
      originalEnd: session.entry.end,
      proposedStart: session.proposedStart,
      proposedEnd: session.proposedEnd,
      hasConflict: session.hasConflict,
    );
    if (_blocksConflict(session.hasConflict)) {
      _feedback('Verschieben blockiert: Zeitkonflikt.');
      _drag.value = null;
      return;
    }
    final callback = widget.onEntryMove;
    final result = callback == null
        ? const NeonPlannerMutationResult.rejected('Verschieben deaktiviert.')
        : await Future<NeonPlannerMutationResult>.sync(
            () => callback(proposal),
          );
    _feedbackResult(result);
    if (mounted) {
      _drag.value = null;
    }
  }

  void _startResize(
    NeonPlannerEntrySnapshot<T> entry,
    NeonPlannerResizeEdge edge,
    double globalY,
  ) {
    _drag.value = null;
    _snapEngine.reset();
    _controller.selectEntry(entry.id);
    _resize.value = NeonPlannerResizeSession<T>(
      entry: entry,
      edge: edge,
      pointerOrigin: globalY,
      scrollOrigin: _scrollController.hasClients ? _scrollController.offset : 0,
      proposedStart: entry.start,
      proposedEnd: entry.end,
      hasConflict: false,
    );
    HapticFeedback.selectionClick();
  }

  void _updateResize(double globalY) {
    final session = _resize.value;
    if (session == null) {
      return;
    }
    _autoScroll(globalY);
    final scrollDelta = _scrollController.hasClients
        ? _scrollController.offset - session.scrollOrigin
        : 0.0;
    final delta = _scale.pixelsToDuration(
      globalY - session.pointerOrigin + scrollDelta,
    );
    DateTime start = session.entry.start;
    DateTime end = session.entry.end;
    if (session.edge == NeonPlannerResizeEdge.start) {
      final raw = session.entry.start.add(delta);
      start = _snapEngine
          .resolve(
            candidate: raw,
            targets: _nearbySnapTargets(raw, session.entry.id),
          )
          .time;
      final latest = end.subtract(widget.config.minimumEntryDuration);
      if (start.isAfter(latest)) {
        start = latest;
      }
      if (start.isBefore(_visibleStart)) {
        start = _visibleStart;
      }
    } else {
      final raw = session.entry.end.add(delta);
      end = _snapEngine
          .resolve(
            candidate: raw,
            targets: _nearbySnapTargets(raw, session.entry.id),
          )
          .time;
      final earliest = start.add(widget.config.minimumEntryDuration);
      if (end.isBefore(earliest)) {
        end = earliest;
      }
      if (end.isAfter(_visibleEnd)) {
        end = _visibleEnd;
      }
    }
    final conflict = _hasConflict(start, end, session.entry.id);
    _resize.value = session.copyWith(
      proposedStart: start,
      proposedEnd: end,
      hasConflict: conflict,
    );
  }

  Future<void> _endResize() async {
    final session = _resize.value;
    if (session == null) {
      return;
    }
    _snapEngine.reset();
    if (_blocksConflict(session.hasConflict)) {
      _feedback('Größenänderung blockiert: Zeitkonflikt.');
      _resize.value = null;
      return;
    }
    final proposal = NeonPlannerResizeProposal<T>(
      entry: session.entry,
      edge: session.edge,
      originalStart: session.entry.start,
      originalEnd: session.entry.end,
      proposedStart: session.proposedStart,
      proposedEnd: session.proposedEnd,
      hasConflict: session.hasConflict,
    );
    final callback = widget.onEntryResize;
    final result = callback == null
        ? const NeonPlannerMutationResult.rejected('Resize deaktiviert.')
        : await Future<NeonPlannerMutationResult>.sync(
            () => callback(proposal),
          );
    _feedbackResult(result);
    if (mounted) {
      _resize.value = null;
    }
  }

  Future<void> _keyboardMove(
    NeonPlannerEntrySnapshot<T> snapshot,
    int direction,
  ) async {
    final callback = widget.onEntryMove;
    if (callback == null) {
      return;
    }
    final delta = widget.config.snapInterval * direction;
    final start = _clampStart(snapshot.start.add(delta), snapshot.duration);
    final end = start.add(snapshot.duration);
    final conflict = _hasConflict(start, end, snapshot.id);
    if (_blocksConflict(conflict)) {
      _feedback('Verschieben blockiert: Zeitkonflikt.');
      return;
    }
    final result = await Future<NeonPlannerMutationResult>.sync(
      () => callback(
        NeonPlannerMoveProposal<T>(
          entry: snapshot,
          originalStart: snapshot.start,
          originalEnd: snapshot.end,
          proposedStart: start,
          proposedEnd: end,
          hasConflict: conflict,
        ),
      ),
    );
    _feedbackResult(result);
  }

  void _startRange(double localY) {
    _snapEngine.reset();
    final raw = _scale.pixelsToTime(
      localY.clamp(0.0, _activeHeight).toDouble(),
    );
    var start = _snapEngine.resolve(candidate: raw).time;
    final latestStart = _visibleEnd.subtract(widget.config.minimumEntryDuration);
    if (start.isAfter(latestStart)) {
      start = latestStart;
    }
    if (start.isBefore(_visibleStart)) {
      start = _visibleStart;
    }
    final end = start.add(widget.config.minimumEntryDuration);
    _range.value = _RangeSession(
      start: start,
      end: end,
      hasConflict: _hasConflict(start, end, null),
    );
    HapticFeedback.selectionClick();
  }

  void _updateRange(double localY) {
    final session = _range.value;
    if (session == null) {
      return;
    }
    final raw = _scale.pixelsToTime(
      localY.clamp(0.0, _activeHeight).toDouble(),
    );
    var pointerTime = _snapEngine.resolve(candidate: raw).time;
    if (pointerTime.isBefore(_visibleStart)) {
      pointerTime = _visibleStart;
    }
    if (pointerTime.isAfter(_visibleEnd)) {
      pointerTime = _visibleEnd;
    }
    var orderedStart = session.start.isBefore(pointerTime)
        ? session.start
        : pointerTime;
    var orderedEnd = session.start.isAfter(pointerTime)
        ? session.start
        : pointerTime;
    if (orderedEnd.difference(orderedStart) <
        widget.config.minimumEntryDuration) {
      final extendedEnd = orderedStart.add(widget.config.minimumEntryDuration);
      if (!extendedEnd.isAfter(_visibleEnd)) {
        orderedEnd = extendedEnd;
      } else {
        orderedStart = orderedEnd.subtract(
          widget.config.minimumEntryDuration,
        );
      }
    }
    _range.value = _RangeSession(
      start: orderedStart,
      end: orderedEnd,
      hasConflict: _hasConflict(orderedStart, orderedEnd, null),
    );
  }

  Future<void> _endRange() async {
    final session = _range.value;
    if (session == null) {
      return;
    }
    _snapEngine.reset();
    if (_blocksConflict(session.hasConflict)) {
      _feedback('Zeitraum blockiert: Zeitkonflikt.');
      _range.value = null;
      return;
    }
    final callback = widget.onRangeCreate;
    final result = callback == null
        ? const NeonPlannerMutationResult.rejected('Erstellen deaktiviert.')
        : await Future<NeonPlannerMutationResult>.sync(
            () => callback(
              NeonPlannerRangeProposal(
                start: session.start,
                end: session.end,
                hasConflict: session.hasConflict,
              ),
            ),
          );
    _feedbackResult(result);
    if (mounted) {
      _range.value = null;
    }
  }

  Iterable<NeonPlannerSnapTarget> _nearbySnapTargets(
    DateTime candidate,
    Object exceptId,
  ) sync* {
    const radius = Duration(hours: 2);
    final nearby = _index.query(
      candidate.subtract(radius).microsecondsSinceEpoch,
      candidate.add(radius).microsecondsSinceEpoch,
    );
    for (final indexed in nearby) {
      if (indexed.snapshot.id == exceptId) {
        continue;
      }
      yield NeonPlannerSnapTarget(
        time: indexed.snapshot.start,
        kind: NeonPlannerSnapTargetKind.entryStart,
        priority: 3,
        id: '${indexed.snapshot.id}:start',
      );
      yield NeonPlannerSnapTarget(
        time: indexed.snapshot.end,
        kind: NeonPlannerSnapTargetKind.entryEnd,
        priority: 3,
        id: '${indexed.snapshot.id}:end',
      );
    }
    yield NeonPlannerSnapTarget(
      time: _controller.currentTime,
      kind: NeonPlannerSnapTargetKind.currentTime,
      priority: 2,
      id: 'current-time',
    );
  }

  bool _hasConflict(DateTime start, DateTime end, Object? exceptId) {
    return _index
        .query(start.microsecondsSinceEpoch, end.microsecondsSinceEpoch)
        .any(
          (indexed) => indexed.snapshot.id != exceptId &&
              indexed.snapshot.start.isBefore(end) &&
              indexed.snapshot.end.isAfter(start),
        );
  }

  bool _blocksConflict(bool hasConflict) {
    return hasConflict &&
        widget.config.conflictPolicy == NeonPlannerConflictPolicy.block;
  }

  DateTime _clampStart(DateTime value, Duration duration) {
    if (value.isBefore(_visibleStart)) {
      return _visibleStart;
    }
    final latest = _visibleEnd.subtract(duration);
    if (value.isAfter(latest)) {
      return latest;
    }
    return value;
  }

  DateTime _displayStart(NeonPlannerEntrySnapshot<T> snapshot) {
    return snapshot.start.isBefore(_visibleStart)
        ? _visibleStart
        : snapshot.start;
  }

  DateTime _displayEnd(NeonPlannerEntrySnapshot<T> snapshot) {
    return snapshot.end.isAfter(_visibleEnd) ? _visibleEnd : snapshot.end;
  }

  void _autoScroll(double globalY) {
    if (!_scrollController.hasClients) {
      return;
    }
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    final localY = box.globalToLocal(Offset(0, globalY)).dy;
    const edge = 72.0;
    var delta = 0.0;
    if (localY < edge) {
      delta = -18 *
          (1 - localY.clamp(0.0, edge).toDouble() / edge);
    } else if (localY > box.size.height - edge) {
      final distance = box.size.height - localY;
      delta = 18 *
          (1 - distance.clamp(0.0, edge).toDouble() / edge);
    }
    if (delta == 0) {
      return;
    }
    final position = _scrollController.position;
    final target = (_scrollController.offset + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    _scrollController.jumpTo(target);
  }

  void _feedbackResult(NeonPlannerMutationResult result) {
    if (result.message != null) {
      _feedback(result.message!);
    } else if (!result.accepted) {
      _feedback('Änderung wurde abgelehnt.');
    }
  }

  void _feedback(String message) {
    widget.onFeedback?.call(message);
  }

}

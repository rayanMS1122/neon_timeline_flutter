part of 'timeline.dart';

extension _TimelineRendering<T> on _NeonPlannerTimelineState<T> {
  Widget _buildCanvas(
    BuildContext context,
    NeonPlannerTimelineThemeData theme,
    double width,
    double viewportHeight,
  ) {
    final scale = _scale;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final queryTop = (offset - widget.config.overscan - widget.padding.top)
        .clamp(0.0, _activeHeight)
        .toDouble();
    final queryBottom =
        (offset + viewportHeight + widget.config.overscan - widget.padding.top)
            .clamp(0.0, _activeHeight)
            .toDouble();
    final queryStart = scale.pixelsToTime(queryTop);
    final queryEnd = scale.pixelsToTime(queryBottom);
    final visibleEntries = _index.query(
      queryStart.microsecondsSinceEpoch,
      queryEnd.microsecondsSinceEpoch,
    );
    _reportDiagnostics(visibleEntries.length);
    final visibleGaps = _gaps.where(
      (gap) => gap.end.isAfter(queryStart) && gap.start.isBefore(queryEnd),
    );
    final axisX = widget.config.timeColumnWidth +
        widget.config.axisColumnWidth / 2;
    final contentLeft =
        widget.config.timeColumnWidth + widget.config.axisColumnWidth;
    final paintedEntries = visibleEntries.map((indexed) {
      final snapshot = indexed.snapshot;
      return NeonPlannerPaintedEntry(
        top: scale.timeToPixels(_displayStart(snapshot)),
        bottom: scale.timeToPixels(_displayEnd(snapshot)),
        color: _accentFor(snapshot, theme),
      );
    }).toList(growable: false);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: widget.padding.top,
          bottom: widget.padding.bottom,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: NeonPlannerAxisPainter(
                scale: scale,
                config: widget.config,
                theme: theme,
                axisX: axisX,
                totalHeight: _activeHeight,
                entries: paintedEntries,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ),
        if (widget.config.enableRangeCreation && widget.onRangeCreate != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (details) =>
                  _startRange(details.localPosition.dy - widget.padding.top),
              onLongPressMoveUpdate: (details) =>
                  _updateRange(details.localPosition.dy - widget.padding.top),
              onLongPressEnd: (_) => unawaited(_endRange()),
            ),
          ),
        ...visibleGaps.map(
          (gap) => _buildGap(gap, scale, contentLeft, width, theme),
        ),
        ...visibleEntries.map(
          (indexed) => _buildEntry(
            indexed.snapshot,
            scale,
            width,
            axisX,
            contentLeft,
            theme,
          ),
        ),
        ValueListenableBuilder<_RangeSession?>(
          valueListenable: _range,
          builder: (context, session, child) {
            if (session == null) {
              return const SizedBox.shrink();
            }
            final top = widget.padding.top +
                scale.timeToPixels(session.start.isBefore(session.end)
                    ? session.start
                    : session.end);
            final bottom = widget.padding.top +
                scale.timeToPixels(session.start.isAfter(session.end)
                    ? session.start
                    : session.end);
            return Positioned(
              left: contentLeft,
              right: widget.config.statusColumnWidth + 12,
              top: top,
              height: (bottom - top).clamp(8.0, _totalHeight).toDouble(),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: (session.hasConflict
                            ? theme.errorColor
                            : theme.dayAccentColor)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: session.hasConflict
                          ? theme.errorColor
                          : theme.dayAccentColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        _buildInteractionOverlay(scale, contentLeft, width, theme),
        Positioned(
          left: 0,
          right: 0,
          top: widget.padding.top,
          bottom: widget.padding.bottom,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => RepaintBoundary(
                child: CustomPaint(
                  painter: NeonPlannerCurrentTimePainter(
                    currentTime: _controller.currentTime,
                    scale: scale,
                    color: theme.focusColor,
                    axisX: axisX,
                    rightInset: widget.config.statusColumnWidth + 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(
    NeonPlannerEntrySnapshot<T> snapshot,
    NeonPlannerTimeScale scale,
    double width,
    double axisX,
    double contentLeft,
    NeonPlannerTimelineThemeData theme,
  ) {
    final displayStart = _displayStart(snapshot);
    final displayEnd = _displayEnd(snapshot);
    final top = widget.padding.top + scale.timeToPixels(displayStart);
    final rawHeight = scale.durationToPixels(displayEnd.difference(displayStart));
    final height = rawHeight.clamp(48.0, 220.0).toDouble();
    final lane = _lanes[snapshot.id];
    return ValueListenableBuilder<NeonPlannerDragSession<T>?>(
      valueListenable: _drag,
      builder: (context, dragSession, child) {
        return ValueListenableBuilder<NeonPlannerResizeSession<T>?>(
          valueListenable: _resize,
          builder: (context, resizeSession, child) {
            final activeSessionId =
                dragSession?.entry.id ?? resizeSession?.entry.id;
            final isActive = activeSessionId == snapshot.id;
            final conflict = isActive
                ? (dragSession?.hasConflict ??
                      resizeSession?.hasConflict ??
                      false)
                : false;
            return Positioned(
              key: ValueKey<Object>(snapshot.id),
              left: 0,
              right: 0,
              top: top,
              height: height,
              child: RepaintBoundary(
                child: NeonPlannerEntryTile<T>(
                  snapshot: snapshot,
                  top: top,
                  height: height,
                  width: width,
                  axisX: axisX,
                  contentLeft: contentLeft,
                  statusWidth: widget.config.statusColumnWidth,
                  theme: theme,
                  isSelected: _selectedId == snapshot.id,
                  isGhost: isActive,
                  hasConflict: conflict,
                  lane: lane?.lane ?? 0,
                  laneCount: lane?.laneCount ?? 1,
                  dragActivation: widget.onEntryMove == null
                      ? NeonPlannerDragActivation.disabled
                      : widget.config.dragActivation,
                  enableResize:
                      widget.config.enableResize && widget.onEntryResize != null,
                  onTap: () {
                    _controller.selectEntry(snapshot.id);
                    widget.onEntryTap?.call(snapshot.data);
                  },
                  onMoveStart: (position) =>
                      _startDrag(snapshot, position.dy),
                  onMoveUpdate: (position) =>
                      _updateDrag(position.dy),
                  onMoveEnd: () => unawaited(_endDrag()),
                  onResizeStart: (edge, position) =>
                      _startResize(snapshot, edge, position.dy),
                  onResizeUpdate: (position) =>
                      _updateResize(position.dy),
                  onResizeEnd: () => unawaited(_endResize()),
                  onKeyboardMove: (direction) =>
                      unawaited(_keyboardMove(snapshot, direction)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGap(
    _Gap gap,
    NeonPlannerTimeScale scale,
    double contentLeft,
    double width,
    NeonPlannerTimelineThemeData theme,
  ) {
    final midpoint = gap.start.add(gap.duration ~/ 2);
    final top = widget.padding.top + scale.timeToPixels(midpoint) - 26;
    return Positioned(
      left: contentLeft,
      right: widget.config.statusColumnWidth + 18,
      top: top,
      height: 62,
      child: NeonPlannerGapPresentation(
        text: gap.message,
        theme: theme,
      ),
    );
  }

  Widget _buildInteractionOverlay(
    NeonPlannerTimeScale scale,
    double contentLeft,
    double width,
    NeonPlannerTimelineThemeData theme,
  ) {
    return ValueListenableBuilder<NeonPlannerDragSession<T>?>(
      valueListenable: _drag,
      builder: (context, dragSession, child) {
        return ValueListenableBuilder<NeonPlannerResizeSession<T>?>(
          valueListenable: _resize,
          builder: (context, resizeSession, child) {
            final snapshot = dragSession?.entry ?? resizeSession?.entry;
            final start = dragSession?.proposedStart ??
                resizeSession?.proposedStart;
            final end = dragSession?.proposedEnd ?? resizeSession?.proposedEnd;
            final hasConflict = dragSession?.hasConflict ??
                resizeSession?.hasConflict ??
                false;
            if (snapshot == null || start == null || end == null) {
              return const SizedBox.shrink();
            }
            final top = widget.padding.top + scale.timeToPixels(start);
            final height = scale
                .durationToPixels(end.difference(start))
                .clamp(48.0, 220.0)
                .toDouble();
            return Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: top,
                  height: height,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.92,
                      child: NeonPlannerEntryTile<T>(
                        snapshot: snapshot.copyWith(start: start, end: end),
                        top: top,
                        height: height,
                        width: width,
                        axisX: widget.config.timeColumnWidth +
                            widget.config.axisColumnWidth / 2,
                        contentLeft: contentLeft,
                        statusWidth: widget.config.statusColumnWidth,
                        theme: theme,
                        isSelected: true,
                        isGhost: false,
                        hasConflict: hasConflict,
                        lane: 0,
                        laneCount: 1,
                        dragActivation: NeonPlannerDragActivation.disabled,
                        enableResize: false,
                        onTap: () {},
                        onMoveStart: (_) {},
                        onMoveUpdate: (_) {},
                        onMoveEnd: () {},
                        onResizeStart: (_, __) {},
                        onResizeUpdate: (_) {},
                        onResizeEnd: () {},
                        onKeyboardMove: (_) {},
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: contentLeft,
                  right: widget.config.statusColumnWidth + 16,
                  top: (top - 64).clamp(8.0, _totalHeight).toDouble(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 310),
                      child: NeonPlannerInteractionOverlay(
                        title: snapshot.presentation.title,
                        start: start,
                        end: end,
                        hasConflict: hasConflict,
                        theme: theme,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}

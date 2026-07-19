part of 'day_timeline_view.dart';
extension _DayTimelineModel<T> on _NeonPlannerDayTimelineState<T> {
  void _validateConfiguration() {
    if (widget.snapInterval <= Duration.zero) {
      throw ArgumentError.value(
        widget.snapInterval,
        'snapInterval',
        'Must be greater than zero.',
      );
    }
    if (widget.snapTolerance < Duration.zero) {
      throw ArgumentError.value(
        widget.snapTolerance,
        'snapTolerance',
        'Must not be negative.',
      );
    }
    if (widget.snapHysteresis < Duration.zero) {
      throw ArgumentError.value(
        widget.snapHysteresis,
        'snapHysteresis',
        'Must not be negative.',
      );
    }
    if (widget.minimumEntryDuration <= Duration.zero) {
      throw ArgumentError.value(
        widget.minimumEntryDuration,
        'minimumEntryDuration',
        'Must be greater than zero.',
      );
    }
    if (!widget.dragMinutesPerPixel.isFinite ||
        widget.dragMinutesPerPixel <= 0) {
      throw ArgumentError.value(
        widget.dragMinutesPerPixel,
        'dragMinutesPerPixel',
        'Must be finite and greater than zero.',
      );
    }
    if (widget.smartFitMaxRows < 1) {
      throw ArgumentError.value(
        widget.smartFitMaxRows,
        'smartFitMaxRows',
        'Must be at least one.',
      );
    }
    if (widget.keyboardFastStepMultiplier < 1) {
      throw ArgumentError.value(
        widget.keyboardFastStepMultiplier,
        'keyboardFastStepMultiplier',
        'Must be at least one.',
      );
    }
    if (widget.undoWindow < Duration.zero) {
      throw ArgumentError.value(
        widget.undoWindow,
        'undoWindow',
        'Must not be negative.',
      );
    }
    if (widget.moveConfirmationDuration < Duration.zero) {
      throw ArgumentError.value(
        widget.moveConfirmationDuration,
        'moveConfirmationDuration',
        'Must not be negative.',
      );
    }
    if (widget.settleAnimationDuration < Duration.zero) {
      throw ArgumentError.value(
        widget.settleAnimationDuration,
        'settleAnimationDuration',
        'Must not be negative.',
      );
    }
    if (!widget.microBreakpoint.isFinite || widget.microBreakpoint <= 0) {
      throw ArgumentError.value(
        widget.microBreakpoint,
        'microBreakpoint',
        'Must be finite and greater than zero.',
      );
    }
    if (!widget.compactBreakpoint.isFinite ||
        widget.compactBreakpoint <= widget.microBreakpoint) {
      throw ArgumentError.value(
        widget.compactBreakpoint,
        'compactBreakpoint',
        'Must be finite and greater than microBreakpoint.',
      );
    }
  }

  Map<Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>
      _overlapPlacements(List<NeonPlannerEntrySnapshot<T>> snapshots) {
    if (snapshots.isEmpty) {
      return <Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>{};
    }

    final result =
        <Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>{};
    final group = <NeonPlannerEntrySnapshot<T>>[];
    DateTime? groupEnd;

    void flushGroup() {
      if (group.isEmpty) {
        return;
      }
      final placements = const NeonPlannerLaneAllocator().allocate(
        group.map(
          (snapshot) => NeonPlannerLaneInterval<NeonPlannerEntrySnapshot<T>>(
            value: snapshot,
            startMicros: snapshot.start.microsecondsSinceEpoch,
            endMicros: snapshot.end.microsecondsSinceEpoch,
          ),
        ),
      );
      final laneCount = placements.fold<int>(
        1,
        (maximum, placement) =>
            placement.lane + 1 > maximum ? placement.lane + 1 : maximum,
      );
      for (final placement in placements) {
        result[placement.value.id] =
            NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>(
          value: placement.value,
          lane: placement.lane,
          laneCount: laneCount,
        );
      }
      group.clear();
      groupEnd = null;
    }

    for (final snapshot in snapshots) {
      if (groupEnd != null && !snapshot.start.isBefore(groupEnd!)) {
        flushGroup();
      }
      group.add(snapshot);
      if (groupEnd == null || snapshot.end.isAfter(groupEnd!)) {
        groupEnd = snapshot.end;
      }
    }
    flushGroup();
    return result;
  }

  List<Widget> _rows(
    List<NeonPlannerEntrySnapshot<T>> snapshots,
    Map<Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>
        placements,
    NeonPlannerTimelineThemeData resolvedTheme,
    _DayLayoutMetrics layout,
  ) {
    if (snapshots.isEmpty) {
      return <Widget>[
        _EmptyDayTimeline(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          theme: resolvedTheme,
          layout: layout,
          onCreateTap: widget.onCreateTap,
        ),
      ];
    }
    final rows = <Widget>[];
    final showDropTargets =
        _dragEnabled && widget.dragMode != NeonPlannerDayDragMode.time;
    final current = _currentTimeForDay;
    var currentPlaced = false;
    if (current != null && current.isBefore(snapshots.first.start)) {
      rows.add(
        _CurrentMarker(
          label: widget.currentTimeLabel,
          theme: resolvedTheme,
          layout: layout,
        ),
      );
      currentPlaced = true;
    }
    if (showDropTargets) {
      rows.add(
        _DayTimelineDrag<T>(this)._buildDropTarget(
          slotId: 'before-${snapshots.first.id}',
          windowStart: _dayStart,
          windowEnd: snapshots.first.start,
          snapshots: snapshots,
          theme: resolvedTheme,
          layout: layout,
        ),
      );
    }
    for (var index = 0; index < snapshots.length; index += 1) {
      final snapshot = snapshots[index];
      final accent = _entryAccent(snapshot, resolvedTheme);
      final placement = placements[snapshot.id];
      final isCurrent = current != null &&
          !current.isBefore(snapshot.start) &&
          current.isBefore(snapshot.end);
      if (isCurrent) {
        currentPlaced = true;
      }
      rows.add(
        _DayTimelineDrag<T>(this)._buildDraggableEntry(
          snapshot: snapshot,
          theme: resolvedTheme,
          accent: accent,
          isFirst: index == 0,
          isLast: index == snapshots.length - 1,
          isCurrent: isCurrent,
          lane: placement?.lane ?? 0,
          laneCount: placement?.laneCount ?? 1,
          layout: layout,
        ),
      );
      final next = index < snapshots.length - 1 ? snapshots[index + 1] : null;
      if (!currentPlaced &&
          current != null &&
          !current.isBefore(snapshot.end) &&
          (next == null || current.isBefore(next.start))) {
        rows.add(
          _CurrentMarker(
            label: widget.currentTimeLabel,
            theme: resolvedTheme,
            layout: layout,
          ),
        );
        currentPlaced = true;
      }
      if (next == null) {
        if (showDropTargets) {
          rows.add(
            _DayTimelineDrag<T>(this)._buildDropTarget(
              slotId: 'after-${snapshot.id}',
              windowStart: snapshot.end,
              windowEnd: _dayEnd,
              snapshots: snapshots,
              theme: resolvedTheme,
              layout: layout,
            ),
          );
        }
        continue;
      }
      if (!next.start.isAfter(snapshot.end)) {
        continue;
      }
      final gapStart =
          snapshot.presentation.kind == NeonPlannerEntryKind.sleep &&
              snapshot.duration <= const Duration(minutes: 5)
          ? snapshot.start
          : snapshot.end;
      final duration = next.start.difference(gapStart);
      final customGap =
          widget.gapBuilder?.call(duration, index, snapshot, next);
      if (showDropTargets) {
        rows.add(
          _DayTimelineDrag<T>(this)._buildDropTarget(
            slotId: 'gap-${snapshot.id}-${next.id}',
            windowStart: gapStart,
            windowEnd: next.start,
            snapshots: snapshots,
            theme: resolvedTheme,
            layout: layout,
          ),
        );
      }
      if (widget.gapBuilder != null && customGap == null) {
        continue;
      }
      final gap = customGap ??
          _defaultGap(duration, index, snapshot, next, resolvedTheme);
      rows.add(
        _CompactGapRow(
          start: gapStart,
          end: next.start,
          gap: gap,
          theme: resolvedTheme,
          previousAccent: accent,
          nextAccent: _entryAccent(next, resolvedTheme),
          layout: layout,
          onTap: widget.onGapTap == null ? null : () => widget.onGapTap!(gap),
        ),
      );
    }
    return rows;
  }

  List<NeonPlannerDayMetric> _defaultMetrics(
    List<NeonPlannerEntrySnapshot<T>> snapshots,
    NeonPlannerTimelineThemeData resolvedTheme,
  ) {
    var appointments = 0;
    var sleep = Duration.zero;
    var focus = Duration.zero;
    for (final snapshot in snapshots) {
      switch (snapshot.presentation.kind) {
        case NeonPlannerEntryKind.sleep:
          sleep += snapshot.duration;
          break;
        case NeonPlannerEntryKind.focus:
          focus += snapshot.duration;
          break;
        case NeonPlannerEntryKind.breakTime:
          break;
        default:
          appointments += 1;
          break;
      }
    }
    return <NeonPlannerDayMetric>[
      NeonPlannerDayMetric(
        label: 'Termine',
        value: '$appointments',
        helper: 'geplant',
        icon: Icons.check_circle_outline_rounded,
        color: resolvedTheme.dayAccentColor,
      ),
      NeonPlannerDayMetric(
        label: 'Schlaf',
        value: _compactDuration(sleep),
        helper: 'gesamt',
        icon: Icons.nightlight_round,
        color: resolvedTheme.nightAccentColor,
      ),
      NeonPlannerDayMetric(
        label: 'Fokus',
        value: _compactDuration(focus),
        helper: 'geplant',
        icon: Icons.auto_awesome_rounded,
        color: resolvedTheme.successColor,
      ),
    ];
  }
}

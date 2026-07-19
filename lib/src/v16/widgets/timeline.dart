import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/controller.dart';
import '../api/entry_adapter.dart';
import '../api/models.dart';
import '../api/timeline_config.dart';
import '../domain/time_scale.dart';
import '../geometry/lane_allocator.dart';
import '../interaction/drag/drag_session.dart';
import '../interaction/resize/resize_session.dart';
import '../interaction/snap/snap_engine.dart';
import '../presentation/gap_presentation.dart';
import '../rendering/axis_painter.dart';
import '../theme/timeline_theme.dart';
import '../viewport/interval_index.dart';
import 'entries/entry_tile.dart';
import 'overlays/interaction_overlay.dart';

part 'timeline_interactions.dart';
part 'timeline_rendering.dart';
part 'timeline_support.dart';

/// Callback for an entry move proposal.
typedef NeonPlannerMoveCallback<T> =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerMoveProposal<T> proposal,
    );

/// Callback for an entry resize proposal.
typedef NeonPlannerResizeCallback<T> =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerResizeProposal<T> proposal,
    );

/// Callback for an empty range proposal.
typedef NeonPlannerRangeCallback =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerRangeProposal proposal,
    );

/// Virtualized, interactive vertical day timeline.
class NeonPlannerTimeline<T> extends StatefulWidget {
  /// Creates a vertical timeline.
  const NeonPlannerTimeline({
    required this.entries,
    required this.adapter,
    required this.selectedDate,
    this.controller,
    this.config = const NeonPlannerTimelineConfig.production(),
    this.theme,
    this.onEntryTap,
    this.onEntryMove,
    this.onEntryResize,
    this.onRangeCreate,
    this.onFeedback,
    this.onDiagnostics,
    this.gapMessageBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 28),
    this.transparent = false,
    super.key,
  });

  /// Application entries.
  final List<T> entries;

  /// Projection from application objects into timeline snapshots.
  final NeonPlannerEntryAdapter<T> adapter;

  /// Day represented by the timeline.
  final DateTime selectedDate;

  /// Optional imperative controller.
  final NeonPlannerTimelineController? controller;

  /// Timeline behavior and geometry.
  final NeonPlannerTimelineConfig config;

  /// Optional explicit package theme.
  final NeonPlannerTimelineThemeData? theme;

  /// Called when an entry is tapped or keyboard-activated.
  final ValueChanged<T>? onEntryTap;

  /// Called when a move is committed.
  final NeonPlannerMoveCallback<T>? onEntryMove;

  /// Called when a resize is committed.
  final NeonPlannerResizeCallback<T>? onEntryResize;

  /// Called when a new range is committed.
  final NeonPlannerRangeCallback? onRangeCreate;

  /// Optional non-visual feedback hook.
  final ValueChanged<String>? onFeedback;

  /// Receives deduplicated viewport and layout counters after a frame.
  final ValueChanged<NeonPlannerTimelineDiagnostics>? onDiagnostics;

  /// Optional gap-copy factory.
  final String Function(Duration gap, int index)? gapMessageBuilder;

  /// Inner vertical padding.
  final EdgeInsets padding;

  /// Removes the package surface color and radius.
  final bool transparent;

  @override
  State<NeonPlannerTimeline<T>> createState() =>
      _NeonPlannerTimelineState<T>();
}

class _NeonPlannerTimelineState<T> extends State<NeonPlannerTimeline<T>> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final ValueNotifier<NeonPlannerDragSession<T>?> _drag =
      ValueNotifier<NeonPlannerDragSession<T>?>(null);
  final ValueNotifier<NeonPlannerResizeSession<T>?> _resize =
      ValueNotifier<NeonPlannerResizeSession<T>?>(null);
  final ValueNotifier<_RangeSession?> _range =
      ValueNotifier<_RangeSession?>(null);

  late NeonPlannerTimelineController _controller;
  late bool _ownsController;
  late NeonPlannerSnapEngine _snapEngine;
  late List<NeonPlannerEntrySnapshot<T>> _snapshots;
  late NeonPlannerIntervalIndex<_IndexedEntry<T>> _index;
  late Map<Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>
  _lanes;
  late List<_Gap> _gaps;
  late NeonPlannerZoomLevel _zoomLevel;
  Object? _selectedId;
  NeonPlannerTimelineDiagnostics? _lastDiagnostics;
  int _maximumLaneCount = 1;

  DateTime get _dayStart => DateTime(
    widget.selectedDate.year,
    widget.selectedDate.month,
    widget.selectedDate.day,
  );

  DateTime get _visibleStart => _dayStart.add(widget.config.visibleStart);

  DateTime get _visibleEnd => _dayStart.add(widget.config.visibleEnd);

  NeonPlannerTimeScale get _scale => NeonPlannerTimeScale(
    origin: _visibleStart,
    pixelsPerMinute: _pixelsPerMinute(_zoomLevel),
  );

  double get _activeHeight =>
      _scale.durationToPixels(_visibleEnd.difference(_visibleStart));

  double get _totalHeight => _activeHeight + widget.padding.vertical;

  @override
  void initState() {
    super.initState();
    widget.config.validate();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? NeonPlannerTimelineController();
    _zoomLevel = widget.controller?.zoomLevel ?? widget.config.initialZoom;
    _selectedId = _controller.selectedEntryId;
    _snapEngine = NeonPlannerSnapEngine(
      interval: widget.config.snapInterval,
      strength: widget.config.snapStrength,
    );
    _rebuildData();
    _controller.addListener(_handleControllerChanged);
    _controller.attach(_scrollController, _scale);
  }

  @override
  void didUpdateWidget(covariant NeonPlannerTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.config.validate();
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _controller.detach(_scrollController);
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? NeonPlannerTimelineController();
      _zoomLevel = _controller.zoomLevel;
      _selectedId = _controller.selectedEntryId;
      _controller.addListener(_handleControllerChanged);
      _controller.attach(_scrollController, _scale);
    }
    if (oldWidget.entries != widget.entries ||
        oldWidget.adapter != widget.adapter ||
        !_sameDay(oldWidget.selectedDate, widget.selectedDate) ||
        oldWidget.config.visibleStart != widget.config.visibleStart ||
        oldWidget.config.visibleEnd != widget.config.visibleEnd ||
        oldWidget.config.minimumGapForMessage !=
            widget.config.minimumGapForMessage) {
      _rebuildData();
      _controller.attach(_scrollController, _scale);
    }
    if (oldWidget.config.snapInterval != widget.config.snapInterval) {
      _snapEngine = NeonPlannerSnapEngine(
        interval: widget.config.snapInterval,
        strength: widget.config.snapStrength,
      );
    } else {
      _snapEngine.strength = widget.config.snapStrength;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.detach(_scrollController);
    if (_ownsController) {
      _controller.dispose();
    }
    _scrollController.dispose();
    _drag.dispose();
    _resize.dispose();
    _range.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final nextZoom = _controller.zoomLevel;
    final nextSelected = _controller.selectedEntryId;
    if (nextZoom == _zoomLevel && nextSelected == _selectedId) {
      return;
    }

    DateTime? anchor;
    if (nextZoom != _zoomLevel && _scrollController.hasClients) {
      final viewport = _scrollController.position.viewportDimension;
      anchor = _scale.pixelsToTime(
        _scrollController.offset + viewport * 0.35 - widget.padding.top,
      );
    }
    setState(() {
      _zoomLevel = nextZoom;
      _selectedId = nextSelected;
    });
    _controller.attach(_scrollController, _scale);
    if (anchor != null) {
      final preservedAnchor = anchor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.jumpToTime(preservedAnchor, alignment: 0.35);
        }
      });
    }
  }

  void _rebuildData() {
    final snapshots = <NeonPlannerEntrySnapshot<T>>[];
    final ids = <Object>{};
    for (final entry in widget.entries) {
      final snapshot = widget.adapter.snapshotOf(entry);
      if (!ids.add(snapshot.id)) {
        throw FlutterError(
          'Duplicate NeonPlanner entry ID: ${snapshot.id}. '
          'Every entry must have a stable, unique ID.',
        );
      }
      if (snapshot.end.isAfter(_visibleStart) &&
          snapshot.start.isBefore(_visibleEnd)) {
        snapshots.add(snapshot);
      }
    }
    snapshots.sort((a, b) {
      final start = a.start.compareTo(b.start);
      return start != 0 ? start : a.end.compareTo(b.end);
    });
    _snapshots = List<NeonPlannerEntrySnapshot<T>>.unmodifiable(snapshots);
    _index = NeonPlannerIntervalIndex<_IndexedEntry<T>>(
      _snapshots.map(_IndexedEntry<T>.new),
    );
    final placements = const NeonPlannerLaneAllocator().allocate(
      _snapshots.map(
        (snapshot) => NeonPlannerLaneInterval<NeonPlannerEntrySnapshot<T>>(
          value: snapshot,
          startMicros: snapshot.start.microsecondsSinceEpoch,
          endMicros: snapshot.end.microsecondsSinceEpoch,
        ),
      ),
    );
    _lanes = <Object, NeonPlannerLanePlacement<NeonPlannerEntrySnapshot<T>>>{
      for (final placement in placements) placement.value.id: placement,
    };
    _maximumLaneCount = placements.fold<int>(
      1,
      (maximum, placement) =>
          placement.laneCount > maximum ? placement.laneCount : maximum,
    );
    _gaps = _buildGaps(_snapshots);
  }

  void _reportDiagnostics(int visibleEntries) {
    final callback = widget.onDiagnostics;
    if (callback == null) {
      return;
    }
    final diagnostics = NeonPlannerTimelineDiagnostics(
      totalEntries: widget.entries.length,
      indexedEntries: _snapshots.length,
      visibleEntries: visibleEntries,
      gapCount: _gaps.length,
      maximumLaneCount: _maximumLaneCount,
      zoomLevel: _zoomLevel,
      canvasHeight: _totalHeight,
    );
    if (diagnostics == _lastDiagnostics) {
      return;
    }
    _lastDiagnostics = diagnostics;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _lastDiagnostics == diagnostics) {
        callback(diagnostics);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inheritedTheme = widget.theme ?? NeonPlannerTimelineTheme.of(context);
    final radius = widget.config.surfaceRadius == 38
        ? inheritedTheme.surfaceRadius
        : widget.config.surfaceRadius;

    return NeonPlannerTimelineTheme(
      data: inheritedTheme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : 640.0;
          final body = RepaintBoundary(
            key: _viewportKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: _totalHeight,
                width: constraints.maxWidth,
                child: AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) => _buildCanvas(
                    context,
                    inheritedTheme,
                    constraints.maxWidth,
                    viewportHeight,
                  ),
                ),
              ),
            ),
          );

          if (widget.transparent) {
            return body;
          }
          return DecoratedBox(
            decoration: BoxDecoration(
              color: inheritedTheme.surfaceColor,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: inheritedTheme.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              clipBehavior: Clip.hardEdge,
              child: body,
            ),
          );
        },
      ),
    );
  }

  List<_Gap> _buildGaps(List<NeonPlannerEntrySnapshot<T>> snapshots) {
    if (!widget.config.showGapMessages || snapshots.length < 2) {
      return <_Gap>[];
    }
    final gaps = <_Gap>[];
    for (var index = 0; index < snapshots.length - 1; index += 1) {
      final current = snapshots[index];
      final next = snapshots[index + 1];
      if (!next.start.isAfter(current.end)) {
        continue;
      }
      final duration = next.start.difference(current.end);
      if (duration < widget.config.minimumGapForMessage) {
        continue;
      }
      gaps.add(
        _Gap(
          start: current.end,
          end: next.start,
          message: widget.gapMessageBuilder?.call(duration, gaps.length) ??
              _defaultGapMessage(gaps.length),
        ),
      );
    }
    return List<_Gap>.unmodifiable(gaps);
  }
}


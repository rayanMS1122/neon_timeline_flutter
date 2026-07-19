import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/models.dart';
import '../../theme/timeline_theme.dart';

part 'entry_tile_support.dart';

/// Internal timeline entry tile without a rectangular card shell.
class NeonPlannerEntryTile<T> extends StatefulWidget {
  /// Creates an entry tile.
  const NeonPlannerEntryTile({
    required this.snapshot,
    required this.top,
    required this.height,
    required this.width,
    required this.axisX,
    required this.contentLeft,
    required this.statusWidth,
    required this.theme,
    required this.isSelected,
    required this.isGhost,
    required this.hasConflict,
    required this.lane,
    required this.laneCount,
    required this.onTap,
    required this.onMoveStart,
    required this.onMoveUpdate,
    required this.onMoveEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onKeyboardMove,
    required this.dragActivation,
    required this.enableResize,
    super.key,
  });

  /// Snapshot.
  final NeonPlannerEntrySnapshot<T> snapshot;

  /// Top position in the full canvas.
  final double top;

  /// Visual height.
  final double height;

  /// Canvas width.
  final double width;

  /// Timeline axis coordinate.
  final double axisX;

  /// Content start.
  final double contentLeft;

  /// Status column width.
  final double statusWidth;

  /// Theme.
  final NeonPlannerTimelineThemeData theme;

  /// Selection state.
  final bool isSelected;

  /// Whether this is the original ghost during a drag.
  final bool isGhost;

  /// Conflict state.
  final bool hasConflict;

  /// Overlap lane.
  final int lane;

  /// Total overlap lanes.
  final int laneCount;

  /// Tap callback.
  final VoidCallback onTap;

  /// Move start callback.
  final ValueChanged<Offset> onMoveStart;

  /// Move update callback.
  final ValueChanged<Offset> onMoveUpdate;

  /// Move end callback.
  final VoidCallback onMoveEnd;

  /// Resize start callback.
  final void Function(NeonPlannerResizeEdge edge, Offset globalPosition)
  onResizeStart;

  /// Resize update callback.
  final ValueChanged<Offset> onResizeUpdate;

  /// Resize end callback.
  final VoidCallback onResizeEnd;

  /// Keyboard move callback.
  final ValueChanged<int> onKeyboardMove;

  /// Drag activation.
  final NeonPlannerDragActivation dragActivation;

  /// Enables resize handles.
  final bool enableResize;

  @override
  State<NeonPlannerEntryTile<T>> createState() =>
      _NeonPlannerEntryTileState<T>();
}

class _NeonPlannerEntryTileState<T> extends State<NeonPlannerEntryTile<T>> {
  bool _hovering = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final presentation = widget.snapshot.presentation;
    final accent = presentation.accentColor ??
        _kindColor(presentation.kind, widget.theme);
    final nodeDiameter = _nodeDiameter(widget.height, widget.theme.nodeRadius);
    final effectiveHeight = widget.height.clamp(nodeDiameter, 220).toDouble();
    final compact = effectiveHeight < 72;
    final micro = effectiveHeight < 52;
    final laneInset = widget.lane * 10.0;
    final contentLeft = widget.contentLeft + laneInset;
    final availableContentWidth =
        widget.width - contentLeft - widget.statusWidth - 12;

    final semanticLabel = presentation.semanticLabel ??
        '${presentation.title}, ${_timeRange(widget.snapshot.start, widget.snapshot.end)}, '
            '${_durationLabel(widget.snapshot.duration)}';

    Widget child = Semantics(
      button: true,
      selected: widget.isSelected,
      enabled: presentation.isEnabled,
      label: semanticLabel,
      onTap: presentation.isEnabled ? widget.onTap : null,
      child: Focus(
        canRequestFocus: presentation.isEnabled,
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: _onKeyEvent,
        child: MouseRegion(
          cursor: presentation.isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: presentation.isEnabled ? widget.onTap : null,
            onLongPressStart:
                widget.dragActivation == NeonPlannerDragActivation.longPress &&
                    presentation.isEnabled
                ? (details) => widget.onMoveStart(details.globalPosition)
                : null,
            onLongPressMoveUpdate:
                widget.dragActivation == NeonPlannerDragActivation.longPress &&
                    presentation.isEnabled
                ? (details) => widget.onMoveUpdate(details.globalPosition)
                : null,
            onLongPressEnd:
                widget.dragActivation == NeonPlannerDragActivation.longPress &&
                    presentation.isEnabled
                ? (_) => widget.onMoveEnd()
                : null,
            onPanStart:
                widget.dragActivation == NeonPlannerDragActivation.immediate &&
                    presentation.isEnabled
                ? (details) => widget.onMoveStart(details.globalPosition)
                : null,
            onPanUpdate:
                widget.dragActivation == NeonPlannerDragActivation.immediate &&
                    presentation.isEnabled
                ? (details) => widget.onMoveUpdate(details.globalPosition)
                : null,
            onPanEnd:
                widget.dragActivation == NeonPlannerDragActivation.immediate &&
                    presentation.isEnabled
                ? (_) => widget.onMoveEnd()
                : null,
            child: SizedBox(
              width: widget.width,
              height: effectiveHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  if (widget.isSelected || _hovering || _focused)
                    Positioned(
                      left: widget.axisX - nodeDiameter / 2 - 7,
                      right: widget.statusWidth + 5,
                      top: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.theme.selectionColor,
                          borderRadius: BorderRadius.circular(18),
                          border: _focused
                              ? Border.all(
                                  color: widget.theme.focusColor,
                                  width: 2,
                                )
                              : null,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    width: widget.axisX - nodeDiameter / 2 - 10,
                    top: (nodeDiameter - 18) / 2,
                    child: Text(
                      _clock(widget.snapshot.start),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: widget.theme.timeStyle,
                    ),
                  ),
                  Positioned(
                    left: widget.axisX - nodeDiameter / 2,
                    top: 0,
                    width: nodeDiameter,
                    height: nodeDiameter,
                    child: _Node(
                      accent: widget.hasConflict
                          ? widget.theme.errorColor
                          : accent,
                      icon: presentation.icon,
                      theme: widget.theme,
                      selected: widget.isSelected,
                    ),
                  ),
                  Positioned(
                    left: contentLeft,
                    top: micro ? 2 : 4,
                    width: availableContentWidth
                        .clamp(40.0, widget.width)
                        .toDouble(),
                    child: _EntryCopy(
                      snapshot: widget.snapshot,
                      theme: widget.theme,
                      compact: compact,
                      micro: micro,
                      hasConflict: widget.hasConflict,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: (nodeDiameter - 28) / 2,
                    child: _StatusIndicator(
                      value: presentation.completion,
                      color: accent,
                      background: widget.theme.gridColor,
                    ),
                  ),
                  if (widget.enableResize &&
                      presentation.isEnabled &&
                      (widget.isSelected || _hovering)) ...<Widget>[
                    Positioned(
                      left: contentLeft,
                      right: widget.statusWidth,
                      top: 0,
                      height: 18,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUp,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanStart: (details) => widget.onResizeStart(
                            NeonPlannerResizeEdge.start,
                            details.globalPosition,
                          ),
                          onPanUpdate: (details) =>
                              widget.onResizeUpdate(details.globalPosition),
                          onPanEnd: (_) => widget.onResizeEnd(),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _ResizeHandle(color: accent),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: contentLeft,
                      right: widget.statusWidth,
                      bottom: 0,
                      height: 18,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeDown,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanStart: (details) => widget.onResizeStart(
                            NeonPlannerResizeEdge.end,
                            details.globalPosition,
                          ),
                          onPanUpdate: (details) =>
                              widget.onResizeUpdate(details.globalPosition),
                          onPanEnd: (_) => widget.onResizeEnd(),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _ResizeHandle(color: accent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.isGhost) {
      child = Opacity(opacity: 0.28, child: child);
    }
    return child;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.onKeyboardMove(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.onKeyboardMove(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}


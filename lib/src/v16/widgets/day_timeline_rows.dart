part of 'day_timeline_view.dart';
const CustomSemanticsAction _resizeEarlierSemanticsAction =
    CustomSemanticsAction(label: 'Ende früher');
const CustomSemanticsAction _resizeLaterSemanticsAction =
    CustomSemanticsAction(label: 'Ende später');
class _CompactEntryRow<T> extends StatefulWidget {
  const _CompactEntryRow({
    required this.snapshot,
    required this.theme,
    required this.accent,
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
    required this.isDragging,
    required this.isSelected,
    required this.isRecentlyMoved,
    required this.settleAnimationDuration,
    required this.showDragHandle,
    required this.timeLabel,
    required this.durationLabel,
    required this.overlapPresentation,
    required this.lane,
    required this.laneCount,
    required this.layout,
    required this.keyboardEnabled,
    required this.onTap,
    required this.onStatusTap,
    required this.onTimeEdit,
    required this.onKeyboardMove,
    required this.onKeyboardResize,
    super.key,
  });
  final NeonPlannerEntrySnapshot<T> snapshot;
  final NeonPlannerTimelineThemeData theme;
  final Color accent;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;
  final bool isDragging;
  final bool isSelected;
  final bool isRecentlyMoved;
  final Duration settleAnimationDuration;
  final bool showDragHandle;
  final String timeLabel;
  final String durationLabel;
  final NeonPlannerOverlapPresentation overlapPresentation;
  final int lane;
  final int laneCount;
  final _DayLayoutMetrics layout;
  final bool keyboardEnabled;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onTimeEdit;
  final void Function(int direction, bool fast) onKeyboardMove;
  final void Function(int direction, bool fast)? onKeyboardResize;
  @override
  State<_CompactEntryRow<T>> createState() => _CompactEntryRowState<T>();
}
class _CompactEntryRowState<T> extends State<_CompactEntryRow<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _hovering = false;
  bool _focused = false;
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  void _activate() {
    _focusNode.requestFocus();
    widget.onTap?.call();
  }
  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    final presentation = widget.snapshot.presentation;
    final highlighted = widget.isSelected || _hovering || _focused;
    final showOverlap = widget.laneCount > 1 &&
        widget.overlapPresentation != NeonPlannerOverlapPresentation.none;
    final durationText = widget.durationLabel.isEmpty
        ? ''
        : widget.durationLabel;
    final rangeAndDuration = layout.isRegular || durationText.isEmpty
        ? _timeRange(widget.snapshot.start, widget.snapshot.end)
        : '${_timeRange(widget.snapshot.start, widget.snapshot.end)} · '
            '$durationText';
    final supportingText = presentation.subtitle ?? presentation.metadata;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final largeText = textScale >= 1.6;
    final showSupportingText =
        supportingText != null && !layout.isMicro && textScale < 1.3;
    final verticalPadding =
        layout.isRegular ? 12.0 : layout.isCompact ? 3.0 : 2.5;
    final textScaleAllowance = math.max(0.0, textScale - 1).toDouble() *
        (layout.isRegular ? 56 : layout.isCompact ? 24 : 22);
    final row = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: widget.isDragging ? 0.32 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        height: layout.entryMinHeight + textScaleAllowance,
        decoration: BoxDecoration(
          color: widget.isDragging
              ? layout.isRegular
                  ? widget.accent.withValues(alpha: 0.05)
                  : Colors.transparent
              : widget.isRecentlyMoved
              ? widget.accent.withValues(alpha: layout.isRegular ? 0.09 : 0.04)
              : highlighted && layout.isRegular
              ? widget.theme.selectionColor.withValues(alpha: 0.48)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(layout.isRegular ? 22 : 10),
          border: _focused
              ? Border.all(color: widget.theme.focusColor, width: 1.5)
              : widget.isRecentlyMoved
              ? Border.all(
                  color: widget.accent.withValues(alpha: 0.30),
                  width: 1.2,
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                  width: layout.timeColumnWidth,
                  child: Padding(
                    padding: EdgeInsets.only(top: layout.isRegular ? 6 : 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.timeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: widget.theme.timeStyle.copyWith(
                            fontSize: layout.timeFontSize,
                            color: widget.isCurrent
                                ? widget.accent
                                : widget.theme.secondaryTextColor,
                            fontWeight: widget.isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (widget.isCurrent && !layout.isMicro) ...<Widget>[
                          const SizedBox(height: 3),
                          _NowPill(
                            accent: widget.accent,
                            theme: widget.theme,
                            compact: !layout.isRegular,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: layout.axisColumnWidth,
                  child: _EntryRail(
                    accent: widget.accent,
                    icon: presentation.icon,
                    showTop: !widget.isFirst,
                    showBottom: !widget.isLast,
                    theme: widget.theme,
                    layout: layout,
                    overlapPresentation: widget.overlapPresentation,
                    lane: widget.lane,
                    laneCount: widget.laneCount,
                    isCurrent: widget.isCurrent,
                    isSelected: widget.isSelected,
                  ),
                ),
                SizedBox(width: layout.columnGap),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: layout.isRegular ? 1 : 0,
                      right: layout.isRegular ? 6 : 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          presentation.title,
                          maxLines: largeText && !layout.isRegular ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: widget.theme.titleStyle.copyWith(
                            fontSize: layout.titleFontSize,
                            height: layout.isMicro ? 1.08 : 1.14,
                          ),
                        ),
                        SizedBox(height: layout.isRegular ? 6 : 1),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                rangeAndDuration,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: widget.theme.timeStyle.copyWith(
                                  fontSize: layout.timeFontSize,
                                ),
                              ),
                            ),
                            if (layout.isRegular &&
                                durationText.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 7),
                              _DurationChip(
                                label: durationText,
                                theme: widget.theme,
                                fontSize: layout.durationFontSize,
                              ),
                            ],
                            if (showOverlap) ...<Widget>[
                              SizedBox(width: layout.isRegular ? 7 : 5),
                              _OverlapChip(
                                lane: widget.lane,
                                laneCount: widget.laneCount,
                                accent: widget.accent,
                                theme: widget.theme,
                                compact: !layout.isRegular,
                                micro: layout.isMicro,
                              ),
                            ],
                          ],
                        ),
                        if (showSupportingText) ...<Widget>[
                          SizedBox(height: layout.isRegular ? 6 : 1),
                          Row(
                            children: <Widget>[
                              if (presentation.metadata != null) ...<Widget>[
                                Icon(
                                  _metadataIcon(presentation.metadata!),
                                  size: layout.isRegular ? 16 : 10,
                                  color: widget.theme.secondaryTextColor,
                                ),
                                SizedBox(width: layout.isRegular ? 6 : 3),
                              ],
                              Expanded(
                                child: Text(
                                  supportingText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.theme.metadataStyle.copyWith(
                                    fontSize: layout.metadataFontSize,
                                    color: widget.theme.secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              SizedBox(
                width: layout.statusColumnWidth,
                  child: Center(
                    child: widget.showDragHandle
                        ? Icon(
                            Icons.drag_indicator_rounded,
                            color: widget.theme.secondaryTextColor,
                            size: layout.isRegular ? 24 : layout.isCompact ? 15 : 14,
                          )
                        : Semantics(
                            button: widget.onStatusTap != null,
                            onTap: widget.onStatusTap,
                            child: SizedBox(
                              width: layout.statusColumnWidth,
                              height: 48,
                              child: Center(
                                child: _StatusRing(
                                  accent: widget.accent,
                                  value: presentation.completion,
                                  theme: widget.theme,
                                  size: layout.statusSize,
                                ),
                              ),
                            ),
                          ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
    final animatedRow = widget.isRecentlyMoved
        ? _SettledEntryPulse(
            key: ValueKey<String>('neon-settled-${widget.snapshot.id}'),
            duration: widget.settleAnimationDuration,
            child: row,
          )
        : row;
    final Map<CustomSemanticsAction, VoidCallback>? resizeActions;
    if (widget.onKeyboardResize == null) {
      resizeActions = null;
    } else {
      resizeActions = <CustomSemanticsAction, VoidCallback>{
        _resizeEarlierSemanticsAction: () =>
            widget.onKeyboardResize!(-1, false),
        _resizeLaterSemanticsAction: () =>
            widget.onKeyboardResize!(1, false),
      };
    }
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label:
          '${presentation.title}, '
          '${_timeRange(widget.snapshot.start, widget.snapshot.end)}',
      hint: widget.keyboardEnabled
          ? 'Pfeiltasten verschieben. Umschalt plus Pfeil verschiebt schneller.'
          : null,
      onTap: _activate,
      onIncrease: widget.keyboardEnabled
          ? () => widget.onKeyboardMove(1, false)
          : null,
      onDecrease: widget.keyboardEnabled
          ? () => widget.onKeyboardMove(-1, false)
          : null,
      customSemanticsActions: resizeActions,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: true,
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: widget.isDragging
                ? null
                : (details) {
                    final inStatusTarget = widget.onStatusTap != null &&
                        details.localPosition.dx >=
                            layout.availableContentWidth - 48;
                    if (inStatusTarget) {
                      widget.onStatusTap!.call();
                    } else {
                      _activate();
                    }
                  },
            onDoubleTap: widget.onTimeEdit,
            child: animatedRow,
          ),
        ),
      ),
    );
  }
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    final fast = keyboard.isShiftPressed;
    final resize = keyboard.isAltPressed;
    if (widget.keyboardEnabled &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (resize && widget.onKeyboardResize != null) {
        widget.onKeyboardResize!(-1, fast);
      } else {
        widget.onKeyboardMove(-1, fast);
      }
      return KeyEventResult.handled;
    }
    if (widget.keyboardEnabled &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (resize && widget.onKeyboardResize != null) {
        widget.onKeyboardResize!(1, fast);
      } else {
        widget.onKeyboardMove(1, fast);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _activate();
      return KeyEventResult.handled;
    }
    if (widget.onTimeEdit != null &&
        (event.logicalKey == LogicalKeyboardKey.f2 ||
            event.logicalKey == LogicalKeyboardKey.keyE)) {
      widget.onTimeEdit!.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
class _CompactGapRow extends StatelessWidget {
  const _CompactGapRow({
    required this.start,
    required this.end,
    required this.gap,
    required this.theme,
    required this.previousAccent,
    required this.nextAccent,
    required this.layout,
    required this.onTap,
  });
  final DateTime start;
  final DateTime end;
  final NeonPlannerCompressedGap gap;
  final NeonPlannerTimelineThemeData theme;
  final Color previousAccent;
  final Color nextAccent;
  final _DayLayoutMetrics layout;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final accent = gap.color ?? Color.lerp(previousAccent, nextAccent, 0.5)!;
    final timeLabel = layout.isMicro
        ? 'bis ${_clock(end)}'
        : '${_clock(start)} bis ${_clock(end)}';
    final rowHeight = onTap == null ? layout.gapHeight : math.max(44.0, layout.gapHeight).toDouble();
    return SizedBox(
      height: rowHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(layout.isRegular ? 16 : 12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: layout.timeColumnWidth,
              child: Text(
                timeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.timeStyle.copyWith(
                  fontSize: layout.timeFontSize,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(
              width: layout.axisColumnWidth,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CustomPaint(
                    size: Size(3, rowHeight),
                    painter: _DottedLinePainter(
                      topColor: previousAccent,
                      bottomColor: nextAccent,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: layout.isRegular
                          ? 34
                          : layout.isCompact
                          ? 22
                          : 18,
                      child: Icon(
                        gap.icon,
                        color: accent,
                        size: layout.isRegular
                            ? 18
                            : layout.isCompact
                            ? 12
                            : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: layout.columnGap),
            Expanded(
              child: Text(
                '${gap.title} · ${_compactDuration(end.difference(start))}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.gapStyle.copyWith(
                  fontSize: layout.isRegular ? 14 : layout.metadataFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null)
              SizedBox(
                width: layout.statusColumnWidth,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.secondaryTextColor,
                  size: layout.isRegular ? 20 : 14,
                ),
              )
            else
              SizedBox(width: layout.statusColumnWidth),
          ],
        ),
      ),
    );
  }
}
class _CurrentMarker extends StatelessWidget {
  const _CurrentMarker({
    required this.label,
    required this.theme,
    required this.layout,
  });
  final String label;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.isRegular ? 46 : layout.isCompact ? 32 : 28,
      child: Row(
        children: <Widget>[
          SizedBox(width: layout.timeColumnWidth),
          SizedBox(
            width: layout.axisColumnWidth,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.focusColor,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.focusColor.withValues(alpha: 0.22),
                      blurRadius: layout.isRegular ? 8 : 4,
                    ),
                  ],
                ),
                child: SizedBox.square(
                  dimension: layout.isRegular ? 10 : 6,
                ),
              ),
            ),
          ),
          SizedBox(width: layout.columnGap),
          Expanded(
            child: Divider(
              color: theme.focusColor.withValues(alpha: 0.42),
              thickness: 1.2,
            ),
          ),
          SizedBox(width: layout.isRegular ? 8 : 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.focusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.isRegular ? 12 : 6,
                vertical: layout.isRegular ? 6 : 3,
              ),
              child: Text(
                label,
                style: theme.metadataStyle.copyWith(
                  color: theme.focusColor,
                  fontSize: layout.metadataFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: layout.statusColumnWidth),
        ],
      ),
    );
  }
}
class _EmptyDayTimeline extends StatelessWidget {
  const _EmptyDayTimeline({
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.layout,
    required this.onCreateTap,
  });

  final String title;
  final String subtitle;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  final VoidCallback? onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: layout.isRegular ? 42 : layout.isCompact ? 20 : 16,
        horizontal: layout.isRegular ? 18 : 8,
      ),
      child: Semantics(
        label: '$title. $subtitle',
        child: Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.successColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: layout.isRegular ? 76 : layout.isCompact ? 48 : 44,
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: theme.successColor,
                  size: layout.isRegular ? 34 : layout.isCompact ? 23 : 21,
                ),
              ),
            ),
            SizedBox(height: layout.isRegular ? 18 : 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.titleStyle.copyWith(
                fontSize: layout.isRegular ? 20 : layout.titleFontSize + 1,
              ),
            ),
            SizedBox(height: layout.isRegular ? 8 : 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.metadataStyle.copyWith(
                fontSize: layout.isRegular ? 14 : layout.metadataFontSize,
              ),
            ),
            if (onCreateTap != null) ...<Widget>[
              SizedBox(height: layout.isRegular ? 20 : 12),
              FilledButton.icon(
                onPressed: onCreateTap,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Termin erstellen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

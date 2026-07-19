part of 'day_timeline_view.dart';

const EdgeInsets _defaultDayTimelinePadding = EdgeInsets.fromLTRB(
  22,
  10,
  22,
  18,
);

@immutable
class _DragFeedbackGeometry {
  const _DragFeedbackGeometry({
    required this.anchor,
    required this.minLeft,
    required this.maxLeft,
    required this.minTop,
    required this.maxTop,
  });

  final Offset anchor;
  final double minLeft;
  final double maxLeft;
  final double minTop;
  final double maxTop;

  Offset correctionFor(Offset globalPosition) {
    final left = globalPosition.dx - anchor.dx;
    final top = globalPosition.dy - anchor.dy;
    final boundedLeft = left.clamp(minLeft, maxLeft).toDouble();
    final boundedTop = top.clamp(minTop, maxTop).toDouble();
    return Offset(boundedLeft - left, boundedTop - top);
  }
}

@immutable
class _DayLayoutMetrics {
  const _DayLayoutMetrics({
    required this.responsiveDensity,
    required this.surfacePadding,
    required this.borderRadius,
    required this.availableContentWidth,
    required this.timeColumnWidth,
    required this.axisColumnWidth,
    required this.statusColumnWidth,
    required this.columnGap,
    required this.entryMinHeight,
    required this.gapHeight,
    required this.nodeSize,
    required this.nodeIconSize,
    required this.statusSize,
    required this.titleFontSize,
    required this.timeFontSize,
    required this.metadataFontSize,
    required this.durationFontSize,
    required this.headerButtonSize,
    required this.headerTitleFontSize,
    required this.metricsHeight,
    required this.feedbackMaxWidth,
    required this.timeLensWidth,
    required this.timeLensHeight,
    required this.timeLensMarks,
    required this.timeLensLabelOnly,
  });

  final NeonPlannerResponsiveDensity responsiveDensity;
  final EdgeInsets surfacePadding;
  final double borderRadius;
  final double availableContentWidth;
  final double timeColumnWidth;
  final double axisColumnWidth;
  final double statusColumnWidth;
  final double columnGap;
  final double entryMinHeight;
  final double gapHeight;
  final double nodeSize;
  final double nodeIconSize;
  final double statusSize;
  final double titleFontSize;
  final double timeFontSize;
  final double metadataFontSize;
  final double durationFontSize;
  final double headerButtonSize;
  final double headerTitleFontSize;
  final double metricsHeight;
  final double feedbackMaxWidth;
  final double timeLensWidth;
  final double timeLensHeight;
  final int timeLensMarks;
  final bool timeLensLabelOnly;

  bool get isMicro =>
      responsiveDensity == NeonPlannerResponsiveDensity.micro;

  bool get isCompact =>
      responsiveDensity == NeonPlannerResponsiveDensity.compact;

  bool get isRegular =>
      responsiveDensity == NeonPlannerResponsiveDensity.regular;

  double get timelineLeadingWidth => timeColumnWidth + axisColumnWidth;

  double get feedbackWidth {
    final usable = math.max(0.0, availableContentWidth - 12).toDouble();
    return math.min(usable, feedbackMaxWidth).toDouble();
  }

  double get timeLensVerticalInset =>
      timeLensLabelOnly ? timeLensHeight / 2 + 6 : timeLensHeight / 2 + 8;

  double get feedbackEstimatedHeight => isRegular ? 132 : isCompact ? 84 : 76;

  static _DayLayoutMetrics resolve({
    required double width,
    required EdgeInsets configuredPadding,
    required double configuredBorderRadius,
    required NeonPlannerDayDensity verticalDensity,
    required NeonPlannerResponsiveDensity responsiveDensity,
  }) {
    final usesDefaultPadding = configuredPadding == _defaultDayTimelinePadding;
    final usesDefaultRadius = configuredBorderRadius == 42;

    final surfacePadding = switch (responsiveDensity) {
      NeonPlannerResponsiveDensity.micro => usesDefaultPadding
          ? const EdgeInsets.fromLTRB(4, 4, 4, 8)
          : configuredPadding,
      NeonPlannerResponsiveDensity.compact => usesDefaultPadding
          ? const EdgeInsets.fromLTRB(6, 4, 6, 8)
          : configuredPadding,
      NeonPlannerResponsiveDensity.regular => configuredPadding,
    };
    final availableContentWidth = math.max(
      0.0,
      width.isFinite ? width - surfacePadding.horizontal : 480.0,
    ).toDouble();

    final verticalScale = switch (verticalDensity) {
      NeonPlannerDayDensity.compact => 0.92,
      NeonPlannerDayDensity.comfortable => 1.0,
      NeonPlannerDayDensity.spacious => 1.12,
    };

    return switch (responsiveDensity) {
      NeonPlannerResponsiveDensity.micro => _DayLayoutMetrics(
          responsiveDensity: responsiveDensity,
          surfacePadding: surfacePadding,
          borderRadius: usesDefaultRadius ? 18 : configuredBorderRadius,
          availableContentWidth: availableContentWidth,
          timeColumnWidth: 36,
          axisColumnWidth: 36,
          statusColumnWidth: 18,
          columnGap: 2,
          entryMinHeight: 52 * verticalScale,
          gapHeight: 28 * verticalScale,
          nodeSize: 32,
          nodeIconSize: 15,
          statusSize: 16,
          titleFontSize: 13,
          timeFontSize: 10,
          metadataFontSize: 9,
          durationFontSize: 8.5,
          headerButtonSize: 44,
          headerTitleFontSize: 16.5,
          metricsHeight: 50,
          feedbackMaxWidth: 172,
          timeLensWidth: 56,
          timeLensHeight: 26,
          timeLensMarks: 1,
          timeLensLabelOnly: true,
        ),
      NeonPlannerResponsiveDensity.compact => _DayLayoutMetrics(
          responsiveDensity: responsiveDensity,
          surfacePadding: surfacePadding,
          borderRadius: usesDefaultRadius ? 22 : configuredBorderRadius,
          availableContentWidth: availableContentWidth,
          timeColumnWidth: 40,
          axisColumnWidth: 40,
          statusColumnWidth: 20,
          columnGap: 3,
          entryMinHeight: 58 * verticalScale,
          gapHeight: 30 * verticalScale,
          nodeSize: 36,
          nodeIconSize: 16,
          statusSize: 18,
          titleFontSize: 13.5,
          timeFontSize: 10.5,
          metadataFontSize: 9.5,
          durationFontSize: 9,
          headerButtonSize: 44,
          headerTitleFontSize: 17,
          metricsHeight: 54,
          feedbackMaxWidth: 190,
          timeLensWidth: 62,
          timeLensHeight: 28,
          timeLensMarks: 1,
          timeLensLabelOnly: true,
        ),
      NeonPlannerResponsiveDensity.regular => _DayLayoutMetrics(
          responsiveDensity: responsiveDensity,
          surfacePadding: surfacePadding,
          borderRadius: configuredBorderRadius,
          availableContentWidth: availableContentWidth,
          timeColumnWidth: 72,
          axisColumnWidth: 78,
          statusColumnWidth: 46,
          columnGap: 12,
          entryMinHeight: 104 * verticalScale,
          gapHeight: 62 * verticalScale,
          nodeSize: 60,
          nodeIconSize: 26,
          statusSize: 30,
          titleFontSize: 18,
          timeFontSize: 14,
          metadataFontSize: 13.5,
          durationFontSize: 12,
          headerButtonSize: 54,
          headerTitleFontSize: 25,
          metricsHeight: 104,
          feedbackMaxWidth: 360,
          timeLensWidth: 128,
          timeLensHeight: 156,
          timeLensMarks: 5,
          timeLensLabelOnly: false,
        ),
    };
  }
}

extension _DayResponsiveState<T> on _NeonPlannerDayTimelineState<T> {
  NeonPlannerResponsiveDensity _resolveResponsiveDensity(double width) {
    if (!widget.autoResponsiveDensity || !width.isFinite) {
      return widget.responsiveDensity;
    }
    if (width <= widget.microBreakpoint) {
      return NeonPlannerResponsiveDensity.micro;
    }
    if (width <= widget.compactBreakpoint) {
      return NeonPlannerResponsiveDensity.compact;
    }
    return NeonPlannerResponsiveDensity.regular;
  }

  bool _showTimeLens(_DayLayoutMetrics layout) {
    if (!widget.showAdaptiveTimeLens) {
      return false;
    }
    return switch (widget.timeLensMode) {
      NeonPlannerTimeLensMode.disabled => false,
      NeonPlannerTimeLensMode.enabled => true,
      NeonPlannerTimeLensMode.automatic =>
        layout.availableContentWidth >= layout.timeLensWidth + 16,
    };
  }

  Offset _boundedFeedbackAnchor(
    BuildContext context,
    Offset globalPosition,
    _DayLayoutMetrics layout,
  ) {
    final childRenderObject = context.findRenderObject();
    final listRenderObject = _listKey.currentContext?.findRenderObject();
    final overlayRenderObject = Overlay.maybeOf(
      context,
      rootOverlay: true,
    )?.context.findRenderObject();
    if (childRenderObject is! RenderBox ||
        listRenderObject is! RenderBox ||
        overlayRenderObject is! RenderBox) {
      _dragFeedbackGeometry = null;
      return Offset.zero;
    }

    final localAnchor = childRenderObject.globalToLocal(globalPosition);
    final contentOrigin = listRenderObject.localToGlobal(Offset.zero);
    final overlayOrigin = overlayRenderObject.localToGlobal(Offset.zero);
    final safePadding = MediaQuery.viewPaddingOf(context);
    const edgeInset = 8.0;
    final minLeft = contentOrigin.dx + 6;
    final maxLeft = math.max(
      minLeft,
      contentOrigin.dx + listRenderObject.size.width - 6 - layout.feedbackWidth,
    ).toDouble();
    final minTop = overlayOrigin.dy + safePadding.top + edgeInset;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final scaledHeightAllowance =
        ((textScale - 1).clamp(0.0, 1.0) * 44).toDouble();
    final feedbackHeight =
        layout.feedbackEstimatedHeight + scaledHeightAllowance;
    final maxTop = math.max(
      minTop,
      overlayOrigin.dy +
          overlayRenderObject.size.height -
          safePadding.bottom -
          edgeInset -
          feedbackHeight,
    ).toDouble();
    final feedbackLeft = (globalPosition.dx - localAnchor.dx)
        .clamp(minLeft, maxLeft)
        .toDouble();
    final feedbackTop = (globalPosition.dy - localAnchor.dy)
        .clamp(minTop, maxTop)
        .toDouble();
    final anchor = Offset(
      globalPosition.dx - feedbackLeft,
      globalPosition.dy - feedbackTop,
    );
    _dragFeedbackGeometry = _DragFeedbackGeometry(
      anchor: anchor,
      minLeft: minLeft,
      maxLeft: maxLeft,
      minTop: minTop,
      maxTop: maxTop,
    );
    return anchor;
  }
}

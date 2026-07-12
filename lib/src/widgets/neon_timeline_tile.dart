import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../models/neon_timeline_types.dart';
import '../theme/neon_timeline_theme.dart';
import 'neon_timeline_indicator.dart';
import 'neon_timeline_node.dart';

/// Composes primary content, opposite content, marker, and connectors.
class NeonTimelineTile extends StatelessWidget {
  /// Creates one timeline tile.
  const NeonTimelineTile({
    required this.content,
    this.oppositeContent,
    this.indicator,
    this.axis = Axis.vertical,
    this.layout = NeonTimelineLayout.center,
    this.status = NeonTimelineStatus.pending,
    this.isFirst = false,
    this.isLast = false,
    this.alternate = false,
    this.beforeConnectorStyle,
    this.afterConnectorStyle,
    this.indicatorPosition = 0.5,
    this.animateIndicator = true,
    this.extent,
    this.padding,
    this.contentGap,
    this.nodeLaneExtent,
    this.adaptiveBreakpoint,
    this.semanticLabel,
    this.semanticIndex,
    this.onTap,
    super.key,
  })  : assert(indicatorPosition >= 0 && indicatorPosition <= 1),
        assert(extent == null || extent > 0),
        assert(contentGap == null || contentGap >= 0),
        assert(nodeLaneExtent == null || nodeLaneExtent > 0),
        assert(adaptiveBreakpoint == null || adaptiveBreakpoint >= 0);

  /// Primary item content.
  final Widget content;

  /// Optional content on the opposite side of a centered rail.
  final Widget? oppositeContent;

  /// Optional custom marker.
  final Widget? indicator;

  /// Main timeline axis.
  final Axis axis;

  /// Rail and content placement.
  final NeonTimelineLayout layout;

  /// Status used by the default marker and semantics.
  final NeonTimelineStatus status;

  /// Whether this tile begins the timeline.
  final bool isFirst;

  /// Whether this tile ends the timeline.
  final bool isLast;

  /// Whether an alternating layout should swap the two sides.
  final bool alternate;

  /// Optional style for the preceding connector.
  final NeonTimelineConnectorStyle? beforeConnectorStyle;

  /// Optional style for the following connector.
  final NeonTimelineConnectorStyle? afterConnectorStyle;

  /// Marker position within the tile's main-axis extent.
  final double indicatorPosition;

  /// Whether the package-owned default indicator follows shared motion.
  final bool animateIndicator;

  /// Fixed main-axis extent. Vertical tiles are content-sized when omitted.
  final double? extent;

  /// Optional tile insets.
  final EdgeInsets? padding;

  /// Optional gap between the rail and content.
  final double? contentGap;

  /// Optional cross-axis rail lane size.
  final double? nodeLaneExtent;

  /// Optional responsive breakpoint.
  final double? adaptiveBreakpoint;

  /// Optional screen-reader description.
  final String? semanticLabel;

  /// Optional ordinal used for assistive traversal.
  final int? semanticIndex;

  /// Optional pointer, keyboard, and assistive activation callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    final enabledOnTap = status == NeonTimelineStatus.disabled ? null : onTap;
    final resolvedPadding = padding ?? theme.tilePadding;
    final resolvedExtent =
        extent ?? (axis == Axis.horizontal ? theme.horizontalItemExtent : null);

    Widget result = Padding(
      padding: resolvedPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedLayout = _resolveLayout(constraints, theme);
          return axis == Axis.vertical
              ? _buildVertical(context, constraints, theme, resolvedLayout)
              : _buildHorizontal(context, constraints, theme, resolvedLayout);
        },
      ),
    );
    if (resolvedExtent != null) {
      result = axis == Axis.vertical
          ? SizedBox(height: resolvedExtent, child: result)
          : SizedBox(width: resolvedExtent, child: result);
    }

    if (enabledOnTap != null) {
      result = FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              enabledOnTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabledOnTap,
          child: result,
        ),
      );
    }

    result = Semantics(
      container: true,
      enabled: status != NeonTimelineStatus.disabled,
      button: enabledOnTap != null,
      label: semanticLabel,
      onTap: enabledOnTap,
      sortKey: semanticIndex == null
          ? null
          : OrdinalSortKey(semanticIndex!.toDouble()),
      child: result,
    );
    return RepaintBoundary(child: result);
  }

  NeonTimelineLayout _resolveLayout(
    BoxConstraints constraints,
    NeonTimelineThemeData theme,
  ) {
    if (layout != NeonTimelineLayout.adaptive) return layout;
    if (axis == Axis.horizontal) return NeonTimelineLayout.center;
    final width = constraints.maxWidth;
    final breakpoint = adaptiveBreakpoint ?? theme.adaptiveBreakpoint;
    return width.isFinite && width < breakpoint
        ? NeonTimelineLayout.start
        : NeonTimelineLayout.center;
  }

  Widget _buildVertical(
    BuildContext context,
    BoxConstraints constraints,
    NeonTimelineThemeData theme,
    NeonTimelineLayout resolvedLayout,
  ) {
    final gap = contentGap ?? theme.contentGap;
    final lane = nodeLaneExtent ?? theme.nodeLaneExtent;
    final sides = _resolveSides(resolvedLayout);
    final textDirection = Directionality.of(context);

    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: extent == null ? theme.verticalMinExtent : 0,
      ),
      child: Row(
        textDirection: textDirection,
        children: _verticalChildren(
          layout: resolvedLayout,
          lane: lane,
          gap: gap,
          before: sides.$1,
          after: sides.$2,
        ),
      ),
    );

    final node = NeonTimelineNode(
      axis: axis,
      indicator:
          indicator ??
              NeonTimelineIndicator(status: status, animate: animateIndicator),
      showBeforeConnector: !isFirst,
      showAfterConnector: !isLast,
      beforeStyle: beforeConnectorStyle,
      afterStyle: afterConnectorStyle,
      indicatorPosition: indicatorPosition,
      indicatorExtent: theme.indicatorStyle.visualExtent,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        row,
        if (resolvedLayout == NeonTimelineLayout.start)
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: lane,
            child: node,
          )
        else if (resolvedLayout == NeonTimelineLayout.end)
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            width: lane,
            child: node,
          )
        else
          Positioned(
            left: (constraints.maxWidth - lane) / 2,
            top: 0,
            bottom: 0,
            width: lane,
            child: node,
          ),
      ],
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    BoxConstraints constraints,
    NeonTimelineThemeData theme,
    NeonTimelineLayout resolvedLayout,
  ) {
    final gap = contentGap ?? theme.contentGap;
    final lane = nodeLaneExtent ?? theme.nodeLaneExtent;
    final sides = _resolveSides(resolvedLayout);
    final column = Column(
      children: _horizontalChildren(
        layout: resolvedLayout,
        lane: lane,
        gap: gap,
        before: sides.$1,
        after: sides.$2,
      ),
    );
    final node = NeonTimelineNode(
      axis: axis,
      indicator:
          indicator ??
              NeonTimelineIndicator(status: status, animate: animateIndicator),
      showBeforeConnector: !isFirst,
      showAfterConnector: !isLast,
      beforeStyle: beforeConnectorStyle,
      afterStyle: afterConnectorStyle,
      indicatorPosition: indicatorPosition,
      indicatorExtent: theme.indicatorStyle.visualExtent,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        column,
        if (resolvedLayout == NeonTimelineLayout.start)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: lane,
            child: node,
          )
        else if (resolvedLayout == NeonTimelineLayout.end)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: lane,
            child: node,
          )
        else
          Positioned(
            top: (constraints.maxHeight - lane) / 2,
            left: 0,
            right: 0,
            height: lane,
            child: node,
          ),
      ],
    );
  }

  (Widget?, Widget?) _resolveSides(NeonTimelineLayout resolvedLayout) {
    final combined = _CombinedContent(
      oppositeContent: oppositeContent,
      content: content,
    );
    return switch (resolvedLayout) {
      NeonTimelineLayout.start => (null, combined),
      NeonTimelineLayout.end => (combined, null),
      NeonTimelineLayout.center || NeonTimelineLayout.adaptive => (
          oppositeContent,
          content
        ),
      NeonTimelineLayout.alternating =>
        alternate ? (content, oppositeContent) : (oppositeContent, content),
    };
  }

  List<Widget> _verticalChildren({
    required NeonTimelineLayout layout,
    required double lane,
    required double gap,
    required Widget? before,
    required Widget? after,
  }) {
    if (layout == NeonTimelineLayout.start) {
      return [
        SizedBox(width: lane),
        SizedBox(width: gap),
        Expanded(child: _SideContent.verticalAfter(child: after)),
      ];
    }
    if (layout == NeonTimelineLayout.end) {
      return [
        Expanded(child: _SideContent.verticalBefore(child: before)),
        SizedBox(width: gap),
        SizedBox(width: lane),
      ];
    }
    return [
      Expanded(child: _SideContent.verticalBefore(child: before)),
      SizedBox(width: gap),
      SizedBox(width: lane),
      SizedBox(width: gap),
      Expanded(child: _SideContent.verticalAfter(child: after)),
    ];
  }

  List<Widget> _horizontalChildren({
    required NeonTimelineLayout layout,
    required double lane,
    required double gap,
    required Widget? before,
    required Widget? after,
  }) {
    if (layout == NeonTimelineLayout.start) {
      return [
        SizedBox(height: lane),
        SizedBox(height: gap),
        Expanded(child: _SideContent.horizontalAfter(child: after)),
      ];
    }
    if (layout == NeonTimelineLayout.end) {
      return [
        Expanded(child: _SideContent.horizontalBefore(child: before)),
        SizedBox(height: gap),
        SizedBox(height: lane),
      ];
    }
    return [
      Expanded(child: _SideContent.horizontalBefore(child: before)),
      SizedBox(height: gap),
      SizedBox(height: lane),
      SizedBox(height: gap),
      Expanded(child: _SideContent.horizontalAfter(child: after)),
    ];
  }
}

class _CombinedContent extends StatelessWidget {
  const _CombinedContent(
      {required this.oppositeContent, required this.content});

  final Widget? oppositeContent;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (oppositeContent != null) ...[
          oppositeContent!,
          const SizedBox(height: 6),
        ],
        content,
      ],
    );
  }
}

class _SideContent extends StatelessWidget {
  const _SideContent({required this.child, required this.alignment});

  const _SideContent.verticalBefore({required Widget? child})
      : this(child: child, alignment: AlignmentDirectional.centerEnd);

  const _SideContent.verticalAfter({required Widget? child})
      : this(child: child, alignment: AlignmentDirectional.centerStart);

  const _SideContent.horizontalBefore({required Widget? child})
      : this(child: child, alignment: Alignment.bottomCenter);

  const _SideContent.horizontalAfter({required Widget? child})
      : this(child: child, alignment: Alignment.topCenter);

  final Widget? child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

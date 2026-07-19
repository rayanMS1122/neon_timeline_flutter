import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/neon_timeline_theme.dart';
import 'neon_timeline_connector.dart';

/// Places an indicator between independently styled connector segments.
class NeonTimelineNode extends StatelessWidget {
  /// Creates a node that fills the available main-axis space.
  const NeonTimelineNode({
    required this.indicator,
    this.axis = Axis.vertical,
    this.showBeforeConnector = true,
    this.showAfterConnector = true,
    this.beforeStyle,
    this.afterStyle,
    this.indicatorPosition = 0.5,
    this.indicatorExtent,
    this.connectorGap = 2,
    super.key,
  }) : assert(indicatorPosition >= 0 && indicatorPosition <= 1),
       assert(indicatorExtent == null || indicatorExtent > 0),
       assert(connectorGap >= 0);

  /// Marker displayed by the node.
  final Widget indicator;

  /// Main timeline axis.
  final Axis axis;

  /// Whether a segment is painted before the marker.
  final bool showBeforeConnector;

  /// Whether a segment is painted after the marker.
  final bool showAfterConnector;

  /// Optional style for the preceding segment.
  final NeonTimelineConnectorStyle? beforeStyle;

  /// Optional style for the following segment.
  final NeonTimelineConnectorStyle? afterStyle;

  /// Marker position as a fraction of the node's main-axis extent.
  final double indicatorPosition;

  /// Main-axis space reserved for the marker.
  final double? indicatorExtent;

  /// Empty space between the marker and each connector.
  final double connectorGap;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    final markerExtent = indicatorExtent ?? theme.indicatorStyle.visualExtent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = axis == Axis.vertical
            ? constraints.maxHeight
            : constraints.maxWidth;
        if (!available.isFinite) {
          return SizedBox.square(
            dimension: markerExtent,
            child: Center(child: indicator),
          );
        }

        final center =
            (available <= markerExtent
                    ? available / 2
                    : (available * indicatorPosition).clamp(
                        markerExtent / 2,
                        available - markerExtent / 2,
                      ))
                .toDouble();
        final beforeExtent = math
            .max(0, center - markerExtent / 2 - connectorGap)
            .toDouble();
        final afterStart = math
            .min(available, center + markerExtent / 2 + connectorGap)
            .toDouble();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (showBeforeConnector && beforeExtent > 0)
              _positionedSegment(
                start: 0,
                extent: beforeExtent,
                child: NeonTimelineConnector(axis: axis, style: beforeStyle),
              ),
            if (showAfterConnector && afterStart < available)
              _positionedSegment(
                start: afterStart,
                extent: available - afterStart,
                child: NeonTimelineConnector(axis: axis, style: afterStyle),
              ),
            _positionedIndicator(
              start: center - markerExtent / 2,
              extent: markerExtent,
            ),
          ],
        );
      },
    );
  }

  Widget _positionedSegment({
    required double start,
    required double extent,
    required Widget child,
  }) {
    if (axis == Axis.vertical) {
      return Positioned(
        top: start,
        height: extent,
        left: 0,
        right: 0,
        child: child,
      );
    }
    return Positioned(
      left: start,
      width: extent,
      top: 0,
      bottom: 0,
      child: child,
    );
  }

  Widget _positionedIndicator({required double start, required double extent}) {
    if (axis == Axis.vertical) {
      return Positioned(
        top: start,
        height: extent,
        left: 0,
        right: 0,
        child: Center(child: indicator),
      );
    }
    return Positioned(
      left: start,
      width: extent,
      top: 0,
      bottom: 0,
      child: Center(child: indicator),
    );
  }
}

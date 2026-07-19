import 'package:flutter/material.dart';

import '../../v7/models/structured_timeline_style.dart';

class StructuredTimelineTimeRail extends StatelessWidget {
  const StructuredTimelineTimeRail({
    required this.style,
    this.activeColor,
    this.width = 2,
    super.key,
  });

  final StructuredTimelineStyle style;
  final Color? activeColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.center,
        child: Container(width: width, color: activeColor ?? style.railColor),
      ),
    );
  }
}

class StructuredTimelineRailMarker extends StatelessWidget {
  const StructuredTimelineRailMarker({
    required this.style,
    required this.color,
    this.icon = Icons.schedule_rounded,
    this.semanticLabel,
    super.key,
  });

  final StructuredTimelineStyle style;
  final Color color;
  final IconData icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: style.markerWidth,
        height: style.markerHeight,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            color.withValues(alpha: 0.1),
            style.surfaceColor,
          ),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

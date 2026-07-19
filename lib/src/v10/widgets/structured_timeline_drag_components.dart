import 'package:flutter/material.dart';

import '../../v7/models/structured_timeline_style.dart';

class StructuredTimelineDragScrim extends StatelessWidget {
  const StructuredTimelineDragScrim({
    this.opacity = 0.04,
    this.color = Colors.black,
    super.key,
  });

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(color: color.withValues(alpha: opacity.clamp(0, 1))),
    );
  }
}

class StructuredTimelineSnapGuide extends StatelessWidget {
  const StructuredTimelineSnapGuide({
    required this.label,
    required this.style,
    this.blocked = false,
    this.magnetized = false,
    this.conflictCount = 0,
    super.key,
  });

  final String label;
  final StructuredTimelineStyle style;
  final bool blocked;
  final bool magnetized;
  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return IgnorePointer(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    blocked
                        ? Icons.block_rounded
                        : magnetized
                        ? Icons.auto_fix_high_rounded
                        : Icons.drag_indicator_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  if (conflictCount > 0) ...<Widget>[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$conflictCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StructuredTimelineDropSlot extends StatelessWidget {
  const StructuredTimelineDropSlot({
    required this.height,
    required this.style,
    this.blocked = false,
    this.label,
    super.key,
  });

  final double height;
  final StructuredTimelineStyle style;
  final bool blocked;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(style.cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.68), width: 1.5),
        ),
        child: label == null
            ? null
            : Center(
                child: Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
      ),
    );
  }
}

class StructuredTimelineDragFeedbackCard extends StatelessWidget {
  const StructuredTimelineDragFeedbackCard({
    required this.child,
    required this.style,
    required this.timeLabel,
    this.blocked = false,
    this.magnetized = false,
    this.conflictCount = 0,
    this.scale = 1.05,
    this.elevation = 28,
    super.key,
  });

  final Widget child;
  final StructuredTimelineStyle style;
  final String timeLabel;
  final bool blocked;
  final bool magnetized;
  final int conflictCount;
  final double scale;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? style.conflictColor : style.primaryColor;
    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        shadowColor: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(style.cardRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            Positioned(
              left: 14,
              top: -14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        blocked
                            ? Icons.warning_amber_rounded
                            : magnetized
                            ? Icons.auto_fix_high_rounded
                            : Icons.schedule_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (conflictCount > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Text(
                          '· $conflictCount conflict${conflictCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StructuredTimelineActionDock extends StatelessWidget {
  const StructuredTimelineActionDock({
    required this.children,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(6),
    super.key,
  });

  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: padding,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

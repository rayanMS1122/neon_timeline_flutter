import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../v6/core/timeline_day_plan.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../models/structured_timeline_gap_layout.dart';

class StructuredTimelineGap<T> extends StatelessWidget {
  const StructuredTimelineGap({
    required this.gap,
    required this.style,
    required this.strings,
    required this.durationFormatter,
    this.layout = const StructuredTimelineGapLayout.hybrid(),
    this.onTap,
    this.showAction = true,
    this.actionVisible = false,
    this.timeColumnOnRight = false,
    this.compressedLabel,
    super.key,
  });

  final TimelineDayGap<T> gap;
  final StructuredTimelineStyle style;
  final StructuredTimelineStrings strings;
  final StructuredTimelineDurationFormatter durationFormatter;
  final StructuredTimelineGapLayout layout;
  final StructuredTimelineGapCallback<T>? onTap;
  final bool showAction;
  final bool actionVisible;
  final bool timeColumnOnRight;
  final String? compressedLabel;

  @override
  Widget build(BuildContext context) {
    final extent = layout.extentFor(gap.duration);
    final compressed = layout.isCompressed(gap.duration);
    return Semantics(
      button: onTap != null,
      label: '${durationFormatter(gap.duration)} ${strings.freeToPlan}',
      child: SizedBox(
        height: extent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScaler = MediaQuery.textScalerOf(context);
            final showCompressedDetail =
                compressed && constraints.maxHeight >= textScaler.scale(44);
            final showExpandedAction =
                showAction &&
                onTap != null &&
                actionVisible &&
                constraints.maxHeight >= textScaler.scale(compressed ? 82 : 58);
            final verticalPadding = constraints.maxHeight < textScaler.scale(28)
                ? 2.0
                : 5.0;
            final contentInset =
                style.horizontalPadding +
                style.timeColumnWidth +
                style.markerWidth +
                style.columnGap * 2;
            final markerCenterX = timeColumnOnRight
                ? constraints.maxWidth -
                      style.horizontalPadding -
                      style.timeColumnWidth -
                      style.columnGap -
                      style.markerWidth / 2
                : style.horizontalPadding +
                      style.timeColumnWidth +
                      style.columnGap +
                      style.markerWidth / 2;
            return Stack(
              children: <Widget>[
                Positioned(
                  left: markerCenterX - 1,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(
                    color: style.railColor,
                    child: const SizedBox(width: 2),
                  ),
                ),
                Positioned.fill(
                  left: timeColumnOnRight
                      ? style.horizontalPadding
                      : contentInset,
                  right: timeColumnOnRight
                      ? contentInset
                      : style.horizontalPadding,
                  child: Center(
                    child: InkWell(
                      onTap: onTap == null
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              unawaited(
                                Future<void>.sync(() => onTap!(context, gap)),
                              );
                            },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  compressed
                                      ? Icons.compress_rounded
                                      : Icons.schedule_rounded,
                                  size: 14,
                                  color: gap.containsNow
                                      ? style.primaryColor
                                      : style.mutedTextColor,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${durationFormatter(gap.duration)} ${strings.freeToPlan}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: style.mutedTextColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (showCompressedDetail) ...<Widget>[
                              const SizedBox(height: 3),
                              Text(
                                compressedLabel ?? strings.compressedFreeTime,
                                style: TextStyle(
                                  color: style.mutedTextColor.withValues(
                                    alpha: 0.78,
                                  ),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (showExpandedAction) ...<Widget>[
                              const SizedBox(height: 7),
                              StructuredTimelineGapAction(
                                label: strings.addTask,
                                color: style.primaryColor,
                                onPressed: () => unawaited(
                                  Future<void>.sync(() => onTap!(context, gap)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StructuredTimelineGapAction extends StatelessWidget {
  const StructuredTimelineGapAction({
    required this.label,
    required this.color,
    this.onPressed,
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 32),
        visualDensity: VisualDensity.compact,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
      label: Text(label),
    );
  }
}

class StructuredTimelineConflictBadge extends StatelessWidget {
  const StructuredTimelineConflictBadge({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class StructuredTimelineConflictBridge extends StatelessWidget {
  const StructuredTimelineConflictBridge({
    required this.color,
    required this.overlap,
    required this.durationFormatter,
    super.key,
  });

  final Color color;
  final Duration overlap;
  final StructuredTimelineDurationFormatter durationFormatter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 18, height: 2, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 5),
        StructuredTimelineConflictBadge(
          label: '${durationFormatter(overlap)} overlap',
          color: color,
        ),
      ],
    );
  }
}

class StructuredTimelineCurrentTimeIndicator extends StatelessWidget {
  const StructuredTimelineCurrentTimeIndicator({
    required this.color,
    this.label = 'Now',
    super.key,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 2, color: color)),
        ],
      ),
    );
  }
}

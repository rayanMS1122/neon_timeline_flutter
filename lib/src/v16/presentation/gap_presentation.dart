import 'package:flutter/material.dart';

import '../theme/timeline_theme.dart';

/// Calm, non-interactive copy rendered in a sufficiently large time gap.
class NeonPlannerGapPresentation extends StatelessWidget {
  /// Creates a gap presentation.
  const NeonPlannerGapPresentation({
    required this.text,
    required this.theme,
    super.key,
  });

  /// Gap copy.
  final String text;

  /// Timeline theme.
  final NeonPlannerTimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surfaceColor.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.gridColor.withValues(alpha: 0.9)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Text(
                '✦',
                style: theme.gapStyle.copyWith(
                  fontSize: 14,
                  color: theme.warningColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.gapStyle,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: theme.gapTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

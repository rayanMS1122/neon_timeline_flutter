import 'package:flutter/material.dart';

import '../../v8/models/advanced_structured_timeline_details.dart';
import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';

/// Version 14 drag feedback: a card, grab capsule and live destination ribbon.
class FriendlyTimelineDragFeedback<T> extends StatelessWidget {
  const FriendlyTimelineDragFeedback({
    required this.details,
    required this.child,
    required this.timeFormatter,
    this.presentation = FriendlyTimelineDragPresentation.guided,
    this.scale = 1.02,
    super.key,
  });

  final AdvancedStructuredTimelineEntryDetails<T> details;
  final Widget child;
  final String Function(DateTime value) timeFormatter;
  final FriendlyTimelineDragPresentation presentation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final preview = details.movePreview;
    final allowed = preview?.canCommit ?? true;
    final magnetized = preview?.magnetized ?? false;
    final conflicts = preview?.conflicts.length ?? 0;
    final start = preview?.start ?? details.effectiveStart;
    final end = preview?.end ?? details.effectiveEnd;
    final accent = allowed
        ? magnetized
              ? theme.lavender
              : theme.primary
        : theme.error;
    final time = '${timeFormatter(start)} – ${timeFormatter(end)}';
    final status = !allowed
        ? 'Blocked'
        : magnetized
        ? 'Smart snap'
        : 'Move here';

    return Semantics(
      liveRegion: true,
      label: '$status. New time $time. '
          '${conflicts == 0 ? 'No conflict' : '$conflicts conflicts'}.',
      child: Transform.scale(
        scale: presentation == FriendlyTimelineDragPresentation.accessible
            ? 1
            : scale,
        child: Material(
          color: Colors.transparent,
          elevation: presentation == FriendlyTimelineDragPresentation.accessible
              ? 8
              : 24,
          shadowColor: theme.shadow,
          borderRadius: BorderRadius.circular(theme.cardRadius),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.cardRadius),
                  border: Border.all(color: accent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.cardRadius - 1),
                  child: child,
                ),
              ),
              PositionedDirectional(
                start: 12,
                top: -15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.panelStrong,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drag_indicator_rounded, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                start: 12,
                bottom: -17,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        magnetized
                            ? Icons.auto_fix_high_rounded
                            : allowed
                            ? Icons.schedule_rounded
                            : Icons.block_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (conflicts > 0) ...[
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$conflicts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft origin marker used by the new guided drag presentation.
class FriendlyTimelineDragPlaceholder<T> extends StatelessWidget {
  const FriendlyTimelineDragPlaceholder({
    required this.child,
    this.label = 'Started here',
    super.key,
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return Semantics(
      label: label,
      child: Stack(
        children: [
          Opacity(opacity: 0.12, child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.lavenderSoft.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(theme.cardRadius),
                  border: Border.all(
                    color: theme.lavender.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight < 58) {
                    return Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Icon(
                          Icons.subdirectory_arrow_left_rounded,
                          size: 18,
                          color: theme.lavender,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.panelStrong.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: theme.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.subdirectory_arrow_left_rounded,
                            size: 14,
                            color: theme.lavender,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: TextStyle(
                              color: theme.mutedText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

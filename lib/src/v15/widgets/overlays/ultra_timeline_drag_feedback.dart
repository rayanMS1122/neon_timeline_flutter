import 'package:flutter/material.dart';

import '../../../v8/models/advanced_structured_timeline_details.dart';
import '../../theme/ultra_timeline_theme.dart';

class UltraTimelineDragFeedback<T> extends StatelessWidget {
  const UltraTimelineDragFeedback({
    required this.details,
    required this.title,
    required this.timeLabel,
    super.key,
  });

  final AdvancedStructuredTimelineEntryDetails<T> details;
  final String title;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    final blocked = details.hasConflict;
    final statusColor = blocked ? theme.coral : theme.mint;
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 230, maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(theme.radiusLarge),
              border: Border.all(color: statusColor, width: 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.shadow,
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      blocked
                          ? Icons.warning_amber_rounded
                          : Icons.open_with_rounded,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: theme.text,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$timeLabel · ${blocked ? 'Conflict' : 'Free slot'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UltraTimelineDragPlaceholder<T> extends StatelessWidget {
  const UltraTimelineDragPlaceholder({
    required this.child,
    required this.details,
    super.key,
  });

  final Widget child;
  final AdvancedStructuredTimelineEntryDetails<T> details;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Stack(
      fit: StackFit.loose,
      children: [
        Opacity(opacity: 0.08, child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(theme.radiusMedium),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.7),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 12,
          top: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.outline),
              ),
              child: Text(
                'Started here',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

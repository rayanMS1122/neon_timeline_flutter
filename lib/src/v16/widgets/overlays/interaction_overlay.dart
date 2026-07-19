import 'package:flutter/material.dart';

import '../../theme/timeline_theme.dart';

/// Compact live feedback shown while moving or resizing an entry.
class NeonPlannerInteractionOverlay extends StatelessWidget {
  /// Creates an interaction overlay.
  const NeonPlannerInteractionOverlay({
    required this.title,
    required this.start,
    required this.end,
    required this.hasConflict,
    required this.theme,
    super.key,
  });

  /// Entry title.
  final String title;

  /// Proposed start.
  final DateTime start;

  /// Proposed end.
  final DateTime end;

  /// Conflict state.
  final bool hasConflict;

  /// Theme.
  final NeonPlannerTimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = hasConflict ? theme.errorColor : theme.successColor;
    return IgnorePointer(
      child: Material(
        elevation: 6,
        color: theme.surfaceColor,
        shadowColor: theme.shadowColor,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                hasConflict ? Icons.error_outline_rounded : Icons.check_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${_clock(start)}–${_clock(end)}',
                      style: theme.timeStyle.copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _clock(DateTime value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

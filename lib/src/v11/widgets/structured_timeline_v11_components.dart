import 'package:flutter/material.dart';

import '../models/structured_timeline_v11_config.dart';

/// Visible persistence/rollback feedback suitable for optimistic app flows.
class StructuredTimelinePersistenceBanner extends StatelessWidget {
  const StructuredTimelinePersistenceBanner({
    required this.state,
    this.message,
    this.onRetry,
    super.key,
  });

  final StructuredTimelinePersistenceState state;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (state == StructuredTimelinePersistenceState.idle) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final isError = state == StructuredTimelinePersistenceState.failed;
    final icon = switch (state) {
      StructuredTimelinePersistenceState.optimistic => Icons.bolt_rounded,
      StructuredTimelinePersistenceState.saving => Icons.cloud_upload_outlined,
      StructuredTimelinePersistenceState.queuedOffline =>
        Icons.cloud_off_outlined,
      StructuredTimelinePersistenceState.rollingBack => Icons.undo_rounded,
      StructuredTimelinePersistenceState.failed => Icons.error_outline_rounded,
      StructuredTimelinePersistenceState.idle => Icons.check,
    };
    final label =
        message ??
        switch (state) {
          StructuredTimelinePersistenceState.optimistic => 'Updating…',
          StructuredTimelinePersistenceState.saving => 'Saving…',
          StructuredTimelinePersistenceState.queuedOffline => 'Saved offline',
          StructuredTimelinePersistenceState.rollingBack =>
            'Restoring previous time…',
          StructuredTimelinePersistenceState.failed => 'Could not save change',
          StructuredTimelinePersistenceState.idle => '',
        };
    return Semantics(
      liveRegion: true,
      label: label,
      child: Material(
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label, maxLines: 2)),
              if (isError && onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Context actions for desktop/web without forcing an application menu.
class StructuredTimelineContextMenu extends StatelessWidget {
  const StructuredTimelineContextMenu({
    required this.child,
    this.onOpen,
    this.onDuplicate,
    this.onDelete,
    this.onMoveEarlier,
    this.onMoveLater,
    super.key,
  });

  final Widget child;
  final VoidCallback? onOpen;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveEarlier;
  final VoidCallback? onMoveLater;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            if (onOpen != null)
              const PopupMenuItem(value: 'open', child: Text('Open')),
            if (onMoveEarlier != null)
              const PopupMenuItem(
                value: 'earlier',
                child: Text('Move earlier'),
              ),
            if (onMoveLater != null)
              const PopupMenuItem(value: 'later', child: Text('Move later')),
            if (onDuplicate != null)
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            if (onDelete != null)
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        );
        switch (selected) {
          case 'open':
            onOpen?.call();
            break;
          case 'earlier':
            onMoveEarlier?.call();
            break;
          case 'later':
            onMoveLater?.call();
            break;
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case null:
            break;
        }
      },
      child: child,
    );
  }
}

/// Calm current-time indicator that does not own a ticker.
class StructuredTimelineCalmNowIndicator extends StatelessWidget {
  const StructuredTimelineCalmNowIndicator({
    required this.label,
    this.accent,
    this.lineThickness = 1.5,
    super.key,
  });

  final String label;
  final Color? accent;
  final double lineThickness;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      label: label,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: lineThickness,
              color: color.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

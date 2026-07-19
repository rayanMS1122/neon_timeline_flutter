import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../v10/models/structured_timeline_experience.dart';
import '../../theme/ultra_timeline_theme.dart';

class UltraDragStatusBar<T> extends StatelessWidget {
  const UltraDragStatusBar({
    required this.stateListenable,
    this.onCancel,
    super.key,
  });

  final ValueListenable<StructuredTimelineDragState<T>> stateListenable;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StructuredTimelineDragState<T>>(
      valueListenable: stateListenable,
      builder: (context, state, _) {
        return AnimatedSwitcher(
          duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
              ? Duration.zero
              : const Duration(milliseconds: 150),
          child: state.active
              ? _ActiveDragStatus<T>(
                  key: const ValueKey<String>('active-drag-status'),
                  state: state,
                  onCancel: onCancel,
                )
              : const SizedBox.shrink(
                  key: ValueKey<String>('idle-drag-status'),
                ),
        );
      },
    );
  }
}

class _ActiveDragStatus<T> extends StatelessWidget {
  const _ActiveDragStatus({
    required this.state,
    this.onCancel,
    super.key,
  });

  final StructuredTimelineDragState<T> state;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    final blocked = state.phase == StructuredTimelineDragPhase.blocked ||
        state.conflictCount > 0;
    final deleting = state.overDeleteTarget ||
        state.phase == StructuredTimelineDragPhase.deleting;
    final color = deleting ? theme.coral : blocked ? theme.amber : theme.mint;
    final icon = deleting
        ? Icons.delete_outline_rounded
        : blocked
            ? Icons.warning_amber_rounded
            : state.magnetized
                ? Icons.auto_fix_high_rounded
                : Icons.open_with_rounded;
    final label = deleting
        ? 'Release to delete'
        : blocked
            ? '${state.conflictCount} conflict${state.conflictCount == 1 ? '' : 's'}'
            : state.magnetized
                ? 'Magnetic snap active'
                : 'Move to a new time';
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 7, 7),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: theme.text,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (onCancel != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Cancel drag',
              visualDensity: VisualDensity.compact,
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

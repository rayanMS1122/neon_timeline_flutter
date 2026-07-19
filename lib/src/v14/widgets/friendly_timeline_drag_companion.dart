import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../models/friendly_timeline_presentation_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';

/// Rebuild-isolated overlay for the live drag companion.
class FriendlyTimelineDragOverlay extends StatelessWidget {
  const FriendlyTimelineDragOverlay({
    this.stateListenable,
    this.fallbackState,
    this.fallbackTitle,
    this.onCancel,
    super.key,
  });

  final ValueListenable<FriendlyTimelineDragUiState>? stateListenable;
  final StructuredTimelineDragState<dynamic>? fallbackState;
  final String? fallbackTitle;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final listenable = stateListenable;
    if (listenable == null) {
      return _buildAnimatedCompanion(
        context,
        FriendlyTimelineDragUiState.fromDragState<dynamic>(
          fallbackState,
          title: fallbackTitle,
        ),
      );
    }
    return ValueListenableBuilder<FriendlyTimelineDragUiState>(
      valueListenable: listenable,
      builder: (context, state, _) => _buildAnimatedCompanion(context, state),
    );
  }

  Widget _buildAnimatedCompanion(
    BuildContext context,
    FriendlyTimelineDragUiState state,
  ) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final active = state.active;
    return IgnorePointer(
      ignoring: !active,
      child: AnimatedSlide(
        offset: active ? Offset.zero : const Offset(0, 1.4),
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 160),
          child: FriendlyTimelineDragCompanion.view(
            state: state,
            onCancel: onCancel,
          ),
        ),
      ),
    );
  }
}

/// Live bottom companion shown only while an entry is moving.
class FriendlyTimelineDragCompanion extends StatelessWidget {
  const FriendlyTimelineDragCompanion({
    this.state,
    this.title,
    this.onCancel,
    super.key,
  }) : viewState = null,
       assert(state != null);

  const FriendlyTimelineDragCompanion.view({
    required FriendlyTimelineDragUiState state,
    this.onCancel,
    super.key,
  }) : viewState = state,
       state = null,
       title = null;

  final StructuredTimelineDragState<dynamic>? state;
  final FriendlyTimelineDragUiState? viewState;
  final String? title;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final value = viewState ??
        FriendlyTimelineDragUiState.fromDragState<dynamic>(
          state,
          title: title,
        );
    final blocked = value.blocked;
    final deleting = value.deleting;
    final magnetized = value.magnetized;
    final conflictCount = value.conflictCount;
    final accent = deleting || blocked
        ? theme.error
        : magnetized
        ? theme.lavender
        : theme.primary;
    final label = deleting
        ? 'Release to delete'
        : blocked
        ? 'This position is blocked'
        : magnetized
        ? 'Magnetic target locked'
        : 'Release to place';
    final details = conflictCount == 0
        ? 'No conflict'
        : '$conflictCount conflict${conflictCount == 1 ? '' : 's'}';
    final entryTitle = value.title ?? title ?? 'Moving entry';
    return Semantics(
      liveRegion: true,
      label: '$entryTitle. $label. $details.',
      child: Material(
        elevation: 18,
        shadowColor: theme.shadow,
        color: theme.panelStrong,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  deleting
                      ? Icons.delete_sweep_rounded
                      : blocked
                      ? Icons.block_rounded
                      : magnetized
                      ? Icons.auto_fix_high_rounded
                      : Icons.pan_tool_alt_rounded,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$label · $details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded, size: 17),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.mutedText,
                    backgroundColor: theme.panel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: theme.outline),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Status pill with icon and text, never color alone.

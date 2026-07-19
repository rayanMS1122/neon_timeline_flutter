import 'package:flutter/material.dart';

import '../../v12/models/ultimate_timeline_details.dart';
import '../../v12/theme/ultimate_timeline_theme.dart';
import '../models/friendly_timeline_presentation_models.dart';
import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';

/// Icon resolver used by the default version 14 entry card.
typedef FriendlyTimelineEntryIconBuilder<T> =
    IconData Function(UltimateTimelineEntryDetails<T> details);

/// Accent resolver used by the default version 14 entry card.
typedef FriendlyTimelineEntryToneBuilder<T> =
    FriendlyTimelineIconTone Function(UltimateTimelineEntryDetails<T> details);

/// Adaptive task card with explicit state icons and a visible drag affordance.
class FriendlyTimelineEntryCard<T> extends StatelessWidget {
  const FriendlyTimelineEntryCard({
    required this.details,
    required this.title,
    required this.timeLabel,
    this.subtitle,
    this.progress,
    this.icon = Icons.auto_awesome_rounded,
    this.tone = FriendlyTimelineIconTone.primary,
    this.semanticLabel,
    this.showDragHandle = true,
    super.key,
  });

  /// Creates a card from the display-ready version 14 presentation model.
  factory FriendlyTimelineEntryCard.presentation({
    required FriendlyTimelineEntryPresentation<T> presentation,
    bool showDragHandle = true,
    Key? key,
  }) {
    return FriendlyTimelineEntryCard<T>(
      key: key,
      details: presentation.details,
      title: presentation.title,
      subtitle: presentation.subtitle,
      timeLabel: presentation.timeLabel,
      progress: presentation.progress,
      icon: presentation.icon,
      tone: presentation.tone,
      semanticLabel: presentation.semanticLabel,
      showDragHandle: showDragHandle,
    );
  }

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final double? progress;
  final IconData icon;
  final FriendlyTimelineIconTone tone;
  final String? semanticLabel;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final friendly = FriendlyTimelineUiTheme.of(context);
    final ultimate = UltimateTimelineTheme.of(context);
    final interaction = details.interaction;
    final accent = _accent(friendly, interaction);
    final background = Color.alphaBlend(
      friendly.backgroundFor(tone).withValues(alpha: 0.58),
      ultimate.surfaceElevated,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final largeText = textScale > 1.35;
        final compact = constraints.maxHeight < 66 || constraints.maxWidth < 280;
        final micro = constraints.maxHeight < (largeText ? 78 : 48);
        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;

        return Semantics(
          container: true,
          label: semanticLabel ?? '$title, $timeLabel',
          child: AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(friendly.cardRadius),
              border: Border.all(
                color: interaction.selected || interaction.focused
                    ? accent.withValues(alpha: 0.75)
                    : friendly.outline,
                width: interaction.selected || interaction.focused ? 1.5 : 1,
              ),
              boxShadow: interaction.dragging
                  ? const <BoxShadow>[]
                  : <BoxShadow>[
                      BoxShadow(
                        color: friendly.shadow,
                        blurRadius: interaction.selected ? 20 : 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(friendly.cardRadius),
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 5, color: accent),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      micro ? 10 : 12,
                      micro ? 5 : 9,
                      showDragHandle ? 48 : 12,
                      micro ? 5 : 9,
                    ),
                    child: Row(
                      children: [
                        if (!micro) ...[
                          _FriendlyEntryIcon(
                            icon: icon,
                            accent: accent,
                            compact: compact,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: _FriendlyEntryContent<T>(
                            details: details,
                            title: title,
                            subtitle: subtitle,
                            timeLabel: timeLabel,
                            progress: progress,
                            accent: accent,
                            compact: compact,
                            micro: micro,
                            largeText: largeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showDragHandle && !interaction.locked)
                    PositionedDirectional(
                      end: 7,
                      top: 0,
                      bottom: 0,
                      child: _FriendlyDragHandle(compact: compact),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _accent(
    FriendlyTimelineUiThemeData theme,
    UltimateTimelineEntryInteractionState<T> interaction,
  ) {
    if (interaction.error) return theme.error;
    if (interaction.locked || interaction.external) return theme.amber;
    if (interaction.completed) return theme.success;
    return theme.foregroundFor(tone);
  }
}

class _FriendlyEntryIcon extends StatelessWidget {
  const _FriendlyEntryIcon({
    required this.icon,
    required this.accent,
    required this.compact,
  });

  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final extent = compact ? 34.0 : 40.0;
    return Container(
      width: extent,
      height: extent,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
      ),
      child: Icon(icon, size: compact ? 18 : 21, color: accent),
    );
  }
}

class _FriendlyEntryContent<T> extends StatelessWidget {
  const _FriendlyEntryContent({
    required this.details,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.progress,
    required this.accent,
    required this.compact,
    required this.micro,
    required this.largeText,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final double? progress;
  final Color accent;
  final bool compact;
  final bool micro;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final interaction = details.interaction;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!(micro && largeText)) ...[
          Row(
            children: [
              Flexible(
                child: Text(
                  timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: micro ? 9.5 : 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (!micro) ...[
                const SizedBox(width: 7),
                _FriendlyStateIcons<T>(details: details),
              ],
            ],
          ),
          const SizedBox(height: 3),
        ],
        Text(
          title,
          maxLines: compact || micro ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: interaction.completed ? theme.mutedText : theme.text,
            fontSize: micro ? 12 : 14,
            height: 1.08,
            fontWeight: FontWeight.w900,
            decoration:
                interaction.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        if (!compact && !micro && subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (!compact && !micro && progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress!.clamp(0, 1).toDouble(),
              minHeight: 4,
              backgroundColor: theme.outline,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ],
    );
  }
}

class _FriendlyDragHandle extends StatelessWidget {
  const _FriendlyDragHandle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return Center(
      child: Semantics(
        button: true,
        label: 'Drag task',
        child: Container(
          width: 34,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            color: theme.panelStrong.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: theme.outline),
          ),
          child: Icon(
            Icons.drag_indicator_rounded,
            size: 20,
            color: theme.mutedText,
          ),
        ),
      ),
    );
  }
}

class _FriendlyStateIcons<T> extends StatelessWidget {
  const _FriendlyStateIcons({required this.details});

  final UltimateTimelineEntryDetails<T> details;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final state = details.interaction;
    final icons = <(IconData, Color, String)>[];
    if (state.locked) icons.add((Icons.lock_rounded, theme.amber, 'Locked'));
    if (state.recurring) {
      icons.add((Icons.repeat_rounded, theme.lavender, 'Recurring'));
    }
    if (state.external) {
      icons.add((Icons.event_busy_rounded, theme.sky, 'External'));
    }
    if (state.error) {
      icons.add((Icons.error_outline_rounded, theme.error, 'Error'));
    }
    if (icons.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < icons.length; index++) ...[
          Tooltip(
            message: icons[index].$3,
            child: Icon(icons[index].$1, size: 12, color: icons[index].$2),
          ),
          if (index != icons.length - 1) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

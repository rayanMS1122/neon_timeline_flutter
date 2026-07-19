import 'package:flutter/material.dart';

import '../../api/ultra_timeline_config.dart';
import '../../presentation/ultra_timeline_presentation.dart';
import '../../theme/ultra_timeline_theme.dart';

/// Adaptive v15 entry card with micro, compact and detailed compositions.
class UltraTimelineEntryCard<T> extends StatelessWidget {
  const UltraTimelineEntryCard({
    required this.presentation,
    required this.zoom,
    this.showDragHandle = true,
    this.reducedMotion = false,
    super.key,
  });

  final UltraTimelineEntryPresentation<T> presentation;
  final UltraTimelineZoomLevel zoom;
  final bool showDragHandle;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    final details = presentation.details;
    final tone = theme.tone(presentation.tone);
    final selected = details.interaction.selected || details.interaction.focused;
    final completed = details.interaction.completed;

    return Semantics(
      button: true,
      selected: selected,
      enabled: !details.interaction.locked,
      label: presentation.semanticLabel ??
          '${presentation.title}, ${presentation.timeLabel}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : _fallbackHeight(zoom);
          final compact = height < 64 ||
              zoom == UltraTimelineZoomLevel.overview ||
              zoom == UltraTimelineZoomLevel.compact;
          final micro = height < 46;
          final detailed = height >= 92 &&
              (zoom == UltraTimelineZoomLevel.detailed ||
                  zoom == UltraTimelineZoomLevel.cinematic);

          final content = AnimatedContainer(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                tone.withValues(alpha: completed ? 0.055 : 0.035),
                theme.panel,
              ),
              borderRadius: BorderRadius.circular(
                micro ? theme.radiusSmall : theme.radiusMedium,
              ),
              border: Border.all(
                color: selected ? tone : theme.outline,
                width: selected ? 1.8 : 1,
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: tone.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                micro ? theme.radiusSmall : theme.radiusMedium,
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: ColoredBox(color: tone),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      micro ? 10 : 12,
                      micro ? 6 : 9,
                      showDragHandle ? 38 : 12,
                      micro ? 6 : 9,
                    ),
                    child: micro
                        ? _MicroContent(
                            title: presentation.title,
                            timeLabel: presentation.timeLabel,
                            tone: tone,
                            theme: theme,
                          )
                        : _EntryContent<T>(
                            presentation: presentation,
                            tone: tone,
                            theme: theme,
                            compact: compact,
                            detailed: detailed,
                          ),
                  ),
                  if (showDragHandle && !details.interaction.locked)
                    PositionedDirectional(
                      end: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Tooltip(
                          message: 'Drag to reschedule',
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: compact ? 18 : 20,
                            color: theme.mutedText.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                    ),
                  if (details.interaction.locked)
                    PositionedDirectional(
                      end: 9,
                      top: 8,
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: theme.mutedText,
                      ),
                    ),
                ],
              ),
            ),
          );

          return RepaintBoundary(child: content);
        },
      ),
    );
  }

  static double _fallbackHeight(UltraTimelineZoomLevel zoom) {
    return switch (zoom) {
      UltraTimelineZoomLevel.overview => 44,
      UltraTimelineZoomLevel.compact => 54,
      UltraTimelineZoomLevel.balanced => 68,
      UltraTimelineZoomLevel.comfortable => 80,
      UltraTimelineZoomLevel.detailed => 96,
      UltraTimelineZoomLevel.cinematic => 112,
    };
  }
}

class _MicroContent extends StatelessWidget {
  const _MicroContent({
    required this.title,
    required this.timeLabel,
    required this.tone,
    required this.theme,
  });

  final String title;
  final String timeLabel;
  final Color tone;
  final UltraTimelineThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          timeLabel.split('–').first.trim(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tone,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: theme.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _EntryContent<T> extends StatelessWidget {
  const _EntryContent({
    required this.presentation,
    required this.tone,
    required this.theme,
    required this.compact,
    required this.detailed,
  });

  final UltraTimelineEntryPresentation<T> presentation;
  final Color tone;
  final UltraTimelineThemeData theme;
  final bool compact;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 30 : 36,
          height: compact ? 30 : 36,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: Icon(presentation.icon, color: tone, size: compact ? 17 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      presentation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: theme.text,
                        fontWeight: FontWeight.w800,
                        decoration: presentation.details.interaction.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    presentation.timeLabel,
                    maxLines: 1,
                    style: textTheme.labelSmall?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (!compact && presentation.subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  presentation.subtitle!,
                  maxLines: detailed ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.mutedText,
                    height: 1.25,
                  ),
                ),
              ],
              if (detailed && presentation.badges.isNotEmpty) ...[
                const SizedBox(height: 7),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: presentation.badges.take(3).map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: textTheme.labelSmall?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ],
              if (!compact && presentation.progress != null) ...[
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: presentation.progress!.clamp(0.0, 1.0).toDouble(),
                    minHeight: 3,
                    backgroundColor: theme.outline.withValues(alpha: 0.55),
                    valueColor: AlwaysStoppedAnimation<Color>(tone),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

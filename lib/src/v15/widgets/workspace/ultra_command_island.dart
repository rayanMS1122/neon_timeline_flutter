import 'package:flutter/material.dart';

import '../../presentation/ultra_timeline_presentation.dart';
import '../../theme/ultra_timeline_theme.dart';

class UltraCommandIsland extends StatelessWidget {
  const UltraCommandIsland({
    required this.title,
    required this.dateLabel,
    this.subtitle,
    this.onPreviousDate,
    this.onNextDate,
    this.onToday,
    this.onSearch,
    this.onCreate,
    this.onSettings,
    this.actions = const <UltraTimelineAction>[],
    this.avatar,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String dateLabel;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onSettings;
  final List<UltraTimelineAction> actions;
  final Widget? avatar;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 58 : theme.commandHeight),
      padding: EdgeInsetsDirectional.fromSTEB(
        compact ? 10 : 14,
        8,
        compact ? 8 : 10,
        8,
      ),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(theme.radiusPanel),
        border: Border.all(color: theme.outline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[theme.primary, theme.violet],
              ),
              borderRadius: BorderRadius.circular(compact ? 13 : 15),
            ),
            child: const Icon(Icons.view_timeline_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          if (!compact)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.text,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: theme.mutedText,
                          ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: theme.text,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          if (!compact) ...[
            const SizedBox(width: 10),
            _DateNavigator(
              label: dateLabel,
              onPrevious: onPreviousDate,
              onNext: onNextDate,
              onToday: onToday,
            ),
          ],
          const SizedBox(width: 6),
          if (onSearch != null)
            _CommandButton(
              tooltip: 'Search',
              icon: Icons.search_rounded,
              onPressed: onSearch,
            ),
          for (final action in actions.take(compact ? 1 : 3))
            _CommandButton(
              tooltip: action.label,
              icon: action.icon,
              color: theme.tone(action.tone),
              onPressed: action.onPressed,
            ),
          if (onSettings != null && !compact)
            _CommandButton(
              tooltip: 'Settings',
              icon: Icons.tune_rounded,
              onPressed: onSettings,
            ),
          if (onCreate != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: Text(compact ? 'Add' : 'New task'),
                style: FilledButton.styleFrom(
                  minimumSize: Size(compact ? 42 : 48, 44),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 16,
                  ),
                ),
              ),
            ),
          if (avatar != null && !compact) ...[
            const SizedBox(width: 8),
            avatar!,
          ],
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.label,
    this.onPrevious,
    this.onNext,
    this.onToday,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.panelStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Previous day',
            visualDensity: VisualDensity.compact,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onToday,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}

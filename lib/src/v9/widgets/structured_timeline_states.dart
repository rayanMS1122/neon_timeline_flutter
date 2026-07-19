import 'package:flutter/material.dart';

import '../../v7/models/structured_timeline_style.dart';
import '../models/structured_timeline_component_details.dart';

class StructuredTimelineFloatingAddButton extends StatelessWidget {
  const StructuredTimelineFloatingAddButton({
    this.label = 'Add task',
    this.onPressed,
    this.extended = true,
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool extended;
  final bool mini;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (!extended) {
      return FloatingActionButton(
        onPressed: onPressed,
        mini: mini,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        tooltip: label,
        child: const Icon(Icons.add_rounded),
      );
    }
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    );
  }
}

class StructuredTimelineEmptyState extends StatelessWidget {
  const StructuredTimelineEmptyState({
    required this.style,
    this.title = 'No tasks',
    this.description = 'Add a task to start planning your day.',
    this.actionLabel = 'Add task',
    this.onAction,
    super.key,
  });

  final StructuredTimelineStyle style;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.event_available_rounded,
                size: 44,
                color: style.primaryColor,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: style.mutedTextColor),
              ),
              if (onAction != null) ...<Widget>[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StructuredTimelineLoadingState extends StatelessWidget {
  const StructuredTimelineLoadingState({this.label = 'Loading', super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        liveRegion: true,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class StructuredTimelineErrorState extends StatelessWidget {
  const StructuredTimelineErrorState({
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

class StructuredTimelineDeleteTarget<T> extends StatelessWidget {
  const StructuredTimelineDeleteTarget({
    required this.active,
    required this.style,
    this.label = 'Delete',
    super.key,
  });

  final bool active;
  final StructuredTimelineStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: active ? style.conflictColor : style.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? style.conflictColor : style.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.delete_outline_rounded,
            color: active ? Colors.white : style.conflictColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : style.conflictColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class StructuredTimelineCurrentEntryBanner<T> extends StatelessWidget {
  const StructuredTimelineCurrentEntryBanner({
    required this.details,
    required this.style,
    required this.title,
    super.key,
  });

  final StructuredTimelineCurrentEntryDetails<T> details;
  final StructuredTimelineStyle style;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _InsightBanner(
      icon: Icons.play_circle_fill_rounded,
      color: style.primaryColor,
      title: title,
      subtitle: '${details.remaining.inMinutes} min left',
    );
  }
}

class StructuredTimelineNextEntryBanner<T> extends StatelessWidget {
  const StructuredTimelineNextEntryBanner({
    required this.details,
    required this.style,
    required this.title,
    super.key,
  });

  final StructuredTimelineNextEntryDetails<T> details;
  final StructuredTimelineStyle style;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _InsightBanner(
      icon: Icons.schedule_rounded,
      color: style.primaryColor,
      title: title,
      subtitle: 'Starts in ${details.startsIn.inMinutes} min',
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

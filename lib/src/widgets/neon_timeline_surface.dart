import 'package:flutter/material.dart';

import '../theme/neon_timeline_theme.dart';

/// Optional page-level surface that matches the package color language.
///
/// Existing timelines do not require this widget; it is a convenience for
/// examples and applications that want a complete presentation shell.
class NeonTimelineSurface extends StatelessWidget {
  const NeonTimelineSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.showAmbientGlow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final bool showAmbientGlow;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    final primary = primaryColor ?? theme.primaryColor;
    final secondary = secondaryColor ?? theme.secondaryColor;
    final background = backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF08070E)
            : const Color(0xFFF7F4FB));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        gradient: showAmbientGlow
            ? RadialGradient(
                center: const Alignment(-0.65, -0.85),
                radius: 1.45,
                colors: <Color>[
                  primary.withOpacity(0.14),
                  secondary.withOpacity(0.055),
                  background,
                ],
                stops: const <double>[0, 0.48, 1],
              )
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Reusable title row for timeline pages.
class NeonTimelineHeader extends StatelessWidget {
  const NeonTimelineHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 12),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.58),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Compact status badge that follows the active neon theme.
class NeonTimelineBadge extends StatelessWidget {
  const NeonTimelineBadge({
    required this.label,
    this.color,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? NeonTimelineTheme.of(context).primaryColor;
    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.11),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: accent.withOpacity(0.32)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withOpacity(0.16),
              blurRadius: 14,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Polished package-owned empty state.
class NeonTimelineEmptyState extends StatelessWidget {
  const NeonTimelineEmptyState({
    this.title = 'Nothing scheduled',
    this.message = 'This timeline has no entries yet.',
    this.icon = Icons.auto_awesome_rounded,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withOpacity(0.10),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.28),
                  ),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 28),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.58),
                    ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

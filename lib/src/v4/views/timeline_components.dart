import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

/// Theme-aware background surface for full-screen timeline products.
class TimelineBackdrop extends StatelessWidget {
  const TimelineBackdrop({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final gradient = switch (theme.visualStyle) {
      TimelineVisualStyle.aurora => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          theme.backgroundColor,
          theme.primaryColor.withAlpha(24),
          theme.secondaryColor.withAlpha(20),
          theme.backgroundColor,
        ],
        stops: const <double>[0, 0.32, 0.68, 1],
      ),
      TimelineVisualStyle.horizon => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          theme.backgroundColor,
          theme.primaryColor.withAlpha(18),
          theme.secondaryColor.withAlpha(14),
          theme.backgroundColor,
        ],
        stops: const <double>[0, 0.34, 0.72, 1],
      ),
      TimelineVisualStyle.obsidian => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          theme.surfaceVariantColor.withAlpha(72),
          theme.backgroundColor,
          theme.backgroundColor,
        ],
      ),
      TimelineVisualStyle.signal => RadialGradient(
        center: const Alignment(-0.65, -0.8),
        radius: 1.35,
        colors: <Color>[
          theme.primaryColor.withAlpha(28),
          theme.backgroundColor,
          theme.secondaryColor.withAlpha(10),
        ],
      ),
      TimelineVisualStyle.neonLegacy => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          theme.primaryColor.withAlpha(18),
          theme.backgroundColor,
          theme.secondaryColor.withAlpha(12),
        ],
      ),
      TimelineVisualStyle.darkProfessional => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          theme.backgroundColor,
          theme.surfaceVariantColor.withAlpha(90),
        ],
      ),
      _ => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          theme.backgroundColor,
          theme.surfaceVariantColor.withAlpha(32),
        ],
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

/// Reusable modern panel. Backdrop blur requires both a glass-capable theme
/// and explicit per-panel opt-in, so dense dashboards remain cheap by default.
class TimelinePanel extends StatelessWidget {
  const TimelinePanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.selected = false,
    this.borderRadius,
    this.onTap,
    this.enableBackdropBlur = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  /// Expensive on dense dashboards and web. Disabled unless explicitly enabled.
  final bool enableBackdropBlur;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(theme.cardRadius);
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.resolve(Directionality.of(context)),
        child: Padding(padding: padding, child: child),
      ),
    );
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? theme.selectionColor : theme.surfaceColor,
        borderRadius: radius,
        border: Border.all(
          color: selected ? theme.focusColor : theme.dividerColor,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: theme.elevation <= 0
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  color: Colors.black.withAlpha(18),
                ),
              ],
      ),
      child: content,
    );
    Widget result = decorated;
    if (enableBackdropBlur && theme.useBlur && theme.blurSigma > 0) {
      result = ClipRRect(
        borderRadius: radius.resolve(Directionality.of(context)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: theme.blurSigma,
            sigmaY: theme.blurSigma,
          ),
          child: decorated,
        ),
      );
    }
    return margin == null ? result : Padding(padding: margin!, child: result);
  }
}

class TimelineMetricCard extends StatelessWidget {
  const TimelineMetricCard({
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.accentColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? trend;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final accent = accentColor ?? theme.primaryColor;
    return TimelinePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withAlpha(24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: accent, size: 20),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: theme.mutedTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: theme.textColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (trend != null) ...<Widget>[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          trend!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineStatusBadge extends StatelessWidget {
  const TimelineStatusBadge({
    required this.label,
    this.status = TimelineStatus.pending,
    this.icon,
    super.key,
  });

  final String label;
  final TimelineStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final color = theme.colorForStatus(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: theme.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineSectionHeader extends StatelessWidget {
  const TimelineSectionHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: theme.textColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: theme.mutedTextColor),
                ),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

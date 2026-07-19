import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

/// Modern, neutral task card with no permanent ticker or storage behavior.
class TimelineCard extends StatelessWidget {
  const TimelineCard({
    required this.title,
    this.subtitle,
    this.category,
    this.timeLabel,
    this.status = TimelineStatus.pending,
    this.accentColor,
    this.progress,
    this.selected = false,
    this.leading,
    this.trailing,
    this.badges = const <Widget>[],
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.enableBackdropBlur = false,
    super.key,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final String title;
  final String? subtitle;
  final String? category;
  final String? timeLabel;
  final TimelineStatus status;
  final Color? accentColor;
  final double? progress;
  final bool selected;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> badges;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;

  /// Expensive on dense lists and web. Disabled unless explicitly enabled.
  final bool enableBackdropBlur;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final accent = accentColor ?? theme.colorForStatus(status);
    final radius = BorderRadius.circular(theme.cardRadius);
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        focusColor: theme.focusColor.withAlpha(38),
        hoverColor: theme.primaryColor.withAlpha(15),
        child: Padding(
          padding: padding ?? theme.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: theme.compact ? 42 : 54,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (theme.titleStyle ??
                                        Theme.of(context).textTheme.titleMedium)
                                    ?.copyWith(
                                      color: theme.textColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                        if (timeLabel != null) ...<Widget>[
                          const SizedBox(width: 12),
                          Text(
                            timeLabel!,
                            style:
                                (theme.metaStyle ??
                                        Theme.of(context).textTheme.labelMedium)
                                    ?.copyWith(color: theme.mutedTextColor),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: theme.compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (theme.bodyStyle ??
                                    Theme.of(context).textTheme.bodyMedium)
                                ?.copyWith(color: theme.mutedTextColor),
                      ),
                    ],
                    if (category != null || badges.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          if (category != null)
                            _TimelinePill(label: category!, color: accent),
                          ...badges,
                        ],
                      ),
                    ],
                    if (progress != null) ...<Widget>[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          color: accent,
                          backgroundColor: theme.dividerColor,
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
        ),
      ),
    );

    final decoration = BoxDecoration(
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
                blurRadius: 18,
                offset: const Offset(0, 8),
                color: Colors.black.withAlpha(20),
              ),
            ],
    );

    Widget result = DecoratedBox(decoration: decoration, child: content);
    if (enableBackdropBlur && theme.useBlur && theme.blurSigma > 0) {
      result = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: theme.blurSigma,
            sigmaY: theme.blurSigma,
          ),
          child: result,
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel,
      child: result,
    );
  }
}

class _TimelinePill extends StatelessWidget {
  const _TimelinePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: theme.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

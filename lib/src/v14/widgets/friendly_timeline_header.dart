import 'package:flutter/material.dart';

import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';
import 'friendly_timeline_panel.dart';

class FriendlyTimelineTopBar extends StatelessWidget {
  const FriendlyTimelineTopBar({
    required this.title,
    this.subtitle,
    this.dateLabel,
    this.compact = false,
    this.status = FriendlyTimelineWorkspaceStatus.ready,
    this.statusLabel,
    this.onPreviousDate,
    this.onNextDate,
    this.onToday,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    this.actions = const <FriendlyTimelineAction>[],
    this.avatar,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final bool compact;
  final FriendlyTimelineWorkspaceStatus status;
  final String? statusLabel;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final List<FriendlyTimelineAction> actions;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final stack = compact || textScale > 1.3;
    return FriendlyTimelinePanel(
      child: stack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FriendlyTitleCluster(
                  title: title,
                  subtitle: subtitle,
                  status: status,
                  statusLabel: statusLabel,
                  avatar: avatar,
                ),
                SizedBox(height: theme.sectionGap),
                FriendlyTimelineDateControl(
                  label: dateLabel ?? 'Today',
                  onPrevious: onPreviousDate,
                  onNext: onNextDate,
                  onToday: onToday,
                  expanded: true,
                ),
                SizedBox(height: theme.sectionGap),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _actionWidgets(context, compact: true),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _FriendlyTitleCluster(
                    title: title,
                    subtitle: subtitle,
                    status: status,
                    statusLabel: statusLabel,
                    avatar: avatar,
                  ),
                ),
                FriendlyTimelineDateControl(
                  label: dateLabel ?? 'Today',
                  onPrevious: onPreviousDate,
                  onNext: onNextDate,
                  onToday: onToday,
                ),
                const SizedBox(width: 10),
                ..._actionWidgets(context),
              ],
            ),
    );
  }

  List<Widget> _actionWidgets(BuildContext context, {bool compact = false}) {
    final values = <Widget>[];
    void add(Widget child) {
      if (values.isNotEmpty) values.add(const SizedBox(width: 8));
      values.add(child);
    }

    if (onSearch != null) {
      add(
        FriendlyTimelineIconButton(
          tooltip: 'Search and commands',
          icon: Icons.search_rounded,
          label: compact ? 'Search' : null,
          onPressed: onSearch,
        ),
      );
    }
    if (onCreate != null) {
      add(
        FriendlyTimelineIconButton(
          tooltip: 'Create entry',
          icon: Icons.add_rounded,
          label: 'New',
          emphasized: true,
          tone: FriendlyTimelineIconTone.primary,
          onPressed: onCreate,
        ),
      );
    }
    for (final action in actions) {
      add(
        FriendlyTimelineIconButton(
          tooltip: action.tooltip ?? action.label,
          icon: action.icon,
          label: compact ? action.label : null,
          tone: action.tone,
          emphasized: action.emphasized,
          onPressed: action.onPressed,
        ),
      );
    }
    if (onOpenSettings != null) {
      add(
        FriendlyTimelineIconButton(
          tooltip: 'Workspace settings',
          icon: Icons.tune_rounded,
          onPressed: onOpenSettings,
        ),
      );
    }
    return values;
  }
}

class _FriendlyTitleCluster extends StatelessWidget {
  const _FriendlyTitleCluster({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    required this.avatar,
  });

  final String title;
  final String? subtitle;
  final FriendlyTimelineWorkspaceStatus status;
  final String? statusLabel;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final logo = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 430 || textScale > 1.35;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  logo,
                  const SizedBox(width: 12),
                  Expanded(child: text),
                  if (avatar != null) ...[
                    const SizedBox(width: 8),
                    SizedBox.square(dimension: 38, child: avatar),
                  ],
                ],
              ),
              const SizedBox(height: 9),
              FriendlyTimelineStatusPill(
                status: status,
                label: statusLabel,
              ),
            ],
          );
        }
        return Row(
          children: [
            logo,
            const SizedBox(width: 12),
            Expanded(child: text),
            const SizedBox(width: 10),
            FriendlyTimelineStatusPill(status: status, label: statusLabel),
            if (avatar != null) ...[
              const SizedBox(width: 10),
              SizedBox.square(dimension: 40, child: avatar),
            ],
          ],
        );
      },
    );
  }
}

/// Date switcher with large, friendly targets.
class FriendlyTimelineDateControl extends StatelessWidget {
  const FriendlyTimelineDateControl({
    required this.label,
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return Semantics(
      container: true,
      label: 'Selected date, $label',
      child: Container(
        height: theme.controlHeight,
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          border: Border.all(color: theme.outline),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            _FriendlyMiniButton(
              tooltip: 'Previous day',
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: onPrevious,
            ),
            if (expanded)
              Expanded(child: _FriendlyDateButton(label: label, onTap: onToday))
            else
              _FriendlyDateButton(label: label, onTap: onToday),
            _FriendlyMiniButton(
              tooltip: 'Next day',
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendlyDateButton extends StatelessWidget {
  const _FriendlyDateButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.calendar_month_rounded, size: 17, color: theme.primary),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size(0, theme.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.controlRadius),
        ),
      ),
    );
  }
}

class _FriendlyMiniButton extends StatelessWidget {
  const _FriendlyMiniButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      color: theme.mutedText,
      constraints: BoxConstraints.tightFor(
        width: theme.controlHeight,
        height: theme.controlHeight,
      ),
      padding: EdgeInsets.zero,
    );
  }
}

/// Rounded icon action used throughout version 14.
class FriendlyTimelineIconButton extends StatelessWidget {
  const FriendlyTimelineIconButton({
    required this.tooltip,
    required this.icon,
    this.label,
    this.onPressed,
    this.tone = FriendlyTimelineIconTone.neutral,
    this.emphasized = false,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final FriendlyTimelineIconTone tone;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final foreground = emphasized
        ? Colors.white
        : theme.foregroundFor(tone);
    final background = emphasized
        ? theme.foregroundFor(tone == FriendlyTimelineIconTone.neutral
              ? FriendlyTimelineIconTone.primary
              : tone)
        : theme.backgroundFor(tone);
    final child = label == null
        ? Icon(icon, size: 20, color: foreground)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(
                label!,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(theme.controlRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          child: Container(
            height: theme.controlHeight,
            padding: label == null
                ? const EdgeInsets.symmetric(horizontal: 13)
                : const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.controlRadius),
              border: emphasized ? null : Border.all(color: theme.outline),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status pill with icon and text, never color alone.
class FriendlyTimelineStatusPill extends StatelessWidget {
  const FriendlyTimelineStatusPill({
    required this.status,
    this.label,
    super.key,
  });

  final FriendlyTimelineWorkspaceStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final values = switch (status) {
      FriendlyTimelineWorkspaceStatus.ready => (
        Icons.check_circle_outline_rounded,
        theme.success,
        'Ready',
      ),
      FriendlyTimelineWorkspaceStatus.saving => (
        Icons.sync_rounded,
        theme.sky,
        'Saving',
      ),
      FriendlyTimelineWorkspaceStatus.saved => (
        Icons.cloud_done_rounded,
        theme.success,
        'Saved',
      ),
      FriendlyTimelineWorkspaceStatus.offline => (
        Icons.cloud_off_rounded,
        theme.warning,
        'Offline',
      ),
      FriendlyTimelineWorkspaceStatus.warning => (
        Icons.history_toggle_off_rounded,
        theme.warning,
        'Rolling back',
      ),
      FriendlyTimelineWorkspaceStatus.failed => (
        Icons.error_outline_rounded,
        theme.error,
        'Failed',
      ),
    };
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: values.$2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: values.$2.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(values.$1, size: 14, color: values.$2),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label ?? values.$3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: values.$2,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/advanced_timeline_ui_models.dart';
import '../theme/advanced_timeline_ui_theme.dart';

/// A production workspace shell for timeline, calendar and planner surfaces.
///
/// The shell is deliberately model-independent. It owns responsive layout,
/// navigation, top-level controls, metrics and visual hierarchy while the
/// supplied [child] owns timeline geometry and interactions.
class AdvancedTimelineWorkspace extends StatelessWidget {
  const AdvancedTimelineWorkspace({
    required this.title,
    required this.child,
    this.subtitle,
    this.dateLabel,
    this.metrics = const <AdvancedTimelineMetric>[],
    this.navigationItems = const <AdvancedTimelineNavigationItem>[],
    this.selectedNavigationIndex = 0,
    this.onNavigationSelected,
    this.onPreviousDate,
    this.onNextDate,
    this.onToday,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    this.actions = const <Widget>[],
    this.status = AdvancedTimelineWorkspaceStatus.ready,
    this.statusLabel,
    this.avatar,
    this.navigationFooter,
    this.bottomBar,
    this.theme,
    this.showAmbientBackground = true,
    super.key,
  }) : assert(selectedNavigationIndex >= 0);

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final Widget child;
  final List<AdvancedTimelineMetric> metrics;
  final List<AdvancedTimelineNavigationItem> navigationItems;
  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final List<Widget> actions;
  final AdvancedTimelineWorkspaceStatus status;
  final String? statusLabel;
  final Widget? avatar;
  final Widget? navigationFooter;
  final Widget? bottomBar;
  final AdvancedTimelineUiThemeData? theme;
  final bool showAmbientBackground;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ??
        AdvancedTimelineUiThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
    return AdvancedTimelineUiTheme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final tokens = AdvancedTimelineUiTheme.of(context);
          return ColoredBox(
            color: tokens.canvas,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showAmbientBackground)
                  const Positioned.fill(child: _AdvancedAmbientBackground()),
                SafeArea(
                  child: Padding(
                    padding: tokens.workspacePadding,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact =
                            constraints.maxWidth < tokens.compactBreakpoint;
                        final showNavigation =
                            navigationItems.isNotEmpty &&
                            constraints.maxWidth >=
                                tokens.navigationBreakpoint;
                        final content = _WorkspaceContent(
                          title: title,
                          subtitle: subtitle,
                          dateLabel: dateLabel,
                          metrics: metrics,
                          status: status,
                          statusLabel: statusLabel,
                          avatar: avatar,
                          actions: actions,
                          onPreviousDate: onPreviousDate,
                          onNextDate: onNextDate,
                          onToday: onToday,
                          onSearch: onSearch,
                          onCreate: onCreate,
                          onOpenSettings: onOpenSettings,
                          compact: compact,
                          mobileNavigationItems: showNavigation
                              ? const <AdvancedTimelineNavigationItem>[]
                              : navigationItems,
                          selectedNavigationIndex: selectedNavigationIndex,
                          onNavigationSelected: onNavigationSelected,
                          bottomBar: bottomBar,
                          child: child,
                        );
                        if (!showNavigation) return content;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AdvancedTimelineNavigationRail(
                              items: navigationItems,
                              selectedIndex: selectedNavigationIndex,
                              onSelected: onNavigationSelected,
                              footer: navigationFooter,
                            ),
                            SizedBox(width: tokens.sectionGap),
                            Expanded(child: content),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WorkspaceContent extends StatelessWidget {
  const _WorkspaceContent({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.metrics,
    required this.status,
    required this.statusLabel,
    required this.avatar,
    required this.actions,
    required this.onPreviousDate,
    required this.onNextDate,
    required this.onToday,
    required this.onSearch,
    required this.onCreate,
    required this.onOpenSettings,
    required this.compact,
    required this.mobileNavigationItems,
    required this.selectedNavigationIndex,
    required this.onNavigationSelected,
    required this.bottomBar,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final List<AdvancedTimelineMetric> metrics;
  final AdvancedTimelineWorkspaceStatus status;
  final String? statusLabel;
  final Widget? avatar;
  final List<Widget> actions;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final bool compact;
  final List<AdvancedTimelineNavigationItem> mobileNavigationItems;
  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
  final Widget? bottomBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdvancedTimelineCommandBar(
          title: title,
          subtitle: subtitle,
          dateLabel: dateLabel,
          compact: compact,
          status: status,
          statusLabel: statusLabel,
          avatar: avatar,
          actions: actions,
          onPreviousDate: onPreviousDate,
          onNextDate: onNextDate,
          onToday: onToday,
          onSearch: onSearch,
          onCreate: onCreate,
          onOpenSettings: onOpenSettings,
        ),
        if (metrics.isNotEmpty) ...[
          SizedBox(height: theme.sectionGap),
          AdvancedTimelineMetricStrip(metrics: metrics),
        ],
        SizedBox(height: theme.sectionGap),
        Expanded(
          child: AdvancedTimelinePanel(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.panelRadius),
              child: child,
            ),
          ),
        ),
        if (mobileNavigationItems.isNotEmpty) ...[
          SizedBox(height: theme.sectionGap),
          AdvancedTimelineMobileNavigation(
            items: mobileNavigationItems,
            selectedIndex: selectedNavigationIndex,
            onSelected: onNavigationSelected,
          ),
        ],
        if (bottomBar != null) ...[
          SizedBox(height: theme.sectionGap),
          bottomBar!,
        ],
      ],
    );
  }
}

/// Responsive command bar with date navigation, sync state and quick actions.
class AdvancedTimelineCommandBar extends StatelessWidget {
  const AdvancedTimelineCommandBar({
    required this.title,
    this.subtitle,
    this.dateLabel,
    this.compact = false,
    this.status = AdvancedTimelineWorkspaceStatus.ready,
    this.statusLabel,
    this.avatar,
    this.actions = const <Widget>[],
    this.onPreviousDate,
    this.onNextDate,
    this.onToday,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final bool compact;
  final AdvancedTimelineWorkspaceStatus status;
  final String? statusLabel;
  final Widget? avatar;
  final List<Widget> actions;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final forceStack = compact || textScale > 1.35;
    return AdvancedTimelinePanel(
      child: forceStack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TitleCluster(
                  title: title,
                  subtitle: subtitle,
                  status: status,
                  statusLabel: statusLabel,
                ),
                SizedBox(height: theme.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: AdvancedTimelineDateNavigator(
                        label: dateLabel ?? 'Today',
                        onPrevious: onPreviousDate,
                        onNext: onNextDate,
                        onToday: onToday,
                        compact: true,
                      ),
                    ),
                    if (onSearch != null) ...[
                      const SizedBox(width: 8),
                      AdvancedTimelineQuickAction(
                        tooltip: 'Search and commands',
                        icon: Icons.search_rounded,
                        onPressed: onSearch,
                      ),
                    ],
                    if (onCreate != null) ...[
                      const SizedBox(width: 8),
                      AdvancedTimelineQuickAction(
                        tooltip: 'Create entry',
                        icon: Icons.add_rounded,
                        emphasized: true,
                        onPressed: onCreate,
                      ),
                    ],
                    if (onOpenSettings != null) ...[
                      const SizedBox(width: 8),
                      AdvancedTimelineQuickAction(
                        tooltip: 'Workspace settings',
                        icon: Icons.tune_rounded,
                        onPressed: onOpenSettings,
                      ),
                    ],
                  ],
                ),
                if (actions.isNotEmpty) ...[
                  SizedBox(height: theme.sectionGap),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var index = 0; index < actions.length; index++) ...[
                          actions[index],
                          if (index != actions.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _TitleCluster(
                    title: title,
                    subtitle: subtitle,
                    status: status,
                    statusLabel: statusLabel,
                  ),
                ),
                AdvancedTimelineDateNavigator(
                  label: dateLabel ?? 'Today',
                  onPrevious: onPreviousDate,
                  onNext: onNextDate,
                  onToday: onToday,
                ),
                if (onSearch != null) ...[
                  const SizedBox(width: 8),
                  AdvancedTimelineQuickAction(
                    tooltip: 'Search and commands',
                    icon: Icons.search_rounded,
                    label: 'Search',
                    onPressed: onSearch,
                  ),
                ],
                if (onCreate != null) ...[
                  const SizedBox(width: 8),
                  AdvancedTimelineQuickAction(
                    tooltip: 'Create entry',
                    icon: Icons.add_rounded,
                    label: 'New',
                    emphasized: true,
                    onPressed: onCreate,
                  ),
                ],
                ...actions.map(
                  (action) => Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: action,
                  ),
                ),
                if (onOpenSettings != null) ...[
                  const SizedBox(width: 8),
                  AdvancedTimelineQuickAction(
                    tooltip: 'Workspace settings',
                    icon: Icons.tune_rounded,
                    onPressed: onOpenSettings,
                  ),
                ],
                if (avatar != null) ...[
                  const SizedBox(width: 10),
                  SizedBox.square(dimension: 38, child: avatar),
                ],
              ],
            ),
    );
  }
}

class _TitleCluster extends StatelessWidget {
  const _TitleCluster({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
  });

  final String title;
  final String? subtitle;
  final AdvancedTimelineWorkspaceStatus status;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.primarySoft,
            borderRadius: BorderRadius.circular(theme.controlRadius),
          ),
          child: SizedBox.square(
            dimension: 42,
            child: Icon(Icons.view_timeline_rounded, color: theme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
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
          ),
        ),
        const SizedBox(width: 10),
        AdvancedTimelineStatusPill(status: status, label: statusLabel),
      ],
    );
  }
}

/// Compact date switcher designed for mouse, keyboard and touch.
class AdvancedTimelineDateNavigator extends StatelessWidget {
  const AdvancedTimelineDateNavigator({
    required this.label,
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Semantics(
      container: true,
      label: 'Selected date, $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          border: Border.all(color: theme.outline),
        ),
        child: SizedBox(
          height: theme.controlHeight,
          child: Row(
            mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _MiniIconButton(
                tooltip: 'Previous day',
                icon: Icons.chevron_left_rounded,
                onPressed: onPrevious,
              ),
              if (compact)
                Expanded(child: _DateButton(label: label, onPressed: onToday))
              else
                _DateButton(label: label, onPressed: onToday),
              _MiniIconButton(
                tooltip: 'Next day',
                icon: Icons.chevron_right_rounded,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.calendar_today_rounded, size: 15, color: theme.primary),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.text,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size(0, theme.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.controlRadius),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      color: theme.mutedText,
      constraints: BoxConstraints.tightFor(
        width: theme.controlHeight,
        height: theme.controlHeight,
      ),
      padding: EdgeInsets.zero,
    );
  }
}

/// Horizontally scrollable metric row that never overflows at large text.
class AdvancedTimelineMetricStrip extends StatelessWidget {
  const AdvancedTimelineMetricStrip({required this.metrics, super.key});

  final List<AdvancedTimelineMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            AdvancedTimelineMetricCard(metric: metrics[index]),
            if (index != metrics.length - 1)
              SizedBox(width: theme.sectionGap),
          ],
        ],
      ),
    );
  }
}

/// A concise KPI card with optional progress visualization.
class AdvancedTimelineMetricCard extends StatelessWidget {
  const AdvancedTimelineMetricCard({required this.metric, super.key});

  final AdvancedTimelineMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Semantics(
      label: metric.semanticLabel ?? '${metric.label}: ${metric.value}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 142, maxWidth: 210),
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 9),
        decoration: BoxDecoration(
          color: metric.emphasized ? theme.primarySoft : theme.panelElevated,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          border: Border.all(
            color: metric.emphasized
                ? theme.primary.withValues(alpha: 0.32)
                : theme.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadow,
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (metric.icon != null) ...[
                  Icon(
                    metric.icon,
                    size: 15,
                    color: metric.emphasized
                        ? theme.primary
                        : theme.mutedText,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  metric.value,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            if (metric.progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: metric.progress,
                  minHeight: 3,
                  color: theme.primary,
                  backgroundColor: theme.outline.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Explicit workspace state. Information is not communicated by color alone.
class AdvancedTimelineStatusPill extends StatelessWidget {
  const AdvancedTimelineStatusPill({
    required this.status,
    this.label,
    super.key,
  });

  final AdvancedTimelineWorkspaceStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    final resolvedLabel = label ?? switch (status) {
      AdvancedTimelineWorkspaceStatus.ready => 'Ready',
      AdvancedTimelineWorkspaceStatus.saving => 'Saving',
      AdvancedTimelineWorkspaceStatus.saved => 'Saved',
      AdvancedTimelineWorkspaceStatus.offline => 'Offline',
      AdvancedTimelineWorkspaceStatus.warning => 'Attention',
      AdvancedTimelineWorkspaceStatus.failed => 'Failed',
    };
    final color = switch (status) {
      AdvancedTimelineWorkspaceStatus.ready => theme.mutedText,
      AdvancedTimelineWorkspaceStatus.saving => theme.info,
      AdvancedTimelineWorkspaceStatus.saved => theme.success,
      AdvancedTimelineWorkspaceStatus.offline => theme.warning,
      AdvancedTimelineWorkspaceStatus.warning => theme.warning,
      AdvancedTimelineWorkspaceStatus.failed => theme.error,
    };
    final icon = switch (status) {
      AdvancedTimelineWorkspaceStatus.ready => Icons.circle_outlined,
      AdvancedTimelineWorkspaceStatus.saving => Icons.sync_rounded,
      AdvancedTimelineWorkspaceStatus.saved => Icons.check_circle_rounded,
      AdvancedTimelineWorkspaceStatus.offline => Icons.cloud_off_rounded,
      AdvancedTimelineWorkspaceStatus.warning => Icons.warning_amber_rounded,
      AdvancedTimelineWorkspaceStatus.failed => Icons.error_outline_rounded,
    };
    return Semantics(
      label: 'Workspace status: $resolvedLabel',
      liveRegion: status == AdvancedTimelineWorkspaceStatus.failed,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.26)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                resolvedLabel,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Public rounded action used throughout the workspace.
class AdvancedTimelineQuickAction extends StatelessWidget {
  const AdvancedTimelineQuickAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
    this.emphasized = false,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    final foreground = emphasized ? Colors.white : theme.text;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: emphasized ? theme.primary : theme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.controlRadius),
          side: BorderSide(
            color: emphasized ? theme.primary : theme.outline,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          child: SizedBox(
            height: theme.controlHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: label == null ? 12 : 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  if (label != null) ...[
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop navigation rail with text labels, badges and large hit targets.
class AdvancedTimelineNavigationRail extends StatelessWidget {
  const AdvancedTimelineNavigationRail({
    required this.items,
    this.selectedIndex = 0,
    this.onSelected,
    this.footer,
    super.key,
  }) : assert(selectedIndex >= 0);

  final List<AdvancedTimelineNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return AdvancedTimelinePanel(
      width: 94,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.controlRadius),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const SizedBox.square(
              dimension: 46,
              child: Icon(Icons.bolt_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (context, index) {
                final item = items[index];
                return _NavigationDestination(
                  item: item,
                  selected: index == selectedIndex,
                  onTap: onSelected == null ? null : () => onSelected!(index),
                );
              },
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 10), footer!],
        ],
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdvancedTimelineNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? theme.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(theme.controlRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      selected ? item.selectedIcon ?? item.icon : item.icon,
                      size: 21,
                      color: selected ? theme.primary : theme.mutedText,
                    ),
                    if (item.badge != null)
                      PositionedDirectional(
                        top: -8,
                        end: -12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.error,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? theme.primary : theme.mutedText,
                    fontSize: 9.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact bottom navigation used when the desktop rail does not fit.
class AdvancedTimelineMobileNavigation extends StatelessWidget {
  const AdvancedTimelineMobileNavigation({
    required this.items,
    this.selectedIndex = 0,
    this.onSelected,
    super.key,
  }) : assert(selectedIndex >= 0);

  final List<AdvancedTimelineNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return AdvancedTimelinePanel(
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _MobileNavigationDestination(
                item: items[index],
                selected: index == selectedIndex,
                onTap: onSelected == null ? null : () => onSelected!(index),
              ),
              if (index != items.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileNavigationDestination extends StatelessWidget {
  const _MobileNavigationDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdvancedTimelineNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? theme.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(theme.controlRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(theme.controlRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 76, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        selected ? item.selectedIcon ?? item.icon : item.icon,
                        size: 19,
                        color: selected ? theme.primary : theme.mutedText,
                      ),
                      if (item.badge != null)
                        PositionedDirectional(
                          top: -8,
                          end: -10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.error,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              child: Text(
                                item.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 7),
                  Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? theme.primary : theme.mutedText,
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared elevated panel with a thin outline and restrained shadow.
class AdvancedTimelinePanel extends StatelessWidget {
  const AdvancedTimelinePanel({
    required this.child,
    this.padding,
    this.width,
    this.height,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return Container(
      width: width,
      height: height,
      padding: padding ?? theme.panelPadding,
      decoration: BoxDecoration(
        color: theme.panelElevated.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(theme.panelRadius),
        border: Border.all(color: theme.outline.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AdvancedAmbientBackground extends StatelessWidget {
  const _AdvancedAmbientBackground();

  @override
  Widget build(BuildContext context) {
    final theme = AdvancedTimelineUiTheme.of(context);
    return IgnorePointer(
      child: CustomPaint(painter: _AmbientPainter(theme)),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter(this.theme);

  final AdvancedTimelineUiThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [theme.primary.withValues(alpha: 0.11), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.82, size.height * 0.06),
          radius: size.shortestSide * 0.62,
        ),
      );
    canvas.drawRect(Offset.zero & size, primaryPaint);

    final accentPaint = Paint()
      ..shader = RadialGradient(
        colors: [theme.canvasAccent.withValues(alpha: 0.8), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.88),
          radius: size.shortestSide * 0.48,
        ),
      );
    canvas.drawRect(Offset.zero & size, accentPaint);
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) => oldDelegate.theme != theme;
}

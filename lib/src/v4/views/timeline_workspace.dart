import 'package:flutter/material.dart';

import '../theme/timeline_theme.dart';
import 'timeline_components.dart';

@immutable
class TimelineWorkspaceDestination {
  const TimelineWorkspaceDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
}

/// Responsive product shell for advanced planner and timeline applications.
///
/// Wide layouts use a navigation rail and optional inspector. Compact layouts
/// use a bottom navigation bar and hide the inspector from the primary canvas.
class TimelineWorkspace extends StatelessWidget {
  const TimelineWorkspace({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.toolbar,
    this.inspector,
    this.inspectorWidth = 320,
    this.railWidth = 86,
    this.compactBreakpoint = 840,
    this.inspectorBreakpoint = 1180,
    super.key,
  }) : assert(selectedIndex >= 0),
       assert(inspectorWidth >= 240),
       assert(railWidth >= 72),
       assert(compactBreakpoint > 0),
       assert(inspectorBreakpoint >= compactBreakpoint);

  final List<TimelineWorkspaceDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? toolbar;
  final Widget? inspector;
  final double inspectorWidth;
  final double railWidth;
  final double compactBreakpoint;
  final double inspectorBreakpoint;

  @override
  Widget build(BuildContext context) {
    assert(selectedIndex < destinations.length || destinations.isEmpty);
    final theme = TimelineTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < compactBreakpoint;
        final showInspector =
            inspector != null && constraints.maxWidth >= inspectorBreakpoint;
        final header = title == null && toolbar == null
            ? null
            : _WorkspaceHeader(
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
                toolbar: toolbar,
                compact: compact,
              );

        Widget canvas = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (header != null) header,
            Expanded(child: body),
          ],
        );

        if (compact) {
          return ColoredBox(
            color: theme.backgroundColor,
            child: Column(
              children: <Widget>[
                Expanded(child: canvas),
                if (destinations.isNotEmpty)
                  NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: destinations
                        .map(
                          (destination) => NavigationDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(
                              destination.selectedIcon ?? destination.icon,
                            ),
                            label: destination.label,
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          );
        }

        return ColoredBox(
          color: theme.backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: railWidth,
                child: _WorkspaceRail(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                ),
              ),
              VerticalDivider(width: 1, color: theme.dividerColor),
              Expanded(child: canvas),
              if (showInspector) ...<Widget>[
                VerticalDivider(width: 1, color: theme.dividerColor),
                SizedBox(
                  width: inspectorWidth,
                  child: TimelinePanel(
                    margin: const EdgeInsets.all(12),
                    child: inspector!,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.toolbar,
    required this.compact,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? toolbar;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceColor.withAlpha(220),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 22,
          14,
          compact ? 12 : 18,
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null)
              TimelineSectionHeader(
                title: title!,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
              ),
            if (title != null && toolbar != null) const SizedBox(height: 12),
            if (toolbar != null) toolbar!,
          ],
        ),
      ),
    );
  }
}

class _WorkspaceRail extends StatelessWidget {
  const _WorkspaceRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<TimelineWorkspaceDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return ColoredBox(
      color: theme.surfaceColor,
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          itemCount: destinations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final destination = destinations[index];
            final selected = index == selectedIndex;
            return Tooltip(
              message: destination.label,
              child: Semantics(
                selected: selected,
                button: true,
                label: destination.label,
                child: InkWell(
                  onTap: () => onDestinationSelected(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : theme.motionDuration,
                    curve: theme.motionCurve,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.selectionColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? theme.focusColor.withAlpha(80)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Icon(
                              selected
                                  ? destination.selectedIcon ?? destination.icon
                                  : destination.icon,
                              color: selected
                                  ? theme.primaryColor
                                  : theme.mutedTextColor,
                            ),
                            if (destination.badge != null)
                              Positioned(
                                right: -12,
                                top: -8,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.errorColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      destination.badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: selected
                                    ? theme.textColor
                                    : theme.mutedTextColor,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

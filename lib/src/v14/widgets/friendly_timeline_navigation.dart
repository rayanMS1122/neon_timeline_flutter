import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';
import 'friendly_timeline_panel.dart';

/// Desktop navigation dock with icon-led destinations.
class FriendlyTimelineNavigationDock extends StatelessWidget {
  const FriendlyTimelineNavigationDock({
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    this.footer,
    super.key,
  });

  final List<FriendlyTimelineNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return FriendlyTimelinePanel(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.lavender],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.bubble_chart_rounded, color: Colors.white),
            ),
            SizedBox(height: theme.sectionGap + 4),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _FriendlyNavigationButton(
                    item: item,
                    selected: index == selectedIndex,
                    onTap: onSelected == null ? null : () => onSelected!(index),
                  );
                },
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

class _FriendlyNavigationButton extends StatelessWidget {
  const _FriendlyNavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FriendlyTimelineNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final foreground = selected
        ? theme.foregroundFor(item.tone)
        : theme.mutedText;
    final background = selected
        ? theme.backgroundFor(item.tone)
        : Colors.transparent;
    return Semantics(
      selected: selected,
      button: true,
      label: item.semanticLabel ?? item.label,
      child: Tooltip(
        message: item.label,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.selectedIcon ?? item.icon : item.icon,
                        size: 22,
                        color: foreground,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 9.5,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (item.badge != null)
                    PositionedDirectional(
                      end: 8,
                      top: 7,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 17),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.coral,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          item.badge!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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

/// Mobile bottom dock that keeps every destination reachable.
/// Compact bottom navigation used below the desktop breakpoint.
class FriendlyTimelineMobileDock extends StatelessWidget {
  const FriendlyTimelineMobileDock({
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    super.key,
  });

  final List<FriendlyTimelineNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return FriendlyTimelinePanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _FriendlyMobileDestination(
                item: items[index],
                selected: index == selectedIndex,
                onTap: onSelected == null ? null : () => onSelected!(index),
              ),
              if (index != items.length - 1)
                SizedBox(width: math.max(5, theme.sectionGap - 5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FriendlyMobileDestination extends StatelessWidget {
  const _FriendlyMobileDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FriendlyTimelineNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final foreground = selected
        ? theme.foregroundFor(item.tone)
        : theme.mutedText;
    return Material(
      color: selected ? theme.backgroundFor(item.tone) : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon ?? item.icon : item.icon,
                size: 19,
                color: foreground,
              ),
              const SizedBox(width: 7),
              Text(
                item.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  item.badge!,
                  style: TextStyle(
                    color: theme.coral,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

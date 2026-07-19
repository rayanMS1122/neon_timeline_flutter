import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../models/friendly_timeline_presentation_models.dart';
import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';

import 'friendly_timeline_drag_companion.dart';
import 'friendly_timeline_header.dart';
import 'friendly_timeline_metrics.dart';
import 'friendly_timeline_navigation.dart';
import 'friendly_timeline_panel.dart';

/// Friendly, icon-led planner shell introduced in version 14.
class FriendlyTimelineWorkspace extends StatelessWidget {
  const FriendlyTimelineWorkspace({
    required this.title,
    required this.child,
    this.subtitle,
    this.dateLabel,
    this.metrics = const <FriendlyTimelineMetric>[],
    this.navigationItems = const <FriendlyTimelineNavigationItem>[],
    this.selectedNavigationIndex = 0,
    this.onNavigationSelected,
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
    this.navigationFooter,
    this.bottomBar,
    this.dragState,
    this.dragTitle,
    this.dragStateListenable,
    this.onCancelDrag,
    this.theme,
    this.showAmbientBackground = true,
    super.key,
  }) : assert(selectedNavigationIndex >= 0);

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final Widget child;
  final List<FriendlyTimelineMetric> metrics;
  final List<FriendlyTimelineNavigationItem> navigationItems;
  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
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
  final Widget? navigationFooter;
  final Widget? bottomBar;
  final StructuredTimelineDragState<dynamic>? dragState;
  final String? dragTitle;
  final ValueListenable<FriendlyTimelineDragUiState>? dragStateListenable;
  final VoidCallback? onCancelDrag;
  final FriendlyTimelineUiThemeData? theme;
  final bool showAmbientBackground;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ??
        FriendlyTimelineUiThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
    return FriendlyTimelineUiTheme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final tokens = FriendlyTimelineUiTheme.of(context);
          return ColoredBox(
            color: tokens.canvas,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showAmbientBackground)
                  const Positioned.fill(child: FriendlyTimelineAmbientBackground()),
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
                        final content = _FriendlyWorkspaceContent(
                          title: title,
                          subtitle: subtitle,
                          dateLabel: dateLabel,
                          metrics: metrics,
                          status: status,
                          statusLabel: statusLabel,
                          onPreviousDate: onPreviousDate,
                          onNextDate: onNextDate,
                          onToday: onToday,
                          onSearch: onSearch,
                          onCreate: onCreate,
                          onOpenSettings: onOpenSettings,
                          actions: actions,
                          avatar: avatar,
                          compact: compact,
                          mobileNavigationItems: showNavigation
                              ? const <FriendlyTimelineNavigationItem>[]
                              : navigationItems,
                          selectedNavigationIndex: selectedNavigationIndex,
                          onNavigationSelected: onNavigationSelected,
                          bottomBar: bottomBar,
                          dragState: dragState,
                          dragTitle: dragTitle,
                          dragStateListenable: dragStateListenable,
                          onCancelDrag: onCancelDrag,
                          child: child,
                        );
                        if (!showNavigation) return content;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FriendlyTimelineNavigationDock(
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

class _FriendlyWorkspaceContent extends StatelessWidget {
  const _FriendlyWorkspaceContent({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.metrics,
    required this.status,
    required this.statusLabel,
    required this.onPreviousDate,
    required this.onNextDate,
    required this.onToday,
    required this.onSearch,
    required this.onCreate,
    required this.onOpenSettings,
    required this.actions,
    required this.avatar,
    required this.compact,
    required this.mobileNavigationItems,
    required this.selectedNavigationIndex,
    required this.onNavigationSelected,
    required this.bottomBar,
    required this.dragState,
    required this.dragTitle,
    required this.dragStateListenable,
    required this.onCancelDrag,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final List<FriendlyTimelineMetric> metrics;
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
  final bool compact;
  final List<FriendlyTimelineNavigationItem> mobileNavigationItems;
  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
  final Widget? bottomBar;
  final StructuredTimelineDragState<dynamic>? dragState;
  final String? dragTitle;
  final ValueListenable<FriendlyTimelineDragUiState>? dragStateListenable;
  final VoidCallback? onCancelDrag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FriendlyTimelineTopBar(
          title: title,
          subtitle: subtitle,
          dateLabel: dateLabel,
          compact: compact,
          status: status,
          statusLabel: statusLabel,
          onPreviousDate: onPreviousDate,
          onNextDate: onNextDate,
          onToday: onToday,
          onSearch: onSearch,
          onCreate: onCreate,
          onOpenSettings: onOpenSettings,
          actions: actions,
          avatar: avatar,
        ),
        if (metrics.isNotEmpty) ...[
          SizedBox(height: theme.sectionGap),
          FriendlyTimelineMetricStrip(metrics: metrics),
        ],
        SizedBox(height: theme.sectionGap),
        Expanded(
          child: FriendlyTimelinePanel(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.panelRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child,
                  PositionedDirectional(
                    start: 12,
                    end: 12,
                    bottom: 12,
                    child: FriendlyTimelineDragOverlay(
                      stateListenable: dragStateListenable,
                      fallbackState: dragState,
                      fallbackTitle: dragTitle,
                      onCancel: onCancelDrag,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (mobileNavigationItems.isNotEmpty) ...[
          SizedBox(height: theme.sectionGap),
          FriendlyTimelineMobileDock(
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

/// Friendly command center with icon-led actions and responsive wrapping.

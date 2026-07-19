import 'package:flutter/material.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../../v11/core/timeline_interaction_history.dart';
import '../../v11/core/timeline_selection_controller.dart';
import '../../v11/models/structured_timeline_v11_config.dart';
import '../../v11/widgets/ultimate_structured_timeline.dart';
import '../../v12/models/ultimate_timeline_config.dart';
import '../../v12/models/ultimate_timeline_details.dart';
import '../../v12/theme/ultimate_timeline_theme.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../models/advanced_timeline_ui_models.dart';
import '../theme/advanced_timeline_ui_theme.dart';
import 'advanced_timeline_workspace.dart';

/// Version 13 all-in-one planner UI.
///
/// This widget composes the production timeline engine with the new responsive
/// workspace shell. It remains independent from repositories, navigation,
/// Cubits and application-specific models.
class AdvancedUiStructuredTimeline<T> extends StatelessWidget {
  const AdvancedUiStructuredTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    required this.title,
    this.subtitle,
    this.config = const UltimateStructuredTimelineConfig.advancedCompact(),
    this.controller,
    this.selectionController,
    this.history,
    this.mutationCoordinator,
    this.persistenceState = StructuredTimelinePersistenceState.idle,
    this.persistenceMessage,
    this.workspaceStatus,
    this.workspaceStatusLabel,
    this.metrics = const <AdvancedTimelineMetric>[],
    this.navigationItems = const <AdvancedTimelineNavigationItem>[],
    this.selectedNavigationIndex = 0,
    this.onNavigationSelected,
    this.onRetry,
    this.onEntryTap,
    this.onOpen,
    this.onComplete,
    this.onMove,
    this.onResize,
    this.onDelete,
    this.onInsert,
    this.onMutationError,
    this.onMutationRollback,
    this.onDateChanged,
    this.onDragStateChanged,
    this.entryBuilder,
    this.ultimateEntryBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.timeFormatter,
    this.durationFormatter,
    this.deleteTargetBuilder,
    this.style,
    this.strings = const StructuredTimelineStrings(),
    this.dateFormatter,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    this.actions = const <Widget>[],
    this.avatar,
    this.navigationFooter,
    this.bottomBar,
    this.workspaceTheme,
    this.timelineTheme,
    this.now,
    this.dataRevision,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 8, bottom: 108),
    this.showInsightBanner = false,
    this.showCompletionToggle = false,
    this.showBoundaryGaps = false,
    this.enableDragging = true,
    this.enableResizing = true,
    this.enableDeleteTarget = true,
    super.key,
  }) : assert(selectedNavigationIndex >= 0);

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime selectedDate;
  final String title;
  final String? subtitle;
  final StructuredTimelineV11Config config;
  final StructuredTimelineController<T>? controller;
  final StructuredTimelineSelectionController? selectionController;
  final StructuredTimelineInteractionHistory? history;
  final TimelineMutationCoordinator<T>? mutationCoordinator;
  final StructuredTimelinePersistenceState persistenceState;
  final String? persistenceMessage;
  final AdvancedTimelineWorkspaceStatus? workspaceStatus;
  final String? workspaceStatusLabel;
  final List<AdvancedTimelineMetric> metrics;
  final List<AdvancedTimelineNavigationItem> navigationItems;
  final int selectedNavigationIndex;
  final ValueChanged<int>? onNavigationSelected;
  final VoidCallback? onRetry;
  final StructuredTimelineEntryCallback<T>? onEntryTap;
  final StructuredTimelineEntryCallback<T>? onOpen;
  final StructuredTimelineEntryCallback<T>? onComplete;
  final StructuredTimelineMoveCallback<T>? onMove;
  final AdvancedStructuredTimelineResizeCallback<T>? onResize;
  final StructuredTimelineMoveCallback<T>? onDelete;
  final StructuredTimelineGapCallback<T>? onInsert;
  final AdvancedStructuredTimelineMutationError<T>? onMutationError;
  final AdvancedStructuredTimelineMutationRollback<T>? onMutationRollback;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<StructuredTimelineDragState<T>>? onDragStateChanged;
  final AdvancedStructuredTimelineEntryBuilder<T>? entryBuilder;
  final UltimateTimelineEntryBuilder<T>? ultimateEntryBuilder;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final StructuredTimelineTimeFormatter? timeFormatter;
  final StructuredTimelineDurationFormatter? durationFormatter;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final StructuredTimelineStyle? style;
  final StructuredTimelineStrings strings;
  final String Function(DateTime value)? dateFormatter;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final List<Widget> actions;
  final Widget? avatar;
  final Widget? navigationFooter;
  final Widget? bottomBar;
  final AdvancedTimelineUiThemeData? workspaceTheme;
  final UltimateTimelineThemeData? timelineTheme;
  final DateTime? now;
  final Object? dataRevision;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showInsightBanner;
  final bool showCompletionToggle;
  final bool showBoundaryGaps;
  final bool enableDragging;
  final bool enableResizing;
  final bool enableDeleteTarget;

  @override
  Widget build(BuildContext context) {
    final resolvedWorkspaceTheme = workspaceTheme ??
        AdvancedTimelineUiThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
    final resolvedTimelineTheme = timelineTheme ??
        UltimateTimelineThemeData.advancedCompact(
          Theme.of(context).colorScheme,
        ).copyWith(
          background: resolvedWorkspaceTheme.panelElevated,
          surface: resolvedWorkspaceTheme.panelElevated,
          surfaceElevated: resolvedWorkspaceTheme.panelElevated,
          border: resolvedWorkspaceTheme.outline,
          text: resolvedWorkspaceTheme.text,
          mutedText: resolvedWorkspaceTheme.mutedText,
          primary: resolvedWorkspaceTheme.primary,
          success: resolvedWorkspaceTheme.success,
          warning: resolvedWorkspaceTheme.warning,
          error: resolvedWorkspaceTheme.error,
          blocked: resolvedWorkspaceTheme.error,
          shadow: resolvedWorkspaceTheme.shadow,
        );
    final effectiveStatus = workspaceStatus ??
        _workspaceStatusFor(persistenceState);
    final formattedDate = dateFormatter?.call(selectedDate) ??
        _formatDate(selectedDate);

    return AdvancedTimelineWorkspace(
      title: title,
      subtitle: subtitle,
      dateLabel: formattedDate,
      metrics: metrics,
      navigationItems: navigationItems,
      selectedNavigationIndex: selectedNavigationIndex,
      onNavigationSelected: onNavigationSelected,
      status: effectiveStatus,
      statusLabel: workspaceStatusLabel ?? persistenceMessage,
      onPreviousDate: onDateChanged == null
          ? null
          : () => onDateChanged!(
              selectedDate.subtract(const Duration(days: 1)),
            ),
      onNextDate: onDateChanged == null
          ? null
          : () => onDateChanged!(
              selectedDate.add(const Duration(days: 1)),
            ),
      onToday: onDateChanged == null
          ? null
          : () {
              final value = now ?? DateTime.now();
              onDateChanged!(DateTime(value.year, value.month, value.day));
            },
      onSearch: onSearch,
      onCreate: onCreate,
      onOpenSettings: onOpenSettings,
      actions: actions,
      avatar: avatar,
      navigationFooter: navigationFooter,
      bottomBar: bottomBar,
      theme: resolvedWorkspaceTheme,
      child: UltimateStructuredTimeline<T>(
        values: values,
        engine: engine,
        selectedDate: selectedDate,
        config: _workspaceConfig(config),
        controller: controller,
        selectionController: selectionController,
        history: history,
        mutationCoordinator: mutationCoordinator,
        persistenceState: persistenceState,
        persistenceMessage: persistenceMessage,
        onRetry: onRetry,
        onEntryTap: onEntryTap,
        onOpen: onOpen,
        onComplete: onComplete,
        onMove: onMove,
        onResize: onResize,
        onDelete: onDelete,
        onInsert: onInsert,
        onMutationError: onMutationError,
        onMutationRollback: onMutationRollback,
        onDateChanged: onDateChanged,
        onDragStateChanged: onDragStateChanged,
        entryBuilder: entryBuilder,
        ultimateEntryBuilder: ultimateEntryBuilder,
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        progressBuilder: progressBuilder,
        timeFormatter: timeFormatter,
        durationFormatter: durationFormatter,
        headerBuilder: (_) => const SizedBox.shrink(),
        deleteTargetBuilder: deleteTargetBuilder,
        style: style,
        theme: resolvedTimelineTheme,
        strings: strings,
        now: now,
        dataRevision: dataRevision,
        scrollController: scrollController,
        physics: physics,
        padding: padding,
        showInsightBanner: showInsightBanner,
        showCompletionToggle: showCompletionToggle,
        showBoundaryGaps: showBoundaryGaps,
        enableDragging: enableDragging,
        enableResizing: enableResizing,
        enableDeleteTarget: enableDeleteTarget,
      ),
    );
  }


  static StructuredTimelineV11Config _workspaceConfig(
    StructuredTimelineV11Config value,
  ) {
    if (value is! UltimateStructuredTimelineConfig) return value;
    return UltimateStructuredTimelineConfig(
      zoom: value.zoom,
      reducedMotion: value.reducedMotion,
      enableContextMenu: value.enableContextMenu,
      enableTrackpadZoom: value.enableTrackpadZoom,
      enableMultiSelection: value.enableMultiSelection,
      enableUndoRedo: value.enableUndoRedo,
      showDiagnostics: value.showDiagnostics,
      minimumTouchTarget: value.minimumTouchTarget,
      keyboardNudge: value.keyboardNudge,
      keyboardLargeNudge: value.keyboardLargeNudge,
      liveAnnouncementThrottle: value.liveAnnouncementThrottle,
      interaction: value.interaction,
      highContrast: value.highContrast,
      showResponsiveHeader: false,
      showCurrentTime: value.showCurrentTime,
      enableImmediateMouseDrag: value.enableImmediateMouseDrag,
      enableKeyboardInteraction: value.enableKeyboardInteraction,
      enableLiveDataStability: value.enableLiveDataStability,
      visualDensity: value.visualDensity,
    );
  }

  static AdvancedTimelineWorkspaceStatus _workspaceStatusFor(
    StructuredTimelinePersistenceState state,
  ) {
    return switch (state) {
      StructuredTimelinePersistenceState.idle =>
        AdvancedTimelineWorkspaceStatus.ready,
      StructuredTimelinePersistenceState.optimistic =>
        AdvancedTimelineWorkspaceStatus.saved,
      StructuredTimelinePersistenceState.saving =>
        AdvancedTimelineWorkspaceStatus.saving,
      StructuredTimelinePersistenceState.queuedOffline =>
        AdvancedTimelineWorkspaceStatus.offline,
      StructuredTimelinePersistenceState.rollingBack =>
        AdvancedTimelineWorkspaceStatus.warning,
      StructuredTimelinePersistenceState.failed =>
        AdvancedTimelineWorkspaceStatus.failed,
    };
  }

  static String _formatDate(DateTime value) {
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[value.weekday - 1]}, ${months[value.month - 1]} ${value.day}';
  }
}

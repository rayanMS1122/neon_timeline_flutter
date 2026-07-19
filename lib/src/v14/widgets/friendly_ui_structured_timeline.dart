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
import '../models/friendly_timeline_presentation_models.dart';
import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';
import 'friendly_timeline_components.dart';
import 'friendly_timeline_workspace.dart';

/// Version 14 all-in-one planner with an icon-led workspace and guided drag.
///
/// Application data stays behind [TimelinePlannerEngine]. The widget composes
/// public timeline primitives, a presentation adapter, and workspace chrome;
/// it does not know about repositories, navigation, or state-management tools.
class FriendlyUiStructuredTimeline<T> extends StatefulWidget {
  const FriendlyUiStructuredTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    required this.title,
    this.subtitle,
    this.config = const UltimateStructuredTimelineConfig.friendly(),
    this.controller,
    this.selectionController,
    this.history,
    this.mutationCoordinator,
    this.persistenceState = StructuredTimelinePersistenceState.idle,
    this.persistenceMessage,
    this.workspaceStatus,
    this.workspaceStatusLabel,
    this.metrics = const <FriendlyTimelineMetric>[],
    this.navigationItems = const <FriendlyTimelineNavigationItem>[],
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
    this.onCancelDrag,
    this.entryBuilder,
    this.ultimateEntryBuilder,
    this.entryPresentationBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.entryIconBuilder,
    this.entryToneBuilder,
    this.dragTitleBuilder,
    this.timeFormatter,
    this.durationFormatter,
    this.deleteTargetBuilder,
    this.style,
    this.strings = const StructuredTimelineStrings(),
    this.dateFormatter,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    this.actions = const <FriendlyTimelineAction>[],
    this.avatar,
    this.navigationFooter,
    this.bottomBar,
    this.workspaceTheme,
    this.timelineTheme,
    this.dragPresentation = FriendlyTimelineDragPresentation.guided,
    this.now,
    this.dataRevision,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 10, bottom: 120),
    this.showInsightBanner = false,
    this.showCompletionToggle = false,
    this.showBoundaryGaps = false,
    this.showEntryDragHandle = true,
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
  final FriendlyTimelineWorkspaceStatus? workspaceStatus;
  final String? workspaceStatusLabel;
  final List<FriendlyTimelineMetric> metrics;
  final List<FriendlyTimelineNavigationItem> navigationItems;
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
  final VoidCallback? onCancelDrag;
  final AdvancedStructuredTimelineEntryBuilder<T>? entryBuilder;
  final UltimateTimelineEntryBuilder<T>? ultimateEntryBuilder;
  final FriendlyTimelineEntryPresentationBuilder<T>? entryPresentationBuilder;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final FriendlyTimelineEntryIconBuilder<T>? entryIconBuilder;
  final FriendlyTimelineEntryToneBuilder<T>? entryToneBuilder;
  final String Function(T value)? dragTitleBuilder;
  final StructuredTimelineTimeFormatter? timeFormatter;
  final StructuredTimelineDurationFormatter? durationFormatter;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final StructuredTimelineStyle? style;
  final StructuredTimelineStrings strings;
  final String Function(DateTime value)? dateFormatter;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final List<FriendlyTimelineAction> actions;
  final Widget? avatar;
  final Widget? navigationFooter;
  final Widget? bottomBar;
  final FriendlyTimelineUiThemeData? workspaceTheme;
  final UltimateTimelineThemeData? timelineTheme;
  final FriendlyTimelineDragPresentation dragPresentation;
  final DateTime? now;
  final Object? dataRevision;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showInsightBanner;
  final bool showCompletionToggle;
  final bool showBoundaryGaps;
  final bool showEntryDragHandle;
  final bool enableDragging;
  final bool enableResizing;
  final bool enableDeleteTarget;

  @override
  State<FriendlyUiStructuredTimeline<T>> createState() =>
      _FriendlyUiStructuredTimelineState<T>();
}

class _FriendlyUiStructuredTimelineState<T>
    extends State<FriendlyUiStructuredTimeline<T>> {
  late final ValueNotifier<FriendlyTimelineDragUiState> _dragUiState;

  @override
  void initState() {
    super.initState();
    _dragUiState = ValueNotifier<FriendlyTimelineDragUiState>(
      const FriendlyTimelineDragUiState.idle(),
    );
  }

  @override
  void dispose() {
    _dragUiState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workspaceTheme = widget.workspaceTheme ??
        FriendlyTimelineUiThemeData.fromColorScheme(colorScheme);
    final timelineTheme = widget.timelineTheme ??
        _defaultTimelineTheme(colorScheme, workspaceTheme);
    final formatTime = widget.timeFormatter ?? _formatTime;
    final dateLabel = widget.dateFormatter?.call(widget.selectedDate) ??
        _formatDate(widget.selectedDate);

    return FriendlyTimelineUiTheme(
      data: workspaceTheme,
      child: FriendlyTimelineWorkspace(
        title: widget.title,
        subtitle: widget.subtitle,
        dateLabel: dateLabel,
        metrics: widget.metrics,
        navigationItems: widget.navigationItems,
        selectedNavigationIndex: widget.selectedNavigationIndex,
        onNavigationSelected: widget.onNavigationSelected,
        status: widget.workspaceStatus ??
            _workspaceStatusFor(widget.persistenceState),
        statusLabel:
            widget.workspaceStatusLabel ?? widget.persistenceMessage,
        onPreviousDate: _dateChangeBy(const Duration(days: -1)),
        onNextDate: _dateChangeBy(const Duration(days: 1)),
        onToday: _todayCallback(),
        onSearch: widget.onSearch,
        onCreate: widget.onCreate,
        onOpenSettings: widget.onOpenSettings,
        actions: widget.actions,
        avatar: widget.avatar,
        navigationFooter: widget.navigationFooter,
        bottomBar: widget.bottomBar,
        dragStateListenable: _dragUiState,
        onCancelDrag: widget.onCancelDrag ?? widget.controller?.cancelDrag,
        theme: workspaceTheme,
        child: _buildTimeline(
          workspaceTheme: workspaceTheme,
          timelineTheme: timelineTheme,
          formatTime: formatTime,
        ),
      ),
    );
  }

  Widget _buildTimeline({
    required FriendlyTimelineUiThemeData workspaceTheme,
    required UltimateTimelineThemeData timelineTheme,
    required StructuredTimelineTimeFormatter formatTime,
  }) {
    return UltimateStructuredTimeline<T>(
      values: widget.values,
      engine: widget.engine,
      selectedDate: widget.selectedDate,
      config: _workspaceConfig(widget.config),
      controller: widget.controller,
      selectionController: widget.selectionController,
      history: widget.history,
      mutationCoordinator: widget.mutationCoordinator,
      persistenceState: widget.persistenceState,
      persistenceMessage: widget.persistenceMessage,
      onRetry: widget.onRetry,
      onEntryTap: widget.onEntryTap,
      onOpen: widget.onOpen,
      onComplete: widget.onComplete,
      onMove: widget.onMove,
      onResize: widget.onResize,
      onDelete: widget.onDelete,
      onInsert: widget.onInsert,
      onMutationError: widget.onMutationError,
      onMutationRollback: widget.onMutationRollback,
      onDateChanged: widget.onDateChanged,
      onDragStateChanged: _handleDragStateChanged,
      entryBuilder: widget.entryBuilder,
      ultimateEntryBuilder: widget.ultimateEntryBuilder ??
          (context, details) => FriendlyTimelineEntryCard<T>.presentation(
                presentation: _resolveEntryPresentation(
                  context,
                  details,
                  formatTime,
                ),
                showDragHandle: widget.showEntryDragHandle,
              ),
      titleBuilder: widget.titleBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      progressBuilder: widget.progressBuilder,
      timeFormatter: formatTime,
      durationFormatter: widget.durationFormatter,
      headerBuilder: (_) => const SizedBox.shrink(),
      deleteTargetBuilder: widget.deleteTargetBuilder,
      dragFeedbackBuilder: (context, details, child) =>
          FriendlyTimelineUiTheme(
            data: workspaceTheme,
            child: FriendlyTimelineDragFeedback<T>(
              details: details,
              timeFormatter: formatTime,
              presentation: widget.dragPresentation,
              child: child,
            ),
          ),
      dragPlaceholderBuilder: (context, details, child) =>
          FriendlyTimelineUiTheme(
            data: workspaceTheme,
            child: FriendlyTimelineDragPlaceholder<T>(child: child),
          ),
      style: widget.style,
      theme: timelineTheme,
      strings: widget.strings,
      now: widget.now,
      dataRevision: widget.dataRevision,
      scrollController: widget.scrollController,
      physics: widget.physics,
      padding: widget.padding,
      showInsightBanner: widget.showInsightBanner,
      showCompletionToggle: widget.showCompletionToggle,
      showBoundaryGaps: widget.showBoundaryGaps,
      enableDragging: widget.enableDragging,
      enableResizing: widget.enableResizing,
      enableDeleteTarget: widget.enableDeleteTarget,
    );
  }

  FriendlyTimelineEntryPresentation<T> _resolveEntryPresentation(
    BuildContext context,
    UltimateTimelineEntryDetails<T> details,
    StructuredTimelineTimeFormatter formatTime,
  ) {
    final custom = widget.entryPresentationBuilder;
    if (custom != null) return custom(context, details);

    final entry = details.entry;
    final title = widget.titleBuilder?.call(entry) ??
        entry.semanticLabel ??
        details.value.toString();
    final timeLabel =
        '${formatTime(details.visibleStart)} – ${formatTime(details.visibleEnd)}';

    return FriendlyTimelineEntryPresentation<T>(
      details: details,
      title: title,
      subtitle: widget.subtitleBuilder?.call(entry) ??
          _metadataString(entry.metadata['structured.subtitle']),
      timeLabel: timeLabel,
      progress: widget.progressBuilder?.call(entry) ??
          _metadataProgress(entry.metadata['structured.progress']),
      icon: widget.entryIconBuilder?.call(details) ??
          _defaultEntryIcon(details),
      tone: widget.entryToneBuilder?.call(details) ??
          _defaultEntryTone(details),
      semanticLabel: '${entry.semanticLabel ?? title}, $timeLabel',
    );
  }

  void _handleDragStateChanged(StructuredTimelineDragState<T> state) {
    final value = state.value;
    final title = value == null
        ? null
        : widget.dragTitleBuilder?.call(value) ?? value.toString();
    _dragUiState.value = FriendlyTimelineDragUiState.fromDragState<T>(
      state,
      title: title,
    );
    widget.onDragStateChanged?.call(state);
  }

  VoidCallback? _dateChangeBy(Duration delta) {
    final callback = widget.onDateChanged;
    if (callback == null) return null;
    return () => callback(widget.selectedDate.add(delta));
  }

  VoidCallback? _todayCallback() {
    final callback = widget.onDateChanged;
    if (callback == null) return null;
    return () {
      final value = widget.now ?? DateTime.now();
      callback(DateTime(value.year, value.month, value.day));
    };
  }

  static UltimateTimelineThemeData _defaultTimelineTheme(
    ColorScheme colorScheme,
    FriendlyTimelineUiThemeData workspaceTheme,
  ) {
    return UltimateTimelineThemeData.advancedCompact(colorScheme).copyWith(
      background: workspaceTheme.panelStrong,
      surface: workspaceTheme.panelStrong,
      surfaceElevated: workspaceTheme.panelStrong,
      border: workspaceTheme.outline,
      text: workspaceTheme.text,
      mutedText: workspaceTheme.mutedText,
      primary: workspaceTheme.primary,
      success: workspaceTheme.success,
      warning: workspaceTheme.warning,
      error: workspaceTheme.error,
      blocked: workspaceTheme.error,
      shadow: workspaceTheme.shadow,
      entry: const UltimateTimelineEntryTheme(
        radius: 20,
        compactRadius: 17,
        accentPlacement: UltimateTimelineAccentPlacement.none,
        tintOpacity: 0,
        completedTintOpacity: 0,
      ),
      drag: const UltimateTimelineDragTheme(
        focusBorderWidth: 2,
        guideThickness: 2,
        scrimOpacity: 0.02,
        allowedOpacity: 0.08,
        blockedOpacity: 0.12,
        feedbackElevation: 24,
      ),
    );
  }

  static StructuredTimelineV11Config _workspaceConfig(
    StructuredTimelineV11Config value,
  ) {
    if (value is! UltimateStructuredTimelineConfig) return value;
    return value.copyWith(showResponsiveHeader: false);
  }

  static FriendlyTimelineWorkspaceStatus _workspaceStatusFor(
    StructuredTimelinePersistenceState state,
  ) {
    return switch (state) {
      StructuredTimelinePersistenceState.idle =>
        FriendlyTimelineWorkspaceStatus.ready,
      StructuredTimelinePersistenceState.optimistic =>
        FriendlyTimelineWorkspaceStatus.saved,
      StructuredTimelinePersistenceState.saving =>
        FriendlyTimelineWorkspaceStatus.saving,
      StructuredTimelinePersistenceState.queuedOffline =>
        FriendlyTimelineWorkspaceStatus.offline,
      StructuredTimelinePersistenceState.rollingBack =>
        FriendlyTimelineWorkspaceStatus.warning,
      StructuredTimelinePersistenceState.failed =>
        FriendlyTimelineWorkspaceStatus.failed,
    };
  }

  static IconData _defaultEntryIcon<T>(UltimateTimelineEntryDetails<T> details) {
    final state = details.interaction;
    if (state.external) return Icons.event_rounded;
    if (state.recurring) return Icons.repeat_rounded;
    if (state.completed) return Icons.check_rounded;
    if (state.error) return Icons.error_outline_rounded;
    return Icons.auto_awesome_rounded;
  }

  static FriendlyTimelineIconTone _defaultEntryTone<T>(
    UltimateTimelineEntryDetails<T> details,
  ) {
    final state = details.interaction;
    if (state.external || state.locked) return FriendlyTimelineIconTone.amber;
    if (state.completed) return FriendlyTimelineIconTone.mint;
    if (state.error) return FriendlyTimelineIconTone.coral;
    if (state.recurring) return FriendlyTimelineIconTone.lavender;
    return FriendlyTimelineIconTone.primary;
  }

  static String? _metadataString(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static double? _metadataProgress(Object? value) {
    if (value is! num || !value.isFinite) return null;
    return value.toDouble().clamp(0, 1).toDouble();
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    return '${weekdays[value.weekday - 1]}, '
        '${months[value.month - 1]} ${value.day}';
  }
}

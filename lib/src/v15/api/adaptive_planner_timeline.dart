import 'package:flutter/material.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../../v11/core/timeline_interaction_history.dart';
import '../../v11/core/timeline_selection_controller.dart';
import '../../v11/models/structured_timeline_v11_config.dart';
import '../../v11/widgets/ultimate_structured_timeline.dart';
import '../../v12/models/ultimate_timeline_details.dart';
import '../../v12/theme/ultimate_timeline_theme.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../domain/ultra_time_range.dart';
import '../interaction/snap/ultra_magnetic_snap_engine.dart';
import '../presentation/ultra_timeline_presentation.dart';
import '../theme/ultra_timeline_theme.dart';
import '../widgets/diagnostics/ultra_timeline_diagnostics_overlay.dart';
import '../widgets/entries/ultra_timeline_entry_card.dart';
import '../widgets/overlays/ultra_timeline_drag_feedback.dart';
import '../widgets/workspace/ultra_planner_workspace.dart';
import '../widgets/workspace/ultra_zoom_gesture_region.dart';
import 'ultra_timeline_config.dart';
import 'ultra_timeline_controller.dart';

/// Version 15 public planner API.
///
/// It composes the proven virtualized timeline renderer with a new isolated
/// control plane, continuous zoom, magnetic snap strength, adaptive cards,
/// range editing, diagnostics, and a compact responsive workspace.
class AdaptivePlannerTimeline<T> extends StatefulWidget {
  const AdaptivePlannerTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    required this.title,
    this.subtitle,
    this.config = const UltraTimelineConfig.production(),
    this.controller,
    this.timelineController,
    this.selectionController,
    this.history,
    this.mutationCoordinator,
    this.persistenceState = StructuredTimelinePersistenceState.idle,
    this.persistenceMessage,
    this.metrics = const <UltraTimelineMetric>[],
    this.actions = const <UltraTimelineAction>[],
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
    this.onRangePreview,
    this.onRangeCommit,
    this.entryBuilder,
    this.ultimateEntryBuilder,
    this.entryPresentationBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.progressBuilder,
    this.entryIconBuilder,
    this.entryToneBuilder,
    this.timeFormatter,
    this.durationFormatter,
    this.deleteTargetBuilder,
    this.style,
    this.timelineTheme,
    this.workspaceTheme,
    this.strings = const StructuredTimelineStrings(),
    this.dateFormatter,
    this.onSearch,
    this.onCreate,
    this.onOpenSettings,
    this.avatar,
    this.now,
    this.dataRevision,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 10, bottom: 124),
    this.showInsightBanner = false,
    this.showCompletionToggle = false,
    this.showBoundaryGaps = false,
    this.showRangeEditorOnEntryTap = true,
    this.enableDragging = true,
    super.key,
  });

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime selectedDate;
  final String title;
  final String? subtitle;
  final UltraTimelineConfig config;
  final UltraTimelineController? controller;
  final StructuredTimelineController<T>? timelineController;
  final StructuredTimelineSelectionController? selectionController;
  final StructuredTimelineInteractionHistory? history;
  final TimelineMutationCoordinator<T>? mutationCoordinator;
  final StructuredTimelinePersistenceState persistenceState;
  final String? persistenceMessage;
  final List<UltraTimelineMetric> metrics;
  final List<UltraTimelineAction> actions;
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
  final ValueChanged<UltraTimeRange>? onRangePreview;
  final ValueChanged<UltraTimeRange>? onRangeCommit;
  final AdvancedStructuredTimelineEntryBuilder<T>? entryBuilder;
  final UltimateTimelineEntryBuilder<T>? ultimateEntryBuilder;
  final UltraTimelineEntryPresentationBuilder<T>? entryPresentationBuilder;
  final StructuredTimelineTitleBuilder<T>? titleBuilder;
  final StructuredTimelineSubtitleBuilder<T>? subtitleBuilder;
  final StructuredTimelineProgressBuilder<T>? progressBuilder;
  final IconData Function(UltimateTimelineEntryDetails<T> details)?
      entryIconBuilder;
  final UltraTimelineTone Function(UltimateTimelineEntryDetails<T> details)?
      entryToneBuilder;
  final StructuredTimelineTimeFormatter? timeFormatter;
  final StructuredTimelineDurationFormatter? durationFormatter;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final StructuredTimelineStyle? style;
  final UltimateTimelineThemeData? timelineTheme;
  final UltraTimelineThemeData? workspaceTheme;
  final StructuredTimelineStrings strings;
  final String Function(DateTime value)? dateFormatter;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onOpenSettings;
  final Widget? avatar;
  final DateTime? now;
  final Object? dataRevision;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showInsightBanner;
  final bool showCompletionToggle;
  final bool showBoundaryGaps;
  final bool showRangeEditorOnEntryTap;
  final bool enableDragging;

  @override
  State<AdaptivePlannerTimeline<T>> createState() =>
      _AdaptivePlannerTimelineState<T>();
}

class _AdaptivePlannerTimelineState<T>
    extends State<AdaptivePlannerTimeline<T>> {
  late UltraTimelineController _controller;
  late bool _ownsController;
  late final ValueNotifier<StructuredTimelineDragState<T>> _dragState;

  @override
  void initState() {
    super.initState();
    assert(widget.config.debugAssertIsValid());
    _attachController();
    _dragState = ValueNotifier<StructuredTimelineDragState<T>>(
      StructuredTimelineDragState<T>.idle(),
    );
  }

  @override
  void didUpdateWidget(AdaptivePlannerTimeline<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _attachController();
    }
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        UltraTimelineController(
          initialZoom: widget.config.initialZoom,
          initialSnapStrength: widget.config.initialSnapStrength,
        );
  }

  @override
  void dispose() {
    _dragState.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.workspaceTheme ??
        UltraTimelineThemeData.fromColorScheme(Theme.of(context).colorScheme);
    final dateLabel = widget.dateFormatter?.call(widget.selectedDate) ??
        _formatDate(widget.selectedDate);

    Widget body = UltraTimelineTheme(
      data: workspaceTheme,
      child: UltraPlannerWorkspace<T>(
        title: widget.title,
        subtitle: widget.subtitle,
        dateLabel: dateLabel,
        controller: _controller,
        config: widget.config,
        dragStateListenable: _dragState,
        metrics: widget.metrics,
        actions: widget.actions,
        onPreviousDate: _dateCallback(-1),
        onNextDate: _dateCallback(1),
        onToday: _todayCallback(),
        onSearch: widget.onSearch,
        onCreate: widget.onCreate,
        onSettings: widget.onOpenSettings,
        onCancelDrag: widget.timelineController?.cancelDrag,
        onRangePreview: widget.onRangePreview,
        onRangeCommit: widget.onRangeCommit,
        avatar: widget.avatar,
        child: ValueListenableBuilder<UltraTimelineZoomLevel>(
          valueListenable: _controller.zoomLevel,
          builder: (context, zoom, _) {
            return ValueListenableBuilder<UltraTimelineSnapStrength>(
              valueListenable: _controller.snapStrength,
              builder: (context, snap, _) {
                return UltraZoomGestureRegion(
                  controller: _controller,
                  enableCtrlWheelZoom: widget.config.enableCtrlWheelZoom,
                  enableTrackpadZoom: widget.config.enableTrackpadZoom,
                  child: _buildTimeline(
                    context,
                    workspaceTheme,
                    zoom,
                    snap,
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    if (widget.config.showDiagnostics) {
      body = UltraTimelineTheme(
        data: workspaceTheme,
        child: UltraTimelineDiagnosticsOverlay(
          controller: _controller,
          entryCount: widget.values.length,
          child: body,
        ),
      );
    }
    return body;
  }

  Widget _buildTimeline(
    BuildContext context,
    UltraTimelineThemeData workspaceTheme,
    UltraTimelineZoomLevel zoom,
    UltraTimelineSnapStrength snap,
  ) {
    final formatTime = widget.timeFormatter ?? _formatClock;
    final reduced = widget.config.reducedMotion ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    final timelineTheme = widget.timelineTheme ??
        _timelineTheme(Theme.of(context).colorScheme, workspaceTheme, reduced);
    final showHandle = widget.config.dragActivation !=
            UltraTimelineDragActivation.disabled &&
        widget.config.dragActivation != UltraTimelineDragActivation.keyboard;

    return UltimateStructuredTimeline<T>(
      values: widget.values,
      engine: widget.engine,
      selectedDate: widget.selectedDate,
      config: widget.config.toUltimateConfig(zoom: zoom, snapStrength: snap),
      controller: widget.timelineController,
      selectionController: widget.selectionController,
      history: widget.history,
      mutationCoordinator: widget.mutationCoordinator,
      persistenceState: widget.persistenceState,
      persistenceMessage: widget.persistenceMessage,
      onRetry: widget.onRetry,
      onEntryTap: _entryTapCallback(),
      onOpen: widget.onOpen,
      onComplete: widget.onComplete,
      onMove: widget.onMove,
      onResize: widget.onResize,
      onDelete: widget.onDelete,
      onInsert: widget.onInsert,
      onMutationError: widget.onMutationError,
      onMutationRollback: widget.onMutationRollback,
      onDateChanged: widget.onDateChanged,
      onDragStateChanged: _handleDragState,
      entryBuilder: widget.entryBuilder,
      ultimateEntryBuilder: widget.ultimateEntryBuilder ??
          (context, details) {
            final presentation = _presentation(context, details, formatTime);
            return UltraTimelineEntryCard<T>(
              presentation: presentation,
              zoom: zoom,
              showDragHandle: showHandle,
              reducedMotion: reduced,
            );
          },
      titleBuilder: widget.titleBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      progressBuilder: widget.progressBuilder,
      timeFormatter: formatTime,
      durationFormatter: widget.durationFormatter,
      headerBuilder: (_) => const SizedBox.shrink(),
      deleteTargetBuilder: widget.deleteTargetBuilder,
      dragFeedbackBuilder: (context, details, child) {
        final title = widget.titleBuilder?.call(details.entry) ??
            details.entry.semanticLabel ??
            details.value.toString();
        final timeLabel =
            '${formatTime(details.effectiveStart)} – ${formatTime(details.effectiveEnd)}';
        return UltraTimelineTheme(
          data: workspaceTheme,
          child: UltraTimelineDragFeedback<T>(
            details: details,
            title: title,
            timeLabel: timeLabel,
          ),
        );
      },
      dragPlaceholderBuilder: (context, details, child) {
        return UltraTimelineTheme(
          data: workspaceTheme,
          child: UltraTimelineDragPlaceholder<T>(
            details: details,
            child: child,
          ),
        );
      },
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
      enableDragging: widget.enableDragging &&
          widget.config.dragActivation != UltraTimelineDragActivation.disabled &&
          widget.config.dragActivation != UltraTimelineDragActivation.keyboard,
      enableResizing: widget.config.enableResizing,
      enableDeleteTarget: widget.config.enableDeleteTarget,
    );
  }

  UltraTimelineEntryPresentation<T> _presentation(
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
    return UltraTimelineEntryPresentation<T>(
      details: details,
      title: title,
      subtitle: widget.subtitleBuilder?.call(entry) ??
          _metadataString(entry.metadata['structured.subtitle']),
      timeLabel: timeLabel,
      icon: widget.entryIconBuilder?.call(details) ?? _defaultIcon(details),
      tone: widget.entryToneBuilder?.call(details) ?? _defaultTone(details),
      progress: widget.progressBuilder?.call(entry) ??
          _metadataProgress(entry.metadata['structured.progress']),
      badges: _metadataBadges(entry.metadata['ultra.badges']),
      semanticLabel: '${entry.semanticLabel ?? title}, $timeLabel',
    );
  }

  StructuredTimelineEntryCallback<T>? _entryTapCallback() {
    if (!widget.showRangeEditorOnEntryTap) return widget.onEntryTap;
    return (context, details) async {
      if (widget.config.enableRangeEditor) {
        final dayStart = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
        );
        _controller.showTimeRangeEditor(
          range: UltraTimeRange(
            start: details.item.start,
            end: details.item.end,
          ),
          bounds: UltraTimeRange(
            start: dayStart,
            end: dayStart.add(const Duration(days: 1)),
          ),
        );
      }
      final callback = widget.onEntryTap;
      if (callback != null) await callback(context, details);
    };
  }

  void _handleDragState(StructuredTimelineDragState<T> state) {
    _dragState.value = state;
    widget.onDragStateChanged?.call(state);
  }

  VoidCallback? _dateCallback(int delta) {
    final callback = widget.onDateChanged;
    if (callback == null) return null;
    return () => callback(widget.selectedDate.add(Duration(days: delta)));
  }

  VoidCallback? _todayCallback() {
    final callback = widget.onDateChanged;
    if (callback == null) return null;
    return () {
      final value = widget.now ?? DateTime.now();
      callback(DateTime(value.year, value.month, value.day));
    };
  }

  static UltimateTimelineThemeData _timelineTheme(
    ColorScheme scheme,
    UltraTimelineThemeData workspace,
    bool reduced,
  ) {
    final base = UltimateTimelineThemeData.advancedCompact(scheme);
    return base.copyWith(
      background: workspace.canvas,
      surface: workspace.canvas,
      surfaceElevated: workspace.panel,
      border: workspace.outline,
      text: workspace.text,
      mutedText: workspace.mutedText,
      primary: workspace.primary,
      success: workspace.mint,
      warning: workspace.amber,
      error: workspace.coral,
      blocked: workspace.coral,
      shadow: workspace.shadow,
      entry: base.entry.copyWith(
        radius: workspace.radiusMedium,
        compactRadius: workspace.radiusSmall,
        accentPlacement: UltimateTimelineAccentPlacement.none,
        tintOpacity: 0,
        completedTintOpacity: 0,
      ),
      drag: base.drag.copyWith(
        scrimOpacity: 0,
        feedbackElevation: reduced ? 4 : 18,
      ),
      motion: base.motion.reduced(reduced),
    );
  }

  static IconData _defaultIcon<T>(UltimateTimelineEntryDetails<T> details) {
    if (details.interaction.completed) return Icons.check_rounded;
    if (details.interaction.locked) return Icons.lock_outline_rounded;
    if (details.interaction.recurring) return Icons.repeat_rounded;
    if (details.interaction.error) return Icons.error_outline_rounded;
    return Icons.bolt_rounded;
  }

  static UltraTimelineTone _defaultTone<T>(
    UltimateTimelineEntryDetails<T> details,
  ) {
    if (details.interaction.error) return UltraTimelineTone.coral;
    if (details.interaction.completed) return UltraTimelineTone.mint;
    if (details.interaction.external) return UltraTimelineTone.amber;
    if (details.interaction.recurring) return UltraTimelineTone.sky;
    return UltraTimelineTone.violet;
  }

  static String? _metadataString(Object? value) {
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  static double? _metadataProgress(Object? value) {
    return value is num
        ? value.toDouble().clamp(0.0, 1.0).toDouble()
        : null;
  }

  static List<String> _metadataBadges(Object? value) {
    if (value is Iterable) {
      return List<String>.unmodifiable(
        value.whereType<String>().where((item) => item.trim().isNotEmpty),
      );
    }
    return const <String>[];
  }

  static String _formatClock(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
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
    return '${weekdays[value.weekday - 1]}, ${value.day} ${months[value.month - 1]}';
  }
}

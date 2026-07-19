import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../../v10/widgets/delight_structured_timeline.dart';
import '../../v12/models/ultimate_timeline_config.dart';
import '../../v12/models/ultimate_timeline_details.dart';
import '../../v12/theme/ultimate_timeline_theme.dart';
import '../../v12/widgets/ultimate_timeline_components.dart';
import '../../v4/models/timeline_types.dart';
import '../../v6/core/timeline_day_plan.dart';
import '../../v6/core/timeline_planner_engine.dart';
import '../../v6/core/timeline_reschedule.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../../v8/core/timeline_mutation_coordinator.dart';
import '../../v8/core/timeline_resize.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../../v8/models/structured_timeline_layout.dart';
import '../../v9/models/structured_timeline_entry_style.dart';
import '../../v9/models/structured_timeline_gap_layout.dart';
import '../core/timeline_interaction_history.dart';
import '../core/timeline_selection_controller.dart';
import '../models/structured_timeline_v11_config.dart';
import 'structured_timeline_v11_components.dart';

/// Highest-level Structured timeline API.
///
/// Version 12 keeps the proven virtualized renderer and coordinate-correct
/// drag engine, then supplies adaptive cards, semantic zoom geometry,
/// single-loop auto-scroll tuning, explicit feedback, responsive header and
/// reusable theme tokens. Application data and persistence stay host-owned.
class UltimateStructuredTimeline<T> extends StatelessWidget {
  const UltimateStructuredTimeline({
    required this.values,
    required this.engine,
    required this.selectedDate,
    this.config = const UltimateStructuredTimelineConfig.production(),
    this.controller,
    this.selectionController,
    this.history,
    this.persistenceState = StructuredTimelinePersistenceState.idle,
    this.persistenceMessage,
    this.onRetry,
    this.mutationCoordinator,
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
    this.headerBuilder,
    this.deleteTargetBuilder,
    this.dragFeedbackBuilder,
    this.dragPlaceholderBuilder,
    this.style,
    this.theme,
    this.strings = const StructuredTimelineStrings(),
    this.now,
    this.dataRevision,
    this.scrollController,
    this.physics,
    this.padding = const EdgeInsets.only(top: 12, bottom: 164),
    this.showInsightBanner = true,
    this.showCompletionToggle = false,
    this.showBoundaryGaps = false,
    this.enableDragging = true,
    this.enableResizing = true,
    this.enableDeleteTarget = true,
    super.key,
  });

  final List<T> values;
  final TimelinePlannerEngine<T> engine;
  final DateTime selectedDate;

  /// Accepts both the backwards-compatible 11.x config and the richer 12.x
  /// [UltimateStructuredTimelineConfig].
  final StructuredTimelineV11Config config;
  final StructuredTimelineController<T>? controller;
  final StructuredTimelineSelectionController? selectionController;
  final StructuredTimelineInteractionHistory? history;
  final StructuredTimelinePersistenceState persistenceState;
  final String? persistenceMessage;
  final VoidCallback? onRetry;
  final TimelineMutationCoordinator<T>? mutationCoordinator;
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
  final WidgetBuilder? headerBuilder;
  final AdvancedStructuredTimelineDeleteTargetBuilder? deleteTargetBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragFeedbackBuilder;
  final AdvancedStructuredTimelineDragDecorator<T>? dragPlaceholderBuilder;
  final StructuredTimelineStyle? style;
  final UltimateTimelineThemeData? theme;
  final StructuredTimelineStrings strings;
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
    final resolvedConfig = _resolveConfig(config);
    assert(resolvedConfig.interaction.debugAssertIsValid());
    final media = MediaQuery.maybeOf(context);
    final reduced =
        resolvedConfig.reducedMotion || (media?.disableAnimations ?? false);
    final highContrast =
        resolvedConfig.highContrast || (media?.highContrast ?? false);
    final metrics = resolvedConfig.zoomMetrics;
    final baseTheme =
        theme ??
        (resolvedConfig.visualDensity == UltimateTimelineVisualDensity.compact
            ? UltimateTimelineThemeData.advancedCompact(
                Theme.of(context).colorScheme,
              )
            : UltimateTimelineThemeData.fromColorScheme(
                Theme.of(context).colorScheme,
              ));
    final resolvedTheme = _withMotion(
      baseTheme,
      baseTheme.motion.reduced(reduced),
    );
    final formatTime = timeFormatter ?? _formatTime;
    final formatDuration = durationFormatter ?? _formatDuration;
    final interaction = resolvedConfig.interaction;
    final minimumHeight = math
        .max(
          metrics.minimumEntryHeight * resolvedConfig.entryHeightFactor,
          resolvedConfig.minimumTouchTarget,
        )
        .toDouble();

    final baseStyle =
        style ??
        (highContrast
            ? StructuredTimelineStyle.highContrast(
                brightness: Theme.of(context).brightness,
              )
            : StructuredTimelineStyle.delight(
                primaryColor: resolvedTheme.primary,
                accentColor: resolvedTheme.primary,
              ));
    final resolvedStyle = baseStyle.copyWith(
      backgroundColor: resolvedTheme.background,
      surfaceColor: resolvedTheme.surface,
      cardColor: resolvedTheme.surfaceElevated,
      primaryColor: resolvedTheme.primary,
      accentColor: resolvedTheme.primary,
      textColor: resolvedTheme.text,
      mutedTextColor: resolvedTheme.mutedText,
      borderColor: resolvedTheme.border,
      railColor: resolvedTheme.border,
      conflictColor: resolvedTheme.error,
      shadowColor: resolvedTheme.shadow,
      pixelsPerMinute: metrics.pixelsPerMinute,
      minimumEntryExtent: minimumHeight,
      cardMinimumHeight: minimumHeight,
      cardRadius: resolvedTheme.entry.radius,
      dragScale: reduced ? 1 : interaction.dragLiftScale,
      dragAnimationDuration: resolvedTheme.motion.dragStart,
      cardTintOpacity:
          resolvedConfig.visualDensity == UltimateTimelineVisualDensity.compact
          ? 0.018
          : baseStyle.cardTintOpacity,
      cardBorderOpacity:
          resolvedConfig.visualDensity == UltimateTimelineVisualDensity.compact
          ? 0.42
          : baseStyle.cardBorderOpacity,
    );

    final experience = const StructuredTimelineExperience.delight().copyWith(
      dragActivationDelay: interaction.longPressDuration,
      magnetDistance: interaction.snapDistance,
      dragLiftScale: reduced ? 1 : interaction.dragLiftScale,
      dragElevation: reduced ? 6 : interaction.dragElevation,
      placeholderOpacity: interaction.placeholderOpacity,
      showDragScrim: interaction.showDragScrim && !reduced,
      showSnapGuide: interaction.showSnapGuide,
      showDropSlot: interaction.showDropPreview,
      showConflictPreview: interaction.showConflictPreview,
      announceDragChanges: interaction.announceDragChanges,
      edgeScrollFrameInterval: reduced
          ? const Duration(milliseconds: 32)
          : const Duration(milliseconds: 16),
    );

    final AdvancedStructuredTimelineEntryBuilder<T> effectiveEntryBuilder =
        entryBuilder ??
        (context, details) {
          final ultimateDetails = _entryDetails(details);
          final custom = ultimateEntryBuilder;
          if (custom != null) return custom(context, ultimateDetails);
          return UltimateTimelineEntryCard<T>(
            details: ultimateDetails,
            title:
                titleBuilder?.call(details.entry) ??
                details.entry.semanticLabel ??
                details.value.toString(),
            subtitle:
                subtitleBuilder?.call(details.entry) ??
                _metadataString(details.entry.metadata['structured.subtitle']),
            progress:
                progressBuilder?.call(details.entry) ??
                _metadataProgress(
                  details.entry.metadata['structured.progress'],
                ),
            zoomLevel: resolvedConfig.zoomLevel,
            timeFormatter: formatTime,
            durationFormatter: formatDuration,
          );
        };

    final callback = onOpen ?? onEntryTap;
    final StructuredTimelineEntryCallback<T>? effectiveEntryTap =
        callback == null && selectionController == null
        ? null
        : (
            BuildContext context,
            StructuredTimelineEntryDetails<T> details,
          ) async {
            selectionController?.select(details.entry.id);
            if (callback != null) {
              await Future<void>.sync(() => callback(context, details));
            }
          };

    final timeline = DelightStructuredTimeline<T>(
      values: values,
      engine: engine,
      selectedDate: selectedDate,
      now: now,
      dataRevision: dataRevision,
      refreshInterval: metrics.clockUpdateInterval,
      dayConfig: const TimelineDayPlanConfig(),
      style: resolvedStyle,
      layout: _layout(
        resolvedConfig.zoomLevel,
        minimumHeight,
        horizontalFactor: resolvedConfig.horizontalSpacingFactor,
        cardRadius: resolvedTheme.entry.radius,
        compactVisual:
            resolvedConfig.visualDensity ==
            UltimateTimelineVisualDensity.compact,
      ),
      entryStyle: const StructuredTimelineEntryStyle.delight().copyWith(
        minimumHeight: minimumHeight,
        showSubtitle: metrics.showSubtitle,
        showProgress: metrics.showMetadata,
        showMetadata: metrics.showMetadata,
      ),
      gapLayout: _gapLayout(resolvedConfig.zoomLevel),
      experience: experience,
      strings: strings,
      controller: controller,
      mutationCoordinator: mutationCoordinator,
      onEntryTap: effectiveEntryTap,
      onComplete: onComplete,
      onMove: onMove,
      onResize: onResize,
      onDelete: onDelete,
      onInsert: onInsert,
      onMutationError: onMutationError,
      onMutationRollback: onMutationRollback,
      onDragStateChanged: onDragStateChanged,
      entryBuilder: effectiveEntryBuilder,
      dragFeedbackBuilder:
          dragFeedbackBuilder ??
          (context, details, child) {
            final preview = details.movePreview;
            return UltimateTimelineTheme(
              data: resolvedTheme,
              child: UltimateTimelineDragFeedback<T>(
                start: preview?.start ?? details.effectiveStart,
                end: preview?.end ?? details.effectiveEnd,
                timeFormatter: formatTime,
                allowed: preview?.canCommit ?? true,
                magnetized: preview?.magnetized ?? false,
                conflictCount: preview?.conflicts.length ?? 0,
                blockReason: preview?.canCommit == false
                    ? strings.moveBlocked
                    : null,
                scale: reduced ? 1 : interaction.dragLiftScale,
                child: child,
              ),
            );
          },
      dragPlaceholderBuilder:
          dragPlaceholderBuilder ??
          (context, details, child) {
            return UltimateTimelineDragPlaceholder<T>(
              opacity: interaction.placeholderOpacity,
              child: child,
            );
          },
      deleteTargetBuilder:
          deleteTargetBuilder ??
          (_, active, __) => UltimateTimelineTheme(
            data: resolvedTheme,
            child: UltimateTimelineDeleteTarget(
              active: active,
              label: strings.delete,
              activeLabel: strings.delete,
            ),
          ),
      titleBuilder: titleBuilder,
      subtitleBuilder: subtitleBuilder,
      progressBuilder: progressBuilder,
      timeFormatter: formatTime,
      durationFormatter: formatDuration,
      scrollController: scrollController,
      physics: physics,
      padding:
          resolvedConfig.visualDensity ==
                  UltimateTimelineVisualDensity.compact &&
              padding == const EdgeInsets.only(top: 12, bottom: 164)
          ? const EdgeInsets.only(top: 6, bottom: 96)
          : padding,
      showInsightBanner:
          showInsightBanner &&
          resolvedConfig.zoomLevel != UltimateTimelineZoomLevel.overview,
      showCompletionToggle: showCompletionToggle,
      showBoundaryGaps: showBoundaryGaps,
      showGapActions:
          resolvedConfig.zoomLevel == UltimateTimelineZoomLevel.detailed,
      enableDragging: enableDragging,
      enableResizing: enableResizing,
      enableDeleteTarget: enableDeleteTarget,
      reschedulePolicy: TimelineReschedulePolicy(
        snap: interaction.dropSnapInterval,
        keepEntireEntryInBounds: true,
        allowConflicts: interaction.allowConflictingDrops,
        enableDeleteTarget: enableDeleteTarget,
        pixelsPerMinute: metrics.pixelsPerMinute,
        magnetizeToNeighbors: true,
        magnetDistance: interaction.snapDistance,
        snapHysteresis: interaction.snapHysteresis,
        preferConflictFreeDrop: interaction.preferConflictFreeDrop,
      ),
      resizePolicy: const TimelineResizePolicy(snap: Duration(minutes: 5)),
      autoScrollPolicy: const TimelineAutoScrollPolicy(
        edgeExtent: 128,
        minimumStep: 1.5,
        maximumStep: 12,
      ),
    );

    Widget body = Stack(
      children: [
        timeline,
        if (persistenceState != StructuredTimelinePersistenceState.idle)
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 16,
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: StructuredTimelinePersistenceBanner(
                state: persistenceState,
                message: persistenceMessage,
                onRetry: onRetry,
              ),
            ),
          ),
      ],
    );

    if (resolvedConfig.showResponsiveHeader) {
      final timelineBody = body;
      body = LayoutBuilder(
        builder: (context, constraints) {
          final header =
              headerBuilder?.call(context) ??
              UltimateTimelineHeader(
                details: UltimateTimelineHeaderDetails(
                  selectedDate: selectedDate,
                  compact:
                      constraints.maxWidth <
                      resolvedTheme.header.compactBreakpoint,
                ),
                onPrevious: onDateChanged == null
                    ? null
                    : () => onDateChanged!(
                        selectedDate.subtract(const Duration(days: 1)),
                      ),
                onNext: onDateChanged == null
                    ? null
                    : () => onDateChanged!(
                        selectedDate.add(const Duration(days: 1)),
                      ),
                onToday: onDateChanged == null
                    ? null
                    : () => onDateChanged!(DateTime.now()),
              );
          final content = Column(
            children: [
              Padding(
                padding:
                    resolvedConfig.visualDensity ==
                        UltimateTimelineVisualDensity.compact
                    ? const EdgeInsets.fromLTRB(10, 8, 10, 3)
                    : const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: header,
              ),
              Expanded(child: timelineBody),
            ],
          );
          if (constraints.hasBoundedHeight) return content;
          return SizedBox(height: 720, child: content);
        },
      );
    }

    return UltimateTimelineTheme(
      data: resolvedTheme,
      child: ColoredBox(color: resolvedTheme.background, child: body),
    );
  }

  UltimateTimelineEntryDetails<T> _entryDetails(
    AdvancedStructuredTimelineEntryDetails<T> details,
  ) {
    final entry = details.entry;
    final locked =
        entry.metadata['timeline.locked'] == true || !entry.draggable;
    return UltimateTimelineEntryDetails<T>(
      base: details,
      segmentType: _segmentType(details),
      interaction: UltimateTimelineEntryInteractionState<T>(
        selected: details.selected,
        focused: details.focused,
        completed: entry.status == TimelineStatus.completed,
        locked: locked,
        recurring: details.base.isRecurring,
        external: details.base.isExternal,
        busy: details.busy,
        error: entry.metadata['timeline.error'] != null,
        errorMessage: _metadataString(entry.metadata['timeline.error']),
        dragging: details.isDragging,
        resizing: details.isResizing,
      ),
    );
  }

  static UltimateTimelineSegmentType _segmentType<T>(
    AdvancedStructuredTimelineEntryDetails<T> details,
  ) {
    final clippedBefore = details.entry.start.isBefore(details.item.start);
    final clippedAfter = details.entry.rawEnd.isAfter(details.item.end);
    if (clippedBefore && clippedAfter) {
      return UltimateTimelineSegmentType.middle;
    }
    if (clippedBefore) return UltimateTimelineSegmentType.end;
    if (clippedAfter) return UltimateTimelineSegmentType.start;
    return UltimateTimelineSegmentType.complete;
  }

  static UltimateStructuredTimelineConfig _resolveConfig(
    StructuredTimelineV11Config value,
  ) {
    if (value is UltimateStructuredTimelineConfig) return value;
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
      showResponsiveHeader: false,
    );
  }

  static StructuredTimelineLayout _layout(
    UltimateTimelineZoomLevel level,
    double minimumHeight, {
    required double horizontalFactor,
    required double cardRadius,
    required bool compactVisual,
  }) {
    final metrics = UltimateTimelineZoomMetrics.forLevel(level);
    final overview = level == UltimateTimelineZoomLevel.overview;
    return StructuredTimelineLayout.custom(
      pixelsPerMinute: metrics.pixelsPerMinute,
      minimumEntryExtent: minimumHeight,
      maximumEntryExtent: level == UltimateTimelineZoomLevel.detailed
          ? 480
          : 320,
      minimumGapExtent: overview ? 28 : 34,
      maximumGapExtent: level == UltimateTimelineZoomLevel.detailed ? 420 : 180,
      horizontalPadding:
          ((overview ? 9 : compactVisual ? 11 : 14) * horizontalFactor)
          .clamp(compactVisual ? 7.0 : 8.0, 18.0)
          .toDouble(),
      timeColumnWidth:
          ((overview ? 34 : compactVisual ? 42 : 48) * horizontalFactor)
          .clamp(compactVisual ? 30.0 : 34.0, 54.0)
          .toDouble(),
      markerWidth:
          ((overview ? 30 : compactVisual ? 34 : 48) * horizontalFactor)
          .clamp(compactVisual ? 28.0 : 34.0, 54.0)
          .toDouble(),
      columnGap: ((compactVisual ? 7 : 9) * horizontalFactor)
          .clamp(compactVisual ? 4.0 : 6.0, 11.0)
          .toDouble(),
      cardRadius: cardRadius,
      cardMinimumHeight: minimumHeight,
      markerHeight: compactVisual
          ? 30
          : minimumHeight.clamp(48, 66).toDouble(),
      overscan: Duration(
        minutes: (metrics.overscan / metrics.pixelsPerMinute).round(),
      ),
      showEndTimes: level != UltimateTimelineZoomLevel.overview,
      showGapActions: level == UltimateTimelineZoomLevel.detailed,
      showConflictBridges: true,
      showResizeHandles: metrics.showResizeHandles,
    );
  }

  static StructuredTimelineGapLayout _gapLayout(
    UltimateTimelineZoomLevel level,
  ) {
    return switch (level) {
      UltimateTimelineZoomLevel.overview =>
        const StructuredTimelineGapLayout.compressed(
          minimumExtent: 32,
          maximumExtent: 40,
          compressedExtent: 36,
        ),
      UltimateTimelineZoomLevel.compact =>
        const StructuredTimelineGapLayout.hybrid(
          pixelsPerMinute: 0.9,
          minimumExtent: 28,
          maximumExtent: 96,
          compressedExtent: 40,
        ),
      UltimateTimelineZoomLevel.normal =>
        const StructuredTimelineGapLayout.hybrid(compressedExtent: 66),
      UltimateTimelineZoomLevel.comfortable =>
        const StructuredTimelineGapLayout.hybrid(
          compressionStartsAt: Duration(hours: 2),
          compressedExtent: 82,
        ),
      UltimateTimelineZoomLevel.detailed =>
        const StructuredTimelineGapLayout.proportional(),
    };
  }

  static UltimateTimelineThemeData _withMotion(
    UltimateTimelineThemeData value,
    UltimateTimelineMotionTheme motion,
  ) {
    return value.copyWith(motion: motion);
  }

  static String? _metadataString(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static double? _metadataProgress(Object? value) =>
      value is num ? value.toDouble().clamp(0.0, 1.0).toDouble() : null;

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes.abs();
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '$rest min';
    if (rest == 0) return '${hours}h';
    return '${hours}h ${rest}m';
  }
}

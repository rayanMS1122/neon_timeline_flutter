import 'package:flutter/material.dart';

import 'models.dart';

/// Runtime counters emitted by the optional diagnostics hook.
@immutable
class NeonPlannerTimelineDiagnostics {
  /// Creates a diagnostics snapshot.
  const NeonPlannerTimelineDiagnostics({
    required this.totalEntries,
    required this.indexedEntries,
    required this.visibleEntries,
    required this.gapCount,
    required this.maximumLaneCount,
    required this.zoomLevel,
    required this.canvasHeight,
  });

  /// Entries supplied by the application.
  final int totalEntries;

  /// Entries intersecting the selected visible day.
  final int indexedEntries;

  /// Entries materialized for the current viewport and overscan.
  final int visibleEntries;

  /// Calm gap presentations in the day model.
  final int gapCount;

  /// Largest overlap lane count in the current day.
  final int maximumLaneCount;

  /// Active semantic zoom level.
  final NeonPlannerZoomLevel zoomLevel;

  /// Full scroll canvas height in logical pixels.
  final double canvasHeight;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeonPlannerTimelineDiagnostics &&
            totalEntries == other.totalEntries &&
            indexedEntries == other.indexedEntries &&
            visibleEntries == other.visibleEntries &&
            gapCount == other.gapCount &&
            maximumLaneCount == other.maximumLaneCount &&
            zoomLevel == other.zoomLevel &&
            canvasHeight == other.canvasHeight;
  }

  @override
  int get hashCode => Object.hash(
    totalEntries,
    indexedEntries,
    visibleEntries,
    gapCount,
    maximumLaneCount,
    zoomLevel,
    canvasHeight,
  );

  @override
  String toString() {
    return 'NeonPlannerTimelineDiagnostics('
        'total: $totalEntries, indexed: $indexedEntries, '
        'visible: $visibleEntries, gaps: $gapCount, '
        'maxLanes: $maximumLaneCount, zoom: $zoomLevel, '
        'canvasHeight: ${canvasHeight.toStringAsFixed(1)})';
  }
}

/// Configuration for timeline behavior and geometry.
@immutable
class NeonPlannerTimelineConfig {
  /// Creates a configuration.
  const NeonPlannerTimelineConfig({
    this.visibleStart = const Duration(),
    this.visibleEnd = const Duration(hours: 24),
    this.initialZoom = NeonPlannerZoomLevel.balanced,
    this.snapStrength = NeonPlannerSnapStrength.balanced,
    this.snapInterval = const Duration(minutes: 15),
    this.minimumEntryDuration = const Duration(minutes: 5),
    this.dragActivation = NeonPlannerDragActivation.longPress,
    this.conflictPolicy = NeonPlannerConflictPolicy.delegate,
    this.enableResize = true,
    this.enableRangeCreation = true,
    this.showGapMessages = true,
    this.minimumGapForMessage = const Duration(minutes: 45),
    this.overscan = 480,
    this.timeColumnWidth = 64,
    this.axisColumnWidth = 72,
    this.statusColumnWidth = 48,
    this.surfaceRadius = 38,
    this.dayStartsAt = const Duration(hours: 6),
    this.nightStartsAt = const Duration(hours: 22),
  }) : assert(overscan >= 0),
       assert(timeColumnWidth >= 48),
       assert(axisColumnWidth >= 48),
       assert(statusColumnWidth >= 0),
       assert(surfaceRadius >= 0);

  /// Opinionated production defaults.
  const NeonPlannerTimelineConfig.production()
    : this(
        visibleStart: const Duration(),
        visibleEnd: const Duration(hours: 24),
        initialZoom: NeonPlannerZoomLevel.balanced,
        snapStrength: NeonPlannerSnapStrength.balanced,
        snapInterval: const Duration(minutes: 15),
        minimumEntryDuration: const Duration(minutes: 5),
        dragActivation: NeonPlannerDragActivation.longPress,
        conflictPolicy: NeonPlannerConflictPolicy.delegate,
        enableResize: true,
        enableRangeCreation: true,
        showGapMessages: true,
        minimumGapForMessage: const Duration(minutes: 45),
        overscan: 480,
        timeColumnWidth: 64,
        axisColumnWidth: 72,
        statusColumnWidth: 48,
        surfaceRadius: 38,
        dayStartsAt: const Duration(hours: 6),
        nightStartsAt: const Duration(hours: 22),
      );

  /// Visible time offset from the selected date.
  final Duration visibleStart;

  /// End of the visible time range.
  final Duration visibleEnd;

  /// Initial semantic zoom.
  final NeonPlannerZoomLevel initialZoom;

  /// Snap strength.
  final NeonPlannerSnapStrength snapStrength;

  /// Base minute grid.
  final Duration snapInterval;

  /// Smallest allowed entry duration.
  final Duration minimumEntryDuration;

  /// Pointer drag activation.
  final NeonPlannerDragActivation dragActivation;

  /// Conflict behavior.
  final NeonPlannerConflictPolicy conflictPolicy;

  /// Enables resize handles.
  final bool enableResize;

  /// Enables creating ranges on empty timeline space.
  final bool enableRangeCreation;

  /// Shows calm gap labels.
  final bool showGapMessages;

  /// Smallest gap eligible for a label.
  final Duration minimumGapForMessage;

  /// Virtualization overscan in logical pixels.
  final double overscan;

  /// Width of the time label column.
  final double timeColumnWidth;

  /// Width of the central axis column.
  final double axisColumnWidth;

  /// Width of the optional status column.
  final double statusColumnWidth;

  /// Outer surface radius.
  final double surfaceRadius;

  /// Start of daytime styling.
  final Duration dayStartsAt;

  /// Start of nighttime styling.
  final Duration nightStartsAt;

  /// Throws when duration-based configuration values are inconsistent.
  ///
  /// Duration ordering cannot be checked inside a `const` constructor because
  /// Dart does not treat those comparison method calls as constant
  /// expressions. Timeline widgets call this method before using the config.
  void validate() {
    if (visibleEnd <= visibleStart) {
      throw ArgumentError.value(
        visibleEnd,
        'visibleEnd',
        'Must be after visibleStart ($visibleStart).',
      );
    }
    if (snapInterval <= Duration.zero) {
      throw ArgumentError.value(
        snapInterval,
        'snapInterval',
        'Must be greater than zero.',
      );
    }
    if (minimumEntryDuration <= Duration.zero) {
      throw ArgumentError.value(
        minimumEntryDuration,
        'minimumEntryDuration',
        'Must be greater than zero.',
      );
    }
    if (minimumGapForMessage < Duration.zero) {
      throw ArgumentError.value(
        minimumGapForMessage,
        'minimumGapForMessage',
        'Must not be negative.',
      );
    }
  }

  /// Returns a modified configuration.
  NeonPlannerTimelineConfig copyWith({
    Duration? visibleStart,
    Duration? visibleEnd,
    NeonPlannerZoomLevel? initialZoom,
    NeonPlannerSnapStrength? snapStrength,
    Duration? snapInterval,
    Duration? minimumEntryDuration,
    NeonPlannerDragActivation? dragActivation,
    NeonPlannerConflictPolicy? conflictPolicy,
    bool? enableResize,
    bool? enableRangeCreation,
    bool? showGapMessages,
    Duration? minimumGapForMessage,
    double? overscan,
    double? timeColumnWidth,
    double? axisColumnWidth,
    double? statusColumnWidth,
    double? surfaceRadius,
    Duration? dayStartsAt,
    Duration? nightStartsAt,
  }) {
    return NeonPlannerTimelineConfig(
      visibleStart: visibleStart ?? this.visibleStart,
      visibleEnd: visibleEnd ?? this.visibleEnd,
      initialZoom: initialZoom ?? this.initialZoom,
      snapStrength: snapStrength ?? this.snapStrength,
      snapInterval: snapInterval ?? this.snapInterval,
      minimumEntryDuration: minimumEntryDuration ?? this.minimumEntryDuration,
      dragActivation: dragActivation ?? this.dragActivation,
      conflictPolicy: conflictPolicy ?? this.conflictPolicy,
      enableResize: enableResize ?? this.enableResize,
      enableRangeCreation: enableRangeCreation ?? this.enableRangeCreation,
      showGapMessages: showGapMessages ?? this.showGapMessages,
      minimumGapForMessage: minimumGapForMessage ?? this.minimumGapForMessage,
      overscan: overscan ?? this.overscan,
      timeColumnWidth: timeColumnWidth ?? this.timeColumnWidth,
      axisColumnWidth: axisColumnWidth ?? this.axisColumnWidth,
      statusColumnWidth: statusColumnWidth ?? this.statusColumnWidth,
      surfaceRadius: surfaceRadius ?? this.surfaceRadius,
      dayStartsAt: dayStartsAt ?? this.dayStartsAt,
      nightStartsAt: nightStartsAt ?? this.nightStartsAt,
    );
  }
}

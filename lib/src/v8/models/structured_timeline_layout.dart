import 'package:flutter/foundation.dart';

import '../../v7/models/structured_timeline_style.dart';

enum StructuredTimelineTimeColumnPosition { left, right }

enum StructuredTimelineDensity {
  compact,
  comfortable,
  dense,
  absoluteTime,
  custom,
}

/// Layout policy for the 8.x Structured timeline.
///
/// The policy contains geometry only. It does not own colors, application
/// models, persistence, or business rules.
@immutable
class StructuredTimelineLayout {
  const StructuredTimelineLayout({
    this.density = StructuredTimelineDensity.comfortable,
    this.timeColumnPosition = StructuredTimelineTimeColumnPosition.left,
    this.pixelsPerMinute = 1.35,
    this.minimumEntryExtent = 72,
    this.maximumEntryExtent = 280,
    this.minimumGapExtent = 54,
    this.maximumGapExtent = 180,
    this.horizontalPadding = 16,
    this.timeColumnWidth = 46,
    this.markerWidth = 46,
    this.columnGap = 10,
    this.cardRadius = 20,
    this.cardMinimumHeight = 62,
    this.markerHeight = 58,
    this.overscan = const Duration(hours: 2),
    this.showEndTimes = true,
    this.showGapActions = true,
    this.showConflictBridges = true,
    this.showResizeHandles = true,
  }) : assert(pixelsPerMinute > 0),
       assert(minimumEntryExtent > 0),
       assert(maximumEntryExtent >= minimumEntryExtent),
       assert(minimumGapExtent >= 0),
       assert(maximumGapExtent >= minimumGapExtent),
       assert(horizontalPadding >= 0),
       assert(timeColumnWidth > 0),
       assert(markerWidth > 0),
       assert(columnGap >= 0),
       assert(cardRadius >= 0),
       assert(cardMinimumHeight > 0),
       assert(markerHeight > 0);

  const StructuredTimelineLayout.compact()
    : this(
        density: StructuredTimelineDensity.compact,
        pixelsPerMinute: 1.05,
        minimumEntryExtent: 58,
        maximumEntryExtent: 210,
        minimumGapExtent: 42,
        maximumGapExtent: 140,
        horizontalPadding: 12,
        timeColumnWidth: 40,
        markerWidth: 40,
        columnGap: 8,
        cardRadius: 16,
        cardMinimumHeight: 52,
        markerHeight: 50,
      );

  const StructuredTimelineLayout.comfortable() : this();

  const StructuredTimelineLayout.dense()
    : this(
        density: StructuredTimelineDensity.dense,
        pixelsPerMinute: 0.86,
        minimumEntryExtent: 48,
        maximumEntryExtent: 170,
        minimumGapExtent: 32,
        maximumGapExtent: 108,
        horizontalPadding: 10,
        timeColumnWidth: 38,
        markerWidth: 36,
        columnGap: 7,
        cardRadius: 14,
        cardMinimumHeight: 46,
        markerHeight: 44,
        showGapActions: false,
      );

  const StructuredTimelineLayout.custom({
    this.timeColumnPosition = StructuredTimelineTimeColumnPosition.left,
    required this.pixelsPerMinute,
    required this.minimumEntryExtent,
    required this.maximumEntryExtent,
    required this.minimumGapExtent,
    required this.maximumGapExtent,
    required this.horizontalPadding,
    required this.timeColumnWidth,
    required this.markerWidth,
    required this.columnGap,
    required this.cardRadius,
    required this.cardMinimumHeight,
    required this.markerHeight,
    this.overscan = const Duration(hours: 2),
    this.showEndTimes = true,
    this.showGapActions = true,
    this.showConflictBridges = true,
    this.showResizeHandles = true,
  }) : density = StructuredTimelineDensity.custom,
       assert(pixelsPerMinute > 0),
       assert(minimumEntryExtent > 0),
       assert(maximumEntryExtent >= minimumEntryExtent),
       assert(minimumGapExtent >= 0),
       assert(maximumGapExtent >= minimumGapExtent),
       assert(horizontalPadding >= 0),
       assert(timeColumnWidth > 0),
       assert(markerWidth > 0),
       assert(columnGap >= 0),
       assert(cardRadius >= 0),
       assert(cardMinimumHeight > 0),
       assert(markerHeight > 0);

  const StructuredTimelineLayout.absoluteTime()
    : this(
        density: StructuredTimelineDensity.absoluteTime,
        pixelsPerMinute: 1.7,
        minimumEntryExtent: 40,
        maximumEntryExtent: 420,
        minimumGapExtent: 18,
        maximumGapExtent: 420,
        horizontalPadding: 14,
        timeColumnWidth: 52,
        markerWidth: 42,
        columnGap: 9,
        cardRadius: 16,
        cardMinimumHeight: 46,
        markerHeight: 48,
      );

  final StructuredTimelineDensity density;
  final StructuredTimelineTimeColumnPosition timeColumnPosition;
  final double pixelsPerMinute;
  final double minimumEntryExtent;
  final double maximumEntryExtent;
  final double minimumGapExtent;
  final double maximumGapExtent;
  final double horizontalPadding;
  final double timeColumnWidth;
  final double markerWidth;
  final double columnGap;
  final double cardRadius;
  final double cardMinimumHeight;
  final double markerHeight;
  final Duration overscan;
  final bool showEndTimes;
  final bool showGapActions;
  final bool showConflictBridges;
  final bool showResizeHandles;

  StructuredTimelineStyle applyTo(
    StructuredTimelineStyle base, {
    double zoom = 1,
  }) {
    final safeZoom = zoom.isFinite ? zoom.clamp(0.5, 3.0).toDouble() : 1.0;
    return base.copyWith(
      pixelsPerMinute: pixelsPerMinute * safeZoom,
      minimumEntryExtent: minimumEntryExtent,
      maximumEntryExtent: maximumEntryExtent,
      minimumGapExtent: minimumGapExtent,
      maximumGapExtent: maximumGapExtent,
      horizontalPadding: horizontalPadding,
      timeColumnWidth: timeColumnWidth,
      markerWidth: markerWidth,
      columnGap: columnGap,
      cardRadius: cardRadius,
      cardMinimumHeight: cardMinimumHeight,
      markerHeight: markerHeight,
    );
  }

  StructuredTimelineLayout copyWith({
    StructuredTimelineDensity? density,
    StructuredTimelineTimeColumnPosition? timeColumnPosition,
    double? pixelsPerMinute,
    double? minimumEntryExtent,
    double? maximumEntryExtent,
    double? minimumGapExtent,
    double? maximumGapExtent,
    double? horizontalPadding,
    double? timeColumnWidth,
    double? markerWidth,
    double? columnGap,
    double? cardRadius,
    double? cardMinimumHeight,
    double? markerHeight,
    Duration? overscan,
    bool? showEndTimes,
    bool? showGapActions,
    bool? showConflictBridges,
    bool? showResizeHandles,
  }) {
    return StructuredTimelineLayout(
      density: density ?? this.density,
      timeColumnPosition: timeColumnPosition ?? this.timeColumnPosition,
      pixelsPerMinute: pixelsPerMinute ?? this.pixelsPerMinute,
      minimumEntryExtent: minimumEntryExtent ?? this.minimumEntryExtent,
      maximumEntryExtent: maximumEntryExtent ?? this.maximumEntryExtent,
      minimumGapExtent: minimumGapExtent ?? this.minimumGapExtent,
      maximumGapExtent: maximumGapExtent ?? this.maximumGapExtent,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      timeColumnWidth: timeColumnWidth ?? this.timeColumnWidth,
      markerWidth: markerWidth ?? this.markerWidth,
      columnGap: columnGap ?? this.columnGap,
      cardRadius: cardRadius ?? this.cardRadius,
      cardMinimumHeight: cardMinimumHeight ?? this.cardMinimumHeight,
      markerHeight: markerHeight ?? this.markerHeight,
      overscan: overscan ?? this.overscan,
      showEndTimes: showEndTimes ?? this.showEndTimes,
      showGapActions: showGapActions ?? this.showGapActions,
      showConflictBridges: showConflictBridges ?? this.showConflictBridges,
      showResizeHandles: showResizeHandles ?? this.showResizeHandles,
    );
  }
}

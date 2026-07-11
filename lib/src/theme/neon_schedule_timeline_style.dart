import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/neon_timeline_card.dart';

/// Layout, gesture, and surface configuration for `NeonScheduleTimeline`.
///
/// This style is independent of [NeonTimelineThemeData]: the theme owns color
/// language and painter effects, while this object owns schedule geometry.
@immutable
class NeonScheduleTimelineStyle {
  /// Creates schedule layout styling.
  const NeonScheduleTimelineStyle({
    this.pixelsPerMinute = 1.35,
    this.minimumEntryExtent = 64,
    this.maximumEntryExtent = 260,
    this.timeColumnWidth = 52,
    this.railLaneExtent = 64,
    this.contentGap = 12,
    this.horizontalPadding = 16,
    this.topPadding = 18,
    this.bottomPadding = 120,
    this.minimumGapExtent = 18,
    this.maximumGapExtent = 150,
    this.gapScale = 0.72,
    this.snapMinutes = 5,
    this.autoScrollEdge = 112,
    this.autoScrollStep = 16,
    this.dragScale = 1.025,
    this.dragOpacity = 0.86,
    this.overlapIndent = 10,
    this.cardVariant = NeonTimelineCardVariant.liquidCrystal,
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(22)),
    this.cardPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 13,
    ),
    this.cardBlurSigma = 12,
    this.useBackdropFilter = true,
    this.enableCardParallax = true,
    this.showGapLabels = true,
    this.showDurationRail = true,
    this.keepEntriesInsideDay = true,
    this.animateLayout = true,
    this.nowColor = const Color(0xFFFF4F9D),
    this.conflictColor = const Color(0xFFFF5D73),
  })  : assert(pixelsPerMinute > 0),
        assert(minimumEntryExtent > 0),
        assert(maximumEntryExtent >= minimumEntryExtent),
        assert(timeColumnWidth >= 0),
        assert(railLaneExtent > 0),
        assert(contentGap >= 0),
        assert(horizontalPadding >= 0),
        assert(topPadding >= 0),
        assert(bottomPadding >= 0),
        assert(minimumGapExtent >= 0),
        assert(maximumGapExtent >= minimumGapExtent),
        assert(gapScale >= 0),
        assert(snapMinutes > 0),
        assert(autoScrollEdge >= 0),
        assert(autoScrollStep >= 0),
        assert(dragScale > 0),
        assert(dragOpacity >= 0 && dragOpacity <= 1),
        assert(overlapIndent >= 0),
        assert(cardBlurSigma >= 0);

  /// Vertical pixels represented by one minute.
  final double pixelsPerMinute;

  /// Smallest visible entry slot.
  final double minimumEntryExtent;

  /// Largest visible entry slot.
  final double maximumEntryExtent;

  /// Width reserved for start and end times.
  final double timeColumnWidth;

  /// Width reserved for the indicator and connector rail.
  final double railLaneExtent;

  /// Gap between the rail and content card.
  final double contentGap;

  /// Horizontal list inset.
  final double horizontalPadding;

  /// Top list inset.
  final double topPadding;

  /// Bottom list inset.
  final double bottomPadding;

  /// Smallest visual free-time gap.
  final double minimumGapExtent;

  /// Largest visual free-time gap.
  final double maximumGapExtent;

  /// Multiplier applied to minute-based free-time height.
  final double gapScale;

  /// Minute increment used by drag-to-reschedule.
  final int snapMinutes;

  /// Distance from a viewport edge that starts drag auto-scroll.
  final double autoScrollEdge;

  /// Maximum pixels moved per drag update during auto-scroll.
  final double autoScrollStep;

  /// Scale applied to a lifted entry.
  final double dragScale;

  /// Opacity applied to a lifted entry.
  final double dragOpacity;

  /// Extra content indent used to expose conflicts.
  final double overlapIndent;

  /// Default card surface.
  final NeonTimelineCardVariant cardVariant;

  /// Default card clipping radius.
  final BorderRadius cardBorderRadius;

  /// Default card content padding.
  final EdgeInsetsGeometry cardPadding;

  /// Backdrop blur sigma used by the default card.
  final double cardBlurSigma;

  /// Whether the default card samples and blurs content behind it.
  ///
  /// Keep this enabled for the full glass appearance. Disable it on very
  /// constrained hardware to retain the same shape, gradients, and neon
  /// painter while removing the most expensive compositing operation.
  final bool useBackdropFilter;

  /// Whether mouse hover can tilt and refract the default card.
  final bool enableCardParallax;

  /// Whether positive gaps display a duration label.
  final bool showGapLabels;

  /// Whether the connector continues through the entry duration.
  final bool showDurationRail;

  /// Whether drag operations keep the entire entry inside the selected day.
  final bool keepEntriesInsideDay;

  /// Whether geometry changes use short implicit animations.
  final bool animateLayout;

  /// Accent used by the current-time marker.
  final Color nowColor;

  /// Accent used by overlap warnings.
  final Color conflictColor;

  /// Runtime-safe pixels-per-minute value.
  ///
  /// Constructor assertions catch invalid values in debug mode. This fallback
  /// also protects release builds receiving configuration from remote data.
  double get resolvedPixelsPerMinute =>
      pixelsPerMinute.isFinite && pixelsPerMinute > 0 ? pixelsPerMinute : 1.35;

  /// Runtime-safe drag snapping interval.
  int get resolvedSnapMinutes => snapMinutes > 0 ? snapMinutes : 5;

  /// Runtime-safe drag scale.
  double get resolvedDragScale =>
      dragScale.isFinite && dragScale > 0 ? dragScale : 1.025;

  /// Runtime-safe drag opacity.
  double get resolvedDragOpacity => dragOpacity.isFinite
      ? dragOpacity.clamp(0.0, 1.0).toDouble()
      : 0.86;

  /// Runtime-safe auto-scroll edge.
  double get resolvedAutoScrollEdge =>
      autoScrollEdge.isFinite && autoScrollEdge > 0 ? autoScrollEdge : 0;

  /// Runtime-safe auto-scroll step.
  double get resolvedAutoScrollStep =>
      autoScrollStep.isFinite && autoScrollStep > 0 ? autoScrollStep : 0;

  /// Runtime-safe card blur.
  double get resolvedCardBlurSigma =>
      cardBlurSigma.isFinite && cardBlurSigma > 0 ? cardBlurSigma : 0;

  /// Returns the clamped visual extent for [duration].
  double extentFor(Duration duration) {
    final minutes = duration.inMinutes <= 0 ? 1 : duration.inMinutes;
    final minimum = minimumEntryExtent.isFinite && minimumEntryExtent > 0
        ? minimumEntryExtent
        : 64.0;
    final configuredMaximum =
        maximumEntryExtent.isFinite ? maximumEntryExtent : 260.0;
    final maximum = configuredMaximum >= minimum
        ? configuredMaximum
        : minimum;
    return (minutes * resolvedPixelsPerMinute)
        .clamp(minimum, maximum)
        .toDouble();
  }

  /// Returns the clamped visual extent for a free-time [gap].
  double gapExtentFor(Duration gap) {
    if (gap <= Duration.zero) return 0;
    final minimum = minimumGapExtent.isFinite && minimumGapExtent >= 0
        ? minimumGapExtent
        : 18.0;
    final configuredMaximum =
        maximumGapExtent.isFinite ? maximumGapExtent : 150.0;
    final maximum = configuredMaximum >= minimum
        ? configuredMaximum
        : minimum;
    final scale = gapScale.isFinite && gapScale >= 0 ? gapScale : 0.72;
    return (gap.inMinutes * resolvedPixelsPerMinute * scale)
        .clamp(minimum, maximum)
        .toDouble();
  }
}

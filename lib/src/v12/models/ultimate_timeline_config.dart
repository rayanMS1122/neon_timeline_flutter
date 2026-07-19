import 'package:flutter/foundation.dart';

import '../../v11/models/structured_timeline_v11_config.dart';

/// Semantic information-density levels used by the 12.x timeline.
enum UltimateTimelineZoomLevel {
  overview,
  compact,
  normal,
  comfortable,
  detailed,
}

/// Visual density presets for host apps that need either a compact operational
/// UI or a more relaxed planning surface.
enum UltimateTimelineVisualDensity {
  compact,
  balanced,
  comfortable,
}

/// Immutable geometry and information-density tokens for one zoom level.
@immutable
class UltimateTimelineZoomMetrics {
  const UltimateTimelineZoomMetrics({
    required this.pixelsPerMinute,
    required this.minimumEntryHeight,
    required this.markerSpacing,
    required this.overscan,
    required this.clockUpdateInterval,
    required this.showSubtitle,
    required this.showMetadata,
    required this.showResizeHandles,
  });

  final double pixelsPerMinute;
  final double minimumEntryHeight;
  final double markerSpacing;
  final double overscan;
  final Duration clockUpdateInterval;
  final bool showSubtitle;
  final bool showMetadata;
  final bool showResizeHandles;

  static const overview = UltimateTimelineZoomMetrics(
    pixelsPerMinute: 0.72,
    minimumEntryHeight: 48,
    markerSpacing: 120,
    overscan: 240,
    clockUpdateInterval: Duration(minutes: 5),
    showSubtitle: false,
    showMetadata: false,
    showResizeHandles: false,
  );

  static const compact = UltimateTimelineZoomMetrics(
    pixelsPerMinute: 1,
    minimumEntryHeight: 54,
    markerSpacing: 90,
    overscan: 280,
    clockUpdateInterval: Duration(minutes: 2),
    showSubtitle: false,
    showMetadata: true,
    showResizeHandles: false,
  );

  static const normal = UltimateTimelineZoomMetrics(
    pixelsPerMinute: 1.3,
    minimumEntryHeight: 66,
    markerSpacing: 60,
    overscan: 320,
    clockUpdateInterval: Duration(minutes: 1),
    showSubtitle: true,
    showMetadata: true,
    showResizeHandles: true,
  );

  static const comfortable = UltimateTimelineZoomMetrics(
    pixelsPerMinute: 1.55,
    minimumEntryHeight: 78,
    markerSpacing: 60,
    overscan: 360,
    clockUpdateInterval: Duration(seconds: 30),
    showSubtitle: true,
    showMetadata: true,
    showResizeHandles: true,
  );

  static const detailed = UltimateTimelineZoomMetrics(
    pixelsPerMinute: 1.9,
    minimumEntryHeight: 96,
    markerSpacing: 30,
    overscan: 420,
    clockUpdateInterval: Duration(seconds: 15),
    showSubtitle: true,
    showMetadata: true,
    showResizeHandles: true,
  );

  static UltimateTimelineZoomMetrics forLevel(UltimateTimelineZoomLevel level) {
    return switch (level) {
      UltimateTimelineZoomLevel.overview => overview,
      UltimateTimelineZoomLevel.compact => compact,
      UltimateTimelineZoomLevel.normal => normal,
      UltimateTimelineZoomLevel.comfortable => comfortable,
      UltimateTimelineZoomLevel.detailed => detailed,
    };
  }
}

/// Pointer, keyboard and motion tuning for direct but deliberate interaction.
@immutable
class UltimateTimelineInteractionConfig {
  const UltimateTimelineInteractionConfig({
    this.longPressDuration = const Duration(milliseconds: 220),
    this.minimumPointerDistance = 6,
    this.dropSnapInterval = const Duration(minutes: 5),
    this.snapHysteresis = const Duration(minutes: 2),
    this.snapDistance = const Duration(minutes: 10),
    this.preferConflictFreeDrop = true,
    this.allowConflictingDrops = true,
    this.dragLiftScale = 1.025,
    this.dragElevation = 22,
    this.placeholderOpacity = 0.14,
    this.showDragScrim = true,
    this.showSnapGuide = true,
    this.showDropPreview = true,
    this.showConflictPreview = true,
    this.announceDragChanges = true,
  }) : assert(minimumPointerDistance >= 0),
       // Duration comparison operators are not valid constant expressions.
       // Duration values are therefore checked by [debugAssertIsValid] when
       // the configuration is consumed by the timeline widget.
       assert(dragLiftScale > 0),
       assert(dragElevation >= 0),
       assert(placeholderOpacity >= 0 && placeholderOpacity <= 1);

  final Duration longPressDuration;
  final double minimumPointerDistance;

  /// Clock-grid interval used for the committed drag target. This remains
  /// independent from [snapDistance], which controls magnetic neighbour
  /// targets. Keeping the two values separate avoids surprising 15-minute
  /// jumps when a host only wants a wider magnetic search radius.
  final Duration dropSnapInterval;
  final Duration snapHysteresis;
  final Duration snapDistance;
  final bool preferConflictFreeDrop;
  final bool allowConflictingDrops;
  final double dragLiftScale;
  final double dragElevation;
  final double placeholderOpacity;
  final bool showDragScrim;
  final bool showSnapGuide;
  final bool showDropPreview;
  final bool showConflictPreview;
  final bool announceDragChanges;

  /// Runs Duration validations in debug mode without breaking const creation.
  ///
  /// Dart cannot evaluate comparison operators on [Duration] inside a const
  /// constructor initializer. Keeping these checks here preserves const
  /// presets while still failing fast when the configuration is used.
  bool debugAssertIsValid() {
    assert(
      dropSnapInterval.inMicroseconds > 0,
      'dropSnapInterval must be greater than Duration.zero.',
    );
    assert(
      snapHysteresis.inMicroseconds >= 0,
      'snapHysteresis must not be negative.',
    );
    assert(
      snapDistance.inMicroseconds >= 0,
      'snapDistance must not be negative.',
    );
    return true;
  }
}

/// Production configuration accepted by [UltimateStructuredTimeline].
///
/// It extends the 11.x configuration, so existing code can pass either type
/// without a migration cliff.
@immutable
class UltimateStructuredTimelineConfig extends StructuredTimelineV11Config {
  const UltimateStructuredTimelineConfig({
    super.zoom = StructuredTimelineSemanticZoom.normal,
    super.reducedMotion = false,
    super.enableContextMenu = true,
    super.enableTrackpadZoom = true,
    super.enableMultiSelection = true,
    super.enableUndoRedo = true,
    super.showDiagnostics = false,
    super.minimumTouchTarget = 48,
    super.keyboardNudge = const Duration(minutes: 5),
    super.keyboardLargeNudge = const Duration(minutes: 30),
    super.liveAnnouncementThrottle = const Duration(milliseconds: 350),
    this.interaction = const UltimateTimelineInteractionConfig(),
    this.highContrast = false,
    this.showResponsiveHeader = true,
    this.showCurrentTime = true,
    this.enableImmediateMouseDrag = true,
    this.enableKeyboardInteraction = true,
    this.enableLiveDataStability = true,
    this.visualDensity = UltimateTimelineVisualDensity.balanced,
  });

  const UltimateStructuredTimelineConfig.production()
    : this(
        zoom: StructuredTimelineSemanticZoom.comfortable,
        minimumTouchTarget: 52,
        interaction: const UltimateTimelineInteractionConfig(
          longPressDuration: Duration(milliseconds: 210),
          snapDistance: Duration(minutes: 12),
        ),
      );

  /// Dense 13.x preset for advanced planner UIs that must show more work in
  /// the same viewport while keeping drag/drop feedback explicit.
  const UltimateStructuredTimelineConfig.advancedCompact()
    : this(
        zoom: StructuredTimelineSemanticZoom.compact,
        minimumTouchTarget: 44,
        keyboardNudge: const Duration(minutes: 5),
        keyboardLargeNudge: const Duration(minutes: 15),
        visualDensity: UltimateTimelineVisualDensity.compact,
        interaction: const UltimateTimelineInteractionConfig(
          longPressDuration: Duration(milliseconds: 170),
          minimumPointerDistance: 4,
          dropSnapInterval: Duration(minutes: 5),
          snapHysteresis: Duration(minutes: 1),
          snapDistance: Duration(minutes: 15),
          preferConflictFreeDrop: true,
          allowConflictingDrops: false,
          dragLiftScale: 1.018,
          dragElevation: 18,
          placeholderOpacity: 0.2,
          showDragScrim: true,
          showSnapGuide: false,
          showDropPreview: true,
          showConflictPreview: true,
          announceDragChanges: true,
        ),
      );

  /// Friendly version 14 preset with faster, guided drag feedback and
  /// comfortable touch targets.
  const UltimateStructuredTimelineConfig.friendly()
    : this(
        zoom: StructuredTimelineSemanticZoom.normal,
        minimumTouchTarget: 48,
        keyboardNudge: const Duration(minutes: 5),
        keyboardLargeNudge: const Duration(minutes: 15),
        visualDensity: UltimateTimelineVisualDensity.balanced,
        interaction: const UltimateTimelineInteractionConfig(
          longPressDuration: Duration(milliseconds: 160),
          minimumPointerDistance: 5,
          dropSnapInterval: Duration(minutes: 5),
          snapHysteresis: Duration(minutes: 2),
          snapDistance: Duration(minutes: 12),
          preferConflictFreeDrop: true,
          allowConflictingDrops: false,
          dragLiftScale: 1.018,
          dragElevation: 22,
          placeholderOpacity: 0.16,
          showDragScrim: true,
          showSnapGuide: true,
          showDropPreview: true,
          showConflictPreview: true,
          announceDragChanges: true,
        ),
      );

  const UltimateStructuredTimelineConfig.accessible()
    : this(
        zoom: StructuredTimelineSemanticZoom.detailed,
        reducedMotion: true,
        minimumTouchTarget: 56,
        liveAnnouncementThrottle: const Duration(milliseconds: 500),
        highContrast: true,
        visualDensity: UltimateTimelineVisualDensity.comfortable,
      );

  final UltimateTimelineInteractionConfig interaction;
  final bool highContrast;
  final bool showResponsiveHeader;
  final bool showCurrentTime;
  final bool enableImmediateMouseDrag;
  final bool enableKeyboardInteraction;
  final bool enableLiveDataStability;
  final UltimateTimelineVisualDensity visualDensity;

  UltimateTimelineZoomLevel get zoomLevel =>
      UltimateTimelineZoomLevel.values[zoom.index];

  UltimateTimelineZoomMetrics get zoomMetrics =>
      UltimateTimelineZoomMetrics.forLevel(zoomLevel);

  double get entryHeightFactor => switch (visualDensity) {
    UltimateTimelineVisualDensity.compact => 0.84,
    UltimateTimelineVisualDensity.balanced => 1,
    UltimateTimelineVisualDensity.comfortable => 1.08,
  };

  double get horizontalSpacingFactor => switch (visualDensity) {
    UltimateTimelineVisualDensity.compact => 0.78,
    UltimateTimelineVisualDensity.balanced => 1,
    UltimateTimelineVisualDensity.comfortable => 1.08,
  };

  @override
  UltimateStructuredTimelineConfig copyWith({
    StructuredTimelineSemanticZoom? zoom,
    bool? reducedMotion,
    bool? enableContextMenu,
    bool? enableTrackpadZoom,
    bool? enableMultiSelection,
    bool? enableUndoRedo,
    bool? showDiagnostics,
    double? minimumTouchTarget,
    Duration? keyboardNudge,
    Duration? keyboardLargeNudge,
    Duration? liveAnnouncementThrottle,
    UltimateTimelineInteractionConfig? interaction,
    bool? highContrast,
    bool? showResponsiveHeader,
    bool? showCurrentTime,
    bool? enableImmediateMouseDrag,
    bool? enableKeyboardInteraction,
    bool? enableLiveDataStability,
    UltimateTimelineVisualDensity? visualDensity,
  }) {
    return UltimateStructuredTimelineConfig(
      zoom: zoom ?? this.zoom,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      enableContextMenu: enableContextMenu ?? this.enableContextMenu,
      enableTrackpadZoom: enableTrackpadZoom ?? this.enableTrackpadZoom,
      enableMultiSelection: enableMultiSelection ?? this.enableMultiSelection,
      enableUndoRedo: enableUndoRedo ?? this.enableUndoRedo,
      showDiagnostics: showDiagnostics ?? this.showDiagnostics,
      minimumTouchTarget: minimumTouchTarget ?? this.minimumTouchTarget,
      keyboardNudge: keyboardNudge ?? this.keyboardNudge,
      keyboardLargeNudge: keyboardLargeNudge ?? this.keyboardLargeNudge,
      liveAnnouncementThrottle:
          liveAnnouncementThrottle ?? this.liveAnnouncementThrottle,
      interaction: interaction ?? this.interaction,
      highContrast: highContrast ?? this.highContrast,
      showResponsiveHeader:
          showResponsiveHeader ?? this.showResponsiveHeader,
      showCurrentTime: showCurrentTime ?? this.showCurrentTime,
      enableImmediateMouseDrag:
          enableImmediateMouseDrag ?? this.enableImmediateMouseDrag,
      enableKeyboardInteraction:
          enableKeyboardInteraction ?? this.enableKeyboardInteraction,
      enableLiveDataStability:
          enableLiveDataStability ?? this.enableLiveDataStability,
      visualDensity: visualDensity ?? this.visualDensity,
    );
  }
}

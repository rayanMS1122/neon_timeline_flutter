import 'package:flutter/foundation.dart';

import '../../v11/models/structured_timeline_v11_config.dart';
import '../../v12/models/ultimate_timeline_config.dart';
import '../interaction/snap/ultra_magnetic_snap_engine.dart';

/// Six semantic information-density levels for v15.
enum UltraTimelineZoomLevel {
  overview,
  compact,
  balanced,
  comfortable,
  detailed,
  cinematic,
}

/// Input policy for direct manipulation.
enum UltraTimelineDragActivation {
  /// Presents an explicit handle; strict hit-testing depends on the renderer.
  handleOnly,
  longPress,
  immediate,
  keyboard,
  disabled,
}

/// Density and interaction configuration for the v15 adaptive planner.
@immutable
class UltraTimelineConfig {
  const UltraTimelineConfig({
    this.initialZoom = UltraTimelineZoomLevel.balanced,
    this.initialSnapStrength = UltraTimelineSnapStrength.balanced,
    this.dragActivation = UltraTimelineDragActivation.longPress,
    this.snapInterval = const Duration(minutes: 5),
    this.minimumDuration = const Duration(minutes: 10),
    this.keyboardStep = const Duration(minutes: 5),
    this.keyboardLargeStep = const Duration(minutes: 30),
    this.minimumTouchTarget = 48,
    this.showDiagnostics = false,
    this.showMetrics = true,
    this.showZoomControl = true,
    this.showSnapControl = true,
    this.showCurrentTime = true,
    this.enableRangeEditor = true,
    this.enableTrackpadZoom = true,
    this.enableCtrlWheelZoom = true,
    this.enableDeleteTarget = true,
    this.enableResizing = true,
    this.reducedMotion = false,
    this.highContrast = false,
  }) : assert(minimumTouchTarget >= 40);

  const UltraTimelineConfig.production()
      : this(
          initialZoom: UltraTimelineZoomLevel.comfortable,
          initialSnapStrength: UltraTimelineSnapStrength.balanced,
          dragActivation: UltraTimelineDragActivation.longPress,
          minimumTouchTarget: 48,
        );

  const UltraTimelineConfig.compact()
      : this(
          initialZoom: UltraTimelineZoomLevel.compact,
          initialSnapStrength: UltraTimelineSnapStrength.soft,
          dragActivation: UltraTimelineDragActivation.longPress,
          minimumTouchTarget: 44,
          showMetrics: false,
        );

  const UltraTimelineConfig.accessible()
      : this(
          initialZoom: UltraTimelineZoomLevel.detailed,
          initialSnapStrength: UltraTimelineSnapStrength.balanced,
          dragActivation: UltraTimelineDragActivation.longPress,
          minimumTouchTarget: 56,
          reducedMotion: true,
          highContrast: true,
        );

  final UltraTimelineZoomLevel initialZoom;
  final UltraTimelineSnapStrength initialSnapStrength;
  final UltraTimelineDragActivation dragActivation;
  final Duration snapInterval;
  final Duration minimumDuration;
  final Duration keyboardStep;
  final Duration keyboardLargeStep;
  final double minimumTouchTarget;
  final bool showDiagnostics;
  final bool showMetrics;
  final bool showZoomControl;
  final bool showSnapControl;
  final bool showCurrentTime;
  final bool enableRangeEditor;
  final bool enableTrackpadZoom;
  final bool enableCtrlWheelZoom;
  final bool enableDeleteTarget;
  final bool enableResizing;
  final bool reducedMotion;
  final bool highContrast;

  UltimateStructuredTimelineConfig toUltimateConfig({
    required UltraTimelineZoomLevel zoom,
    required UltraTimelineSnapStrength snapStrength,
  }) {
    final base = UltimateStructuredTimelineConfig(
      zoom: _semanticZoom(zoom),
      reducedMotion: reducedMotion,
      enableTrackpadZoom: enableTrackpadZoom,
      showDiagnostics: false,
      minimumTouchTarget: minimumTouchTarget,
      keyboardNudge: keyboardStep,
      keyboardLargeNudge: keyboardLargeStep,
      highContrast: highContrast,
      showResponsiveHeader: false,
      showCurrentTime: showCurrentTime,
      enableImmediateMouseDrag:
          dragActivation == UltraTimelineDragActivation.immediate,
      enableKeyboardInteraction:
          dragActivation != UltraTimelineDragActivation.disabled,
      visualDensity: _visualDensity(zoom),
      interaction: _interaction(snapStrength),
    );
    return base;
  }

  UltimateTimelineInteractionConfig _interaction(
    UltraTimelineSnapStrength strength,
  ) {
    final distance = switch (strength) {
      UltraTimelineSnapStrength.off => Duration.zero,
      UltraTimelineSnapStrength.soft => const Duration(minutes: 5),
      UltraTimelineSnapStrength.balanced => const Duration(minutes: 10),
      UltraTimelineSnapStrength.strong => const Duration(minutes: 16),
    };
    final delay = switch (dragActivation) {
      UltraTimelineDragActivation.immediate => Duration.zero,
      UltraTimelineDragActivation.handleOnly => const Duration(milliseconds: 80),
      UltraTimelineDragActivation.longPress => const Duration(milliseconds: 220),
      UltraTimelineDragActivation.keyboard => const Duration(milliseconds: 260),
      UltraTimelineDragActivation.disabled => const Duration(days: 1),
    };
    return UltimateTimelineInteractionConfig(
      longPressDuration: delay,
      minimumPointerDistance: 5,
      dropSnapInterval: snapInterval,
      snapHysteresis: strength == UltraTimelineSnapStrength.strong
          ? const Duration(minutes: 3)
          : const Duration(minutes: 2),
      snapDistance: distance,
      preferConflictFreeDrop: true,
      allowConflictingDrops: false,
      dragLiftScale: reducedMotion ? 1 : 1.012,
      dragElevation: reducedMotion ? 6 : 18,
      placeholderOpacity: 0.12,
      showDragScrim: false,
      showSnapGuide: strength != UltraTimelineSnapStrength.off,
      showDropPreview: true,
      showConflictPreview: true,
      announceDragChanges: true,
    );
  }

  static StructuredTimelineSemanticZoom _semanticZoom(
    UltraTimelineZoomLevel zoom,
  ) {
    return switch (zoom) {
      UltraTimelineZoomLevel.overview => StructuredTimelineSemanticZoom.overview,
      UltraTimelineZoomLevel.compact => StructuredTimelineSemanticZoom.compact,
      UltraTimelineZoomLevel.balanced => StructuredTimelineSemanticZoom.normal,
      UltraTimelineZoomLevel.comfortable =>
        StructuredTimelineSemanticZoom.comfortable,
      UltraTimelineZoomLevel.detailed || UltraTimelineZoomLevel.cinematic =>
        StructuredTimelineSemanticZoom.detailed,
    };
  }

  static UltimateTimelineVisualDensity _visualDensity(
    UltraTimelineZoomLevel zoom,
  ) {
    return switch (zoom) {
      UltraTimelineZoomLevel.overview || UltraTimelineZoomLevel.compact =>
        UltimateTimelineVisualDensity.compact,
      UltraTimelineZoomLevel.balanced => UltimateTimelineVisualDensity.balanced,
      UltraTimelineZoomLevel.comfortable ||
      UltraTimelineZoomLevel.detailed ||
      UltraTimelineZoomLevel.cinematic =>
        UltimateTimelineVisualDensity.comfortable,
    };
  }

  bool debugAssertIsValid() {
    assert(snapInterval.inMicroseconds > 0, 'snapInterval must be positive.');
    assert(minimumDuration.inMicroseconds > 0, 'minimumDuration must be positive.');
    return true;
  }
}

extension UltraTimelineZoomLevelX on UltraTimelineZoomLevel {
  double get position {
    if (UltraTimelineZoomLevel.values.length <= 1) return 0;
    return index / (UltraTimelineZoomLevel.values.length - 1);
  }

  String get label => switch (this) {
        UltraTimelineZoomLevel.overview => 'Overview',
        UltraTimelineZoomLevel.compact => 'Compact',
        UltraTimelineZoomLevel.balanced => 'Balanced',
        UltraTimelineZoomLevel.comfortable => 'Comfortable',
        UltraTimelineZoomLevel.detailed => 'Detailed',
        UltraTimelineZoomLevel.cinematic => 'Cinematic',
      };
}

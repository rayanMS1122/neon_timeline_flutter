import 'package:flutter/foundation.dart';

/// Semantic zoom levels that change information density rather than blindly
/// scaling every pixel in the timeline.
enum StructuredTimelineSemanticZoom {
  overview,
  compact,
  normal,
  comfortable,
  detailed,
}

/// Offline/persistence state surfaced by the timeline without owning storage.
enum StructuredTimelinePersistenceState {
  idle,
  optimistic,
  saving,
  queuedOffline,
  rollingBack,
  failed,
}

/// Unified interaction defaults for the 11.x experience.
@immutable
class StructuredTimelineV11Config {
  const StructuredTimelineV11Config({
    this.zoom = StructuredTimelineSemanticZoom.normal,
    this.reducedMotion = false,
    this.enableContextMenu = true,
    this.enableTrackpadZoom = true,
    this.enableMultiSelection = true,
    this.enableUndoRedo = true,
    this.showDiagnostics = false,
    this.minimumTouchTarget = 48,
    this.keyboardNudge = const Duration(minutes: 5),
    this.keyboardLargeNudge = const Duration(minutes: 30),
    this.liveAnnouncementThrottle = const Duration(milliseconds: 350),
  }) : assert(minimumTouchTarget >= 44);

  const StructuredTimelineV11Config.production()
    : this(
        zoom: StructuredTimelineSemanticZoom.comfortable,
        minimumTouchTarget: 52,
      );

  const StructuredTimelineV11Config.accessible()
    : this(
        zoom: StructuredTimelineSemanticZoom.detailed,
        reducedMotion: true,
        minimumTouchTarget: 56,
        liveAnnouncementThrottle: const Duration(milliseconds: 500),
      );

  final StructuredTimelineSemanticZoom zoom;
  final bool reducedMotion;
  final bool enableContextMenu;
  final bool enableTrackpadZoom;
  final bool enableMultiSelection;
  final bool enableUndoRedo;
  final bool showDiagnostics;
  final double minimumTouchTarget;
  final Duration keyboardNudge;
  final Duration keyboardLargeNudge;
  final Duration liveAnnouncementThrottle;

  StructuredTimelineV11Config copyWith({
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
  }) {
    return StructuredTimelineV11Config(
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
    );
  }
}

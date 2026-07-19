import 'package:flutter/foundation.dart';

/// Interaction and presentation defaults for the 10.x Structured timeline.
///
/// The object is intentionally independent from application state. Hosts may
/// use a preset and override only the parts that matter to their product.
@immutable
class StructuredTimelineExperience {
  const StructuredTimelineExperience({
    this.dragActivationDelay = const Duration(milliseconds: 280),
    this.showDragScrim = true,
    this.showSnapGuide = true,
    this.showDropSlot = true,
    this.showConflictPreview = true,
    this.magnetizeToNeighbors = true,
    this.preferConflictFreeDrop = true,
    this.magnetDistance = const Duration(minutes: 8),
    this.dragLiftScale = 1.045,
    this.dragElevation = 24,
    this.placeholderOpacity = 0.16,
    this.scrimOpacity = 0.035,
    this.edgeScrollFrameInterval = const Duration(milliseconds: 16),
    this.selectOnDragStart = true,
    this.hideFloatingActionWhileDragging = true,
    this.announceDragChanges = true,
  }) : assert(dragLiftScale > 0),
       assert(dragElevation >= 0),
       assert(placeholderOpacity >= 0 && placeholderOpacity <= 1),
       assert(scrimOpacity >= 0 && scrimOpacity <= 1);

  const StructuredTimelineExperience.delight()
    : this(
        dragActivationDelay: const Duration(milliseconds: 240),
        magnetDistance: const Duration(minutes: 10),
        dragLiftScale: 1.055,
        dragElevation: 30,
        placeholderOpacity: 0.12,
        scrimOpacity: 0.045,
      );

  const StructuredTimelineExperience.precise()
    : this(
        dragActivationDelay: const Duration(milliseconds: 340),
        magnetDistance: const Duration(minutes: 5),
        dragLiftScale: 1.025,
        dragElevation: 18,
        placeholderOpacity: 0.2,
        scrimOpacity: 0.025,
      );

  const StructuredTimelineExperience.batterySaver()
    : this(
        dragActivationDelay: const Duration(milliseconds: 320),
        showDragScrim: false,
        showDropSlot: false,
        dragLiftScale: 1,
        dragElevation: 8,
        placeholderOpacity: 0.2,
        scrimOpacity: 0,
        edgeScrollFrameInterval: const Duration(milliseconds: 32),
      );

  final Duration dragActivationDelay;
  final bool showDragScrim;
  final bool showSnapGuide;
  final bool showDropSlot;
  final bool showConflictPreview;
  final bool magnetizeToNeighbors;
  final bool preferConflictFreeDrop;
  final Duration magnetDistance;
  final double dragLiftScale;
  final double dragElevation;
  final double placeholderOpacity;
  final double scrimOpacity;
  final Duration edgeScrollFrameInterval;
  final bool selectOnDragStart;
  final bool hideFloatingActionWhileDragging;
  final bool announceDragChanges;

  StructuredTimelineExperience copyWith({
    Duration? dragActivationDelay,
    bool? showDragScrim,
    bool? showSnapGuide,
    bool? showDropSlot,
    bool? showConflictPreview,
    bool? magnetizeToNeighbors,
    bool? preferConflictFreeDrop,
    Duration? magnetDistance,
    double? dragLiftScale,
    double? dragElevation,
    double? placeholderOpacity,
    double? scrimOpacity,
    Duration? edgeScrollFrameInterval,
    bool? selectOnDragStart,
    bool? hideFloatingActionWhileDragging,
    bool? announceDragChanges,
  }) {
    return StructuredTimelineExperience(
      dragActivationDelay: dragActivationDelay ?? this.dragActivationDelay,
      showDragScrim: showDragScrim ?? this.showDragScrim,
      showSnapGuide: showSnapGuide ?? this.showSnapGuide,
      showDropSlot: showDropSlot ?? this.showDropSlot,
      showConflictPreview: showConflictPreview ?? this.showConflictPreview,
      magnetizeToNeighbors: magnetizeToNeighbors ?? this.magnetizeToNeighbors,
      preferConflictFreeDrop:
          preferConflictFreeDrop ?? this.preferConflictFreeDrop,
      magnetDistance: magnetDistance ?? this.magnetDistance,
      dragLiftScale: dragLiftScale ?? this.dragLiftScale,
      dragElevation: dragElevation ?? this.dragElevation,
      placeholderOpacity: placeholderOpacity ?? this.placeholderOpacity,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
      edgeScrollFrameInterval:
          edgeScrollFrameInterval ?? this.edgeScrollFrameInterval,
      selectOnDragStart: selectOnDragStart ?? this.selectOnDragStart,
      hideFloatingActionWhileDragging:
          hideFloatingActionWhileDragging ??
          this.hideFloatingActionWhileDragging,
      announceDragChanges: announceDragChanges ?? this.announceDragChanges,
    );
  }
}

enum StructuredTimelineDragPhase {
  idle,
  armed,
  dragging,
  blocked,
  deleting,
  committing,
  completed,
  cancelled,
  failed,
}

@immutable
class StructuredTimelineDragState<T> {
  const StructuredTimelineDragState({
    required this.phase,
    this.value,
    this.entryId,
    this.start,
    this.end,
    this.conflictCount = 0,
    this.magnetized = false,
    this.overDeleteTarget = false,
  });

  const StructuredTimelineDragState.idle()
    : this(phase: StructuredTimelineDragPhase.idle);

  final StructuredTimelineDragPhase phase;
  final T? value;
  final Object? entryId;
  final DateTime? start;
  final DateTime? end;
  final int conflictCount;
  final bool magnetized;
  final bool overDeleteTarget;

  bool get active => switch (phase) {
    StructuredTimelineDragPhase.armed ||
    StructuredTimelineDragPhase.dragging ||
    StructuredTimelineDragPhase.blocked ||
    StructuredTimelineDragPhase.deleting ||
    StructuredTimelineDragPhase.committing => true,
    _ => false,
  };
}

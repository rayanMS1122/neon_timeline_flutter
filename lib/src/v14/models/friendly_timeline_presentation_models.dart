import 'package:flutter/widgets.dart';

import '../../v10/models/structured_timeline_experience.dart';
import '../../v12/models/ultimate_timeline_details.dart';
import 'friendly_timeline_ui_models.dart';

/// Immutable, display-ready data consumed by the default version 14 card.
///
/// Keeping formatting and product-specific labels out of the card prevents the
/// rendering layer from reaching into application models or package internals.
@immutable
class FriendlyTimelineEntryPresentation<T> {
  const FriendlyTimelineEntryPresentation({
    required this.details,
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.tone,
    this.subtitle,
    this.progress,
    this.semanticLabel,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final double? progress;
  final IconData icon;
  final FriendlyTimelineIconTone tone;
  final String? semanticLabel;

  FriendlyTimelineEntryPresentation<T> copyWith({
    String? title,
    String? subtitle,
    bool clearSubtitle = false,
    String? timeLabel,
    double? progress,
    bool clearProgress = false,
    IconData? icon,
    FriendlyTimelineIconTone? tone,
    String? semanticLabel,
    bool clearSemanticLabel = false,
  }) {
    return FriendlyTimelineEntryPresentation<T>(
      details: details,
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      timeLabel: timeLabel ?? this.timeLabel,
      progress: clearProgress ? null : (progress ?? this.progress),
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      semanticLabel: clearSemanticLabel
          ? null
          : (semanticLabel ?? this.semanticLabel),
    );
  }
}

/// Builds a display-ready version 14 entry model.
typedef FriendlyTimelineEntryPresentationBuilder<T> =
    FriendlyTimelineEntryPresentation<T> Function(
      BuildContext context,
      UltimateTimelineEntryDetails<T> details,
    );

/// Small, non-generic projection of drag state used by workspace chrome.
///
/// The timeline itself no longer rebuilds for every pointer update. Only the
/// companion overlay listens to this object.
@immutable
class FriendlyTimelineDragUiState {
  const FriendlyTimelineDragUiState({
    required this.phase,
    this.title,
    this.start,
    this.end,
    this.conflictCount = 0,
    this.magnetized = false,
    this.overDeleteTarget = false,
  });

  const FriendlyTimelineDragUiState.idle()
      : this(phase: StructuredTimelineDragPhase.idle);

  static FriendlyTimelineDragUiState fromDragState<T>(
    StructuredTimelineDragState<T>? state, {
    String? title,
  }) {
    if (state == null) return const FriendlyTimelineDragUiState.idle();
    return FriendlyTimelineDragUiState(
      phase: state.phase,
      title: title,
      start: state.start,
      end: state.end,
      conflictCount: state.conflictCount,
      magnetized: state.magnetized,
      overDeleteTarget: state.overDeleteTarget,
    );
  }

  final StructuredTimelineDragPhase phase;
  final String? title;
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

  bool get blocked => phase == StructuredTimelineDragPhase.blocked;
  bool get deleting => phase == StructuredTimelineDragPhase.deleting;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FriendlyTimelineDragUiState &&
            other.phase == phase &&
            other.title == title &&
            other.start == start &&
            other.end == end &&
            other.conflictCount == conflictCount &&
            other.magnetized == magnetized &&
            other.overDeleteTarget == overDeleteTarget;
  }

  @override
  int get hashCode => Object.hash(
        phase,
        title,
        start,
        end,
        conflictCount,
        magnetized,
        overDeleteTarget,
      );
}

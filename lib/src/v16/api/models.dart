import 'package:flutter/material.dart';

/// Semantic category used to choose default color and behavior.
enum NeonPlannerEntryKind {
  /// A generic event.
  standard,

  /// A reminder.
  reminder,

  /// A meeting or appointment.
  appointment,

  /// Travel or commuting.
  travel,

  /// Focused work.
  focus,

  /// A break or recovery period.
  breakTime,

  /// A social activity.
  people,

  /// Sleep or night activity.
  sleep,

  /// A user-defined category.
  custom,
}

/// How pointer dragging is activated.
enum NeonPlannerDragActivation {
  /// Dragging is disabled.
  disabled,

  /// Dragging starts after a long press.
  longPress,

  /// Dragging starts immediately.
  immediate,

  /// Only a visible handle starts dragging.
  handleOnly,

  /// Pointer dragging is disabled but keyboard movement remains available.
  keyboard,
}

/// Conflict behavior during move, resize, and create operations.
enum NeonPlannerConflictPolicy {
  /// Conflicts are allowed and reported visually.
  allow,

  /// Conflicts block committing the operation.
  block,

  /// The package delegates the decision to the application callback.
  delegate,
}

/// Semantic zoom levels used by the timeline.
enum NeonPlannerZoomLevel {
  /// Maximum overview.
  overview,

  /// Compact presentation.
  compact,

  /// Balanced default presentation.
  balanced,

  /// Comfortable presentation.
  comfortable,

  /// Detailed presentation.
  detailed,

  /// Maximum detail.
  cinematic,
}

/// Magnetic snap strength.
enum NeonPlannerSnapStrength {
  /// Snapping is disabled.
  off,

  /// Small attraction radius.
  soft,

  /// Balanced attraction radius.
  balanced,

  /// Strong attraction radius.
  strong,
}

/// Visual information for an entry.
@immutable
class NeonPlannerEntryPresentation {
  /// Creates entry presentation data.
  const NeonPlannerEntryPresentation({
    required this.title,
    required this.icon,
    this.subtitle,
    this.metadata,
    this.semanticLabel,
    this.kind = NeonPlannerEntryKind.standard,
    this.accentColor,
    this.completion,
    this.isEnabled = true,
  }) : assert(completion == null || (completion >= 0 && completion <= 1));

  /// Primary title.
  final String title;

  /// Optional secondary description.
  final String? subtitle;

  /// Optional compact metadata line.
  final String? metadata;

  /// Optional screen-reader override.
  final String? semanticLabel;

  /// Icon displayed in the circular node.
  final IconData icon;

  /// Semantic event category.
  final NeonPlannerEntryKind kind;

  /// Optional color override.
  final Color? accentColor;

  /// Optional completion from 0 to 1.
  final double? completion;

  /// Whether direct interactions are enabled.
  final bool isEnabled;
}

/// Immutable application entry projected for timeline rendering.
@immutable
class NeonPlannerEntrySnapshot<T> {
  /// Creates an immutable snapshot.
  NeonPlannerEntrySnapshot({
    required this.id,
    required this.data,
    required this.start,
    required this.end,
    required this.presentation,
  }) : assert(end.isAfter(start), 'Entry end must be after start.');

  /// Stable application-defined ID.
  final Object id;

  /// Original application object.
  final T data;

  /// Inclusive start time.
  final DateTime start;

  /// Exclusive end time.
  final DateTime end;

  /// Rendering metadata.
  final NeonPlannerEntryPresentation presentation;

  /// Entry duration.
  Duration get duration => end.difference(start);

  /// Returns a copy with changed temporal values.
  NeonPlannerEntrySnapshot<T> copyWith({DateTime? start, DateTime? end}) {
    return NeonPlannerEntrySnapshot<T>(
      id: id,
      data: data,
      start: start ?? this.start,
      end: end ?? this.end,
      presentation: presentation,
    );
  }
}

/// Proposed move sent to the application for approval.
@immutable
class NeonPlannerMoveProposal<T> {
  /// Creates a move proposal.
  const NeonPlannerMoveProposal({
    required this.entry,
    required this.originalStart,
    required this.originalEnd,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
  });

  /// Entry being moved.
  final NeonPlannerEntrySnapshot<T> entry;

  /// Original start.
  final DateTime originalStart;

  /// Original end.
  final DateTime originalEnd;

  /// Proposed start.
  final DateTime proposedStart;

  /// Proposed end.
  final DateTime proposedEnd;

  /// Whether the package detected an overlap.
  final bool hasConflict;
}

/// Which edge is being resized.
enum NeonPlannerResizeEdge {
  /// Start edge.
  start,

  /// End edge.
  end,
}

/// Proposed resize sent to the application for approval.
@immutable
class NeonPlannerResizeProposal<T> {
  /// Creates a resize proposal.
  const NeonPlannerResizeProposal({
    required this.entry,
    required this.edge,
    required this.originalStart,
    required this.originalEnd,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
  });

  /// Entry being resized.
  final NeonPlannerEntrySnapshot<T> entry;

  /// Edge being resized.
  final NeonPlannerResizeEdge edge;

  /// Original start.
  final DateTime originalStart;

  /// Original end.
  final DateTime originalEnd;

  /// Proposed start.
  final DateTime proposedStart;

  /// Proposed end.
  final DateTime proposedEnd;

  /// Whether the package detected an overlap.
  final bool hasConflict;
}

/// Proposed empty range creation.
@immutable
class NeonPlannerRangeProposal {
  /// Creates a range proposal.
  const NeonPlannerRangeProposal({
    required this.start,
    required this.end,
    required this.hasConflict,
  });

  /// Proposed start.
  final DateTime start;

  /// Proposed end.
  final DateTime end;

  /// Whether the range overlaps an entry.
  final bool hasConflict;

  /// Proposed duration.
  Duration get duration => end.difference(start);
}

/// Result returned by mutation callbacks.
@immutable
class NeonPlannerMutationResult {
  /// Creates a mutation result.
  const NeonPlannerMutationResult._({required this.accepted, this.message});

  /// Creates an accepted result.
  const NeonPlannerMutationResult.accepted([String? message])
    : this._(accepted: true, message: message);

  /// Creates a rejected result.
  const NeonPlannerMutationResult.rejected([String? message])
    : this._(accepted: false, message: message);

  /// Whether the application accepted the proposal.
  final bool accepted;

  /// Optional feedback message.
  final String? message;
}

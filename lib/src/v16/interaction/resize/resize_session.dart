import '../../api/models.dart';

/// Internal immutable resize session state.
final class NeonPlannerResizeSession<T> {
  /// Creates a resize session.
  const NeonPlannerResizeSession({
    required this.entry,
    required this.edge,
    required this.pointerOrigin,
    required this.scrollOrigin,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
  });

  /// Entry being resized.
  final NeonPlannerEntrySnapshot<T> entry;

  /// Active edge.
  final NeonPlannerResizeEdge edge;

  /// Initial global pointer y coordinate.
  final double pointerOrigin;

  /// Scroll offset when the gesture started.
  final double scrollOrigin;

  /// Proposed start.
  final DateTime proposedStart;

  /// Proposed end.
  final DateTime proposedEnd;

  /// Conflict state.
  final bool hasConflict;

  /// Returns a modified session.
  NeonPlannerResizeSession<T> copyWith({
    DateTime? proposedStart,
    DateTime? proposedEnd,
    bool? hasConflict,
  }) {
    return NeonPlannerResizeSession<T>(
      entry: entry,
      edge: edge,
      pointerOrigin: pointerOrigin,
      scrollOrigin: scrollOrigin,
      proposedStart: proposedStart ?? this.proposedStart,
      proposedEnd: proposedEnd ?? this.proposedEnd,
      hasConflict: hasConflict ?? this.hasConflict,
    );
  }
}

import '../../api/models.dart';

/// Internal immutable drag session state.
final class NeonPlannerDragSession<T> {
  /// Creates a drag session.
  const NeonPlannerDragSession({
    required this.entry,
    required this.pointerOrigin,
    required this.scrollOrigin,
    required this.proposedStart,
    required this.proposedEnd,
    required this.hasConflict,
    this.lastPointerY,
    this.velocityPixelsPerSecond = 0,
  });

  /// Entry being dragged.
  final NeonPlannerEntrySnapshot<T> entry;

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

  /// Last pointer coordinate.
  final double? lastPointerY;

  /// Estimated pointer velocity.
  final double velocityPixelsPerSecond;

  /// Returns a modified session.
  NeonPlannerDragSession<T> copyWith({
    DateTime? proposedStart,
    DateTime? proposedEnd,
    bool? hasConflict,
    double? lastPointerY,
    double? velocityPixelsPerSecond,
  }) {
    return NeonPlannerDragSession<T>(
      entry: entry,
      pointerOrigin: pointerOrigin,
      scrollOrigin: scrollOrigin,
      proposedStart: proposedStart ?? this.proposedStart,
      proposedEnd: proposedEnd ?? this.proposedEnd,
      hasConflict: hasConflict ?? this.hasConflict,
      lastPointerY: lastPointerY ?? this.lastPointerY,
      velocityPixelsPerSecond:
          velocityPixelsPerSecond ?? this.velocityPixelsPerSecond,
    );
  }
}

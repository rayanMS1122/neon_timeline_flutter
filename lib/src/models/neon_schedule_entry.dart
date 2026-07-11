import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'neon_timeline_types.dart';

/// Immutable adapter that turns an application model into a scheduled entry.
///
/// [T] remains owned by the host application. The package never serializes,
/// mutates, or stores it.
@immutable
class NeonScheduleEntry<T> {
  /// Creates a scheduled entry.
  const NeonScheduleEntry({
    required this.id,
    required this.value,
    required this.start,
    this.duration = const Duration(minutes: 30),
    this.status = NeonTimelineStatus.pending,
    this.color,
    this.semanticLabel,
    this.draggable = true,
    this.enabled = true,
  });

  /// Stable identity used for keys and state retention.
  final Object id;

  /// Application-owned value represented by this entry.
  final T value;

  /// Scheduled start date and time.
  final DateTime start;

  /// Scheduled duration.
  ///
  /// Invalid or zero values are normalized by [NeonScheduleTimeline].
  final Duration duration;

  /// Visual and semantic state.
  final NeonTimelineStatus status;

  /// Optional entry-specific accent.
  final Color? color;

  /// Optional screen-reader description.
  final String? semanticLabel;

  /// Whether long-press drag-to-reschedule is allowed.
  final bool draggable;

  /// Whether pointer and keyboard interaction is allowed.
  final bool enabled;

  /// Scheduled end date and time.
  DateTime get end => start.add(duration);
}

/// Computed, immutable context passed to schedule builders and callbacks.
@immutable
class NeonScheduleEntryDetails<T> {
  /// Creates schedule entry details.
  const NeonScheduleEntryDetails({
    required this.entry,
    required this.index,
    required this.itemCount,
    required this.day,
    required this.displayStart,
    required this.displayDuration,
    required this.isCurrent,
    required this.overlapsPrevious,
    required this.overlapsNext,
    required this.backToBackWithPrevious,
    required this.backToBackWithNext,
    this.previousEntry,
    this.nextEntry,
    this.gapBefore,
    this.gapAfter,
  });

  /// Current entry.
  final NeonScheduleEntry<T> entry;

  /// Zero-based position after optional sorting.
  final int index;

  /// Number of visible entries.
  final int itemCount;

  /// Calendar day represented by the timeline.
  final DateTime day;

  /// Start time used for layout after clipping and normalization.
  final DateTime displayStart;

  /// Positive duration used for layout.
  final Duration displayDuration;

  /// Previous visible entry, if any.
  final NeonScheduleEntry<T>? previousEntry;

  /// Next visible entry, if any.
  final NeonScheduleEntry<T>? nextEntry;

  /// Positive free time before this entry, when present.
  final Duration? gapBefore;

  /// Positive free time after this entry, when present.
  final Duration? gapAfter;

  /// Whether the current time falls inside this entry.
  final bool isCurrent;

  /// Whether this entry intersects the previous entry.
  final bool overlapsPrevious;

  /// Whether this entry intersects the next entry.
  final bool overlapsNext;

  /// Whether this entry starts exactly when the previous entry ends.
  final bool backToBackWithPrevious;

  /// Whether the next entry starts exactly when this entry ends.
  final bool backToBackWithNext;

  /// Whether this is the first visible entry.
  bool get isFirst => index == 0;

  /// Whether this is the last visible entry.
  bool get isLast => index == itemCount - 1;

  /// End time used for layout.
  DateTime get displayEnd => displayStart.add(displayDuration);
}

/// Builds the visible content of one scheduled entry.
typedef NeonScheduleEntryBuilder<T> = Widget Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

/// Builds a time label for one scheduled entry.
typedef NeonScheduleTimeBuilder<T> = Widget Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

/// Builds a marker for one scheduled entry.
typedef NeonScheduleIndicatorBuilder<T> = Widget Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

/// Handles activation of one scheduled entry.
typedef NeonScheduleEntryCallback<T> = void Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

/// Handles a snapped, clamped reschedule operation.
typedef NeonScheduleMoveCallback<T> = FutureOr<void> Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
  DateTime newStart,
);

/// Builds a localized free-time label.
typedef NeonScheduleGapLabelBuilder = String Function(
  BuildContext context,
  Duration gap,
);

/// Builds the localized current-time marker label.
typedef NeonScheduleNowLabelBuilder = String Function(
  BuildContext context,
  DateTime now,
);

/// Builds a localized conflict label for one entry.
typedef NeonScheduleConflictLabelBuilder<T> = String Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

/// Handles a full-swipe dismissal request for one schedule entry.
typedef NeonScheduleDismissCallback<T> = FutureOr<void> Function(
  BuildContext context,
  NeonScheduleEntryDetails<T> details,
);

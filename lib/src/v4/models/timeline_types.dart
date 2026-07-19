import 'package:flutter/widgets.dart';

/// Stable lifecycle state shared by every 4.x timeline view.
enum TimelineStatus { pending, active, completed, error, disabled }

/// Placement strategy for the rail and timeline content.
enum TimelineLayout { start, center, end, alternating, adaptive }

/// Product-level view modes supported by the timeline platform API.
enum TimelineViewKind {
  timeline,
  schedule,
  planner,
  agenda,
  roadmap,
  project,
  resource,
  dependency,
  calendar,
  presentation,
}

/// Built-in visual languages. Custom themes remain first-class.
enum TimelineVisualStyle {
  modern,
  minimal,
  editorial,
  glass,
  enterprise,
  highContrast,
  darkProfessional,
  neonLegacy,
  aurora,
  softProfessional,
  horizon,
  obsidian,
  paper,
  signal,
  custom,
}

/// Conflict categories emitted by [TimelineRenderPlan].
enum TimelineConflictType {
  none,
  partialOverlap,
  fullContainment,
  sameStart,
  sameEnd,
  sameRange,
  invalidRange,
  resourceConflict,
  capacityConflict,
  dependencyConflict,
  workingHoursConflict,
}

/// Date normalization policy used by the core engine.
enum TimelineTimeSemantics { preserveInput, local, utc }

/// Selection behavior for interactive views.
enum TimelineSelectionMode { none, single, multiple }

/// Generic orientation and layout settings shared by view widgets.
@immutable
class TimelineLayoutConfig {
  const TimelineLayoutConfig({
    this.axis = Axis.vertical,
    this.layout = TimelineLayout.adaptive,
    this.compact = false,
    this.itemExtent,
    this.indicatorPosition = 0.5,
    this.reverse = false,
    this.shrinkWrap = false,
  }) : assert(itemExtent == null || itemExtent > 0),
       assert(indicatorPosition >= 0 && indicatorPosition <= 1);

  final Axis axis;
  final TimelineLayout layout;
  final bool compact;
  final double? itemExtent;
  final double indicatorPosition;
  final bool reverse;
  final bool shrinkWrap;

  TimelineLayoutConfig copyWith({
    Axis? axis,
    TimelineLayout? layout,
    bool? compact,
    double? itemExtent,
    bool clearItemExtent = false,
    double? indicatorPosition,
    bool? reverse,
    bool? shrinkWrap,
  }) {
    return TimelineLayoutConfig(
      axis: axis ?? this.axis,
      layout: layout ?? this.layout,
      compact: compact ?? this.compact,
      itemExtent: clearItemExtent ? null : (itemExtent ?? this.itemExtent),
      indicatorPosition: indicatorPosition ?? this.indicatorPosition,
      reverse: reverse ?? this.reverse,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}

/// Interaction policy shared by schedule and planner views.
@immutable
class TimelineInteractionConfig {
  const TimelineInteractionConfig({
    this.enabled = true,
    this.selectionMode = TimelineSelectionMode.single,
    this.enableDragging = true,
    this.enableResizing = false,
    this.enableKeyboard = true,
    this.enableHaptics = true,
    this.snapMinutes = 5,
    this.longPressDelay = const Duration(milliseconds: 420),
    this.movementThreshold = 8,
  }) : assert(snapMinutes > 0),
       assert(movementThreshold >= 0);

  final bool enabled;
  final TimelineSelectionMode selectionMode;
  final bool enableDragging;
  final bool enableResizing;
  final bool enableKeyboard;
  final bool enableHaptics;
  final int snapMinutes;
  final Duration longPressDelay;
  final double movementThreshold;

  TimelineInteractionConfig copyWith({
    bool? enabled,
    TimelineSelectionMode? selectionMode,
    bool? enableDragging,
    bool? enableResizing,
    bool? enableKeyboard,
    bool? enableHaptics,
    int? snapMinutes,
    Duration? longPressDelay,
    double? movementThreshold,
  }) {
    return TimelineInteractionConfig(
      enabled: enabled ?? this.enabled,
      selectionMode: selectionMode ?? this.selectionMode,
      enableDragging: enableDragging ?? this.enableDragging,
      enableResizing: enableResizing ?? this.enableResizing,
      enableKeyboard: enableKeyboard ?? this.enableKeyboard,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      snapMinutes: snapMinutes ?? this.snapMinutes,
      longPressDelay: longPressDelay ?? this.longPressDelay,
      movementThreshold: movementThreshold ?? this.movementThreshold,
    );
  }
}

/// Motion policy. It never changes layout or data semantics.
@immutable
class TimelineMotionConfig {
  const TimelineMotionConfig({
    this.enabled = true,
    this.framesPerSecond = 24,
    this.maxAnimatedEntries = 1,
    this.pauseWhileScrolling = true,
    this.respectReducedMotion = true,
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeOutCubic,
  }) : assert(framesPerSecond >= 1 && framesPerSecond <= 120),
       assert(maxAnimatedEntries >= 0);

  const TimelineMotionConfig.disabled()
    : this(enabled: false, framesPerSecond: 1, maxAnimatedEntries: 0);

  final bool enabled;
  final int framesPerSecond;
  final int maxAnimatedEntries;
  final bool pauseWhileScrolling;
  final bool respectReducedMotion;
  final Duration duration;
  final Curve curve;

  TimelineMotionConfig copyWith({
    bool? enabled,
    int? framesPerSecond,
    int? maxAnimatedEntries,
    bool? pauseWhileScrolling,
    bool? respectReducedMotion,
    Duration? duration,
    Curve? curve,
  }) {
    return TimelineMotionConfig(
      enabled: enabled ?? this.enabled,
      framesPerSecond: framesPerSecond ?? this.framesPerSecond,
      maxAnimatedEntries: maxAnimatedEntries ?? this.maxAnimatedEntries,
      pauseWhileScrolling: pauseWhileScrolling ?? this.pauseWhileScrolling,
      respectReducedMotion: respectReducedMotion ?? this.respectReducedMotion,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }
}

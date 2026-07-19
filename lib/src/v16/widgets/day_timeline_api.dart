part of 'day_timeline_view.dart';

/// Callback used when an entry is dropped at a new time in the compact view.
typedef NeonPlannerDayMoveCallback<T> =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerMoveProposal<T> proposal,
    );

/// Callback used when an entry edge is resized in the compact view.
typedef NeonPlannerDayResizeCallback<T> =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerResizeProposal<T> proposal,
    );

/// Callback invoked by the built-in undo surface after a successful move.
///
/// The callback receives the original accepted move proposal. The application
/// remains responsible for restoring its own data.
typedef NeonPlannerDayUndoMoveCallback<T> =
    FutureOr<NeonPlannerMutationResult> Function(
      NeonPlannerMoveProposal<T> acceptedProposal,
    );

/// Controls how compact day entries are moved.
enum NeonPlannerDayDragMode {
  /// Dragging vertically scrubs the entry through real clock time.
  time,

  /// Entries can only be placed into explicit compressed gap drop zones.
  slots,

  /// Shows gap drop zones while also allowing direct time scrubbing anywhere.
  hybrid,
}

/// Vertical density of entries and compressed gaps.
enum NeonPlannerDayDensity {
  /// Maximum overview with smaller nodes and shorter rows.
  compact,

  /// Balanced mobile default.
  comfortable,

  /// More breathing room and larger interaction surfaces.
  spacious,
}

/// Responsive density derived from the timeline widget's own width.
enum NeonPlannerResponsiveDensity {
  /// Very narrow phones and embedded timeline panels.
  micro,

  /// Typical phone-sized timeline panels.
  compact,

  /// Tablets, desktop, and wide embedded panels.
  regular,
}

/// Controls whether the adaptive time lens is rendered.
enum NeonPlannerTimeLensMode {
  /// Uses a compact lens that adapts to the resolved responsive density.
  automatic,

  /// Keeps the adaptive lens enabled at every supported width.
  enabled,

  /// Disables the adaptive lens.
  disabled,
}

/// Determines whether the timeline owns a scroll viewport or sizes to content.
enum NeonPlannerDayFit {
  /// Chooses content sizing for short days and internal scrolling for long days.
  smart,

  /// Uses the available height and scrolls internally.
  scroll,

  /// Sizes to all rows and delegates scrolling to an ancestor.
  content,
}

/// Visual treatment for entries that overlap in clock time.
enum NeonPlannerOverlapPresentation {
  /// Do not add a dedicated overlap treatment.
  none,

  /// Offset rail nodes and show a compact lane indicator.
  stacked,

  /// Keep the rail centered and show only an overlap badge.
  badge,
}

/// A compact metric displayed above [NeonPlannerDayTimeline].
@immutable
class NeonPlannerDayMetric {
  /// Creates a day metric.
  const NeonPlannerDayMetric({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    this.color,
  });

  /// Small heading.
  final String label;

  /// Dominant value.
  final String value;

  /// Supporting copy below the value.
  final String helper;

  /// Metric icon.
  final IconData icon;

  /// Optional semantic accent override.
  final Color? color;
}

/// Presentation data for a compressed interval between timeline entries.
@immutable
class NeonPlannerCompressedGap {
  /// Creates a compressed gap.
  const NeonPlannerCompressedGap({
    required this.title,
    required this.icon,
    this.color,
  });

  /// Short interval label.
  final String title;

  /// Semantic icon.
  final IconData icon;

  /// Optional accent override.
  final Color? color;
}

/// A premium, overview-first day timeline.
///
/// Empty intervals are compressed into semantic rows, while direct dragging
/// and resizing still operate on real clock time. The application remains the
/// source of truth for every mutation.
class NeonPlannerDayTimeline<T> extends StatefulWidget {
  /// Creates the compact day timeline.
  const NeonPlannerDayTimeline({
    required this.entries,
    required this.adapter,
    required this.selectedDate,
    this.metrics,
    this.theme,
    this.onBack,
    this.onCalendarTap,
    this.onMoreTap,
    this.onEntryTap,
    this.onEntryStatusTap,
    this.onEntryTimeEdit,
    this.onEntryMove,
    this.onEntryResize,
    this.onUndoMove,
    this.onCreateTap,
    this.onFeedback,
    this.onGapTap,
    this.gapBuilder,
    this.dateLabelBuilder,
    this.entryTimeLabelBuilder,
    this.entryDurationLabelBuilder,
    this.dropZoneLabelBuilder,
    this.dragActivation = NeonPlannerDragActivation.longPress,
    this.dragMode = NeonPlannerDayDragMode.time,
    this.snapInterval = const Duration(minutes: 5),
    this.snapToEntryEdges = true,
    this.snapTolerance = const Duration(minutes: 9),
    this.snapHysteresis = const Duration(minutes: 3),
    this.conflictPolicy = NeonPlannerConflictPolicy.allow,
    this.dragMinutesPerPixel = 0.75,
    this.minimumEntryDuration = const Duration(minutes: 5),
    this.enableResize = true,
    this.showTimeScrubber = true,
    this.showAdaptiveTimeLens = true,
    this.timeLensMode = NeonPlannerTimeLensMode.automatic,
    this.showMoveConfirmation = true,
    this.showResizeConfirmation = true,
    this.animateCommittedMove = true,
    this.moveConfirmationDuration = const Duration(milliseconds: 1600),
    this.settleAnimationDuration = const Duration(milliseconds: 520),
    this.enableAutoScroll = true,
    this.enableKeyboardMovement = true,
    this.keyboardFastStepMultiplier = 4,
    this.showBuiltInUndo = true,
    this.undoWindow = const Duration(seconds: 5),
    this.density = NeonPlannerDayDensity.comfortable,
    this.responsiveDensity = NeonPlannerResponsiveDensity.regular,
    this.autoResponsiveDensity = true,
    this.compactBreakpoint = 480,
    this.microBreakpoint = 360,
    this.fit = NeonPlannerDayFit.smart,
    this.smartFitMaxRows = 11,
    this.overlapPresentation = NeonPlannerOverlapPresentation.stacked,
    this.showGrabber = true,
    this.showHeader = true,
    this.showMetrics = true,
    this.showCurrentTimeIndicator = true,
    this.currentTime,
    this.currentTimeLabel = 'Jetzt',
    this.emptyTitle = 'Freier Tag',
    this.emptySubtitle = 'Noch keine Termine geplant.',
    this.padding = _defaultDayTimelinePadding,
    this.borderRadius = 42,
    this.backgroundColor,
    this.scrollController,
    super.key,
  }) : assert(microBreakpoint > 0),
       assert(compactBreakpoint > microBreakpoint);

  /// Application entries.
  final List<T> entries;

  /// Projects application data into timeline snapshots.
  final NeonPlannerEntryAdapter<T> adapter;

  /// Day represented by this view.
  final DateTime selectedDate;

  /// Optional explicit summary metrics. Three metrics work best.
  final List<NeonPlannerDayMetric>? metrics;

  /// Optional timeline theme override.
  final NeonPlannerTimelineThemeData? theme;

  /// Header back callback.
  final VoidCallback? onBack;

  /// Header calendar callback.
  final VoidCallback? onCalendarTap;

  /// Header overflow callback.
  final VoidCallback? onMoreTap;

  /// Entry tap callback.
  final ValueChanged<T>? onEntryTap;

  /// Status-ring callback.
  final ValueChanged<T>? onEntryStatusTap;

  /// Optional direct time-editor callback, triggered by double tap or keyboard.
  final ValueChanged<T>? onEntryTimeEdit;

  /// Called after a dragged entry is dropped at a proposed time.
  final NeonPlannerDayMoveCallback<T>? onEntryMove;

  /// Called after a start or end edge is resized.
  final NeonPlannerDayResizeCallback<T>? onEntryResize;

  /// Called when the user taps the built-in undo action.
  final NeonPlannerDayUndoMoveCallback<T>? onUndoMove;

  /// Optional create action shown in the empty state.
  final VoidCallback? onCreateTap;

  /// Receives drag, resize, undo, rejection, and error messages.
  final ValueChanged<String>? onFeedback;

  /// Gap row callback.
  final ValueChanged<NeonPlannerCompressedGap>? onGapTap;

  /// Optional compressed-gap factory.
  final NeonPlannerCompressedGap? Function(
    Duration duration,
    int index,
    NeonPlannerEntrySnapshot<T> previous,
    NeonPlannerEntrySnapshot<T> next,
  )? gapBuilder;

  /// Optional date label formatter.
  final String Function(DateTime date)? dateLabelBuilder;

  /// Optional left-side entry time formatter.
  final String Function(T entry, DateTime start)? entryTimeLabelBuilder;

  /// Optional duration-chip formatter. Return an empty string to hide it.
  final String Function(T entry, Duration duration)? entryDurationLabelBuilder;

  /// Optional drop-zone copy formatter.
  final String Function(DateTime proposedStart, bool hasConflict)?
      dropZoneLabelBuilder;

  /// Pointer gesture that activates dragging.
  final NeonPlannerDragActivation dragActivation;

  /// Drag interaction used by the compact timeline.
  final NeonPlannerDayDragMode dragMode;

  /// Minute grid used by dragging, resizing, and keyboard movement.
  final Duration snapInterval;

  /// Enables magnetic alignment to neighboring entry starts and ends.
  final bool snapToEntryEdges;

  /// Maximum raw-time distance for magnetic entry-edge snapping.
  final Duration snapTolerance;

  /// Extra release distance that prevents a chosen snap target from flickering.
  final Duration snapHysteresis;

  /// Conflict behavior for compact mutations.
  final NeonPlannerConflictPolicy conflictPolicy;

  /// Number of clock minutes represented by one vertical drag pixel.
  final double dragMinutesPerPixel;

  /// Smallest duration allowed by resize interactions.
  final Duration minimumEntryDuration;

  /// Enables resize handles when [onEntryResize] is supplied.
  final bool enableResize;

  /// Shows a live horizontal time rule while dragging or resizing.
  final bool showTimeScrubber;

  /// Shows a compact magnified time scale around the active drag target.
  final bool showAdaptiveTimeLens;

  /// Responsive behavior of the adaptive time lens.
  final NeonPlannerTimeLensMode timeLensMode;

  /// Shows a short confirmation surface after an accepted move.
  final bool showMoveConfirmation;

  /// Shows a short confirmation surface after an accepted resize.
  final bool showResizeConfirmation;

  /// Pulses the committed entry briefly after the application accepts a move.
  final bool animateCommittedMove;

  /// Lifetime of the transient move confirmation surface.
  final Duration moveConfirmationDuration;

  /// Duration of the settled-entry pulse after an accepted mutation.
  final Duration settleAnimationDuration;

  /// Enables edge auto-scroll while dragging or resizing.
  final bool enableAutoScroll;

  /// Enables arrow-key movement and screen-reader increment/decrement actions.
  final bool enableKeyboardMovement;

  /// Multiplier used while Shift is held during keyboard movement.
  final int keyboardFastStepMultiplier;

  /// Shows an internal undo bar after accepted moves when [onUndoMove] exists.
  final bool showBuiltInUndo;

  /// Time before the internal undo action disappears.
  final Duration undoWindow;

  /// Entry and gap density.
  final NeonPlannerDayDensity density;

  /// Density used when [autoResponsiveDensity] is disabled.
  final NeonPlannerResponsiveDensity responsiveDensity;

  /// Resolves responsive density from the timeline's actual widget width.
  final bool autoResponsiveDensity;

  /// Width below which compact responsive geometry is used.
  final double compactBreakpoint;

  /// Width below which micro responsive geometry is used.
  final double microBreakpoint;

  /// Whether this widget scrolls internally or sizes to its content.
  final NeonPlannerDayFit fit;

  /// Maximum generated row count that [NeonPlannerDayFit.smart] keeps compact.
  final int smartFitMaxRows;

  /// Visual treatment for overlapping entries.
  final NeonPlannerOverlapPresentation overlapPresentation;

  /// Shows the small mobile grabber at the top.
  final bool showGrabber;

  /// Shows the date and action row.
  final bool showHeader;

  /// Shows the summary strip.
  final bool showMetrics;

  /// Shows the current-time marker at its chronological position.
  final bool showCurrentTimeIndicator;

  /// Optional current-time override, useful for deterministic tests.
  final DateTime? currentTime;

  /// Label rendered beside the current-position marker.
  final String currentTimeLabel;

  /// Empty-state heading.
  final String emptyTitle;

  /// Empty-state supporting copy.
  final String emptySubtitle;

  /// Inner padding.
  final EdgeInsets padding;

  /// Outer corner radius.
  final double borderRadius;

  /// Optional outer background override.
  final Color? backgroundColor;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  @override
  State<NeonPlannerDayTimeline<T>> createState() =>
      _NeonPlannerDayTimelineState<T>();
}

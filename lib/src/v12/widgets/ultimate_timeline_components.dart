import 'dart:async';

import 'package:flutter/material.dart';

import '../../v8/core/timeline_resize.dart';
import '../models/ultimate_timeline_config.dart';
import '../models/ultimate_timeline_details.dart';
import '../theme/ultimate_timeline_theme.dart';

/// Adaptive 12.x task card that selects micro, compact or full content based
/// on real constraints and text scale instead of a fixed-height assumption.
class UltimateTimelineEntryCard<T> extends StatelessWidget {
  const UltimateTimelineEntryCard({
    required this.details,
    required this.title,
    required this.timeFormatter,
    required this.durationFormatter,
    this.subtitle,
    this.progress,
    this.zoomLevel = UltimateTimelineZoomLevel.comfortable,
    this.trailing,
    super.key,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final double? progress;
  final UltimateTimelineZoomLevel zoomLevel;
  final String Function(DateTime value) timeFormatter;
  final String Function(Duration value) durationFormatter;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final entry = details.entry;
    final state = details.interaction;
    final accent = entry.color ?? UltimateTimelineTheme.of(context).primary;
    final start = details.visibleStart;
    final end = details.visibleEnd;
    final time = '${timeFormatter(start)}–${timeFormatter(end)}';
    final duration = durationFormatter(details.duration);
    final semantics = <String>[
      title,
      time,
      duration,
      if (state.completed) 'Completed',
      if (state.selected) 'Selected',
      if (state.locked) 'Locked',
      if (state.recurring) 'Recurring',
      if (state.external) 'External event',
      if (details.base.hasConflict) 'Conflict',
      if (state.busy) 'Saving',
      if (state.error) state.errorMessage ?? 'Error',
    ].join(', ');

    return Semantics(
      container: true,
      label: semantics,
      selected: state.selected,
      enabled: entry.enabled,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(
            context,
          ).scale(1).clamp(1.0, 2.0).toDouble();
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : UltimateTimelineZoomMetrics.forLevel(
                  zoomLevel,
                ).minimumEntryHeight;
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 360.0;
          final micro = height < 58 * textScale || width < 190;
          final compact =
              !micro &&
              (height < 92 * textScale ||
                  width < 300 ||
                  zoomLevel.index <= UltimateTimelineZoomLevel.compact.index);
          final surface = UltimateTimelineEntrySurface<T>(
            details: details,
            accent: accent,
            compact: compact || micro,
            child: micro
                ? UltimateTimelineMicroEntry<T>(
                    details: details,
                    title: title,
                    timeLabel: timeFormatter(start),
                    accent: accent,
                  )
                : compact
                ? UltimateTimelineCompactEntry<T>(
                    details: details,
                    title: title,
                    timeLabel: time,
                    accent: accent,
                    trailing: trailing,
                  )
                : _UltimateTimelineFullEntry<T>(
                    details: details,
                    title: title,
                    subtitle: subtitle,
                    timeLabel: time,
                    durationLabel: duration,
                    progress: progress,
                    accent: accent,
                    trailing: trailing,
                  ),
          );
          if (details.segmentType == UltimateTimelineSegmentType.complete) {
            return surface;
          }
          return UltimateTimelineMultiDayEntry<T>(
            details: details,
            child: surface,
          );
        },
      ),
    );
  }
}

/// Shared card surface with explicit selected/focus/conflict/busy layers.
class UltimateTimelineEntrySurface<T> extends StatelessWidget {
  const UltimateTimelineEntrySurface({
    required this.details,
    required this.accent,
    required this.child,
    this.compact = false,
    super.key,
  });

  final UltimateTimelineEntryDetails<T> details;
  final Color accent;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final state = details.interaction;
    final conflict = details.base.hasConflict;
    final borderColor = state.error || conflict
        ? theme.error
        : state.selected || state.focused
        ? theme.primary
        : theme.border;
    final radius = compact ? theme.entry.compactRadius : theme.entry.radius;
    final elevation = state.selected || state.focused
        ? theme.entry.selectedElevation
        : theme.entry.elevation;
    return RepaintBoundary(
      child: Material(
        color: theme.surfaceElevated,
        elevation: elevation,
        shadowColor: theme.shadow,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          duration: theme.motion.focus,
          curve: theme.motion.curve,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              accent.withValues(
                alpha: state.completed
                    ? theme.entry.completedTintOpacity
                    : theme.entry.tintOpacity,
              ),
              theme.surfaceElevated,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: state.selected || state.focused
                  ? theme.entry.selectedBorderWidth
                  : theme.entry.borderWidth,
            ),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (theme.entry.accentPlacement ==
                  UltimateTimelineAccentPlacement.leading)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: theme.entry.accentWidth,
                  child: ColoredBox(color: conflict ? theme.error : accent),
                ),
              if (theme.entry.accentPlacement ==
                  UltimateTimelineAccentPlacement.top)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: theme.entry.accentWidth,
                  child: ColoredBox(color: conflict ? theme.error : accent),
                ),
              Padding(padding: theme.entry.contentPadding, child: child),
              if (state.busy)
                PositionedDirectional(
                  end: 9,
                  top: 9,
                  child: SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primary,
                    ),
                  ),
                ),
              if (state.error)
                PositionedDirectional(
                  end: 8,
                  bottom: 8,
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 17,
                    color: theme.error,
                    semanticLabel: state.errorMessage ?? 'Error',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Public time/status header for full cards.
class UltimateTimelineEntryHeader extends StatelessWidget {
  const UltimateTimelineEntryHeader({
    required this.timeLabel,
    required this.durationLabel,
    required this.accent,
    this.trailing,
    super.key,
  });

  final String timeLabel;
  final String durationLabel;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              timeLabel,
              maxLines: 1,
              style: TextStyle(
                color: accent,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            durationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// Public title/description body.
class UltimateTimelineEntryBody extends StatelessWidget {
  const UltimateTimelineEntryBody({
    required this.title,
    this.subtitle,
    this.completed = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: completed ? theme.mutedText : theme.text,
            fontSize: 15,
            height: 1.12,
            fontWeight: FontWeight.w700,
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 11.5,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Public progress and state footer.
class UltimateTimelineEntryFooter extends StatelessWidget {
  const UltimateTimelineEntryFooter({
    required this.accent,
    this.progress,
    this.leading,
    this.trailing,
    super.key,
  });

  final Color accent;
  final double? progress;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final normalized = progress?.clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        if (leading != null) leading!,
        if (leading != null && normalized != null) const SizedBox(width: 9),
        if (normalized != null)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 4,
                color: accent,
                backgroundColor: accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        if (trailing != null) ...[const SizedBox(width: 9), trailing!],
      ],
    );
  }
}

/// Reserved action area that wraps instead of overlapping card content.
class UltimateTimelineEntryActions extends StatelessWidget {
  const UltimateTimelineEntryActions({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: children,
    );
  }
}

/// Optional immediate pointer drag handle for custom composition surfaces.
///
/// The host connects the callbacks to its drag session; the handle supplies a
/// stable mouse cursor, large hit target and keyboard/screen-reader label.
class UltimateTimelineDragHandle extends StatelessWidget {
  const UltimateTimelineDragHandle({
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    this.semanticLabel = 'Move task',
    super.key,
  });

  final GestureDragStartCallback onStart;
  final GestureDragUpdateCallback onUpdate;
  final GestureDragEndCallback onEnd;
  final VoidCallback onCancel;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: onStart,
          onPanUpdate: onUpdate,
          onPanEnd: onEnd,
          onPanCancel: onCancel,
          child: SizedBox.square(
            dimension: 44,
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 20,
              color: theme.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact entry representation for moderate heights and widths.
class UltimateTimelineCompactEntry<T> extends StatelessWidget {
  const UltimateTimelineCompactEntry({
    required this.details,
    required this.title,
    required this.timeLabel,
    required this.accent,
    this.trailing,
    super.key,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String timeLabel;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: details.interaction.completed
                      ? theme.mutedText
                      : theme.text,
                  fontSize: 14,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  decoration: details.interaction.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _UltimateTimelineStateIcons<T>(details: details),
        if (trailing != null) ...[const SizedBox(width: 5), trailing!],
      ],
    );
  }
}

/// Minimal readable representation for very short visual tasks.
class UltimateTimelineMicroEntry<T> extends StatelessWidget {
  const UltimateTimelineMicroEntry({
    required this.details,
    required this.title,
    required this.timeLabel,
    required this.accent,
    super.key,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String timeLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Row(
      children: [
        Text(
          timeLabel,
          style: TextStyle(
            color: accent,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (details.base.hasConflict)
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: theme.error,
            semanticLabel: 'Conflict',
          )
        else if (details.interaction.locked)
          Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: theme.mutedText,
            semanticLabel: 'Locked',
          ),
      ],
    );
  }
}

/// Adds continuation language to start/middle/end multi-day segments.
class UltimateTimelineMultiDayEntry<T> extends StatelessWidget {
  const UltimateTimelineMultiDayEntry({
    required this.details,
    required this.child,
    super.key,
  });

  final UltimateTimelineEntryDetails<T> details;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final continuesBefore = switch (details.segmentType) {
      UltimateTimelineSegmentType.middle ||
      UltimateTimelineSegmentType.end ||
      UltimateTimelineSegmentType.clippedBefore => true,
      _ => false,
    };
    final continuesAfter = switch (details.segmentType) {
      UltimateTimelineSegmentType.start ||
      UltimateTimelineSegmentType.middle ||
      UltimateTimelineSegmentType.clippedAfter => true,
      _ => false,
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (continuesBefore)
          PositionedDirectional(
            start: 12,
            top: 3,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 14,
              color: theme.mutedText,
              semanticLabel: 'Continues from previous day',
            ),
          ),
        if (continuesAfter)
          PositionedDirectional(
            end: 12,
            bottom: 3,
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 14,
              color: theme.mutedText,
              semanticLabel: 'Continues on next day',
            ),
          ),
      ],
    );
  }
}

class _UltimateTimelineFullEntry<T> extends StatelessWidget {
  const _UltimateTimelineFullEntry({
    required this.details,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.durationLabel,
    required this.progress,
    required this.accent,
    required this.trailing,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final String durationLabel;
  final double? progress;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final completion = details.base.onComplete;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UltimateTimelineEntryHeader(
          timeLabel: timeLabel,
          durationLabel: durationLabel,
          accent: accent,
          trailing: trailing,
        ),
        const SizedBox(height: 7),
        UltimateTimelineEntryBody(
          title: title,
          subtitle: subtitle,
          completed: details.interaction.completed,
        ),
        if (progress != null ||
            completion != null ||
            details.interaction.recurring ||
            details.interaction.locked) ...[
          const SizedBox(height: 9),
          UltimateTimelineEntryFooter(
            accent: accent,
            progress: progress,
            leading: _UltimateTimelineStateIcons<T>(details: details),
            trailing: completion == null
                ? null
                : IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: details.interaction.completed
                        ? 'Completed'
                        : 'Complete task',
                    onPressed: details.interaction.busy
                        ? null
                        : () => unawaited(completion()),
                    icon: Icon(
                      details.interaction.completed
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 21,
                      color: accent,
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

class _UltimateTimelineStateIcons<T> extends StatelessWidget {
  const _UltimateTimelineStateIcons({required this.details});

  final UltimateTimelineEntryDetails<T> details;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final state = details.interaction;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.recurring)
          Icon(
            Icons.repeat_rounded,
            size: 15,
            color: theme.mutedText,
            semanticLabel: 'Recurring',
          ),
        if (state.external)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 5),
            child: Icon(
              Icons.event_rounded,
              size: 15,
              color: theme.mutedText,
              semanticLabel: 'External event',
            ),
          ),
        if (state.locked)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 5),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: theme.mutedText,
              semanticLabel: 'Locked',
            ),
          ),
        if (details.base.hasConflict)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 5),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: theme.error,
              semanticLabel: 'Conflict',
            ),
          ),
      ],
    );
  }
}

/// Public overlay compositor for drag feedback, target and conflict layers.
class UltimateTimelineDragLayer<T> extends StatelessWidget {
  const UltimateTimelineDragLayer({
    required this.feedback,
    this.dropPreview,
    this.snapGuide,
    this.conflictPreview,
    this.showScrim = true,
    super.key,
  });

  final Widget feedback;
  final Widget? dropPreview;
  final Widget? snapGuide;
  final Widget? conflictPreview;
  final bool showScrim;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Stack(
      children: [
        if (showScrim)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: theme.text.withValues(alpha: theme.drag.scrimOpacity),
              ),
            ),
          ),
        if (dropPreview != null) dropPreview!,
        if (snapGuide != null) snapGuide!,
        if (conflictPreview != null) conflictPreview!,
        feedback,
      ],
    );
  }
}

/// Stable-size lifted card with live time and non-color status language.
class UltimateTimelineDragFeedback<T> extends StatelessWidget {
  const UltimateTimelineDragFeedback({
    required this.child,
    required this.start,
    required this.end,
    required this.timeFormatter,
    this.allowed = true,
    this.magnetized = false,
    this.conflictCount = 0,
    this.blockReason,
    this.scale = 1.025,
    super.key,
  });

  final Widget child;
  final DateTime start;
  final DateTime end;
  final String Function(DateTime value) timeFormatter;
  final bool allowed;
  final bool magnetized;
  final int conflictCount;
  final String? blockReason;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final color = allowed ? theme.primary : theme.blocked;
    final timeLabel = '${timeFormatter(start)}–${timeFormatter(end)}';
    final label = allowed ? timeLabel : 'Drop blocked';
    return Semantics(
      liveRegion: true,
      label: allowed
          ? 'New time $timeLabel. ${magnetized ? 'Magnetic target. ' : ''}${conflictCount == 0 ? 'No conflict' : '$conflictCount conflicts'}.'
          : 'Move not possible. ${blockReason ?? 'Drop blocked'}. $timeLabel.',
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          elevation: theme.drag.feedbackElevation,
          shadowColor: theme.shadow,
          borderRadius: BorderRadius.circular(theme.entry.radius),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.entry.radius),
                child: child,
              ),
              PositionedDirectional(
                start: 12,
                top: -13,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          allowed
                              ? magnetized
                                    ? Icons.vertical_align_center_rounded
                                    : Icons.schedule_rounded
                              : Icons.block_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (conflictCount > 0) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$conflictCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clearly non-interactive origin marker, visually distinct from a real task.
class UltimateTimelineDragPlaceholder<T> extends StatelessWidget {
  const UltimateTimelineDragPlaceholder({
    required this.child,
    this.label = 'Original position',
    this.opacity = 0.14,
    super.key,
  });

  final Widget child;
  final String label;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Semantics(
      label: label,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(opacity: opacity, child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _UltimateDashedBorderPainter(
                  color: theme.primary.withValues(alpha: 0.55),
                  radius: theme.entry.radius,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight < 54) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: theme.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact destructive drop target used by the v13 workspace design.
///
/// It deliberately stays small, clamps visual text scaling and keeps the full
/// meaning in semantics so it cannot cover a large part of the timeline.
class UltimateTimelineDeleteTarget extends StatelessWidget {
  const UltimateTimelineDeleteTarget({
    required this.active,
    this.label = 'Delete area',
    this.activeLabel = 'Release to delete',
    super.key,
  });

  final bool active;
  final String label;
  final String activeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final color = active ? theme.error : theme.mutedText;
    return Align(
      alignment: Alignment.bottomCenter,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: 1,
        maxScaleFactor: 1.25,
        child: Semantics(
          liveRegion: active,
          label: active ? activeLabel : label,
          child: AnimatedScale(
            duration: theme.motion.focus,
            curve: theme.motion.curve,
            scale: active ? 1.035 : 1,
            child: AnimatedContainer(
              duration: theme.motion.focus,
              curve: theme.motion.curve,
              width: active ? 184 : 154,
              height: 46,
              decoration: BoxDecoration(
                color: active ? theme.error : theme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? theme.error : theme.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? theme.error.withValues(alpha: 0.2)
                        : theme.shadow,
                    blurRadius: active ? 18 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active
                        ? Icons.delete_forever_rounded
                        : Icons.delete_outline_rounded,
                    size: 18,
                    color: active ? Colors.white : color,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      active ? activeLabel : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? Colors.white : color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Highlighted target range with icon and label, not color alone.
class UltimateTimelineDropPreview<T> extends StatelessWidget {
  const UltimateTimelineDropPreview({
    required this.height,
    required this.label,
    this.allowed = true,
    this.magnetized = false,
    this.conflictCount = 0,
    super.key,
  });

  final double height;
  final String label;
  final bool allowed;
  final bool magnetized;
  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final color = allowed ? theme.primary : theme.blocked;
    final semanticLabel = allowed
        ? '$label. ${magnetized ? 'Magnetic target. ' : ''}${conflictCount == 0 ? 'Drop available.' : '$conflictCount conflicts.'}'
        : '$label. Drop blocked.';
    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      child: IgnorePointer(
        child: SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: allowed
                    ? theme.drag.allowedOpacity
                    : theme.drag.blockedOpacity,
              ),
              borderRadius: BorderRadius.circular(theme.entry.radius),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadiusDirectional.horizontal(
                        start: Radius.circular(theme.entry.radius),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 10,
                  top: 8,
                  bottom: 8,
                  child: _UltimateDropRail(color: color),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          allowed
                              ? magnetized
                                    ? Icons.vertical_align_center_rounded
                                    : Icons.check_rounded
                              : Icons.block_rounded,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (conflictCount > 0) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 15,
                            color: theme.error,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$conflictCount',
                            style: TextStyle(
                              color: theme.error,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UltimateDropRail extends StatelessWidget {
  const _UltimateDropRail({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (_) => SizedBox.square(
          dimension: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.58),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Temporal guide line with explicit snap label.
class UltimateTimelineSnapGuide extends StatelessWidget {
  const UltimateTimelineSnapGuide({
    required this.label,
    this.allowed = true,
    this.magnetized = true,
    super.key,
  });

  final String label;
  final bool allowed;
  final bool magnetized;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final color = allowed ? theme.primary : theme.blocked;
    return IgnorePointer(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: theme.drag.guideThickness,
              color: color.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allowed
                        ? magnetized
                              ? Icons.vertical_align_center_rounded
                              : Icons.schedule_rounded
                        : Icons.block_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Non-color conflict summary for live drag/resize preview.
class UltimateTimelineConflictPreview<T> extends StatelessWidget {
  const UltimateTimelineConflictPreview({
    required this.count,
    this.message,
    super.key,
  });

  final int count;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final theme = UltimateTimelineTheme.of(context);
    return Semantics(
      liveRegion: true,
      label: message ?? '$count conflicts',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.error.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: theme.error),
              const SizedBox(width: 6),
              Text(
                message ?? '$count conflicts',
                style: TextStyle(
                  color: theme.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explicit reason shown for a blocked drop.
class UltimateTimelineBlockedDropIndicator extends StatelessWidget {
  const UltimateTimelineBlockedDropIndicator({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Semantics(
      liveRegion: true,
      label: 'Move not possible. $reason',
      child: Chip(
        avatar: Icon(Icons.block_rounded, size: 16, color: theme.blocked),
        label: Text(reason),
        side: BorderSide(color: theme.blocked.withValues(alpha: 0.45)),
        backgroundColor: theme.blocked.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Edge direction/strength indicator for active auto-scroll.
class UltimateTimelineAutoScrollIndicator extends StatelessWidget {
  const UltimateTimelineAutoScrollIndicator({
    required this.velocity,
    required this.maximumVelocity,
    super.key,
  });

  final double velocity;
  final double maximumVelocity;

  @override
  Widget build(BuildContext context) {
    if (velocity == 0 || maximumVelocity <= 0) {
      return const SizedBox.shrink();
    }
    final theme = UltimateTimelineTheme.of(context);
    final strength = (velocity.abs() / maximumVelocity)
        .clamp(0.0, 1.0)
        .toDouble();
    return Semantics(
      label: velocity < 0 ? 'Scrolling earlier' : 'Scrolling later',
      child: Opacity(
        opacity: 0.45 + strength * 0.55,
        child: Icon(
          velocity < 0
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: theme.primary,
          size: 24 + strength * 10,
        ),
      ),
    );
  }
}

/// Overlay compositor for resize feedback and handles.
class UltimateTimelineResizeLayer<T> extends StatelessWidget {
  const UltimateTimelineResizeLayer({
    required this.child,
    this.preview,
    this.startHandle,
    this.endHandle,
    super.key,
  });

  final Widget child;
  final Widget? preview;
  final Widget? startHandle;
  final Widget? endHandle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (preview != null) preview!,
        if (startHandle != null) startHandle!,
        if (endHandle != null) endHandle!,
      ],
    );
  }
}

/// Live resize time/duration preview.
class UltimateTimelineResizePreview<T> extends StatelessWidget {
  const UltimateTimelineResizePreview({
    required this.start,
    required this.end,
    required this.timeFormatter,
    required this.durationFormatter,
    this.allowed = true,
    this.reason,
    super.key,
  });

  final DateTime start;
  final DateTime end;
  final String Function(DateTime value) timeFormatter;
  final String Function(Duration value) durationFormatter;
  final bool allowed;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final color = allowed ? theme.primary : theme.blocked;
    final label =
        '${timeFormatter(start)}–${timeFormatter(end)} · '
        '${durationFormatter(end.difference(start))}';
    return Align(
      alignment: Alignment.topLeft,
      child: Semantics(
        liveRegion: true,
        label: allowed ? 'Resized to $label' : 'Resize blocked. $reason',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Text(
              allowed ? label : reason ?? 'Resize blocked',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large invisible resize hit target with a deliberately quiet visual handle.
class UltimateTimelineResizeHandle<T> extends StatelessWidget {
  const UltimateTimelineResizeHandle({
    required this.edge,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    this.onIncrease,
    this.onDecrease,
    super.key,
  });

  final TimelineResizeEdge edge;
  final GestureDragStartCallback onStart;
  final GestureDragUpdateCallback onUpdate;
  final GestureDragEndCallback onEnd;
  final VoidCallback onCancel;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return Align(
      alignment: edge == TimelineResizeEdge.start
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      child: SizedBox(
        height: theme.resize.hitTargetHeight,
        child: Semantics(
          button: true,
          label: edge == TimelineResizeEdge.start
              ? 'Resize start time'
              : 'Resize end time',
          onIncrease: onIncrease,
          onDecrease: onDecrease,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: onStart,
            onVerticalDragUpdate: onUpdate,
            onVerticalDragEnd: onEnd,
            onVerticalDragCancel: onCancel,
            child: Center(
              child: Container(
                width: theme.resize.visualHandleWidth,
                height: theme.resize.visualHandleHeight,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive public header that moves secondary content behind one action on
/// narrow layouts while preserving the primary date/navigation controls.
class UltimateTimelineHeader extends StatelessWidget {
  const UltimateTimelineHeader({
    required this.details,
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.weekStrip,
    this.metrics,
    this.viewControls,
    this.filters,
    this.secondaryActions,
    super.key,
  });

  final UltimateTimelineHeaderDetails details;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final Widget? weekStrip;
  final Widget? metrics;
  final Widget? viewControls;
  final Widget? filters;
  final Widget? secondaryActions;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              details.compact ||
              constraints.maxWidth < theme.header.compactBreakpoint;
          final navigator = UltimateTimelineDateNavigator(
            date: details.selectedDate,
            compact: compact,
            onPrevious: onPrevious,
            onNext: onNext,
            onToday: onToday,
          );
          return DecoratedBox(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(theme.header.radius),
              border: Border.all(color: theme.border),
            ),
            child: Padding(
              padding: theme.header.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: navigator),
                      if (!compact && viewControls != null) ...[
                        SizedBox(width: theme.header.controlSpacing),
                        viewControls!,
                      ],
                      if (compact &&
                          (viewControls != null ||
                              filters != null ||
                              secondaryActions != null))
                        UltimateTimelineResponsiveActions(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (viewControls != null) viewControls!,
                              if (filters != null) filters!,
                              if (secondaryActions != null) secondaryActions!,
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (weekStrip != null) ...[
                    const SizedBox(height: 12),
                    weekStrip!,
                  ],
                  if (!compact && (metrics != null || filters != null)) ...[
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        if (metrics != null) Expanded(child: metrics!),
                        if (filters != null) ...[
                          const SizedBox(width: 10),
                          Flexible(child: filters!),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Always-visible primary date and previous/next navigation.
class UltimateTimelineDateNavigator extends StatelessWidget {
  const UltimateTimelineDateNavigator({
    required this.date,
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.compact = false,
    super.key,
  });

  final DateTime date;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UltimateTimelineTheme.of(context);
    final label =
        '${_weekday(date.weekday)}, ${date.day}.${date.month}.${date.year}';
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: onPrevious,
          iconSize: compact ? 20 : 24,
          padding: EdgeInsets.zero,
          visualDensity: compact ? VisualDensity.compact : null,
          constraints: BoxConstraints.tightFor(
            width: compact ? 36 : 48,
            height: compact ? 36 : 48,
          ),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToday,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.text,
                  fontSize: compact ? 14.5 : 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: onNext,
          iconSize: compact ? 20 : 24,
          padding: EdgeInsets.zero,
          visualDensity: compact ? VisualDensity.compact : null,
          constraints: BoxConstraints.tightFor(
            width: compact ? 36 : 48,
            height: compact ? 36 : 48,
          ),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  static String _weekday(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

/// Horizontal week content boundary with safe overflow behavior.
class UltimateTimelineWeekStrip extends StatelessWidget {
  const UltimateTimelineWeekStrip({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

/// Wrap-safe metrics boundary.
class UltimateTimelineMetrics extends StatelessWidget {
  const UltimateTimelineMetrics({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

/// Public view-control boundary.
class UltimateTimelineViewControls extends StatelessWidget {
  const UltimateTimelineViewControls({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }
}

/// Horizontally scrollable filter boundary for narrow devices.
class UltimateTimelineFilterBar extends StatelessWidget {
  const UltimateTimelineFilterBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

/// Moves secondary header controls into a bottom sheet on compact screens.
class UltimateTimelineResponsiveActions extends StatelessWidget {
  const UltimateTimelineResponsiveActions({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'More timeline controls',
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(padding: const EdgeInsets.all(18), child: child),
        ),
      ),
      icon: const Icon(Icons.tune_rounded),
    );
  }
}

class _UltimateDashedBorderPainter extends CustomPainter {
  const _UltimateDashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _UltimateDashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

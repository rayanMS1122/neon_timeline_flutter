import 'dart:async';

import 'package:flutter/material.dart';

import '../../v4/models/timeline_types.dart';
import '../../v7/models/structured_timeline_details.dart';
import '../../v7/models/structured_timeline_style.dart';
import '../../v8/models/advanced_structured_timeline_details.dart';
import '../models/structured_timeline_entry_style.dart';

typedef StructuredTimelineEntryComponentBuilder<T> =
    Widget Function(
      BuildContext context,
      AdvancedStructuredTimelineEntryDetails<T> details,
    );

typedef StructuredTimelineEntryControlBuilder<T> =
    Widget Function(
      BuildContext context,
      AdvancedStructuredTimelineEntryDetails<T> details,
      Widget defaultControl,
    );

class StructuredTimelineEntrySurface extends StatelessWidget {
  const StructuredTimelineEntrySurface({
    required this.child,
    required this.style,
    required this.accentColor,
    this.conflict = false,
    this.selected = false,
    this.focused = false,
    this.busy = false,
    this.radius,
    super.key,
  });

  final Widget child;
  final StructuredTimelineStyle style;
  final Color accentColor;
  final bool conflict;
  final bool selected;
  final bool focused;
  final bool busy;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = radius ?? style.cardRadius;
    final borderColor = conflict
        ? style.conflictColor
        : selected || focused
        ? style.primaryColor
        : accentColor.withValues(alpha: style.cardBorderOpacity);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: style.cardTintOpacity),
          style.cardColor,
        ),
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: borderColor,
          width: focused
              ? 2
              : selected
              ? 1.5
              : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: style.shadowColor.withValues(alpha: selected ? 0.7 : 0.38),
            blurRadius: selected ? 18 : 10,
            offset: Offset(0, selected ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: ColoredBox(
                color: conflict ? style.conflictColor : accentColor,
              ),
            ),
            Positioned.fill(child: child),
            if (busy)
              Positioned(
                right: 12,
                top: 10,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StructuredTimelineEntryHeader extends StatelessWidget {
  const StructuredTimelineEntryHeader({
    required this.timeLabel,
    required this.style,
    this.trailing,
    super.key,
  });

  final String timeLabel;
  final StructuredTimelineStyle style;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            timeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: style.mutedTextColor,
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class StructuredTimelineEntryBody extends StatelessWidget {
  const StructuredTimelineEntryBody({
    required this.title,
    required this.style,
    required this.entryStyle,
    this.subtitle,
    this.completed = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final StructuredTimelineStyle style;
  final StructuredTimelineEntryStyle entryStyle;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: entryStyle.maximumTitleLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: completed ? style.mutedTextColor : style.textColor,
            fontSize: entryStyle.titleSize,
            height: 1.12,
            fontWeight: FontWeight.w900,
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        if (entryStyle.showSubtitle &&
            subtitle != null &&
            subtitle!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: entryStyle.maximumSubtitleLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: style.mutedTextColor,
              fontSize: entryStyle.subtitleSize,
              height: 1.16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class StructuredTimelineEntryFooter extends StatelessWidget {
  const StructuredTimelineEntryFooter({
    required this.style,
    required this.color,
    this.progress,
    this.leading,
    this.trailing,
    super.key,
  });

  final StructuredTimelineStyle style;
  final Color color;
  final double? progress;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final normalized = progress?.clamp(0.0, 1.0).toDouble();
    return Row(
      children: <Widget>[
        if (leading != null) leading!,
        if (leading != null && normalized != null) const SizedBox(width: 8),
        if (normalized != null)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: normalized,
                color: color,
                backgroundColor: color.withValues(alpha: 0.14),
              ),
            ),
          ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class StructuredTimelineEntryCard<T> extends StatelessWidget {
  const StructuredTimelineEntryCard({
    required this.details,
    required this.title,
    required this.timeFormatter,
    required this.durationFormatter,
    this.subtitle,
    this.progress,
    this.entryStyle = const StructuredTimelineEntryStyle.comfortable(),
    this.strings = const StructuredTimelineStrings(),
    this.headerBuilder,
    this.bodyBuilder,
    this.footerBuilder,
    this.completionBuilder,
    this.lockBuilder,
    this.recurringBuilder,
    this.trailing,
    this.footerLeading,
    super.key,
  });

  final AdvancedStructuredTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final double? progress;
  final StructuredTimelineEntryStyle entryStyle;
  final StructuredTimelineStrings strings;
  final StructuredTimelineEntryComponentBuilder<T>? headerBuilder;
  final StructuredTimelineEntryComponentBuilder<T>? bodyBuilder;
  final StructuredTimelineEntryComponentBuilder<T>? footerBuilder;
  final StructuredTimelineEntryControlBuilder<T>? completionBuilder;
  final StructuredTimelineEntryControlBuilder<T>? lockBuilder;
  final StructuredTimelineEntryControlBuilder<T>? recurringBuilder;
  final StructuredTimelineTimeFormatter timeFormatter;
  final StructuredTimelineDurationFormatter durationFormatter;
  final Widget? trailing;
  final Widget? footerLeading;

  @override
  Widget build(BuildContext context) {
    final style = details.style;
    final completed = details.entry.status == TimelineStatus.completed;
    final color = completed
        ? style.completedColor
        : details.entry.color ?? style.accentColor;
    final timeLabel =
        '${timeFormatter(details.effectiveStart)}–'
        '${timeFormatter(details.effectiveEnd)} · '
        '${durationFormatter(details.effectiveDuration)}';

    return Semantics(
      container: true,
      label: '$title, $timeLabel',
      selected: details.selected,
      enabled: details.entry.enabled,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : entryStyle.minimumHeight;
          final textScale = MediaQuery.textScalerOf(
            context,
          ).scale(1).clamp(1.0, 2.0).toDouble();
          final compactThreshold = 78 + (textScale - 1) * 82;
          final compact = height < compactThreshold;
          final showSubtitle =
              !compact && entryStyle.showSubtitle && height >= 88 * textScale;
          final showFooter =
              !compact &&
              height >= 104 * textScale &&
              (entryStyle.showProgress || footerLeading != null);
          final adaptiveStyle = compact
              ? const StructuredTimelineEntryStyle.compact()
              : entryStyle;
          final indicators = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (details.base.isRecurring)
                recurringBuilder?.call(
                      context,
                      details,
                      StructuredTimelineRecurringIndicator(
                        color: style.mutedTextColor,
                      ),
                    ) ??
                    StructuredTimelineRecurringIndicator(
                      color: style.mutedTextColor,
                    ),
              if (details.base.isExternal)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child:
                      lockBuilder?.call(
                        context,
                        details,
                        StructuredTimelineLockIndicator(
                          color: style.mutedTextColor,
                        ),
                      ) ??
                      StructuredTimelineLockIndicator(
                        color: style.mutedTextColor,
                      ),
                ),
              if (!_sameCalendarDay(
                details.effectiveStart,
                details.effectiveEnd,
              ))
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Semantics(
                    label: strings.continuesNextDay,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: style.mutedTextColor,
                    ),
                  ),
                ),
              if (details.onComplete != null && !compact) ...<Widget>[
                const SizedBox(width: 4),
                completionBuilder?.call(
                      context,
                      details,
                      StructuredTimelineCompletionControl(
                        completed: completed,
                        color: color,
                        semanticLabel: completed
                            ? strings.done
                            : strings.completeTask,
                        onPressed: details.busy
                            ? null
                            : () => unawaited(details.onComplete!()),
                      ),
                    ) ??
                    StructuredTimelineCompletionControl(
                      completed: completed,
                      color: color,
                      semanticLabel: completed
                          ? strings.done
                          : strings.completeTask,
                      onPressed: details.busy
                          ? null
                          : () => unawaited(details.onComplete!()),
                    ),
              ],
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          );

          return StructuredTimelineEntrySurface(
            style: style,
            accentColor: color,
            conflict: details.hasConflict,
            selected: details.selected,
            focused: details.focused,
            busy: details.busy,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                adaptiveStyle.horizontalPadding,
                adaptiveStyle.verticalPadding,
                adaptiveStyle.horizontalPadding +
                    (details.busy ? adaptiveStyle.actionAreaWidth : 0),
                adaptiveStyle.verticalPadding,
              ),
              child: compact
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                timeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: style.mutedTextColor,
                                  fontSize: 9.5,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: completed
                                      ? style.mutedTextColor
                                      : style.textColor,
                                  fontSize: adaptiveStyle.titleSize,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (indicators.children.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 6),
                          Flexible(child: indicators),
                        ],
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        headerBuilder?.call(context, details) ??
                            StructuredTimelineEntryHeader(
                              timeLabel: timeLabel,
                              style: style,
                              trailing: indicators,
                            ),
                        const SizedBox(height: 4),
                        bodyBuilder?.call(context, details) ??
                            StructuredTimelineEntryBody(
                              title: title,
                              subtitle: showSubtitle ? subtitle : null,
                              style: style,
                              entryStyle: adaptiveStyle,
                              completed: completed,
                            ),
                        if (showFooter) ...<Widget>[
                          const SizedBox(height: 7),
                          footerBuilder?.call(context, details) ??
                              StructuredTimelineEntryFooter(
                                style: style,
                                color: color,
                                progress: entryStyle.showProgress
                                    ? progress
                                    : null,
                                leading: footerLeading,
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

  static bool _sameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class StructuredTimelineSelectionControl extends StatelessWidget {
  const StructuredTimelineSelectionControl({
    required this.selected,
    required this.color,
    this.onPressed,
    this.semanticLabel = 'Select task',
    super.key,
  });

  final bool selected;
  final Color color;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? color : color.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class StructuredTimelineCompletionControl extends StatelessWidget {
  const StructuredTimelineCompletionControl({
    required this.completed,
    required this.color,
    this.onPressed,
    this.semanticLabel = 'Complete task',
    super.key,
  });

  final bool completed;
  final Color color;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: completed,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          completed ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: color,
        ),
      ),
    );
  }
}

class StructuredTimelineLockIndicator extends StatelessWidget {
  const StructuredTimelineLockIndicator({
    required this.color,
    this.size = 14,
    this.semanticLabel = 'Locked',
    super.key,
  });

  final Color color;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Icon(Icons.lock_outline_rounded, color: color, size: size),
    );
  }
}

class StructuredTimelineRecurringIndicator extends StatelessWidget {
  const StructuredTimelineRecurringIndicator({
    required this.color,
    this.size = 14,
    this.semanticLabel = 'Recurring',
    super.key,
  });

  final Color color;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Icon(Icons.sync_rounded, color: color, size: size),
    );
  }
}

class StructuredTimelineResizeHandle extends StatelessWidget {
  const StructuredTimelineResizeHandle({
    required this.color,
    required this.semanticLabel,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
    this.onIncrease,
    this.onDecrease,
    this.horizontal = true,
    super.key,
  });

  final Color color;
  final String semanticLabel;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final GestureDragCancelCallback? onDragCancel;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: horizontal ? onDragStart : null,
        onVerticalDragUpdate: horizontal ? onDragUpdate : null,
        onVerticalDragEnd: horizontal ? onDragEnd : null,
        onVerticalDragCancel: horizontal ? onDragCancel : null,
        onHorizontalDragStart: horizontal ? null : onDragStart,
        onHorizontalDragUpdate: horizontal ? null : onDragUpdate,
        onHorizontalDragEnd: horizontal ? null : onDragEnd,
        onHorizontalDragCancel: horizontal ? null : onDragCancel,
        child: SizedBox(
          width: horizontal ? double.infinity : 20,
          height: horizontal ? 20 : double.infinity,
          child: Center(
            child: Container(
              width: horizontal ? 42 : 4,
              height: horizontal ? 4 : 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StructuredTimelineDragFeedback<T> extends StatelessWidget {
  const StructuredTimelineDragFeedback({
    required this.child,
    required this.details,
    super.key,
  });

  final Widget child;
  final AdvancedStructuredTimelineEntryDetails<T> details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 12,
      borderRadius: BorderRadius.circular(details.style.cardRadius),
      child: Transform.scale(scale: details.style.dragScale, child: child),
    );
  }
}

class StructuredTimelineDragPlaceholder<T> extends StatelessWidget {
  const StructuredTimelineDragPlaceholder({
    required this.details,
    required this.height,
    super.key,
  });

  final AdvancedStructuredTimelineEntryDetails<T> details;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: details.style.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(details.style.cardRadius),
        border: Border.all(
          color: details.style.primaryColor.withValues(alpha: 0.36),
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

class StructuredTimelineDragLayer<T> extends StatelessWidget {
  const StructuredTimelineDragLayer({
    required this.child,
    this.overlay,
    this.active = false,
    super.key,
  });

  final Widget child;
  final Widget? overlay;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        if (active && overlay != null) Positioned.fill(child: overlay!),
      ],
    );
  }
}

class StructuredTimelineDropTarget<T> extends StatelessWidget {
  const StructuredTimelineDropTarget({
    required this.child,
    required this.active,
    required this.color,
    this.semanticLabel = 'Drop task here',
    super.key,
  });

  final Widget child;
  final bool active;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: AnimatedContainer(
        duration: MediaQuery.maybeOf(context)?.disableAnimations == true
            ? Duration.zero
            : const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : Colors.transparent,
            width: 2,
          ),
          color: active ? color.withValues(alpha: 0.06) : Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}

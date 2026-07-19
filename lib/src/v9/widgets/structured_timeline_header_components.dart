import 'package:flutter/material.dart';

import '../../v7/models/structured_timeline_style.dart';
import '../models/structured_timeline_component_details.dart';
import '../models/structured_timeline_zoom.dart';

class StructuredTimelineAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const StructuredTimelineAppBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.backgroundColor,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      backgroundColor: backgroundColor,
      titleSpacing: leading == null ? 20 : 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
      actions: actions,
    );
  }
}

class StructuredTimelineDateNavigator extends StatelessWidget {
  const StructuredTimelineDateNavigator({
    required this.date,
    required this.style,
    this.onPrevious,
    this.onNext,
    this.onDateTap,
    this.dateFormatter,
    super.key,
  });

  final DateTime date;
  final StructuredTimelineStyle style;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onDateTap;
  final String Function(DateTime value)? dateFormatter;

  @override
  Widget build(BuildContext context) {
    final label =
        dateFormatter?.call(date) ?? '${date.day}.${date.month}.${date.year}';
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Previous day',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class StructuredTimelineWeekStrip extends StatelessWidget {
  const StructuredTimelineWeekStrip({
    required this.selectedDate,
    required this.style,
    this.onSelect,
    this.firstDayOfWeek = DateTime.monday,
    super.key,
  });

  final DateTime selectedDate;
  final StructuredTimelineStyle style;
  final ValueChanged<DateTime>? onSelect;
  final int firstDayOfWeek;

  @override
  Widget build(BuildContext context) {
    final offset = (selectedDate.weekday - firstDayOfWeek) % 7;
    final first = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - offset,
    );
    const labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 58,
      child: Row(
        children: <Widget>[
          for (var index = 0; index < 7; index++)
            Expanded(
              child: _WeekDayButton(
                date: DateTime(first.year, first.month, first.day + index),
                label: labels[index],
                selectedDate: selectedDate,
                style: style,
                onSelect: onSelect,
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekDayButton extends StatelessWidget {
  const _WeekDayButton({
    required this.date,
    required this.label,
    required this.selectedDate,
    required this.style,
    required this.onSelect,
  });

  final DateTime date;
  final String label;
  final DateTime selectedDate;
  final StructuredTimelineStyle style;
  final ValueChanged<DateTime>? onSelect;

  @override
  Widget build(BuildContext context) {
    final selected =
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label ${date.day}',
      child: InkWell(
        onTap: onSelect == null ? null : () => onSelect!(date),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: MediaQuery.maybeOf(context)?.disableAnimations == true
              ? Duration.zero
              : const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            color: selected
                ? style.primaryColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: style.mutedTextColor, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: TextStyle(
                  color: selected ? style.primaryColor : style.textColor,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StructuredTimelineMetricsBar extends StatelessWidget {
  const StructuredTimelineMetricsBar({
    required this.metrics,
    required this.style,
    this.showUtilization = false,
    super.key,
  });

  final StructuredTimelineMetrics metrics;
  final StructuredTimelineStyle style;
  final bool showUtilization;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _MetricChip(label: 'Entries', value: '${metrics.entries}', style: style),
      _MetricChip(label: 'Busy', value: _duration(metrics.busy), style: style),
      _MetricChip(label: 'Free', value: _duration(metrics.free), style: style),
      _MetricChip(
        label: 'Conflicts',
        value: '${metrics.conflicts}',
        style: style,
      ),
      if (showUtilization)
        _MetricChip(
          label: 'Utilization',
          value: '${(metrics.utilization * 100).round()}%',
          style: style,
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < chips.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }

  static String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final StructuredTimelineStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: style.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.borderColor),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: style.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class StructuredTimelineViewControls extends StatelessWidget {
  const StructuredTimelineViewControls({
    required this.zoomLevel,
    this.onZoomOut,
    this.onZoomIn,
    this.onResetZoom,
    this.additionalActions = const <Widget>[],
    super.key,
  });

  final StructuredTimelineZoomLevel zoomLevel;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;
  final VoidCallback? onResetZoom;
  final List<Widget> additionalActions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        IconButton(
          tooltip: 'Zoom out',
          onPressed: onZoomOut,
          icon: const Icon(Icons.zoom_out_rounded),
        ),
        TextButton(onPressed: onResetZoom, child: Text(zoomLevel.name)),
        IconButton(
          tooltip: 'Zoom in',
          onPressed: onZoomIn,
          icon: const Icon(Icons.zoom_in_rounded),
        ),
        ...additionalActions,
      ],
    );
  }
}

class StructuredTimelineFilterBar extends StatelessWidget {
  const StructuredTimelineFilterBar({
    required this.controller,
    this.hintText = 'Filter tasks',
    this.onChanged,
    this.trailing = const <Widget>[],
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        ...trailing,
      ],
    );
  }
}

class StructuredTimelineDayHeader extends StatelessWidget {
  const StructuredTimelineDayHeader({
    required this.date,
    required this.style,
    this.metrics,
    this.onPrevious,
    this.onNext,
    this.onSelectDate,
    this.onSelectWeekDay,
    this.controls,
    this.showWeekStrip = true,
    this.showMetrics = true,
    super.key,
  });

  final DateTime date;
  final StructuredTimelineStyle style;
  final StructuredTimelineMetrics? metrics;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSelectDate;
  final ValueChanged<DateTime>? onSelectWeekDay;
  final Widget? controls;
  final bool showWeekStrip;
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.surfaceColor,
        border: Border(bottom: BorderSide(color: style.borderColor)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StructuredTimelineDateNavigator(
                date: date,
                style: style,
                onPrevious: onPrevious,
                onNext: onNext,
                onDateTap: onSelectDate,
              ),
              if (showWeekStrip)
                StructuredTimelineWeekStrip(
                  selectedDate: date,
                  style: style,
                  onSelect: onSelectWeekDay,
                ),
              if (showMetrics && metrics != null)
                StructuredTimelineMetricsBar(metrics: metrics!, style: style),
              if (controls != null) ...<Widget>[
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: controls!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

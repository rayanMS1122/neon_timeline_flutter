part of 'day_timeline_view.dart';

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.label,
    required this.theme,
    required this.onBack,
    required this.onCalendarTap,
    required this.onMoreTap,
    required this.layout,
  });

  final String label;
  final NeonPlannerTimelineThemeData theme;
  final VoidCallback? onBack;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onMoreTap;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final spacing = layout.isRegular ? 12.0 : layout.isCompact ? 2.0 : 0.0;
    return Row(
      children: <Widget>[
        _HeaderButton(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Zurück',
          onTap: onBack,
          theme: theme,
          size: layout.headerButtonSize,
          compact: !layout.isRegular,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleStyle.copyWith(
                    fontSize: layout.headerTitleFontSize,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(width: layout.isRegular ? 4 : 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: layout.isRegular ? 22 : 14,
                color: theme.primaryTextColor,
              ),
            ],
          ),
        ),
        SizedBox(width: spacing),
        _HeaderButton(
          icon: Icons.calendar_today_outlined,
          tooltip: 'Kalender öffnen',
          onTap: onCalendarTap,
          theme: theme,
          size: layout.headerButtonSize,
          compact: !layout.isRegular,
        ),
        SizedBox(width: layout.isRegular ? 8 : 2),
        _HeaderButton(
          icon: Icons.more_horiz_rounded,
          tooltip: 'Weitere Aktionen',
          onTap: onMoreTap,
          theme: theme,
          size: layout.headerButtonSize,
          compact: !layout.isRegular,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.theme,
    required this.size,
    required this.compact,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final NeonPlannerTimelineThemeData theme;
  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visualSize = compact ? size - 12 : size;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: size / 2,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.gridColor),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.shadowColor.withValues(
                        alpha: compact ? 0.18 : 1,
                      ),
                      blurRadius: compact ? 2 : 12,
                      offset: Offset(0, compact ? 1 : 5),
                    ),
                  ],
                ),
                child: SizedBox.square(
                  dimension: visualSize,
                  child: Icon(
                    icon,
                    size: compact ? 15 : 22,
                    color: theme.primaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsStrip extends StatelessWidget {
  const _MetricsStrip({
    required this.metrics,
    required this.theme,
    required this.layout,
  });

  final List<NeonPlannerDayMetric> metrics;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: theme.surfaceColor.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(layout.isRegular ? 26 : 12),
      border: Border.all(color: theme.gridColor.withValues(alpha: 0.95)),
    );

    if (layout.isRegular) {
      return DecoratedBox(
        decoration: decoration,
        child: SizedBox(
          height: layout.metricsHeight,
          child: Row(
            children: <Widget>[
              for (
                var index = 0;
                index < metrics.length;
                index += 1
              ) ...<Widget>[
                Expanded(
                  child: _MetricItem(
                    metric: metrics[index],
                    theme: theme,
                    layout: layout,
                  ),
                ),
                if (index < metrics.length - 1)
                  SizedBox(
                    height: 62,
                    child: VerticalDivider(color: theme.gridColor, width: 1),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    if (metrics.length <= 3) {
      return DecoratedBox(
        decoration: decoration,
        child: SizedBox(
          height: layout.metricsHeight,
          child: Row(
            children: <Widget>[
              for (
                var index = 0;
                index < metrics.length;
                index += 1
              ) ...<Widget>[
                Expanded(
                  child: _MetricItem(
                    metric: metrics[index],
                    theme: theme,
                    layout: layout,
                  ),
                ),
                if (index < metrics.length - 1)
                  SizedBox(
                    height: layout.metricsHeight - 14,
                    child: VerticalDivider(color: theme.gridColor, width: 1),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox(
        height: layout.metricsHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: metrics.length,
          separatorBuilder: (context, index) =>
              VerticalDivider(color: theme.gridColor, width: 1),
          itemBuilder: (context, index) => SizedBox(
            width: layout.isMicro ? 72 : 84,
            child: _MetricItem(
              metric: metrics[index],
              theme: theme,
              layout: layout,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.metric,
    required this.theme,
    required this.layout,
  });

  final NeonPlannerDayMetric metric;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;

  @override
  Widget build(BuildContext context) {
    final color = metric.color ?? theme.focusColor;
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    if (!layout.isRegular) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.isMicro ? 1 : 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!largeText) ...<Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: layout.isMicro ? 18 : 20,
                  child: Icon(
                    metric.icon,
                    color: color,
                    size: layout.isMicro ? 10 : 11,
                  ),
                ),
              ),
              const SizedBox(height: 1),
            ],
            Text(
              metric.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.titleStyle.copyWith(
                fontSize: layout.isMicro ? 12 : 13,
                height: 1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.metadataStyle.copyWith(
                fontSize: layout.isMicro ? 8.5 : 9,
                height: 1,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 52,
              child: Icon(metric.icon, color: color, size: 26),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.metadataStyle.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleStyle.copyWith(fontSize: 20),
                ),
                Text(
                  metric.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.metadataStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

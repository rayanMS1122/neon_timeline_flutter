import 'package:flutter/material.dart';

import '../models/friendly_timeline_ui_models.dart';
import '../theme/friendly_timeline_ui_theme.dart';

/// Horizontally scrollable version 14 metric row.
class FriendlyTimelineMetricStrip extends StatelessWidget {
  const FriendlyTimelineMetricStrip({required this.metrics, super.key});

  final List<FriendlyTimelineMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            FriendlyTimelineMetricCard(metric: metrics[index]),
            if (index != metrics.length - 1)
              SizedBox(width: theme.sectionGap),
          ],
        ],
      ),
    );
  }
}

/// Friendly metric card with an icon tile and optional progress.
class FriendlyTimelineMetricCard extends StatelessWidget {
  const FriendlyTimelineMetricCard({required this.metric, super.key});

  final FriendlyTimelineMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    final foreground = theme.foregroundFor(metric.tone);
    return Semantics(
      label: metric.semanticLabel ?? '${metric.label}, ${metric.value}',
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.panelStrong,
          borderRadius: BorderRadius.circular(theme.cardRadius),
          border: Border.all(color: theme.outline),
          boxShadow: [
            BoxShadow(
              color: theme.shadow,
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.backgroundFor(metric.tone),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(metric.icon, color: foreground, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (metric.progress != null) ...[
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: metric.progress,
                        backgroundColor: theme.outline,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop icon navigation dock.

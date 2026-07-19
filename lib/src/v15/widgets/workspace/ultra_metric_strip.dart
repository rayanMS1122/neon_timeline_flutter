import 'package:flutter/material.dart';

import '../../presentation/ultra_timeline_presentation.dart';
import '../../theme/ultra_timeline_theme.dart';

class UltraMetricStrip extends StatelessWidget {
  const UltraMetricStrip({required this.metrics, super.key});

  final List<UltraTimelineMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    final theme = UltraTimelineTheme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble();
    return SizedBox(
      height: 56 + (textScale - 1) * 20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final tone = theme.tone(metric.tone);
          return Container(
            constraints: const BoxConstraints(minWidth: 130),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(metric.icon, color: tone, size: 17),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.value,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: theme.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      metric.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: theme.mutedText,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

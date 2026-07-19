import 'package:flutter/material.dart';

import '../../api/ultra_timeline_config.dart';
import '../../api/ultra_timeline_controller.dart';
import '../../theme/ultra_timeline_theme.dart';

/// Continuous zoom control with semantic density thresholds.
class UltraZoomSlider extends StatelessWidget {
  const UltraZoomSlider({
    required this.controller,
    this.compact = false,
    super.key,
  });

  final UltraTimelineController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Semantics(
      container: true,
      label: 'Timeline zoom',
      child: ValueListenableBuilder<double>(
        valueListenable: controller.zoomPosition,
        builder: (context, value, _) {
          return Container(
            constraints: BoxConstraints(minHeight: compact ? 46 : 52),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Zoom out',
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.zoomOut,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: compact ? 112 : 170,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.outline,
                      thumbColor: theme.primary,
                      overlayColor: theme.primary.withValues(alpha: 0.10),
                      valueIndicatorColor: theme.panelStrong,
                      valueIndicatorTextStyle: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: 1,
                      divisions: null,
                      label: controller.zoomLevel.value.label,
                      semanticFormatterCallback: (_) =>
                          '${controller.zoomLevel.value.label} zoom',
                      onChanged: controller.setZoomPosition,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Zoom in',
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.zoomIn,
                  icon: const Icon(Icons.add_rounded),
                ),
                if (!compact)
                  ValueListenableBuilder<UltraTimelineZoomLevel>(
                    valueListenable: controller.zoomLevel,
                    builder: (context, level, _) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Text(
                        level.label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: theme.mutedText,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../api/ultra_timeline_config.dart';
import '../../api/ultra_timeline_controller.dart';
import '../../theme/ultra_timeline_theme.dart';
import '../controls/ultra_snap_slider.dart';
import '../controls/ultra_zoom_slider.dart';

class UltraControlDock extends StatelessWidget {
  const UltraControlDock({
    required this.controller,
    required this.config,
    this.compact = false,
    this.onNow,
    this.onFit,
    super.key,
  });

  final UltraTimelineController controller;
  final UltraTimelineConfig config;
  final bool compact;
  final VoidCallback? onNow;
  final VoidCallback? onFit;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.panel.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.outline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onNow != null)
              IconButton(
                tooltip: 'Jump to now',
                onPressed: onNow,
                icon: Icon(Icons.my_location_rounded, color: theme.sky),
              ),
            if (onFit != null)
              IconButton(
                tooltip: 'Fit day',
                onPressed: onFit,
                icon: Icon(Icons.fit_screen_rounded, color: theme.mint),
              ),
            if (config.showZoomControl)
              UltraZoomSlider(controller: controller, compact: compact),
            if (config.showSnapControl) ...[
              const SizedBox(width: 6),
              UltraSnapSlider(controller: controller, compact: compact),
            ],
          ],
        ),
      ),
    );
  }
}

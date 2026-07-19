import 'package:flutter/material.dart';

import '../../api/ultra_timeline_controller.dart';
import '../../interaction/snap/ultra_magnetic_snap_engine.dart';
import '../../theme/ultra_timeline_theme.dart';

class UltraSnapSlider extends StatelessWidget {
  const UltraSnapSlider({
    required this.controller,
    this.compact = false,
    super.key,
  });

  final UltraTimelineController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return ValueListenableBuilder<double>(
      valueListenable: controller.snapPosition,
      builder: (context, value, _) {
        return Container(
          constraints: BoxConstraints(minHeight: compact ? 46 : 52),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.panel,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: theme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_fix_high_rounded, color: theme.violet, size: 20),
              const SizedBox(width: 4),
              SizedBox(
                width: compact ? 92 : 128,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: theme.violet,
                    inactiveTrackColor: theme.outline,
                    thumbColor: theme.violet,
                    overlayColor: theme.violet.withValues(alpha: 0.10),
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 1,
                    divisions: UltraTimelineSnapStrength.values.length - 1,
                    label: _label(controller.snapStrength.value),
                    semanticFormatterCallback: (_) =>
                        '${_label(controller.snapStrength.value)} snapping',
                    onChanged: controller.setSnapPosition,
                  ),
                ),
              ),
              if (!compact)
                ValueListenableBuilder<UltraTimelineSnapStrength>(
                  valueListenable: controller.snapStrength,
                  builder: (context, strength, _) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Text(
                      _label(strength),
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
    );
  }

  static String _label(UltraTimelineSnapStrength value) {
    return switch (value) {
      UltraTimelineSnapStrength.off => 'Off',
      UltraTimelineSnapStrength.soft => 'Soft',
      UltraTimelineSnapStrength.balanced => 'Balanced',
      UltraTimelineSnapStrength.strong => 'Strong',
    };
  }
}

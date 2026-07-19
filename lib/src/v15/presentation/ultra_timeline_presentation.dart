import 'package:flutter/material.dart';

import '../../v12/models/ultimate_timeline_details.dart';

/// Color intent for v15 entry cards and icon tiles.
enum UltraTimelineTone { primary, violet, mint, coral, amber, sky, neutral }

/// Stable presentation model consumed by v15 entry widgets.
@immutable
class UltraTimelineEntryPresentation<T> {
  const UltraTimelineEntryPresentation({
    required this.details,
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.tone,
    this.subtitle,
    this.progress,
    this.badges = const <String>[],
    this.semanticLabel,
  });

  final UltimateTimelineEntryDetails<T> details;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final IconData icon;
  final UltraTimelineTone tone;
  final double? progress;
  final List<String> badges;
  final String? semanticLabel;
}

typedef UltraTimelineEntryPresentationBuilder<T> =
    UltraTimelineEntryPresentation<T> Function(
      BuildContext context,
      UltimateTimelineEntryDetails<T> details,
    );

/// Compact metric displayed above the timeline canvas.
@immutable
class UltraTimelineMetric {
  const UltraTimelineMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = UltraTimelineTone.neutral,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final UltraTimelineTone tone;
  final double? progress;
}

/// Host-defined command surfaced in the v15 command island.
@immutable
class UltraTimelineAction {
  const UltraTimelineAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tone = UltraTimelineTone.neutral,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final UltraTimelineTone tone;
}

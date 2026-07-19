import 'package:flutter/material.dart';

/// Persistence and collaboration state rendered by the workspace status pill.
enum AdvancedTimelineWorkspaceStatus {
  ready,
  saving,
  saved,
  offline,
  warning,
  failed,
}

/// A small, model-independent metric displayed above the timeline.
@immutable
class AdvancedTimelineMetric {
  const AdvancedTimelineMetric({
    required this.label,
    required this.value,
    this.icon,
    this.progress,
    this.semanticLabel,
    this.emphasized = false,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final String label;
  final String value;
  final IconData? icon;
  final double? progress;
  final String? semanticLabel;
  final bool emphasized;
}

/// Public destination used by the desktop and mobile navigation widgets.
@immutable
class AdvancedTimelineNavigationItem {
  const AdvancedTimelineNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
}

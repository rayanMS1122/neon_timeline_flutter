import 'package:flutter/material.dart';

/// Friendly semantic color families used by version 14 icon surfaces.
enum FriendlyTimelineIconTone {
  primary,
  lavender,
  mint,
  coral,
  amber,
  sky,
  neutral,
}

/// Persistence and collaboration state rendered by the v14 workspace.
enum FriendlyTimelineWorkspaceStatus {
  ready,
  saving,
  saved,
  offline,
  warning,
  failed,
}

/// Visual treatment used while an entry is being moved.
enum FriendlyTimelineDragPresentation {
  /// A lifted entry with a compact live status capsule.
  floatingCard,

  /// A softer card with an obvious grab affordance and destination ribbon.
  guided,

  /// A low-motion, high-contrast presentation.
  accessible,
}

/// One destination in the friendly desktop or mobile navigation.
@immutable
class FriendlyTimelineNavigationItem {
  const FriendlyTimelineNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.tone = FriendlyTimelineIconTone.primary,
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
  final FriendlyTimelineIconTone tone;
  final String? semanticLabel;
}

/// A compact, model-independent metric displayed above the planner.
@immutable
class FriendlyTimelineMetric {
  const FriendlyTimelineMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.progress,
    this.tone = FriendlyTimelineIconTone.primary,
    this.semanticLabel,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final String label;
  final String value;
  final IconData icon;
  final double? progress;
  final FriendlyTimelineIconTone tone;
  final String? semanticLabel;
}

/// Optional quick action rendered in the v14 command bar.
@immutable
class FriendlyTimelineAction {
  const FriendlyTimelineAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.tone = FriendlyTimelineIconTone.neutral,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final FriendlyTimelineIconTone tone;
  final bool emphasized;
}

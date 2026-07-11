import 'package:flutter/widgets.dart';

import '../theme/neon_timeline_styles.dart';
import 'neon_timeline_types.dart';

/// Declarative item used by the default `NeonTimeline` constructor.
@immutable
class NeonTimelineItem {
  /// Creates a timeline item.
  const NeonTimelineItem({
    required this.content,
    this.id,
    this.oppositeContent,
    this.indicator,
    this.status = NeonTimelineStatus.pending,
    this.semanticLabel,
    this.onTap,
    this.connectorStyle,
  });

  /// Stable identity used for the tile key.
  final Object? id;

  /// Primary item content.
  final Widget content;

  /// Optional content on the other side of a centered rail.
  final Widget? oppositeContent;

  /// Optional custom marker.
  final Widget? indicator;

  /// Item state used by default marker and connector styling.
  final NeonTimelineStatus status;

  /// Optional screen-reader description.
  final String? semanticLabel;

  /// Optional activation callback.
  final VoidCallback? onTap;

  /// Optional connector override for this item.
  final NeonTimelineConnectorStyle? connectorStyle;
}

/// Resolves connector styling for an indexed timeline item.
typedef NeonTimelineConnectorStyleBuilder = NeonTimelineConnectorStyle Function(
  BuildContext context,
  NeonTimelineItemDetails details,
);

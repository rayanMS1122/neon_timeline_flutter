import 'package:flutter/widgets.dart';

/// Visual and semantic state of one timeline item.
enum NeonTimelineStatus {
  /// The item has not started yet.
  pending,

  /// The item is currently active.
  active,

  /// The item has completed successfully.
  completed,

  /// The item needs attention or failed.
  error,

  /// The item cannot currently be interacted with.
  disabled,
}

/// Placement strategy for the rail and the two content areas.
enum NeonTimelineLayout {
  /// Put the rail at the logical start edge and all content after it.
  start,

  /// Put the rail between opposite and primary content.
  center,

  /// Put the rail at the logical end edge and all content before it.
  end,

  /// Alternate primary content around a centered rail.
  alternating,

  /// Use [center] when wide and [start] below the adaptive breakpoint.
  adaptive,
}

/// Shape used by timeline indicators.
enum NeonIndicatorShape {
  /// A circular indicator.
  circle,

  /// A rounded square indicator.
  square,

  /// A square rotated by 45 degrees.
  diamond,
}

/// Rendering depth used by timeline indicators.
enum NeonIndicatorEffect {
  /// Lightweight Material decoration with one soft glow.
  classic,

  /// Layered glass, inner reflections, and a spectral rim.
  glass,

  /// Cinematic glass plus energy rays, caustics, and orbit particles.
  stellar,

  /// Maximum-depth renderer with counter-rotating coronae and interference.
  quantum,

  /// Event-horizon renderer with accretion rings, magnetic arcs, and lensing.
  singularity,

  /// Segmented transparent renderer with scanlines and digital diffraction.
  hologram,

  /// Ultra-depth neural core with vector-field arcs, shockwaves, and lattice nodes.
  neuralCore,
}

/// Rendering depth used by timeline connectors.
enum NeonConnectorEffect {
  /// A lightweight static connector.
  classic,

  /// A layered beam with a bright core and optional moving energy.
  energy,

  /// A turbulent spectral beam with multiple synchronized energy trails.
  plasma,

  /// Braided, refractive beam with warp packets and transverse lens flares.
  warp,

  /// Segmented data rail with scanlines, ticks, and moving packets.
  hologram,

  /// Multi-strand photon lattice with cross-links, persistent trails, and packets.
  photonLattice,
}

/// Rendering budget used by advanced painters.
///
/// The quality setting never changes layout or semantics. It only controls
/// vector sample counts and micro-detail density.
enum NeonTimelineRenderQuality {
  /// Reduced sample counts for dense timelines and lower-power devices.
  balanced,

  /// Higher fidelity suitable for most desktop and modern mobile devices.
  high,

  /// Maximum vector detail for hero timelines and showcase screens.
  ultra,
}

/// Rendering strategy for a connector segment.
enum NeonConnectorVariant {
  /// A continuous single-color line.
  solid,

  /// A repeated dash and gap pattern.
  dashed,

  /// A continuous line interpolating between two colors.
  gradient,
}

/// Immutable context passed to indexed timeline builders.
@immutable
class NeonTimelineItemDetails {
  /// Creates builder details for one item.
  const NeonTimelineItemDetails({
    required this.index,
    required this.itemCount,
    required this.axis,
    required this.layout,
    required this.textDirection,
    required this.status,
    this.previousStatus,
    this.nextStatus,
  });

  /// Zero-based item index.
  final int index;

  /// Total item count.
  final int itemCount;

  /// Main timeline axis.
  final Axis axis;

  /// Requested layout before responsive resolution.
  final NeonTimelineLayout layout;

  /// Ambient text direction used to resolve logical start and end.
  final TextDirection textDirection;

  /// State of the current item.
  final NeonTimelineStatus status;

  /// State of the preceding item, or `null` for the first item.
  final NeonTimelineStatus? previousStatus;

  /// State of the following item, or `null` for the last item.
  final NeonTimelineStatus? nextStatus;

  /// Whether this is the first item.
  bool get isFirst => index == 0;

  /// Whether this is the last item.
  bool get isLast => index == itemCount - 1;

  /// Whether [index] is even.
  bool get isEven => index.isEven;
}

/// Builds content for a specific timeline item.
typedef NeonTimelineContentBuilder = Widget Function(
  BuildContext context,
  NeonTimelineItemDetails details,
);

/// Resolves the state of an indexed timeline item.
typedef NeonTimelineStatusBuilder = NeonTimelineStatus Function(int index);

/// Builds an optional semantic description for an item.
typedef NeonTimelineSemanticLabelBuilder = String? Function(
  BuildContext context,
  NeonTimelineItemDetails details,
);

/// Handles activation of an indexed item.
typedef NeonTimelineItemCallback = void Function(
  BuildContext context,
  NeonTimelineItemDetails details,
);

/// Resolves a stable key for an indexed item.
typedef NeonTimelineKeyBuilder = Key? Function(
  BuildContext context,
  NeonTimelineItemDetails details,
);

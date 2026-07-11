import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/neon_timeline_types.dart';
import 'neon_timeline_styles.dart';

export 'neon_timeline_styles.dart';

/// Theme data for all `neon_timeline_flutter` widgets.
///
/// Add it to `ThemeData.extensions`, or apply it locally with
/// [NeonTimelineTheme].
@immutable
class NeonTimelineThemeData extends ThemeExtension<NeonTimelineThemeData> {
  /// Creates a neon timeline theme.
  const NeonTimelineThemeData({
    this.primaryColor = const Color(0xFF8B7CFF),
    this.secondaryColor = const Color(0xFFFF7BAE),
    this.surfaceColor = const Color(0xFF12101D),
    this.textColor = const Color(0xFFF8F6FF),
    this.mutedColor = const Color(0xFF77718F),
    this.completedColor = const Color(0xFF29D391),
    this.errorColor = const Color(0xFFFF5D75),
    this.disabledColor = const Color(0xFF5A5668),
    this.indicatorStyle = const NeonTimelineIndicatorStyle(),
    this.connectorStyle = const NeonTimelineConnectorStyle(),
    this.tilePadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    this.contentGap = 14,
    this.nodeLaneExtent = 42,
    this.verticalMinExtent = 104,
    this.horizontalItemExtent = 260,
    this.adaptiveBreakpoint = 520,
    this.animationDuration = const Duration(milliseconds: 360),
    this.animationCurve = Curves.easeOutCubic,
    this.motionDuration = const Duration(milliseconds: 4200),
  })  : assert(contentGap >= 0),
        assert(nodeLaneExtent > 0),
        assert(verticalMinExtent > 0),
        assert(horizontalItemExtent > 0),
        assert(adaptiveBreakpoint >= 0);

  /// High-emphasis accent and active-state color.
  final Color primaryColor;

  /// Secondary accent used in gradients.
  final Color secondaryColor;

  /// Default card surface.
  final Color surfaceColor;

  /// Default high-emphasis text color.
  final Color textColor;

  /// Pending and low-emphasis color.
  final Color mutedColor;

  /// Backwards-compatible alias for the pending-state color.
  Color get pendingColor => mutedColor;

  /// Completed-state color.
  final Color completedColor;

  /// Error-state color.
  final Color errorColor;

  /// Disabled-state color.
  final Color disabledColor;

  /// Default indicator styling.
  final NeonTimelineIndicatorStyle indicatorStyle;

  /// Default connector styling.
  final NeonTimelineConnectorStyle connectorStyle;

  /// Insets around each tile.
  final EdgeInsets tilePadding;

  /// Logical gap between the rail and content.
  final double contentGap;

  /// Cross-axis space reserved for the rail and marker.
  final double nodeLaneExtent;

  /// Minimum height of vertical entries.
  final double verticalMinExtent;

  /// Default width of horizontal entries.
  final double horizontalItemExtent;

  /// Width below which adaptive layouts become one-sided.
  final double adaptiveBreakpoint;

  /// Default reveal and pulse transition duration.
  final Duration animationDuration;

  /// Default transition curve.
  final Curve animationCurve;

  /// Shared normalized cycle used to synchronize advanced visual effects.
  final Duration motionDuration;

  /// Dark neon preset.
  factory NeonTimelineThemeData.neon() => const NeonTimelineThemeData();

  /// Cinematic spectral preset based on layered glass and energy rendering.
  ///
  /// This preset keeps the same timeline layout and data API. It only increases
  /// the rendering depth of markers and active connector segments.
  factory NeonTimelineThemeData.spectral() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFFFF6DBB),
      secondaryColor: Color(0xFF8D72FF),
      surfaceColor: Color(0xFF100E1B),
      textColor: Color(0xFFFFF8FE),
      mutedColor: Color(0xFF746D8C),
      completedColor: Color(0xFF49D9A5),
      errorColor: Color(0xFFFF5F7F),
      disabledColor: Color(0xFF4D495C),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 54,
        color: Color(0xFFFF6DBB),
        borderColor: Color(0xFFFFE0C0),
        glowColor: Color(0xFFFF4EAA),
        secondaryColor: Color(0xFFFFA36E),
        tertiaryColor: Color(0xFF8D72FF),
        interiorColor: Color(0xFF15111F),
        borderWidth: 1.35,
        glowRadius: 18,
        effect: NeonIndicatorEffect.stellar,
        intensity: 1.08,
        detail: 1,
        rayLength: 0.92,
        particleCount: 7,
        rotationSpeed: 0.9,
        corona: 0.72,
        depth: 0.82,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        variant: NeonConnectorVariant.gradient,
        color: Color(0xFFFF86CF),
        endColor: Color(0xFF7868ED),
        secondaryColor: Color(0xFFFFA36E),
        coreColor: Color(0xFFFFFFFF),
        thickness: 2.1,
        glowRadius: 9,
        effect: NeonConnectorEffect.energy,
        animated: true,
        animationDuration: Duration(milliseconds: 3800),
        intensity: 1.05,
        detail: 0.9,
        flowSpeed: 1,
        particleCount: 6,
        turbulence: 0.38,
        trailCount: 2,
      ),
      tilePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      contentGap: 18,
      nodeLaneExtent: 92,
      verticalMinExtent: 132,
      horizontalItemExtent: 300,
      animationDuration: Duration(milliseconds: 520),
      animationCurve: Curves.easeOutCubic,
      motionDuration: Duration(milliseconds: 4200),
    );
  }

  /// Maximum-depth quantum preset with synchronized corona and plasma.
  ///
  /// It keeps the existing timeline structure and only changes rendering.
  factory NeonTimelineThemeData.quantum() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFFFF5FC8),
      secondaryColor: Color(0xFF66D9FF),
      surfaceColor: Color(0xFF090A14),
      textColor: Color(0xFFFFFAFF),
      mutedColor: Color(0xFF66617D),
      completedColor: Color(0xFF4DE2AD),
      errorColor: Color(0xFFFF587A),
      disabledColor: Color(0xFF474453),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 58,
        color: Color(0xFFFF62C8),
        borderColor: Color(0xFFFFFFFF),
        glowColor: Color(0xFFFF3FAA),
        secondaryColor: Color(0xFFFFB15E),
        tertiaryColor: Color(0xFF64DFFF),
        interiorColor: Color(0xFF0E1020),
        borderWidth: 1.45,
        glowRadius: 21,
        effect: NeonIndicatorEffect.quantum,
        intensity: 1.18,
        detail: 1,
        rayLength: 1.08,
        particleCount: 10,
        rotationSpeed: 1.28,
        corona: 1,
        depth: 0.92,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        variant: NeonConnectorVariant.gradient,
        color: Color(0xFFFF6EC9),
        endColor: Color(0xFF6578FF),
        secondaryColor: Color(0xFF66D9FF),
        coreColor: Color(0xFFFFFFFF),
        thickness: 2.25,
        glowRadius: 11,
        effect: NeonConnectorEffect.plasma,
        animated: true,
        animationDuration: Duration(milliseconds: 4200),
        intensity: 1.16,
        detail: 1,
        flowSpeed: 1.08,
        particleCount: 9,
        turbulence: 0.72,
        trailCount: 3,
      ),
      tilePadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      contentGap: 19,
      nodeLaneExtent: 112,
      verticalMinExtent: 146,
      horizontalItemExtent: 312,
      animationDuration: Duration(milliseconds: 560),
      animationCurve: Curves.easeOutCubic,
      motionDuration: Duration(milliseconds: 4200),
    );
  }

  /// Maximum-depth singularity preset with a braided warp rail.
  ///
  /// This is the most expensive built-in renderer. It keeps the existing
  /// timeline API and layout, but adds pointer parallax, magnetic corona arcs,
  /// event-horizon lensing, refractive strands, packets, and cross flares.
  factory NeonTimelineThemeData.hyperion() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFFFF4FC4),
      secondaryColor: Color(0xFF5BE7FF),
      surfaceColor: Color(0xFF080812),
      textColor: Color(0xFFFFFBFF),
      mutedColor: Color(0xFF625E78),
      completedColor: Color(0xFF55E7AE),
      errorColor: Color(0xFFFF4F72),
      disabledColor: Color(0xFF45424F),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 64,
        color: Color(0xFFFF5ACA),
        borderColor: Color(0xFFFFFFFF),
        glowColor: Color(0xFFFF28A9),
        secondaryColor: Color(0xFFFFB45D),
        tertiaryColor: Color(0xFF5DE5FF),
        interiorColor: Color(0xFF070914),
        borderWidth: 1.55,
        glowRadius: 24,
        effect: NeonIndicatorEffect.singularity,
        intensity: 1.28,
        detail: 1,
        rayLength: 1.18,
        particleCount: 14,
        rotationSpeed: 1.34,
        corona: 1,
        depth: 1,
        chromaticAberration: 1.1,
        refraction: 0.96,
        scanlineOpacity: 0.13,
        arcCount: 9,
        sparkCount: 16,
        noise: 0.5,
        parallax: 0.92,
        eventHorizon: 0.94,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        variant: NeonConnectorVariant.gradient,
        color: Color(0xFFFF62CF),
        endColor: Color(0xFF596FFF),
        secondaryColor: Color(0xFF5DE5FF),
        coreColor: Color(0xFFFFFFFF),
        thickness: 2.35,
        glowRadius: 13,
        effect: NeonConnectorEffect.warp,
        animated: true,
        animationDuration: Duration(milliseconds: 4800),
        intensity: 1.24,
        detail: 1,
        flowSpeed: 1.12,
        particleCount: 12,
        turbulence: 0.78,
        trailCount: 4,
        strandCount: 5,
        waveFrequency: 7.4,
        chromaticAberration: 1.05,
        packetCount: 4,
        scanlineOpacity: 0.15,
        refraction: 0.92,
        crossFlare: 0.92,
        noise: 0.42,
        pulseWidth: 0.48,
      ),
      tilePadding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      contentGap: 22,
      nodeLaneExtent: 150,
      verticalMinExtent: 166,
      horizontalItemExtent: 338,
      animationDuration: Duration(milliseconds: 620),
      animationCurve: Curves.easeOutExpo,
      motionDuration: Duration(milliseconds: 4800),
    );
  }

  /// Ultra-depth neural-core preset with a photon-lattice connector.
  ///
  /// This preset keeps the same timeline data, layout, semantics, and
  /// interaction API. Only the vector rendering depth changes.
  factory NeonTimelineThemeData.omniverse() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFFFF63D8),
      secondaryColor: Color(0xFF56E7FF),
      surfaceColor: Color(0xFF070811),
      textColor: Color(0xFFFFFBFF),
      mutedColor: Color(0xFF625E78),
      completedColor: Color(0xFF57F0B8),
      errorColor: Color(0xFFFF5478),
      disabledColor: Color(0xFF454250),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 66,
        color: Color(0xFFFF63D8),
        borderColor: Color(0xFFFFFFFF),
        glowColor: Color(0xFFFF32BD),
        secondaryColor: Color(0xFFFFC15F),
        tertiaryColor: Color(0xFF57E8FF),
        interiorColor: Color(0xFF050712),
        borderWidth: 1.5,
        glowRadius: 26,
        effect: NeonIndicatorEffect.neuralCore,
        intensity: 1.32,
        detail: 1,
        rayLength: 1.24,
        particleCount: 16,
        rotationSpeed: 1.42,
        corona: 1,
        depth: 1,
        chromaticAberration: 1.22,
        refraction: 1,
        scanlineOpacity: 0.10,
        arcCount: 11,
        sparkCount: 20,
        noise: 0.58,
        parallax: 0.96,
        eventHorizon: 0.82,
        quality: NeonTimelineRenderQuality.ultra,
        haloRingCount: 7,
        fieldLineCount: 14,
        diffraction: 0.94,
        shockwave: 0.92,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        variant: NeonConnectorVariant.gradient,
        color: Color(0xFFFF6DDB),
        endColor: Color(0xFF5A76FF),
        secondaryColor: Color(0xFF58E9FF),
        coreColor: Color(0xFFFFFFFF),
        thickness: 2.45,
        glowRadius: 14,
        effect: NeonConnectorEffect.photonLattice,
        animated: true,
        animationDuration: Duration(milliseconds: 5000),
        intensity: 1.28,
        detail: 1,
        flowSpeed: 1.10,
        particleCount: 14,
        turbulence: 0.82,
        trailCount: 4,
        strandCount: 6,
        waveFrequency: 8.2,
        chromaticAberration: 1.15,
        packetCount: 5,
        scanlineOpacity: 0.12,
        refraction: 0.96,
        crossFlare: 0.96,
        noise: 0.48,
        pulseWidth: 0.46,
        quality: NeonTimelineRenderQuality.ultra,
        latticeDensity: 11,
        trailPersistence: 0.92,
        photonSpread: 0.92,
        interference: 0.94,
      ),
      tilePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      contentGap: 23,
      nodeLaneExtent: 176,
      verticalMinExtent: 176,
      horizontalItemExtent: 352,
      animationDuration: Duration(milliseconds: 650),
      animationCurve: Curves.easeOutExpo,
      motionDuration: Duration(milliseconds: 5000),
    );
  }

  /// Cyan-green neural-core colorway with slower motion.
  factory NeonTimelineThemeData.neuralAurora() {
    final base = NeonTimelineThemeData.omniverse();
    return base.copyWith(
      primaryColor: const Color(0xFF4AF0C1),
      secondaryColor: const Color(0xFF65B8FF),
      surfaceColor: const Color(0xFF06110F),
      completedColor: const Color(0xFF77FFD1),
      indicatorStyle: base.indicatorStyle.copyWith(
        color: const Color(0xFF50F1C3),
        glowColor: const Color(0xFF2BE7B0),
        secondaryColor: const Color(0xFFB2FFE8),
        tertiaryColor: const Color(0xFF64B7FF),
        interiorColor: const Color(0xFF04110F),
        rotationSpeed: 1.02,
      ),
      connectorStyle: base.connectorStyle.copyWith(
        color: const Color(0xFF53F0C1),
        endColor: const Color(0xFF6487FF),
        secondaryColor: const Color(0xFFB2FFE8),
        flowSpeed: 0.88,
        animationDuration: const Duration(milliseconds: 5600),
      ),
      motionDuration: const Duration(milliseconds: 5600),
    );
  }

  /// Gold-rose neural-core colorway with stronger diffraction.
  factory NeonTimelineThemeData.neuralEmber() {
    final base = NeonTimelineThemeData.omniverse();
    return base.copyWith(
      primaryColor: const Color(0xFFFF8A5B),
      secondaryColor: const Color(0xFFFF4FC8),
      surfaceColor: const Color(0xFF14090D),
      indicatorStyle: base.indicatorStyle.copyWith(
        color: const Color(0xFFFF8D5E),
        glowColor: const Color(0xFFFF4F8E),
        secondaryColor: const Color(0xFFFFD36E),
        tertiaryColor: const Color(0xFFFF58CF),
        interiorColor: const Color(0xFF16080B),
        diffraction: 1,
      ),
      connectorStyle: base.connectorStyle.copyWith(
        color: const Color(0xFFFFA05F),
        endColor: const Color(0xFFFF4FC8),
        secondaryColor: const Color(0xFFFFDA79),
        interference: 1,
      ),
    );
  }

  /// Transparent cyan-violet hologram preset.
  factory NeonTimelineThemeData.holographic() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFF60E9FF),
      secondaryColor: Color(0xFF9C72FF),
      surfaceColor: Color(0xFF071018),
      textColor: Color(0xFFEFFFFF),
      mutedColor: Color(0xFF52717C),
      completedColor: Color(0xFF64F5C5),
      errorColor: Color(0xFFFF688B),
      disabledColor: Color(0xFF3E5158),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 58,
        color: Color(0xFF63EBFF),
        borderColor: Color(0xFFEFFFFF),
        glowColor: Color(0xFF27CFFF),
        secondaryColor: Color(0xFFAF72FF),
        tertiaryColor: Color(0xFF53FFD1),
        interiorColor: Color(0xFF07141B),
        borderWidth: 1.25,
        glowRadius: 18,
        effect: NeonIndicatorEffect.hologram,
        intensity: 1.12,
        detail: 1,
        rayLength: 0.82,
        particleCount: 10,
        rotationSpeed: 0.76,
        corona: 0.78,
        depth: 0.7,
        chromaticAberration: 0.9,
        refraction: 0.62,
        scanlineOpacity: 0.48,
        arcCount: 8,
        sparkCount: 12,
        noise: 0.48,
        parallax: 0.76,
        eventHorizon: 0.5,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: Color(0xFF5DE9FF),
        endColor: Color(0xFF9A6CFF),
        secondaryColor: Color(0xFF52FFD0),
        coreColor: Color(0xFFFFFFFF),
        thickness: 1.8,
        dashLength: 7,
        gapLength: 3,
        glowRadius: 8,
        effect: NeonConnectorEffect.hologram,
        animated: true,
        animationDuration: Duration(milliseconds: 3600),
        intensity: 1.08,
        detail: 1,
        flowSpeed: 1.05,
        particleCount: 10,
        turbulence: 0.28,
        trailCount: 2,
        strandCount: 3,
        waveFrequency: 8,
        chromaticAberration: 0.86,
        packetCount: 5,
        scanlineOpacity: 0.62,
        refraction: 0.58,
        crossFlare: 0.72,
        noise: 0.55,
        pulseWidth: 0.32,
      ),
      contentGap: 20,
      nodeLaneExtent: 116,
      verticalMinExtent: 148,
      horizontalItemExtent: 316,
      motionDuration: Duration(milliseconds: 3600),
    );
  }

  /// Hot gold-magenta singularity variant.
  factory NeonTimelineThemeData.solarFlare() {
    return NeonTimelineThemeData.hyperion().copyWith(
      primaryColor: const Color(0xFFFFA64D),
      secondaryColor: const Color(0xFFFF4D9D),
      surfaceColor: const Color(0xFF150B0D),
      indicatorStyle: NeonTimelineThemeData.hyperion().indicatorStyle.copyWith(
            color: const Color(0xFFFF9C45),
            glowColor: const Color(0xFFFF5F37),
            secondaryColor: const Color(0xFFFFE17A),
            tertiaryColor: const Color(0xFFFF4EB3),
            interiorColor: const Color(0xFF180908),
          ),
      connectorStyle: NeonTimelineThemeData.hyperion().connectorStyle.copyWith(
            color: const Color(0xFFFFB153),
            endColor: const Color(0xFFFF4DAA),
            secondaryColor: const Color(0xFFFFE477),
          ),
    );
  }

  /// Ice-blue singularity variant with restrained motion.
  factory NeonTimelineThemeData.cryogenic() {
    return NeonTimelineThemeData.hyperion().copyWith(
      primaryColor: const Color(0xFF9AEFFF),
      secondaryColor: const Color(0xFF698CFF),
      surfaceColor: const Color(0xFF06101A),
      indicatorStyle: NeonTimelineThemeData.hyperion().indicatorStyle.copyWith(
            color: const Color(0xFFB5F5FF),
            glowColor: const Color(0xFF4BCFFF),
            secondaryColor: const Color(0xFFFFFFFF),
            tertiaryColor: const Color(0xFF718CFF),
            interiorColor: const Color(0xFF06121E),
            intensity: 1.12,
            rotationSpeed: 0.78,
          ),
      connectorStyle: NeonTimelineThemeData.hyperion().connectorStyle.copyWith(
            color: const Color(0xFF9AEFFF),
            endColor: const Color(0xFF667CFF),
            secondaryColor: const Color(0xFFFFFFFF),
            flowSpeed: 0.78,
          ),
      motionDuration: const Duration(milliseconds: 5600),
    );
  }

  /// Near-black violet variant focused on the event horizon.
  factory NeonTimelineThemeData.voidPulse() {
    return NeonTimelineThemeData.hyperion().copyWith(
      primaryColor: const Color(0xFFB66BFF),
      secondaryColor: const Color(0xFFFF4FD8),
      surfaceColor: const Color(0xFF050508),
      indicatorStyle: NeonTimelineThemeData.hyperion().indicatorStyle.copyWith(
            color: const Color(0xFF9B62FF),
            glowColor: const Color(0xFF7A38FF),
            secondaryColor: const Color(0xFFFF53DD),
            tertiaryColor: const Color(0xFF5D7CFF),
            interiorColor: const Color(0xFF020205),
            eventHorizon: 1,
            scanlineOpacity: 0.08,
          ),
      connectorStyle: NeonTimelineThemeData.hyperion().connectorStyle.copyWith(
            color: const Color(0xFFB66BFF),
            endColor: const Color(0xFFFF4FD8),
            secondaryColor: const Color(0xFF5D7CFF),
          ),
    );
  }

  /// Cool green-blue quantum variant.
  factory NeonTimelineThemeData.aurora() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFF45F0B5),
      secondaryColor: Color(0xFF64B5FF),
      surfaceColor: Color(0xFF071512),
      textColor: Color(0xFFF3FFFB),
      mutedColor: Color(0xFF5E7D77),
      completedColor: Color(0xFF6BFFCB),
      errorColor: Color(0xFFFF667F),
      disabledColor: Color(0xFF3E5552),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 56,
        color: Color(0xFF45F0B5),
        borderColor: Color(0xFFDFFFF5),
        glowColor: Color(0xFF34DFA8),
        secondaryColor: Color(0xFF8CFFE0),
        tertiaryColor: Color(0xFF64B5FF),
        interiorColor: Color(0xFF0B1718),
        borderWidth: 1.4,
        glowRadius: 19,
        effect: NeonIndicatorEffect.quantum,
        intensity: 1.08,
        detail: 0.94,
        rayLength: 0.94,
        particleCount: 8,
        rotationSpeed: 0.94,
        corona: 0.86,
        depth: 0.84,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: Color(0xFF52F0B9),
        endColor: Color(0xFF5B8CFF),
        secondaryColor: Color(0xFF8CFFE0),
        coreColor: Color(0xFFF4FFFF),
        thickness: 2.15,
        glowRadius: 9,
        effect: NeonConnectorEffect.plasma,
        animated: true,
        animationDuration: Duration(milliseconds: 4400),
        intensity: 1.05,
        detail: 0.9,
        flowSpeed: 0.92,
        particleCount: 7,
        turbulence: 0.58,
        trailCount: 2,
      ),
      nodeLaneExtent: 106,
      verticalMinExtent: 140,
      horizontalItemExtent: 306,
      contentGap: 18,
      motionDuration: Duration(milliseconds: 4400),
    );
  }

  /// Warm orange-pink quantum variant.
  factory NeonTimelineThemeData.ember() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFFFF7A66),
      secondaryColor: Color(0xFFFF4FB4),
      surfaceColor: Color(0xFF160C13),
      textColor: Color(0xFFFFF8F4),
      mutedColor: Color(0xFF83656E),
      completedColor: Color(0xFF65D9A5),
      errorColor: Color(0xFFFF445F),
      disabledColor: Color(0xFF5B454C),
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: 56,
        color: Color(0xFFFF7A66),
        borderColor: Color(0xFFFFE6BC),
        glowColor: Color(0xFFFF4F92),
        secondaryColor: Color(0xFFFFB25F),
        tertiaryColor: Color(0xFFFF4FC4),
        interiorColor: Color(0xFF1C1017),
        borderWidth: 1.4,
        glowRadius: 20,
        effect: NeonIndicatorEffect.quantum,
        intensity: 1.12,
        detail: 0.96,
        rayLength: 1,
        particleCount: 9,
        rotationSpeed: 1.12,
        corona: 0.92,
        depth: 0.88,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: Color(0xFFFF916B),
        endColor: Color(0xFFFF4FC4),
        secondaryColor: Color(0xFFFFD077),
        coreColor: Color(0xFFFFFBED),
        thickness: 2.2,
        glowRadius: 10,
        effect: NeonConnectorEffect.plasma,
        animated: true,
        animationDuration: Duration(milliseconds: 4000),
        intensity: 1.1,
        detail: 0.94,
        flowSpeed: 1.04,
        particleCount: 8,
        turbulence: 0.66,
        trailCount: 3,
      ),
      nodeLaneExtent: 108,
      verticalMinExtent: 142,
      horizontalItemExtent: 308,
      contentGap: 18,
      motionDuration: Duration(milliseconds: 4000),
    );
  }

  /// Restrained dark preset with reduced glow.
  factory NeonTimelineThemeData.midnight() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFF6EE7F9),
      secondaryColor: Color(0xFFA78BFA),
      surfaceColor: Color(0xFF10151E),
      textColor: Color(0xFFF1F5F9),
      mutedColor: Color(0xFF64748B),
      indicatorStyle: NeonTimelineIndicatorStyle(
        color: Color(0xFF6EE7F9),
        borderColor: Color(0xFFCFFAFE),
        glowColor: Color(0xFF22D3EE),
        glowRadius: 6,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: Color(0xFF22D3EE),
        endColor: Color(0xFF4338CA),
        glowRadius: 2,
      ),
    );
  }

  /// Clean light preset.
  factory NeonTimelineThemeData.light() {
    return const NeonTimelineThemeData(
      primaryColor: Color(0xFF5B4CF0),
      secondaryColor: Color(0xFFDB2777),
      surfaceColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF19152A),
      mutedColor: Color(0xFF8B86A3),
      disabledColor: Color(0xFFB9B5C6),
      indicatorStyle: NeonTimelineIndicatorStyle(
        color: Color(0xFF5B4CF0),
        borderColor: Color(0xFFFFFFFF),
        glowColor: Color(0xFF7C6FF5),
        glowRadius: 4,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: Color(0xFF5B4CF0),
        endColor: Color(0xFFD8D5E8),
        glowRadius: 0,
      ),
    );
  }

  /// Derives a complete theme from one seed color.
  factory NeonTimelineThemeData.fromSeed(
    Color seed, {
    Brightness brightness = Brightness.dark,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    return NeonTimelineThemeData(
      primaryColor: scheme.primary,
      secondaryColor: scheme.secondary,
      surfaceColor: scheme.surface,
      textColor: scheme.onSurface,
      mutedColor: scheme.onSurfaceVariant,
      completedColor: const Color(0xFF29D391),
      errorColor: scheme.error,
      disabledColor: scheme.outline,
      indicatorStyle: NeonTimelineIndicatorStyle(
        color: scheme.primary,
        borderColor: scheme.onPrimary,
        glowColor: scheme.primary,
        glowRadius: isDark ? 10 : 3,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: scheme.primary,
        endColor: scheme.secondary,
        glowRadius: isDark ? 5 : 0,
      ),
    );
  }

  /// Resolves the accent associated with [status].
  Color colorForStatus(NeonTimelineStatus status) {
    return switch (status) {
      NeonTimelineStatus.pending => mutedColor,
      NeonTimelineStatus.active => primaryColor,
      NeonTimelineStatus.completed => completedColor,
      NeonTimelineStatus.error => errorColor,
      NeonTimelineStatus.disabled => disabledColor,
    };
  }

  @override
  NeonTimelineThemeData copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? surfaceColor,
    Color? textColor,
    Color? mutedColor,
    Color? completedColor,
    Color? errorColor,
    Color? disabledColor,
    NeonTimelineIndicatorStyle? indicatorStyle,
    NeonTimelineConnectorStyle? connectorStyle,
    EdgeInsets? tilePadding,
    double? contentGap,
    double? nodeLaneExtent,
    double? verticalMinExtent,
    double? horizontalItemExtent,
    double? adaptiveBreakpoint,
    Duration? animationDuration,
    Curve? animationCurve,
    Duration? motionDuration,
  }) {
    return NeonTimelineThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      mutedColor: mutedColor ?? this.mutedColor,
      completedColor: completedColor ?? this.completedColor,
      errorColor: errorColor ?? this.errorColor,
      disabledColor: disabledColor ?? this.disabledColor,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      connectorStyle: connectorStyle ?? this.connectorStyle,
      tilePadding: tilePadding ?? this.tilePadding,
      contentGap: contentGap ?? this.contentGap,
      nodeLaneExtent: nodeLaneExtent ?? this.nodeLaneExtent,
      verticalMinExtent: verticalMinExtent ?? this.verticalMinExtent,
      horizontalItemExtent: horizontalItemExtent ?? this.horizontalItemExtent,
      adaptiveBreakpoint: adaptiveBreakpoint ?? this.adaptiveBreakpoint,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      motionDuration: motionDuration ?? this.motionDuration,
    );
  }

  @override
  NeonTimelineThemeData lerp(
    covariant NeonTimelineThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return NeonTimelineThemeData(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      mutedColor: Color.lerp(mutedColor, other.mutedColor, t)!,
      completedColor: Color.lerp(completedColor, other.completedColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      indicatorStyle: NeonTimelineIndicatorStyle.lerp(
        indicatorStyle,
        other.indicatorStyle,
        t,
      ),
      connectorStyle: NeonTimelineConnectorStyle.lerp(
        connectorStyle,
        other.connectorStyle,
        t,
      ),
      tilePadding: EdgeInsets.lerp(tilePadding, other.tilePadding, t)!,
      contentGap: lerpDouble(contentGap, other.contentGap, t)!,
      nodeLaneExtent: lerpDouble(nodeLaneExtent, other.nodeLaneExtent, t)!,
      verticalMinExtent:
          lerpDouble(verticalMinExtent, other.verticalMinExtent, t)!,
      horizontalItemExtent:
          lerpDouble(horizontalItemExtent, other.horizontalItemExtent, t)!,
      adaptiveBreakpoint:
          lerpDouble(adaptiveBreakpoint, other.adaptiveBreakpoint, t)!,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
      motionDuration: Duration(
        microseconds: lerpDouble(
          motionDuration.inMicroseconds,
          other.motionDuration.inMicroseconds,
          t,
        )!
            .round(),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeonTimelineThemeData &&
            primaryColor == other.primaryColor &&
            secondaryColor == other.secondaryColor &&
            surfaceColor == other.surfaceColor &&
            textColor == other.textColor &&
            mutedColor == other.mutedColor &&
            completedColor == other.completedColor &&
            errorColor == other.errorColor &&
            disabledColor == other.disabledColor &&
            indicatorStyle == other.indicatorStyle &&
            connectorStyle == other.connectorStyle &&
            tilePadding == other.tilePadding &&
            contentGap == other.contentGap &&
            nodeLaneExtent == other.nodeLaneExtent &&
            verticalMinExtent == other.verticalMinExtent &&
            horizontalItemExtent == other.horizontalItemExtent &&
            adaptiveBreakpoint == other.adaptiveBreakpoint &&
            animationDuration == other.animationDuration &&
            animationCurve == other.animationCurve &&
            motionDuration == other.motionDuration;
  }

  @override
  int get hashCode => Object.hash(
        primaryColor,
        secondaryColor,
        surfaceColor,
        textColor,
        mutedColor,
        completedColor,
        errorColor,
        disabledColor,
        indicatorStyle,
        connectorStyle,
        tilePadding,
        contentGap,
        nodeLaneExtent,
        verticalMinExtent,
        horizontalItemExtent,
        adaptiveBreakpoint,
        animationDuration,
        animationCurve,
        motionDuration,
      );
}

/// Applies [NeonTimelineThemeData] to a subtree.
class NeonTimelineTheme extends InheritedTheme {
  /// Creates a local timeline theme.
  const NeonTimelineTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Theme values exposed to descendants.
  final NeonTimelineThemeData data;

  /// Returns the closest local or app-level timeline theme.
  static NeonTimelineThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<NeonTimelineTheme>();
    if (inherited != null) return inherited.data;

    final materialTheme = Theme.of(context);
    final extension = materialTheme.extension<NeonTimelineThemeData>();
    if (extension != null) return extension;

    return materialTheme.brightness == Brightness.light
        ? NeonTimelineThemeData.light()
        : NeonTimelineThemeData.neon();
  }

  @override
  bool updateShouldNotify(NeonTimelineTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NeonTimelineTheme(data: data, child: child);
  }
}

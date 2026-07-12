import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/neon_timeline_types.dart';

/// Immutable visual configuration for a timeline marker.
@immutable
class NeonTimelineIndicatorStyle {
  /// Creates an indicator style.
  const NeonTimelineIndicatorStyle({
    this.size = 26,
    this.color = const Color(0xFF8B7CFF),
    this.borderColor = const Color(0xFFD8D2FF),
    this.glowColor = const Color(0xFF8B7CFF),
    this.secondaryColor = const Color(0xFFFF7BAE),
    this.tertiaryColor = const Color(0xFF6EE7F9),
    this.interiorColor = const Color(0xFF151222),
    this.borderWidth = 1.5,
    this.glowRadius = 10,
    this.shape = NeonIndicatorShape.circle,
    this.effect = NeonIndicatorEffect.classic,
    this.intensity = 1,
    this.detail = 0.8,
    this.rayLength = 0.85,
    this.particleCount = 6,
    this.rotationSpeed = 1,
    this.corona = 0.75,
    this.depth = 0.7,
    this.chromaticAberration = 0.55,
    this.refraction = 0.68,
    this.scanlineOpacity = 0.18,
    this.arcCount = 5,
    this.sparkCount = 8,
    this.noise = 0.24,
    this.parallax = 0.65,
    this.eventHorizon = 0.78,
    this.quality = NeonTimelineRenderQuality.high,
    this.haloRingCount = 4,
    this.fieldLineCount = 8,
    this.diffraction = 0.72,
    this.shockwave = 0.68,
  })  : assert(size > 0),
        assert(borderWidth >= 0),
        assert(glowRadius >= 0),
        assert(intensity >= 0 && intensity <= 2),
        assert(detail >= 0 && detail <= 1),
        assert(rayLength >= 0 && rayLength <= 2),
        assert(particleCount >= 0),
        assert(rotationSpeed >= 0 && rotationSpeed <= 4),
        assert(corona >= 0 && corona <= 1),
        assert(depth >= 0 && depth <= 1),
        assert(chromaticAberration >= 0 && chromaticAberration <= 2),
        assert(refraction >= 0 && refraction <= 1),
        assert(scanlineOpacity >= 0 && scanlineOpacity <= 1),
        assert(arcCount >= 0 && arcCount <= 16),
        assert(sparkCount >= 0 && sparkCount <= 32),
        assert(noise >= 0 && noise <= 1),
        assert(parallax >= 0 && parallax <= 1),
        assert(eventHorizon >= 0 && eventHorizon <= 1),
        assert(haloRingCount >= 0 && haloRingCount <= 12),
        assert(fieldLineCount >= 0 && fieldLineCount <= 24),
        assert(diffraction >= 0 && diffraction <= 1),
        assert(shockwave >= 0 && shockwave <= 1);

  /// Marker width and height before glow overflow is added.
  final double size;

  /// Main fill and status color.
  final Color color;

  /// Outline color used by the lightweight renderer.
  final Color borderColor;

  /// Outer glow color.
  final Color glowColor;

  /// Second spectral accent.
  final Color secondaryColor;

  /// Third spectral accent.
  final Color tertiaryColor;

  /// Dark core color used inside advanced indicators.
  final Color interiorColor;

  /// Outline thickness.
  final double borderWidth;

  /// Blur radius of the outer glow.
  final double glowRadius;

  /// Marker geometry.
  final NeonIndicatorShape shape;

  /// Rendering depth of the marker.
  final NeonIndicatorEffect effect;

  /// Overall light output. Recommended range: `0.65` to `1.35`.
  final double intensity;

  /// Micro-detail amount for reflections, caustics, and particles.
  final double detail;

  /// Length multiplier for lens rays.
  final double rayLength;

  /// Number of deterministic orbit particles.
  final int particleCount;

  /// Spectral-ring rotation multiplier.
  final double rotationSpeed;

  /// Strength of outer corona arcs.
  final double corona;

  /// Perceived glass depth and pointer-press parallax.
  final double depth;

  /// Separation of red/cyan fringe layers.
  final double chromaticAberration;

  /// Strength of glass distortion and internal lensing.
  final double refraction;

  /// Scanline opacity used by hologram and singularity renderers.
  final double scanlineOpacity;

  /// Number of magnetic or segmented corona arcs.
  final int arcCount;

  /// Number of micro sparks around the marker.
  final int sparkCount;

  /// Deterministic texture and shimmer strength.
  final double noise;

  /// Pointer-driven highlight displacement.
  final double parallax;

  /// Darkness and compression of the singularity core.
  final double eventHorizon;

  /// Vector sample budget used by advanced renderers.
  final NeonTimelineRenderQuality quality;

  /// Number of concentric halo rings used by neural-core rendering.
  final int haloRingCount;

  /// Number of animated vector-field lines around neural cores.
  final int fieldLineCount;

  /// Strength of diffraction spikes and spectral separation.
  final double diffraction;

  /// Strength of expanding shockwave rings.
  final double shockwave;

  /// Total visual extent including advanced glow and corona overflow.
  double get visualExtent {
    final factor = switch (effect) {
      NeonIndicatorEffect.classic => 1.0,
      NeonIndicatorEffect.glass => 1.65,
      NeonIndicatorEffect.stellar => 1.95,
      NeonIndicatorEffect.quantum => 2.35,
      NeonIndicatorEffect.singularity => 2.8,
      NeonIndicatorEffect.hologram => 2.15,
      NeonIndicatorEffect.neuralCore => 3.15,
    };
    if (effect == NeonIndicatorEffect.classic) return size;
    return size + math.max(18.0, glowRadius * factor);
  }

  /// Returns a copy with selected values replaced.
  NeonTimelineIndicatorStyle copyWith({
    double? size,
    Color? color,
    Color? borderColor,
    Color? glowColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? interiorColor,
    double? borderWidth,
    double? glowRadius,
    NeonIndicatorShape? shape,
    NeonIndicatorEffect? effect,
    double? intensity,
    double? detail,
    double? rayLength,
    int? particleCount,
    double? rotationSpeed,
    double? corona,
    double? depth,
    double? chromaticAberration,
    double? refraction,
    double? scanlineOpacity,
    int? arcCount,
    int? sparkCount,
    double? noise,
    double? parallax,
    double? eventHorizon,
    NeonTimelineRenderQuality? quality,
    int? haloRingCount,
    int? fieldLineCount,
    double? diffraction,
    double? shockwave,
  }) {
    return NeonTimelineIndicatorStyle(
      size: size ?? this.size,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      glowColor: glowColor ?? this.glowColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      interiorColor: interiorColor ?? this.interiorColor,
      borderWidth: borderWidth ?? this.borderWidth,
      glowRadius: glowRadius ?? this.glowRadius,
      shape: shape ?? this.shape,
      effect: effect ?? this.effect,
      intensity: intensity ?? this.intensity,
      detail: detail ?? this.detail,
      rayLength: rayLength ?? this.rayLength,
      particleCount: particleCount ?? this.particleCount,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      corona: corona ?? this.corona,
      depth: depth ?? this.depth,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      refraction: refraction ?? this.refraction,
      scanlineOpacity: scanlineOpacity ?? this.scanlineOpacity,
      arcCount: arcCount ?? this.arcCount,
      sparkCount: sparkCount ?? this.sparkCount,
      noise: noise ?? this.noise,
      parallax: parallax ?? this.parallax,
      eventHorizon: eventHorizon ?? this.eventHorizon,
      quality: quality ?? this.quality,
      haloRingCount: haloRingCount ?? this.haloRingCount,
      fieldLineCount: fieldLineCount ?? this.fieldLineCount,
      diffraction: diffraction ?? this.diffraction,
      shockwave: shockwave ?? this.shockwave,
    );
  }

  /// Interpolates between two indicator styles.
  static NeonTimelineIndicatorStyle lerp(
    NeonTimelineIndicatorStyle a,
    NeonTimelineIndicatorStyle b,
    double t,
  ) {
    return NeonTimelineIndicatorStyle(
      size: lerpDouble(a.size, b.size, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      glowColor: Color.lerp(a.glowColor, b.glowColor, t)!,
      secondaryColor: Color.lerp(a.secondaryColor, b.secondaryColor, t)!,
      tertiaryColor: Color.lerp(a.tertiaryColor, b.tertiaryColor, t)!,
      interiorColor: Color.lerp(a.interiorColor, b.interiorColor, t)!,
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t)!,
      glowRadius: lerpDouble(a.glowRadius, b.glowRadius, t)!,
      shape: t < 0.5 ? a.shape : b.shape,
      effect: t < 0.5 ? a.effect : b.effect,
      intensity: lerpDouble(a.intensity, b.intensity, t)!,
      detail: lerpDouble(a.detail, b.detail, t)!,
      rayLength: lerpDouble(a.rayLength, b.rayLength, t)!,
      particleCount: lerpDouble(a.particleCount, b.particleCount, t)!.round(),
      rotationSpeed: lerpDouble(a.rotationSpeed, b.rotationSpeed, t)!,
      corona: lerpDouble(a.corona, b.corona, t)!,
      depth: lerpDouble(a.depth, b.depth, t)!,
      chromaticAberration:
          lerpDouble(a.chromaticAberration, b.chromaticAberration, t)!,
      refraction: lerpDouble(a.refraction, b.refraction, t)!,
      scanlineOpacity: lerpDouble(a.scanlineOpacity, b.scanlineOpacity, t)!,
      arcCount: lerpDouble(a.arcCount, b.arcCount, t)!.round(),
      sparkCount: lerpDouble(a.sparkCount, b.sparkCount, t)!.round(),
      noise: lerpDouble(a.noise, b.noise, t)!,
      parallax: lerpDouble(a.parallax, b.parallax, t)!,
      eventHorizon: lerpDouble(a.eventHorizon, b.eventHorizon, t)!,
      quality: t < 0.5 ? a.quality : b.quality,
      haloRingCount: lerpDouble(a.haloRingCount, b.haloRingCount, t)!.round(),
      fieldLineCount:
          lerpDouble(a.fieldLineCount, b.fieldLineCount, t)!.round(),
      diffraction: lerpDouble(a.diffraction, b.diffraction, t)!,
      shockwave: lerpDouble(a.shockwave, b.shockwave, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeonTimelineIndicatorStyle &&
            size == other.size &&
            color == other.color &&
            borderColor == other.borderColor &&
            glowColor == other.glowColor &&
            secondaryColor == other.secondaryColor &&
            tertiaryColor == other.tertiaryColor &&
            interiorColor == other.interiorColor &&
            borderWidth == other.borderWidth &&
            glowRadius == other.glowRadius &&
            shape == other.shape &&
            effect == other.effect &&
            intensity == other.intensity &&
            detail == other.detail &&
            rayLength == other.rayLength &&
            particleCount == other.particleCount &&
            rotationSpeed == other.rotationSpeed &&
            corona == other.corona &&
            depth == other.depth &&
            chromaticAberration == other.chromaticAberration &&
            refraction == other.refraction &&
            scanlineOpacity == other.scanlineOpacity &&
            arcCount == other.arcCount &&
            sparkCount == other.sparkCount &&
            noise == other.noise &&
            parallax == other.parallax &&
            eventHorizon == other.eventHorizon &&
            quality == other.quality &&
            haloRingCount == other.haloRingCount &&
            fieldLineCount == other.fieldLineCount &&
            diffraction == other.diffraction &&
            shockwave == other.shockwave;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        size,
        color,
        borderColor,
        glowColor,
        secondaryColor,
        tertiaryColor,
        interiorColor,
        borderWidth,
        glowRadius,
        shape,
        effect,
        intensity,
        detail,
        rayLength,
        particleCount,
        rotationSpeed,
        corona,
        depth,
        chromaticAberration,
        refraction,
        scanlineOpacity,
        arcCount,
        sparkCount,
        noise,
        parallax,
        eventHorizon,
        quality,
        haloRingCount,
        fieldLineCount,
        diffraction,
        shockwave,
      ]);
}

/// Immutable visual configuration for a connector line.
@immutable
class NeonTimelineConnectorStyle {
  /// Creates a connector style.
  const NeonTimelineConnectorStyle({
    this.variant = NeonConnectorVariant.gradient,
    this.color = const Color(0xFF8B7CFF),
    this.endColor = const Color(0xFF3A355F),
    this.secondaryColor = const Color(0xFFFF7BAE),
    this.coreColor = const Color(0xFFFFFFFF),
    this.thickness = 2,
    this.dashLength = 6,
    this.gapLength = 4,
    this.glowRadius = 5,
    this.lineCap = StrokeCap.round,
    this.effect = NeonConnectorEffect.classic,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 3400),
    this.intensity = 1,
    this.detail = 0.75,
    this.flowSpeed = 1,
    this.particleCount = 5,
    this.turbulence = 0.45,
    this.trailCount = 2,
    this.phaseOffset = 0,
    this.strandCount = 3,
    this.waveFrequency = 6,
    this.chromaticAberration = 0.55,
    this.packetCount = 3,
    this.scanlineOpacity = 0.2,
    this.refraction = 0.65,
    this.crossFlare = 0.72,
    this.noise = 0.22,
    this.pulseWidth = 0.42,
    this.quality = NeonTimelineRenderQuality.high,
    this.latticeDensity = 7,
    this.trailPersistence = 0.72,
    this.photonSpread = 0.68,
    this.interference = 0.74,
  })  : assert(thickness > 0),
        assert(dashLength > 0),
        assert(gapLength >= 0),
        assert(glowRadius >= 0),
        assert(intensity >= 0 && intensity <= 2),
        assert(detail >= 0 && detail <= 1),
        assert(flowSpeed > 0 && flowSpeed <= 4),
        assert(particleCount >= 0),
        assert(turbulence >= 0 && turbulence <= 1),
        assert(trailCount >= 1 && trailCount <= 6),
        assert(phaseOffset >= 0 && phaseOffset <= 1),
        assert(strandCount >= 1 && strandCount <= 8),
        assert(waveFrequency >= 1 && waveFrequency <= 16),
        assert(chromaticAberration >= 0 && chromaticAberration <= 2),
        assert(packetCount >= 0 && packetCount <= 8),
        assert(scanlineOpacity >= 0 && scanlineOpacity <= 1),
        assert(refraction >= 0 && refraction <= 1),
        assert(crossFlare >= 0 && crossFlare <= 1),
        assert(noise >= 0 && noise <= 1),
        assert(pulseWidth >= 0.05 && pulseWidth <= 1),
        assert(latticeDensity >= 2 && latticeDensity <= 18),
        assert(trailPersistence >= 0 && trailPersistence <= 1),
        assert(photonSpread >= 0 && photonSpread <= 1),
        assert(interference >= 0 && interference <= 1);

  /// Connector rendering strategy.
  final NeonConnectorVariant variant;

  /// Start or solid color.
  final Color color;

  /// End color for [NeonConnectorVariant.gradient].
  final Color endColor;

  /// Secondary spectral accent used by warp and hologram modes.
  final Color secondaryColor;

  /// Bright center color used by advanced effects.
  final Color coreColor;

  /// Line thickness.
  final double thickness;

  /// Painted length of each dash.
  final double dashLength;

  /// Empty length between dashes.
  final double gapLength;

  /// Blur radius of the line glow.
  final double glowRadius;

  /// Shape used at the ends of painted line segments.
  final StrokeCap lineCap;

  /// Rendering depth of the connector.
  final NeonConnectorEffect effect;

  /// Whether advanced modes paint moving highlights and particles.
  final bool animated;

  /// Duration of one complete energy pass.
  final Duration animationDuration;

  /// Overall light output. Recommended range: `0.65` to `1.35`.
  final double intensity;

  /// Micro-detail amount for fringes, particles, and scanlines.
  final double detail;

  /// Multiplier applied to the moving energy phase.
  final double flowSpeed;

  /// Number of deterministic particles painted along the connector.
  final int particleCount;

  /// Wave displacement from `0` to `1`.
  final double turbulence;

  /// Number of moving energy trails in plasma mode.
  final int trailCount;

  /// Normalized phase offset used to stagger neighboring connectors.
  final double phaseOffset;

  /// Number of braided strands in warp mode.
  final int strandCount;

  /// Number of oscillations along the beam.
  final double waveFrequency;

  /// Separation of spectral fringe layers.
  final double chromaticAberration;

  /// Number of moving warp or hologram packets.
  ///
  /// Set to `0` to disable packet animation entirely.
  final int packetCount;

  /// Scanline and data-tick opacity.
  final double scanlineOpacity;

  /// Strength of internal beam distortion.
  final double refraction;

  /// Strength of transverse lens flares.
  final double crossFlare;

  /// Deterministic micro-noise strength.
  final double noise;

  /// Relative length of moving packets.
  final double pulseWidth;

  /// Vector sample budget used by advanced connectors.
  final NeonTimelineRenderQuality quality;

  /// Number of cross-links in the photon lattice.
  final int latticeDensity;

  /// Persistence of trailing light behind moving photon packets.
  final double trailPersistence;

  /// Width of the photon field around the connector axis.
  final double photonSpread;

  /// Strength of wave-interference highlights.
  final double interference;

  /// Returns a copy with selected values replaced.
  NeonTimelineConnectorStyle copyWith({
    NeonConnectorVariant? variant,
    Color? color,
    Color? endColor,
    Color? secondaryColor,
    Color? coreColor,
    double? thickness,
    double? dashLength,
    double? gapLength,
    double? glowRadius,
    StrokeCap? lineCap,
    NeonConnectorEffect? effect,
    bool? animated,
    Duration? animationDuration,
    double? intensity,
    double? detail,
    double? flowSpeed,
    int? particleCount,
    double? turbulence,
    int? trailCount,
    double? phaseOffset,
    int? strandCount,
    double? waveFrequency,
    double? chromaticAberration,
    int? packetCount,
    double? scanlineOpacity,
    double? refraction,
    double? crossFlare,
    double? noise,
    double? pulseWidth,
    NeonTimelineRenderQuality? quality,
    int? latticeDensity,
    double? trailPersistence,
    double? photonSpread,
    double? interference,
  }) {
    return NeonTimelineConnectorStyle(
      variant: variant ?? this.variant,
      color: color ?? this.color,
      endColor: endColor ?? this.endColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      coreColor: coreColor ?? this.coreColor,
      thickness: thickness ?? this.thickness,
      dashLength: dashLength ?? this.dashLength,
      gapLength: gapLength ?? this.gapLength,
      glowRadius: glowRadius ?? this.glowRadius,
      lineCap: lineCap ?? this.lineCap,
      effect: effect ?? this.effect,
      animated: animated ?? this.animated,
      animationDuration: animationDuration ?? this.animationDuration,
      intensity: intensity ?? this.intensity,
      detail: detail ?? this.detail,
      flowSpeed: flowSpeed ?? this.flowSpeed,
      particleCount: particleCount ?? this.particleCount,
      turbulence: turbulence ?? this.turbulence,
      trailCount: trailCount ?? this.trailCount,
      phaseOffset: phaseOffset ?? this.phaseOffset,
      strandCount: strandCount ?? this.strandCount,
      waveFrequency: waveFrequency ?? this.waveFrequency,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      packetCount: packetCount ?? this.packetCount,
      scanlineOpacity: scanlineOpacity ?? this.scanlineOpacity,
      refraction: refraction ?? this.refraction,
      crossFlare: crossFlare ?? this.crossFlare,
      noise: noise ?? this.noise,
      pulseWidth: pulseWidth ?? this.pulseWidth,
      quality: quality ?? this.quality,
      latticeDensity: latticeDensity ?? this.latticeDensity,
      trailPersistence: trailPersistence ?? this.trailPersistence,
      photonSpread: photonSpread ?? this.photonSpread,
      interference: interference ?? this.interference,
    );
  }

  /// Interpolates between two connector styles.
  static NeonTimelineConnectorStyle lerp(
    NeonTimelineConnectorStyle a,
    NeonTimelineConnectorStyle b,
    double t,
  ) {
    return NeonTimelineConnectorStyle(
      variant: t < 0.5 ? a.variant : b.variant,
      color: Color.lerp(a.color, b.color, t)!,
      endColor: Color.lerp(a.endColor, b.endColor, t)!,
      secondaryColor: Color.lerp(a.secondaryColor, b.secondaryColor, t)!,
      coreColor: Color.lerp(a.coreColor, b.coreColor, t)!,
      thickness: lerpDouble(a.thickness, b.thickness, t)!,
      dashLength: lerpDouble(a.dashLength, b.dashLength, t)!,
      gapLength: lerpDouble(a.gapLength, b.gapLength, t)!,
      glowRadius: lerpDouble(a.glowRadius, b.glowRadius, t)!,
      lineCap: t < 0.5 ? a.lineCap : b.lineCap,
      effect: t < 0.5 ? a.effect : b.effect,
      animated: t < 0.5 ? a.animated : b.animated,
      animationDuration: Duration(
        milliseconds: lerpDouble(
          a.animationDuration.inMilliseconds,
          b.animationDuration.inMilliseconds,
          t,
        )!
            .round(),
      ),
      intensity: lerpDouble(a.intensity, b.intensity, t)!,
      detail: lerpDouble(a.detail, b.detail, t)!,
      flowSpeed: lerpDouble(a.flowSpeed, b.flowSpeed, t)!,
      particleCount: lerpDouble(a.particleCount, b.particleCount, t)!.round(),
      turbulence: lerpDouble(a.turbulence, b.turbulence, t)!,
      trailCount: lerpDouble(a.trailCount, b.trailCount, t)!.round(),
      phaseOffset: lerpDouble(a.phaseOffset, b.phaseOffset, t)!,
      strandCount: lerpDouble(a.strandCount, b.strandCount, t)!.round(),
      waveFrequency: lerpDouble(a.waveFrequency, b.waveFrequency, t)!,
      chromaticAberration:
          lerpDouble(a.chromaticAberration, b.chromaticAberration, t)!,
      packetCount: lerpDouble(a.packetCount, b.packetCount, t)!.round(),
      scanlineOpacity: lerpDouble(a.scanlineOpacity, b.scanlineOpacity, t)!,
      refraction: lerpDouble(a.refraction, b.refraction, t)!,
      crossFlare: lerpDouble(a.crossFlare, b.crossFlare, t)!,
      noise: lerpDouble(a.noise, b.noise, t)!,
      pulseWidth: lerpDouble(a.pulseWidth, b.pulseWidth, t)!,
      quality: t < 0.5 ? a.quality : b.quality,
      latticeDensity:
          lerpDouble(a.latticeDensity, b.latticeDensity, t)!.round(),
      trailPersistence: lerpDouble(a.trailPersistence, b.trailPersistence, t)!,
      photonSpread: lerpDouble(a.photonSpread, b.photonSpread, t)!,
      interference: lerpDouble(a.interference, b.interference, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeonTimelineConnectorStyle &&
            variant == other.variant &&
            color == other.color &&
            endColor == other.endColor &&
            secondaryColor == other.secondaryColor &&
            coreColor == other.coreColor &&
            thickness == other.thickness &&
            dashLength == other.dashLength &&
            gapLength == other.gapLength &&
            glowRadius == other.glowRadius &&
            lineCap == other.lineCap &&
            effect == other.effect &&
            animated == other.animated &&
            animationDuration == other.animationDuration &&
            intensity == other.intensity &&
            detail == other.detail &&
            flowSpeed == other.flowSpeed &&
            particleCount == other.particleCount &&
            turbulence == other.turbulence &&
            trailCount == other.trailCount &&
            phaseOffset == other.phaseOffset &&
            strandCount == other.strandCount &&
            waveFrequency == other.waveFrequency &&
            chromaticAberration == other.chromaticAberration &&
            packetCount == other.packetCount &&
            scanlineOpacity == other.scanlineOpacity &&
            refraction == other.refraction &&
            crossFlare == other.crossFlare &&
            noise == other.noise &&
            pulseWidth == other.pulseWidth &&
            quality == other.quality &&
            latticeDensity == other.latticeDensity &&
            trailPersistence == other.trailPersistence &&
            photonSpread == other.photonSpread &&
            interference == other.interference;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        variant,
        color,
        endColor,
        secondaryColor,
        coreColor,
        thickness,
        dashLength,
        gapLength,
        glowRadius,
        lineCap,
        effect,
        animated,
        animationDuration,
        intensity,
        detail,
        flowSpeed,
        particleCount,
        turbulence,
        trailCount,
        phaseOffset,
        strandCount,
        waveFrequency,
        chromaticAberration,
        packetCount,
        scanlineOpacity,
        refraction,
        crossFlare,
        noise,
        pulseWidth,
        quality,
        latticeDensity,
        trailPersistence,
        photonSpread,
        interference,
      ]);
}

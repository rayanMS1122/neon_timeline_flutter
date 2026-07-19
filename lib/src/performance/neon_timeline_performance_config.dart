import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/neon_timeline_types.dart';
import '../theme/neon_timeline_theme.dart';

/// High-level rendering budget for timelines.
enum NeonTimelinePerformanceProfile {
  adaptive,
  batterySaver,
  balanced,
  highQuality,
}

/// Web strategy used for large glow surfaces.
enum NeonTimelineWebGlowStrategy { adaptive, layeredContours, nativeBlur }

/// Public performance policy shared by generic and planner timelines.
///
/// The policy never changes layout, colors, semantics, or public interaction.
/// It only limits continuous motion and expensive rendering detail.
@immutable
class NeonTimelinePerformanceConfig {
  const NeonTimelinePerformanceConfig({
    this.profile = NeonTimelinePerformanceProfile.adaptive,
    this.motionFramesPerSecond,
    this.maxAnimatedEntries,
    this.pauseMotionWhileScrolling,
    this.enableBackdropBlur,
    this.enableParallax,
    this.enableParticles,
    this.cacheExtent,
    this.motionStartupDelay,
    this.webGlowStrategy = NeonTimelineWebGlowStrategy.adaptive,
    this.renderQuality,
  }) : assert(
         motionFramesPerSecond == null ||
             (motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
       ),
       assert(maxAnimatedEntries == null || maxAnimatedEntries >= 0),
       assert(cacheExtent == null || cacheExtent >= 0);

  const NeonTimelinePerformanceConfig.adaptive()
    : this(profile: NeonTimelinePerformanceProfile.adaptive);

  const NeonTimelinePerformanceConfig.batterySaver()
    : this(
        profile: NeonTimelinePerformanceProfile.batterySaver,
        motionFramesPerSecond: 12,
        maxAnimatedEntries: 0,
        pauseMotionWhileScrolling: true,
        enableBackdropBlur: false,
        enableParallax: false,
        enableParticles: false,
        cacheExtent: 80,
        motionStartupDelay: const Duration(milliseconds: 220),
        webGlowStrategy: NeonTimelineWebGlowStrategy.layeredContours,
        renderQuality: NeonTimelineRenderQuality.balanced,
      );

  const NeonTimelinePerformanceConfig.balanced()
    : this(
        profile: NeonTimelinePerformanceProfile.balanced,
        motionFramesPerSecond: 24,
        maxAnimatedEntries: 1,
        pauseMotionWhileScrolling: true,
        enableBackdropBlur: false,
        cacheExtent: 160,
        motionStartupDelay: const Duration(milliseconds: 120),
        webGlowStrategy: NeonTimelineWebGlowStrategy.layeredContours,
        renderQuality: NeonTimelineRenderQuality.balanced,
      );

  const NeonTimelinePerformanceConfig.highQuality()
    : this(
        profile: NeonTimelinePerformanceProfile.highQuality,
        motionFramesPerSecond: 60,
        maxAnimatedEntries: 4,
        pauseMotionWhileScrolling: false,
        enableParticles: true,
        cacheExtent: 320,
        motionStartupDelay: const Duration(milliseconds: 40),
        webGlowStrategy: NeonTimelineWebGlowStrategy.adaptive,
        renderQuality: NeonTimelineRenderQuality.ultra,
      );

  final NeonTimelinePerformanceProfile profile;
  final int? motionFramesPerSecond;
  final int? maxAnimatedEntries;
  final bool? pauseMotionWhileScrolling;
  final bool? enableBackdropBlur;
  final bool? enableParallax;
  final bool? enableParticles;
  final double? cacheExtent;
  final Duration? motionStartupDelay;
  final NeonTimelineWebGlowStrategy webGlowStrategy;
  final NeonTimelineRenderQuality? renderQuality;

  NeonTimelineResolvedPerformance resolve(
    BuildContext context, {
    required int itemCount,
  }) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final dense = itemCount >= 40;
    final veryDense = itemCount >= 160;

    var fps = 24;
    var maxAnimated = 1;
    var pauseOnScroll = true;
    var backdrop = !kIsWeb && !dense;
    var parallax = !kIsWeb && !dense;
    var particles = !veryDense;
    var extent = dense ? 100.0 : 180.0;
    var startupDelay = const Duration(milliseconds: 120);
    var quality = dense
        ? NeonTimelineRenderQuality.balanced
        : NeonTimelineRenderQuality.high;

    switch (profile) {
      case NeonTimelinePerformanceProfile.adaptive:
        if (kIsWeb) {
          fps = veryDense ? 12 : (dense ? 16 : 20);
          maxAnimated = veryDense ? 0 : 1;
          backdrop = false;
          parallax = false;
          quality = NeonTimelineRenderQuality.balanced;
          startupDelay = const Duration(milliseconds: 180);
        } else if (veryDense) {
          fps = 16;
          maxAnimated = 1;
          backdrop = false;
          parallax = false;
          quality = NeonTimelineRenderQuality.balanced;
        } else if (dense) {
          fps = 20;
          maxAnimated = 1;
          backdrop = false;
          quality = NeonTimelineRenderQuality.balanced;
        }
        break;
      case NeonTimelinePerformanceProfile.batterySaver:
        fps = 12;
        maxAnimated = 0;
        backdrop = false;
        parallax = false;
        particles = false;
        extent = 80;
        startupDelay = const Duration(milliseconds: 220);
        quality = NeonTimelineRenderQuality.balanced;
        break;
      case NeonTimelinePerformanceProfile.balanced:
        fps = kIsWeb ? 20 : 24;
        maxAnimated = 1;
        pauseOnScroll = true;
        backdrop = false;
        parallax = !kIsWeb && !dense;
        particles = !veryDense;
        extent = dense ? 100 : 160;
        startupDelay = const Duration(milliseconds: 120);
        quality = NeonTimelineRenderQuality.balanced;
        break;
      case NeonTimelinePerformanceProfile.highQuality:
        fps = kIsWeb ? 30 : 60;
        maxAnimated = dense ? 1 : 4;
        pauseOnScroll = false;
        backdrop = !kIsWeb;
        parallax = !kIsWeb;
        particles = true;
        extent = 320;
        startupDelay = const Duration(milliseconds: 40);
        quality = NeonTimelineRenderQuality.ultra;
        break;
    }

    if (reduceMotion) {
      fps = 1;
      maxAnimated = 0;
      backdrop = false;
      parallax = false;
      particles = false;
    }

    final resolvedBackdrop = reduceMotion
        ? false
        : (enableBackdropBlur ?? backdrop);
    return NeonTimelineResolvedPerformance(
      motionFramesPerSecond: reduceMotion
          ? 1
          : (motionFramesPerSecond ?? fps).clamp(1, 120).toInt(),
      maxAnimatedEntries: reduceMotion
          ? 0
          : (maxAnimatedEntries ?? maxAnimated).clamp(0, 1000).toInt(),
      pauseMotionWhileScrolling: pauseMotionWhileScrolling ?? pauseOnScroll,
      enableBackdropBlur: resolvedBackdrop,
      enableParallax: reduceMotion ? false : (enableParallax ?? parallax),
      enableParticles: reduceMotion ? false : (enableParticles ?? particles),
      cacheExtent: _safeExtent(cacheExtent ?? extent),
      motionStartupDelay: _safeDelay(motionStartupDelay ?? startupDelay),
      webGlowStrategy: _resolvedWebGlowStrategy(resolvedBackdrop),
      renderQuality: renderQuality ?? quality,
      reduceMotion: reduceMotion,
    );
  }

  NeonTimelineWebGlowStrategy _resolvedWebGlowStrategy(bool backdrop) {
    if (webGlowStrategy != NeonTimelineWebGlowStrategy.adaptive) {
      return webGlowStrategy;
    }
    if (kIsWeb || !backdrop) {
      return NeonTimelineWebGlowStrategy.layeredContours;
    }
    return NeonTimelineWebGlowStrategy.nativeBlur;
  }

  static double _safeExtent(double value) {
    return value.isFinite && value >= 0 ? value : 160;
  }

  static Duration _safeDelay(Duration value) {
    return value.isNegative ? Duration.zero : value;
  }
}

/// Runtime-resolved performance values.
@immutable
class NeonTimelineResolvedPerformance {
  const NeonTimelineResolvedPerformance({
    required this.motionFramesPerSecond,
    required this.maxAnimatedEntries,
    required this.pauseMotionWhileScrolling,
    required this.enableBackdropBlur,
    required this.enableParallax,
    required this.enableParticles,
    required this.cacheExtent,
    required this.motionStartupDelay,
    required this.webGlowStrategy,
    required this.renderQuality,
    required this.reduceMotion,
  });

  final int motionFramesPerSecond;
  final int maxAnimatedEntries;
  final bool pauseMotionWhileScrolling;
  final bool enableBackdropBlur;
  final bool enableParallax;
  final bool enableParticles;
  final double cacheExtent;
  final Duration motionStartupDelay;
  final NeonTimelineWebGlowStrategy webGlowStrategy;
  final NeonTimelineRenderQuality renderQuality;
  final bool reduceMotion;

  /// Applies only cost controls. Layout and color values remain unchanged.
  NeonTimelineThemeData tuneTheme(NeonTimelineThemeData theme) {
    final indicator = theme.indicatorStyle.copyWith(
      quality: renderQuality,
      particleCount: enableParticles ? theme.indicatorStyle.particleCount : 0,
      sparkCount: enableParticles ? theme.indicatorStyle.sparkCount : 0,
      noise: enableParticles ? theme.indicatorStyle.noise : 0,
    );
    final connector = theme.connectorStyle.copyWith(
      quality: renderQuality,
      particleCount: enableParticles ? theme.connectorStyle.particleCount : 0,
      packetCount: enableParticles ? theme.connectorStyle.packetCount : 0,
      noise: enableParticles ? theme.connectorStyle.noise : 0,
    );
    return theme.copyWith(indicatorStyle: indicator, connectorStyle: connector);
  }
}

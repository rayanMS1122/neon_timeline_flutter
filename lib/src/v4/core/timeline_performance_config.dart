import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../performance/neon_timeline_performance_config.dart';

enum TimelinePerformanceProfile {
  adaptive,
  batterySaver,
  balanced,
  highQuality,
}

/// Neutral 4.x performance policy with a compatibility bridge to 3.x painters.
@immutable
class TimelinePerformanceConfig {
  const TimelinePerformanceConfig({
    this.profile = TimelinePerformanceProfile.adaptive,
    this.motionFramesPerSecond,
    this.maxAnimatedEntries,
    this.pauseMotionWhileScrolling,
    this.enableBackdropBlur,
    this.enableParallax,
    this.enableParticles,
    this.cacheExtent,
    this.virtualizationThreshold = 80,
    this.overscanItems = 4,
  }) : assert(
         motionFramesPerSecond == null ||
             (motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
       ),
       assert(maxAnimatedEntries == null || maxAnimatedEntries >= 0),
       assert(cacheExtent == null || cacheExtent >= 0),
       assert(virtualizationThreshold >= 0),
       assert(overscanItems >= 0);

  const TimelinePerformanceConfig.adaptive()
    : this(profile: TimelinePerformanceProfile.adaptive);

  const TimelinePerformanceConfig.batterySaver()
    : this(
        profile: TimelinePerformanceProfile.batterySaver,
        motionFramesPerSecond: 12,
        maxAnimatedEntries: 0,
        pauseMotionWhileScrolling: true,
        enableBackdropBlur: false,
        enableParallax: false,
        enableParticles: false,
        cacheExtent: 80,
        virtualizationThreshold: 30,
        overscanItems: 2,
      );

  const TimelinePerformanceConfig.balanced()
    : this(
        profile: TimelinePerformanceProfile.balanced,
        motionFramesPerSecond: 24,
        maxAnimatedEntries: 1,
        pauseMotionWhileScrolling: true,
        enableBackdropBlur: false,
        enableParallax: false,
        enableParticles: false,
        cacheExtent: 160,
        virtualizationThreshold: 50,
        overscanItems: 4,
      );

  const TimelinePerformanceConfig.highQuality()
    : this(
        profile: TimelinePerformanceProfile.highQuality,
        motionFramesPerSecond: 60,
        maxAnimatedEntries: 4,
        pauseMotionWhileScrolling: false,
        enableBackdropBlur: true,
        enableParallax: true,
        enableParticles: true,
        cacheExtent: 320,
        virtualizationThreshold: 120,
        overscanItems: 8,
      );

  final TimelinePerformanceProfile profile;
  final int? motionFramesPerSecond;
  final int? maxAnimatedEntries;
  final bool? pauseMotionWhileScrolling;
  final bool? enableBackdropBlur;
  final bool? enableParallax;
  final bool? enableParticles;
  final double? cacheExtent;
  final int virtualizationThreshold;
  final int overscanItems;

  /// Resolves `adaptive` into deterministic values for the current workload.
  /// This method is pure and therefore directly unit-testable.
  TimelinePerformanceConfig resolve({
    required bool isWeb,
    required int entryCount,
    bool reduceMotion = false,
    bool lowPowerMode = false,
  }) {
    if (reduceMotion) {
      return TimelinePerformanceConfig(
        profile: profile,
        motionFramesPerSecond: 1,
        maxAnimatedEntries: 0,
        pauseMotionWhileScrolling: true,
        enableBackdropBlur: false,
        enableParallax: false,
        enableParticles: false,
        cacheExtent: cacheExtent ?? 100,
        virtualizationThreshold: virtualizationThreshold,
        overscanItems: math.min(overscanItems, 3).toInt(),
      );
    }

    if (profile != TimelinePerformanceProfile.adaptive) return this;
    final large = entryCount >= virtualizationThreshold;
    final veryLarge = entryCount >= math.max(virtualizationThreshold * 5, 500);
    final constrained = lowPowerMode || isWeb || large;
    return TimelinePerformanceConfig(
      profile: TimelinePerformanceProfile.adaptive,
      motionFramesPerSecond:
          motionFramesPerSecond ??
          (veryLarge
              ? 12
              : constrained
              ? 18
              : 24),
      maxAnimatedEntries: maxAnimatedEntries ?? (veryLarge ? 0 : 1),
      pauseMotionWhileScrolling: pauseMotionWhileScrolling ?? true,
      enableBackdropBlur:
          enableBackdropBlur ?? (!isWeb && !large && !lowPowerMode),
      enableParallax: enableParallax ?? (!isWeb && !large && !lowPowerMode),
      enableParticles: enableParticles ?? false,
      cacheExtent:
          cacheExtent ??
          (veryLarge
              ? 80
              : isWeb
              ? 120
              : 180),
      virtualizationThreshold: virtualizationThreshold,
      overscanItems: veryLarge
          ? math.min(overscanItems, 2).toInt()
          : overscanItems,
    );
  }

  TimelinePerformanceConfig copyWith({
    TimelinePerformanceProfile? profile,
    int? motionFramesPerSecond,
    bool clearMotionFramesPerSecond = false,
    int? maxAnimatedEntries,
    bool clearMaxAnimatedEntries = false,
    bool? pauseMotionWhileScrolling,
    bool? enableBackdropBlur,
    bool? enableParallax,
    bool? enableParticles,
    double? cacheExtent,
    bool clearCacheExtent = false,
    int? virtualizationThreshold,
    int? overscanItems,
  }) {
    return TimelinePerformanceConfig(
      profile: profile ?? this.profile,
      motionFramesPerSecond: clearMotionFramesPerSecond
          ? null
          : (motionFramesPerSecond ?? this.motionFramesPerSecond),
      maxAnimatedEntries: clearMaxAnimatedEntries
          ? null
          : (maxAnimatedEntries ?? this.maxAnimatedEntries),
      pauseMotionWhileScrolling:
          pauseMotionWhileScrolling ?? this.pauseMotionWhileScrolling,
      enableBackdropBlur: enableBackdropBlur ?? this.enableBackdropBlur,
      enableParallax: enableParallax ?? this.enableParallax,
      enableParticles: enableParticles ?? this.enableParticles,
      cacheExtent: clearCacheExtent ? null : (cacheExtent ?? this.cacheExtent),
      virtualizationThreshold:
          virtualizationThreshold ?? this.virtualizationThreshold,
      overscanItems: overscanItems ?? this.overscanItems,
    );
  }

  NeonTimelinePerformanceConfig toLegacy() {
    final base = switch (profile) {
      TimelinePerformanceProfile.adaptive =>
        const NeonTimelinePerformanceConfig.adaptive(),
      TimelinePerformanceProfile.batterySaver =>
        const NeonTimelinePerformanceConfig.batterySaver(),
      TimelinePerformanceProfile.balanced =>
        const NeonTimelinePerformanceConfig.balanced(),
      TimelinePerformanceProfile.highQuality =>
        const NeonTimelinePerformanceConfig.highQuality(),
    };
    return NeonTimelinePerformanceConfig(
      profile: base.profile,
      motionFramesPerSecond:
          motionFramesPerSecond ?? base.motionFramesPerSecond,
      maxAnimatedEntries: maxAnimatedEntries ?? base.maxAnimatedEntries,
      pauseMotionWhileScrolling:
          pauseMotionWhileScrolling ?? base.pauseMotionWhileScrolling,
      enableBackdropBlur: enableBackdropBlur ?? base.enableBackdropBlur,
      enableParallax: enableParallax ?? base.enableParallax,
      enableParticles: enableParticles ?? base.enableParticles,
      cacheExtent: cacheExtent ?? base.cacheExtent,
      motionStartupDelay: base.motionStartupDelay,
      webGlowStrategy: base.webGlowStrategy,
      renderQuality: base.renderQuality,
    );
  }
}

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Applies [filter] to [Paint.maskFilter] only when [filter] is non-null.
/// On Web all [NeonBlurCache] entries are null so this is a no-op, eliminating
/// the software-rasterised Gaussian blur that causes 100 % CPU on Flutter Web.
extension NeonPaintBlur on Paint {
  // ignore: avoid_returning_this
  Paint applyBlur(MaskFilter? filter) {
    if (filter != null) maskFilter = filter;
    return this;
  }
}


/// Fast trigonometry lookup table for painter hot paths.
///
/// Replaces `math.sin` / `math.cos` with an array lookup + linear
/// interpolation, cutting ~80 % of the transcendental-function overhead in
/// painters that call trig dozens of times per frame.
///
/// Accuracy: ~0.0001 radians worst-case — invisible at display resolution.
class NeonTrig {
  NeonTrig._();

  static const int _kSize = 4096; // power-of-two for fast masking
  static const int _kMask = _kSize - 1;
  static const double _kScale = _kSize / (math.pi * 2);
  static const double _k2Pi = math.pi * 2;

  static final Float64List _sinTable = () {
    final t = Float64List(_kSize + 1);
    for (var i = 0; i <= _kSize; i++) {
      t[i] = math.sin(i / _kSize * _k2Pi);
    }
    return t;
  }();

  /// Fast `sin(x)` — equivalent to `math.sin(x)` for painter purposes.
  static double sin(double x) {
    // Normalize x into [0, 2π).
    final pos = (x % _k2Pi + _k2Pi) % _k2Pi;
    final idx = pos * _kScale;
    final i = idx.toInt();
    final frac = idx - i;
    // Linear interpolation between two table entries.
    return _sinTable[i & _kMask] * (1.0 - frac) +
        _sinTable[(i + 1) & _kMask] * frac;
  }

  /// Fast `cos(x)` — implemented as `sin(x + π/2)`.
  static double cos(double x) => sin(x + math.pi / 2);
}

/// Cached [MaskFilter] values derived from [glowRadius].
///
/// On **Flutter Web**, all entries are `null`. Flutter Web has no GPU-backed
/// Gaussian blur — `MaskFilter.blur` falls back to a software rasteriser that
/// runs on the UI thread (CPU), causing 100 % CPU usage per animator. Skipping
/// the blur on Web still preserves the glow look through the overlapping
/// semi-transparent radial layers already drawn by every effect.
///
/// On native platforms the filters are allocated once per painter instance
/// (i.e., once per style change) and reused across frames.
class NeonBlurCache {
  NeonBlurCache({required double glowRadius})
  // On Web every field is null — painters null-check before assigning.
      : shadow = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(4.0, glowRadius * 0.52),
              ),
        auraSoft = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(8.0, glowRadius * 1.35),
              ),
        auraHard = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(4.5, glowRadius * 0.72),
              ),
        bloomOuter = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(5.0, glowRadius * 1.38),
              ),
        bloomMid = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(3.0, glowRadius * 0.74),
              ),
        bloomInner = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(1.5, glowRadius * 0.32),
              ),
        focusHalo = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(2.0, glowRadius * 0.24),
              ),
        sparkGlow = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(5.0, glowRadius * 0.55),
              ),
        singularityDisk = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(1.5, glowRadius * 0.22),
              ),
        singularityHorizon = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(4.0, glowRadius * 0.42),
              ),
        coronaArc = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(1.2, glowRadius * 0.18),
              ),
        energyGlow = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(3.0, glowRadius * 1.35),
              ),
        energyMid = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(1.5, glowRadius * 0.52),
              ),
        warpField = kIsWeb
            ? null
            : MaskFilter.blur(
                BlurStyle.normal,
                math.max(4.0, glowRadius * 1.5),
              );

  // Indicator blurs — null on Web.
  final MaskFilter? shadow;
  final MaskFilter? auraSoft;
  final MaskFilter? auraHard;
  final MaskFilter? bloomOuter;
  final MaskFilter? bloomMid;
  final MaskFilter? bloomInner;
  final MaskFilter? focusHalo;
  final MaskFilter? sparkGlow;
  final MaskFilter? singularityDisk;
  final MaskFilter? singularityHorizon;
  final MaskFilter? coronaArc;

  // Connector blurs — null on Web.
  final MaskFilter? energyGlow;
  final MaskFilter? energyMid;
  final MaskFilter? warpField;
}

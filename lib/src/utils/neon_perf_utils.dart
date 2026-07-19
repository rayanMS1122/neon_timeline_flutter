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
/// Replaces repeated `math.sin` / `math.cos` calls with a 4096-entry lookup.
/// The table is initialized once; painter hot paths then perform only arithmetic
/// and an indexed read.
class NeonTrig {
  NeonTrig._();

  static const int _kSize = 4096;
  static const int _kMask = _kSize - 1;
  static const double _kTau = math.pi * 2;
  static const double _kScale = _kSize / _kTau;

  static final Float64List _sinTable = () {
    final table = Float64List(_kSize);
    for (var index = 0; index < _kSize; index++) {
      table[index] = math.sin(index / _kSize * _kTau);
    }
    return table;
  }();

  /// Fast `sin(x)` for painter hot paths.
  ///
  /// A 4096-sample nearest lookup avoids modulo, interpolation, and repeated
  /// transcendental calls. The maximum angular quantization is below one
  /// physical pixel for the package's rendered geometry.
  static double sin(double radians) {
    final index = (radians * _kScale).round() & _kMask;
    return _sinTable[index];
  }

  /// Fast `cos(x)` for painter hot paths.
  static double cos(double radians) {
    final index = (radians * _kScale + _kSize / 4).round() & _kMask;
    return _sinTable[index];
  }

  /// Fast sine for a normalized turn where `1.0` equals one full rotation.
  static double sinTurns(double turns) {
    final index = (turns * _kSize).round() & _kMask;
    return _sinTable[index];
  }

  /// Fast cosine for a normalized turn where `1.0` equals one full rotation.
  static double cosTurns(double turns) {
    final index = (turns * _kSize + _kSize / 4).round() & _kMask;
    return _sinTable[index];
  }
}

/// Reuses mutable [Path] objects inside one painter delegate.
class NeonPathPool {
  final List<Path> _paths = <Path>[];
  int _cursor = 0;

  /// Starts a new frame.
  void reset() => _cursor = 0;

  /// Returns an empty reusable path.
  Path next() {
    final Path path;
    if (_cursor < _paths.length) {
      path = _paths[_cursor]..reset();
    } else {
      path = Path();
      _paths.add(path);
    }
    _cursor++;
    return path;
  }
}

/// Quantizes expensive animated geometry while color and opacity can continue
/// to update at the motion clock rate.
/// Reuses mutable [Paint] objects inside one painter delegate.
///
/// Canvas draw calls consume the current paint state immediately, so a painter
/// can safely reset and reuse the same bounded pool on the next frame. This
/// removes dozens of short-lived Dart and engine wrapper allocations from the
/// advanced indicator and connector hot paths.
class NeonPaintPool {
  final List<Paint> _paints = <Paint>[];
  int _cursor = 0;

  /// Starts a new frame. Previously allocated paint objects stay retained.
  void reset() => _cursor = 0;

  /// Returns a paint reset to Flutter defaults.
  Paint next() {
    final Paint paint;
    if (_cursor < _paints.length) {
      paint = _paints[_cursor];
    } else {
      paint = Paint();
      _paints.add(paint);
    }
    _cursor++;
    return paint
      ..isAntiAlias = true
      ..color = const Color(0xFF000000)
      ..blendMode = BlendMode.srcOver
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 4
      ..shader = null
      ..maskFilter = null
      ..colorFilter = null
      ..imageFilter = null
      ..filterQuality = FilterQuality.none
      ..invertColors = false;
  }
}

class NeonPhaseQuantizer {
  NeonPhaseQuantizer._();

  /// Returns a stable bucket for a normalized repeating phase.
  static int bucket(double phase, {int buckets = 96}) {
    final safeBuckets = buckets.clamp(1, 512).toInt();
    return ((phase % 1.0) * safeBuckets).floor() % safeBuckets;
  }

  /// Returns the normalized phase represented by [bucket].
  static double phaseFor(int bucket, {int buckets = 96}) {
    final safeBuckets = buckets.clamp(1, 512).toInt();
    return (bucket % safeBuckets) / safeBuckets;
  }
}

/// Shared, quantized blur cache for painter hot paths.
///
/// Gaussian blur is disabled on Flutter Web, where dozens of animated blur
/// passes can dominate the UI thread. Native renderers reuse one filter per
/// quarter-pixel sigma instead of allocating a new engine object every frame.
class NeonBlur {
  NeonBlur._();

  static final Map<int, MaskFilter> _normalCache = <int, MaskFilter>{};

  /// Returns a cached normal blur, or `null` when blur should be skipped.
  static MaskFilter? normal(double sigma) {
    if (kIsWeb || !sigma.isFinite || sigma <= 0) return null;
    final key = (sigma.clamp(0.0, 64.0) * 4).round();
    return _normalCache.putIfAbsent(
      key,
      () => MaskFilter.blur(BlurStyle.normal, key / 4),
    );
  }
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
    : shadow = NeonBlur.normal(math.max(4.0, glowRadius * 0.52)),
      auraSoft = NeonBlur.normal(math.max(8.0, glowRadius * 1.35)),
      auraHard = NeonBlur.normal(math.max(4.5, glowRadius * 0.72)),
      bloomOuter = NeonBlur.normal(math.max(5.0, glowRadius * 1.38)),
      bloomMid = NeonBlur.normal(math.max(3.0, glowRadius * 0.74)),
      bloomInner = NeonBlur.normal(math.max(1.5, glowRadius * 0.32)),
      focusHalo = NeonBlur.normal(math.max(2.0, glowRadius * 0.24)),
      sparkGlow = NeonBlur.normal(math.max(5.0, glowRadius * 0.55)),
      singularityDisk = NeonBlur.normal(math.max(1.5, glowRadius * 0.22)),
      singularityHorizon = NeonBlur.normal(math.max(4.0, glowRadius * 0.42)),
      coronaArc = NeonBlur.normal(math.max(1.2, glowRadius * 0.18)),
      energyGlow = NeonBlur.normal(math.max(3.0, glowRadius * 1.35)),
      energyMid = NeonBlur.normal(math.max(1.5, glowRadius * 0.52)),
      warpField = NeonBlur.normal(math.max(4.0, glowRadius * 1.5));

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
  final MaskFilter? energyGlow;
  final MaskFilter? energyMid;
  final MaskFilter? warpField;
}

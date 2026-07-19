import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/neon_timeline_types.dart';
import '../theme/neon_timeline_theme.dart';
import '../utils/neon_perf_utils.dart';
import 'neon_timeline_motion.dart';

/// A solid, energy, plasma, warp, hologram, or photon-lattice connector.
class NeonTimelineConnector extends StatefulWidget {
  /// Creates a connector that fills the available main-axis extent.
  const NeonTimelineConnector({
    this.axis = Axis.vertical,
    this.style,
    super.key,
  });

  /// Direction in which the line is painted.
  final Axis axis;

  /// Optional style override.
  final NeonTimelineConnectorStyle? style;

  @override
  State<NeonTimelineConnector> createState() => _NeonTimelineConnectorState();
}

class _NeonTimelineConnectorState extends State<NeonTimelineConnector> {
  NeonTimelineMotionClock? _localClock;
  NeonTimelineMotionData? _sharedMotion;

  NeonTimelineMotionClock _ensureLocalClock(NeonTimelineConnectorStyle style) {
    final clock = _localClock ??= NeonTimelineMotionClock(
      duration: style.animationDuration,
      framesPerSecond: 24,
      initialValue: 0.28,
    );
    clock.configure(duration: style.animationDuration, framesPerSecond: 24);
    return clock;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sharedMotion = NeonTimelineMotionScope.maybeOf(context);
    _configureAnimation(_resolvedStyle);
  }

  @override
  void didUpdateWidget(covariant NeonTimelineConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style) {
      _configureAnimation(_resolvedStyle);
    }
  }

  NeonTimelineConnectorStyle get _resolvedStyle =>
      widget.style ?? NeonTimelineTheme.of(context).connectorStyle;

  Animation<double> _effectiveAnimation(NeonTimelineConnectorStyle style) {
    final advanced = style.effect != NeonConnectorEffect.classic;
    final shouldAnimate = advanced && style.animated;
    if (shouldAnimate && _sharedMotion?.enabled == true) {
      return _sharedMotion!.animation;
    }
    if (shouldAnimate && _sharedMotion == null) {
      return _ensureLocalClock(style).animation;
    }
    return const AlwaysStoppedAnimation<double>(0.28);
  }

  void _configureAnimation(NeonTimelineConnectorStyle style) {
    _localClock?.configure(
      duration: style.animationDuration,
      framesPerSecond: 24,
    );
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    final advanced = style.effect != NeonConnectorEffect.classic;
    final shouldAnimate =
        advanced &&
        style.animated &&
        !reduceMotion &&
        tickerEnabled &&
        _sharedMotion == null;
    if (shouldAnimate) {
      _ensureLocalClock(style).start();
    } else {
      _localClock?.stop(value: 0.28);
    }
  }

  @override
  void dispose() {
    _localClock?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolvedStyle;
    final animation = _effectiveAnimation(style);
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: style.effect != NeonConnectorEffect.classic,
        willChange:
            style.animated && animation is! AlwaysStoppedAnimation<double>,
        painter: _ConnectorPainter(
          axis: widget.axis,
          style: style,
          animation: animation,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.axis,
    required this.style,
    required this.animation,
  }) : super(repaint: animation);

  final Axis axis;
  final NeonTimelineConnectorStyle style;
  final Animation<double> animation;
  final NeonPaintPool _paintPool = NeonPaintPool();
  final NeonPathPool _pathPool = NeonPathPool();

  // Reusable Paint objects for draws that don't need a per-call shader.
  // Allocating these once and mutating color/strokeWidth is faster than
  // creating a new _paintPool.next() on every frame.
  final Paint _particleGlowPaint = Paint();
  final Paint _particleDotPaint = Paint();
  static final MaskFilter? _particleBlur = NeonBlur.normal(1.8);

  // Cached blur filters — computed once per painter instance.
  late final NeonBlurCache _blurs = NeonBlurCache(glowRadius: style.glowRadius);
  final Map<int, Path> _wavePathCache = <int, Path>{};

  double get _phase =>
      ((animation.value + style.phaseOffset) * style.flowSpeed) % 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _paintPool.reset();
    _pathPool.reset();

    final start = axis == Axis.vertical
        ? Offset(size.width / 2, 0)
        : Offset(0, size.height / 2);
    final end = axis == Axis.vertical
        ? Offset(size.width / 2, size.height)
        : Offset(size.width, size.height / 2);

    switch (style.effect) {
      case NeonConnectorEffect.classic:
        _paintClassicConnector(canvas, size, start, end);
        break;
      case NeonConnectorEffect.energy:
        _paintEnergyConnector(canvas, start, end);
        break;
      case NeonConnectorEffect.plasma:
        _paintPlasmaConnector(canvas, start, end);
        break;
      case NeonConnectorEffect.warp:
        _paintWarpConnector(canvas, start, end);
        break;
      case NeonConnectorEffect.hologram:
        _paintHologramConnector(canvas, start, end);
        break;
      case NeonConnectorEffect.photonLattice:
        _paintPhotonLatticeConnector(canvas, start, end);
        break;
    }
  }

  void _paintClassicConnector(
    Canvas canvas,
    Size size,
    Offset start,
    Offset end,
  ) {
    if (style.glowRadius > 0) {
      _paintLine(
        canvas,
        start,
        end,
        _paintPool.next()
          ..color = style.color.withAlpha(100)
          ..strokeWidth = style.thickness * 2.1
          ..strokeCap = style.lineCap
          ..applyBlur(NeonBlur.normal(style.glowRadius)),
      );
    }

    final paint = _paintPool.next()
      ..strokeWidth = style.thickness
      ..strokeCap = style.lineCap;
    if (style.variant == NeonConnectorVariant.gradient) {
      paint.shader = LinearGradient(
        begin: axis == Axis.vertical
            ? Alignment.topCenter
            : Alignment.centerLeft,
        end: axis == Axis.vertical
            ? Alignment.bottomCenter
            : Alignment.centerRight,
        colors: <Color>[style.color, style.endColor],
      ).createShader(Offset.zero & size);
    } else {
      paint.color = style.color;
    }
    _paintLine(canvas, start, end, paint);
  }

  void _paintEnergyConnector(
    Canvas canvas,
    Offset start,
    Offset end, {
    bool paintFlow = true,
    double baseOpacity = 1,
  }) {
    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    final strength = (style.intensity * baseOpacity).clamp(0.0, 1.0).toDouble();
    final shader = ui.Gradient.linear(
      start,
      end,
      <Color>[
        style.color.withValues(alpha: 0.18 * strength),
        style.color.withValues(alpha: 0.82 * strength),
        style.coreColor.withValues(alpha: 0.98 * strength),
        style.endColor.withValues(alpha: 0.86 * strength),
        style.endColor.withValues(alpha: 0.16 * strength),
      ],
      const <double>[0, 0.30, 0.50, 0.70, 1],
    );

    if (style.glowRadius > 0) {
      canvas.drawLine(
        start,
        end,
        _paintPool.next()
          ..shader = shader
          ..strokeWidth = style.thickness * 5.8
          ..strokeCap = style.lineCap
          ..applyBlur(_blurs.energyGlow),
      );
      canvas.drawLine(
        start,
        end,
        _paintPool.next()
          ..shader = shader
          ..strokeWidth = style.thickness * 2.8
          ..strokeCap = style.lineCap
          ..applyBlur(_blurs.energyMid),
      );
    }

    if (style.detail > 0.08) {
      _paintChromaticFringes(canvas, frame, strength);
    }

    final mainPaint = _paintPool.next()
      ..strokeWidth = style.thickness
      ..strokeCap = style.lineCap;
    if (style.variant == NeonConnectorVariant.gradient) {
      mainPaint.shader = shader;
    } else {
      mainPaint.color = style.color.withValues(alpha: 0.92 * strength);
    }
    _paintLine(canvas, start, end, mainPaint);

    canvas.drawLine(
      start,
      end,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          start,
          end,
          <Color>[
            Colors.transparent,
            style.coreColor.withValues(alpha: 0.38 * strength),
            style.coreColor.withValues(alpha: 0.92 * strength),
            style.coreColor.withValues(alpha: 0.34 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.34, 0.50, 0.66, 1],
        )
        ..strokeWidth = math.max(0.55, style.thickness * 0.38)
        ..strokeCap = style.lineCap,
    );

    if (style.animated && paintFlow) {
      _paintEnergyFlow(canvas, frame, strength);
    }
  }

  void _paintChromaticFringes(
    Canvas canvas,
    _BeamFrame frame,
    double strength,
  ) {
    final shift =
        math.max(0.45, style.thickness * 0.34) *
        (0.65 + style.chromaticAberration * 0.7);
    final fringeOffset = frame.normal * shift;
    canvas.drawLine(
      frame.start - fringeOffset,
      frame.end - fringeOffset,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          frame.start,
          frame.end,
          <Color>[
            style.secondaryColor.withValues(alpha: 0.06),
            style.color.withValues(alpha: 0.42 * strength * style.detail),
            style.coreColor.withValues(alpha: 0.72 * strength * style.detail),
            Colors.transparent,
          ],
          const <double>[0, 0.34, 0.52, 1],
        )
        ..strokeWidth = math.max(0.65, style.thickness * 0.52)
        ..strokeCap = style.lineCap,
    );
    canvas.drawLine(
      frame.start + fringeOffset,
      frame.end + fringeOffset,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          frame.start,
          frame.end,
          <Color>[
            Colors.transparent,
            style.coreColor.withValues(alpha: 0.58 * strength * style.detail),
            style.endColor.withValues(alpha: 0.48 * strength * style.detail),
            style.endColor.withValues(alpha: 0.04),
          ],
          const <double>[0, 0.45, 0.68, 1],
        )
        ..strokeWidth = math.max(0.55, style.thickness * 0.46)
        ..strokeCap = style.lineCap,
    );
  }

  void _paintPlasmaConnector(Canvas canvas, Offset start, Offset end) {
    _paintEnergyConnector(canvas, start, end, paintFlow: false);

    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    final strength = style.intensity.clamp(0.0, 1.0).toDouble();
    _paintPlasmaSheath(canvas, frame, strength);

    if (!style.animated) return;
    for (var trail = 0; trail < style.trailCount; trail++) {
      final trailPhase = (_phase + trail / style.trailCount) % 1.0;
      final opacity = 1 - trail / (style.trailCount + 1) * 0.52;
      _paintEnergyFlow(
        canvas,
        frame,
        strength,
        phaseOverride: trailPhase,
        opacity: opacity,
        paintParticles: trail == 0,
      );
    }
  }

  void _paintPlasmaSheath(Canvas canvas, _BeamFrame frame, double strength) {
    if (style.turbulence <= 0 || style.detail <= 0.05) return;
    final waveCount = style.detail > 0.72 ? 3 : 2;
    final amplitude =
        math.max(0.8, style.thickness * 1.45) * style.turbulence * style.detail;

    for (var wave = 0; wave < waveCount; wave++) {
      final path = _wavePath(
        frame,
        amplitude: amplitude * (1 - wave * 0.14),
        frequency: style.waveFrequency * (0.72 + wave * 0.18),
        phase: _phase * math.pi * 2 * (wave.isEven ? 1.0 : -0.72) + wave * 1.8,
      );
      final color = wave.isEven ? style.color : style.endColor;
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = style.thickness * (1.8 - wave * 0.28)
          ..color = color.withValues(
            alpha: (0.16 - wave * 0.025) * strength * style.detail,
          )
          ..applyBlur(NeonBlur.normal(math.max(1.5, style.glowRadius * 0.42))),
      );
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(0.38, style.thickness * 0.24)
          ..color = color.withValues(
            alpha: (0.34 - wave * 0.055) * strength * style.detail,
          ),
      );
    }
  }

  void _paintWarpConnector(Canvas canvas, Offset start, Offset end) {
    _paintEnergyConnector(
      canvas,
      start,
      end,
      paintFlow: false,
      baseOpacity: 0.88,
    );
    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    final strength = style.intensity.clamp(0.0, 1.0).toDouble();

    _paintWarpField(canvas, frame, strength);
    _paintBraidedStrands(canvas, frame, strength);
    _paintRefractionShimmer(canvas, frame, strength);

    if (style.animated && style.packetCount > 0) {
      for (var packet = 0; packet < style.packetCount; packet++) {
        final packetPhase = (_phase + packet / style.packetCount) % 1.0;
        _paintWarpPacket(
          canvas,
          frame,
          packetPhase,
          strength * (1 - packet * 0.08),
          paintParticles: packet == 0,
        );
      }
    }
  }

  void _paintWarpField(Canvas canvas, _BeamFrame frame, double strength) {
    final fieldWidth = style.thickness * (7 + style.refraction * 5);
    canvas.drawLine(
      frame.start,
      frame.end,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          frame.start,
          frame.end,
          <Color>[
            Colors.transparent,
            style.secondaryColor.withValues(alpha: 0.08 * strength),
            style.color.withValues(alpha: 0.11 * strength),
            style.endColor.withValues(alpha: 0.08 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.22, 0.50, 0.78, 1],
        )
        ..strokeWidth = fieldWidth
        ..strokeCap = StrokeCap.round
        ..applyBlur(_blurs.warpField),
    );

    if (style.crossFlare <= 0) return;
    final count = math.max(3, (3 + style.detail * 4).round());
    for (var index = 0; index < count; index++) {
      final t = (index + 0.5) / count;
      final point = frame.pointAt(t);
      final envelope = NeonTrig.sin(t * math.pi);
      final half = style.thickness * (2.2 + style.crossFlare * 3.8) * envelope;
      canvas.drawLine(
        point - frame.normal * half,
        point + frame.normal * half,
        _paintPool.next()
          ..shader = ui.Gradient.linear(
            point - frame.normal * half,
            point + frame.normal * half,
            <Color>[
              Colors.transparent,
              style.secondaryColor.withValues(alpha: 0.12 * strength),
              style.coreColor.withValues(alpha: 0.32 * strength),
              style.tertiaryFallback.withValues(alpha: 0.12 * strength),
              Colors.transparent,
            ],
            const <double>[0, 0.35, 0.5, 0.65, 1],
          )
          ..strokeWidth = 0.55
          ..strokeCap = StrokeCap.round
          ..applyBlur(NeonBlur.normal(1.6)),
      );
    }
  }

  void _paintBraidedStrands(Canvas canvas, _BeamFrame frame, double strength) {
    final amplitude =
        math.max(0.9, style.thickness * 1.65) * (0.45 + style.turbulence * 0.9);
    for (var strand = 0; strand < style.strandCount; strand++) {
      final offsetPhase = strand / style.strandCount * math.pi * 2;
      final direction = strand.isEven ? 1.0 : -1.0;
      final path = _wavePath(
        frame,
        amplitude: amplitude * (0.72 + (strand % 3) * 0.12),
        frequency: style.waveFrequency * (0.82 + (strand % 2) * 0.18),
        phase:
            offsetPhase +
            _phase * math.pi * 2 * direction * (0.54 + strand * 0.05),
      );
      final color = switch (strand % 3) {
        0 => style.color,
        1 => style.secondaryColor,
        _ => style.endColor,
      };
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = style.thickness * (0.62 - strand * 0.035)
          ..color = color.withValues(
            alpha: (0.30 - strand * 0.024) * strength * style.detail,
          )
          ..applyBlur(NeonBlur.normal(math.max(0.8, style.glowRadius * 0.16))),
      );
    }
  }

  void _paintRefractionShimmer(
    Canvas canvas,
    _BeamFrame frame,
    double strength,
  ) {
    if (style.refraction <= 0 || style.detail <= 0.2) return;
    final count = math.max(8, (10 + style.detail * 12).round());
    for (var index = 0; index < count; index++) {
      final t = index / math.max(1, count - 1);
      final seed = index * 71 + (_phase * 30).floor();
      final offset =
          (_hash01(seed) * 2 - 1) *
          style.thickness *
          (1.4 + style.refraction * 1.8);
      final point = frame.pointAt(t) + frame.normal * offset;
      final length = style.thickness * (0.6 + _hash01(seed + 13) * 1.8);
      canvas.drawLine(
        point - frame.direction * length,
        point + frame.direction * length,
        _paintPool.next()
          ..strokeWidth = 0.38
          ..strokeCap = StrokeCap.round
          ..color = (index.isEven ? style.secondaryColor : style.endColor)
              .withValues(
                alpha: 0.16 * strength * style.detail * style.refraction,
              ),
      );
    }
  }

  void _paintWarpPacket(
    Canvas canvas,
    _BeamFrame frame,
    double phase,
    double strength, {
    required bool paintParticles,
  }) {
    final packetLength = math.min(
      frame.length * style.pulseWidth,
      math.max(26.0, style.thickness * 28),
    );
    final centerDistance =
        phase * (frame.length + packetLength) - packetLength / 2;
    final startDistance = (centerDistance - packetLength / 2)
        .clamp(0.0, frame.length)
        .toDouble();
    final endDistance = (centerDistance + packetLength / 2)
        .clamp(0.0, frame.length)
        .toDouble();
    if (endDistance <= startDistance) return;

    final from = frame.start + frame.direction * startDistance;
    final to = frame.start + frame.direction * endDistance;
    final center = Offset.lerp(from, to, 0.5)!;
    canvas.drawLine(
      from,
      to,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          from,
          to,
          <Color>[
            Colors.transparent,
            style.secondaryColor.withValues(alpha: 0.48 * strength),
            style.coreColor.withValues(alpha: 1.0 * strength),
            style.endColor.withValues(alpha: 0.48 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.25, 0.5, 0.75, 1],
        )
        ..strokeWidth = style.thickness * 5.4
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(math.max(2.0, style.glowRadius * 0.72))),
    );
    canvas.drawCircle(
      center,
      math.max(1.2, style.thickness * 0.78),
      _paintPool.next()
        ..color = style.coreColor.withValues(alpha: 0.96 * strength)
        ..applyBlur(NeonBlur.normal(1.5)),
    );

    if (style.crossFlare > 0) {
      final half = style.thickness * (3.2 + style.crossFlare * 5.5);
      canvas.drawLine(
        center - frame.normal * half,
        center + frame.normal * half,
        _paintPool.next()
          ..shader = ui.Gradient.linear(
            center - frame.normal * half,
            center + frame.normal * half,
            <Color>[
              Colors.transparent,
              style.secondaryColor.withValues(alpha: 0.34 * strength),
              style.coreColor.withValues(alpha: 0.90 * strength),
              style.endColor.withValues(alpha: 0.34 * strength),
              Colors.transparent,
            ],
            const <double>[0, 0.36, 0.5, 0.64, 1],
          )
          ..strokeWidth = math.max(0.65, style.thickness * 0.42)
          ..strokeCap = StrokeCap.round
          ..applyBlur(NeonBlur.normal(2.2)),
      );
    }

    if (paintParticles) {
      _paintParticles(canvas, frame, phase, strength);
    }
  }

  void _paintHologramConnector(Canvas canvas, Offset start, Offset end) {
    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    final strength = style.intensity.clamp(0.0, 1.0).toDouble();

    canvas.drawLine(
      start,
      end,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          start,
          end,
          <Color>[
            style.color.withValues(alpha: 0.06 * strength),
            style.color.withValues(alpha: 0.22 * strength),
            style.coreColor.withValues(alpha: 0.34 * strength),
            style.endColor.withValues(alpha: 0.22 * strength),
            style.endColor.withValues(alpha: 0.06 * strength),
          ],
          const <double>[0, 0.24, 0.5, 0.76, 1],
        )
        ..strokeWidth = style.thickness * 4.8
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(math.max(2.0, style.glowRadius * 0.85))),
    );

    final dashPaint = _paintPool.next()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        start,
        end,
        <Color>[style.color, style.coreColor, style.endColor],
        const <double>[0, 0.5, 1],
      );
    _paintSegmentedLine(
      canvas,
      frame,
      dashPaint,
      dashLength: style.dashLength,
      gapLength: math.max(1.0, style.gapLength),
      phase: style.animated ? _phase : 0,
    );

    _paintHologramTicks(canvas, frame, strength);
    _paintHologramNoise(canvas, frame, strength);

    if (style.animated && style.packetCount > 0) {
      for (var packet = 0; packet < style.packetCount; packet++) {
        final packetPhase = (_phase + packet / style.packetCount) % 1.0;
        _paintHologramPacket(
          canvas,
          frame,
          packetPhase,
          strength * (1 - packet * 0.09),
        );
      }
    }
  }

  void _paintHologramTicks(Canvas canvas, _BeamFrame frame, double strength) {
    if (style.scanlineOpacity <= 0 || style.detail <= 0.05) return;
    final count = math.max(8, (frame.length / 10).floor());
    for (var index = 0; index <= count; index++) {
      final t = index / math.max(1, count);
      final point = frame.pointAt(t);
      final major = index % 4 == 0;
      final half = style.thickness * (major ? 2.8 : 1.55);
      final flicker =
          0.55 + 0.45 * NeonTrig.sin(index * 1.37 + _phase * math.pi * 2 * 1.2);
      canvas.drawLine(
        point - frame.normal * half,
        point + frame.normal * half,
        _paintPool.next()
          ..strokeWidth = major ? 0.72 : 0.42
          ..strokeCap = StrokeCap.round
          ..color = (major ? style.secondaryColor : style.endColor).withValues(
            alpha:
                style.scanlineOpacity *
                (major ? 0.48 : 0.24) *
                flicker *
                strength *
                style.detail,
          ),
      );
    }
  }

  void _paintHologramNoise(Canvas canvas, _BeamFrame frame, double strength) {
    if (style.noise <= 0 || style.detail <= 0.2) return;
    final count = math.max(8, style.particleCount * 2);
    for (var index = 0; index < count; index++) {
      final seed = index * 101 + (_phase * 80).floor();
      final t = _hash01(seed);
      final offset =
          (_hash01(seed + 17) * 2 - 1) *
          style.thickness *
          (2 + style.refraction * 2);
      final point = frame.pointAt(t) + frame.normal * offset;
      final length = 0.8 + _hash01(seed + 31) * 4.2;
      canvas.drawLine(
        point,
        point + frame.direction * length,
        _paintPool.next()
          ..strokeWidth = 0.44
          ..color = (index.isEven ? style.color : style.secondaryColor)
              .withValues(alpha: 0.26 * strength * style.noise * style.detail),
      );
    }
  }

  void _paintHologramPacket(
    Canvas canvas,
    _BeamFrame frame,
    double phase,
    double strength,
  ) {
    final center = frame.pointAt(phase);
    final half = style.thickness * (2.8 + style.crossFlare * 4.5);
    canvas.drawLine(
      center - frame.normal * half,
      center + frame.normal * half,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          center - frame.normal * half,
          center + frame.normal * half,
          <Color>[
            Colors.transparent,
            style.secondaryColor.withValues(alpha: 0.42 * strength),
            style.coreColor.withValues(alpha: 0.92 * strength),
            style.endColor.withValues(alpha: 0.42 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.35, 0.5, 0.65, 1],
        )
        ..strokeWidth = math.max(0.65, style.thickness * 0.46)
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(1.8)),
    );
    canvas.drawCircle(
      center,
      math.max(0.9, style.thickness * 0.62),
      _paintPool.next()
        ..color = style.coreColor.withValues(alpha: 0.82 * strength),
    );
  }

  void _paintPhotonLatticeConnector(Canvas canvas, Offset start, Offset end) {
    _paintEnergyConnector(
      canvas,
      start,
      end,
      paintFlow: false,
      baseOpacity: 0.72,
    );
    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    final strength = style.intensity.clamp(0.0, 1.0).toDouble();
    final fieldWidth = style.thickness * (4.2 + style.photonSpread * 5.8);

    canvas.drawLine(
      start,
      end,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          start,
          end,
          <Color>[
            Colors.transparent,
            style.secondaryColor.withValues(alpha: 0.08 * strength),
            style.color.withValues(alpha: 0.15 * strength),
            style.endColor.withValues(alpha: 0.08 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.22, 0.5, 0.78, 1],
        )
        ..strokeWidth = fieldWidth
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(math.max(4.0, style.glowRadius * 1.35))),
    );

    final strandCount = math.max(3, style.strandCount);
    for (var strand = 0; strand < strandCount; strand++) {
      final normalized = strandCount <= 1
          ? 0.0
          : strand / (strandCount - 1) * 2 - 1;
      final amplitude =
          style.thickness *
          (1.1 + style.photonSpread * 3.6) *
          (0.35 + normalized.abs() * 0.65);
      final direction = strand.isEven ? 1.0 : -1.0;
      final path = _wavePath(
        frame,
        amplitude: amplitude,
        frequency: style.waveFrequency * (0.76 + strand * 0.055),
        phase: _phaseRadians * direction + strand * 1.73,
      );
      final color = switch (strand % 3) {
        0 => style.color,
        1 => style.secondaryColor,
        _ => style.endColor,
      };
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.1, style.thickness * 1.5)
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.12 * strength * style.detail)
          ..applyBlur(NeonBlur.normal(math.max(1.5, style.glowRadius * 0.34))),
      );
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.42, style.thickness * 0.34)
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.62 * strength * style.detail),
      );
    }

    _paintPhotonCrossLinks(canvas, frame, strength);
    _paintPhotonInterference(canvas, frame, strength);

    if (style.animated && style.packetCount > 0) {
      for (var packet = 0; packet < style.packetCount; packet++) {
        final packetPhase = (_phase + packet / style.packetCount) % 1.0;
        _paintPhotonPacket(
          canvas,
          frame,
          packetPhase,
          strength * (1 - packet * 0.055),
          packet,
        );
      }
      _paintParticles(canvas, frame, _phase, strength);
    }
  }

  double get _phaseRadians => _phase * math.pi * 2;

  void _paintPhotonCrossLinks(
    Canvas canvas,
    _BeamFrame frame,
    double strength,
  ) {
    final links = math.max(
      2,
      style.latticeDensity +
          (style.quality == NeonTimelineRenderQuality.ultra ? 3 : 0),
    );
    final amplitude = style.thickness * (1.55 + style.photonSpread * 3.8);
    for (var index = 0; index <= links; index++) {
      final t = index / math.max(1, links);
      final envelope = NeonTrig.sin(t * math.pi);
      final wave = NeonTrig.sin(
        t * math.pi * style.waveFrequency + _phaseRadians,
      );
      final offset = amplitude * envelope * (0.38 + wave.abs() * 0.62);
      final center = frame.pointAt(t);
      final from = center - frame.normal * offset;
      final to = center + frame.normal * offset;
      final flicker =
          0.58 + 0.42 * NeonTrig.sin(index * 1.47 + _phaseRadians * 1.35).abs();
      canvas.drawLine(
        from,
        to,
        _paintPool.next()
          ..shader = ui.Gradient.linear(
            from,
            to,
            <Color>[
              style.secondaryColor.withValues(alpha: 0.0),
              style.secondaryColor.withValues(
                alpha: 0.22 * strength * style.interference * flicker,
              ),
              style.coreColor.withValues(
                alpha: 0.58 * strength * style.interference * flicker,
              ),
              style.endColor.withValues(
                alpha: 0.22 * strength * style.interference * flicker,
              ),
              style.endColor.withValues(alpha: 0.0),
            ],
            const <double>[0, 0.28, 0.5, 0.72, 1],
          )
          ..strokeWidth = index % 3 == 0 ? 0.82 : 0.48
          ..strokeCap = StrokeCap.round,
      );
      if (index % 2 == 0) {
        canvas.drawCircle(
          center,
          math.max(0.55, style.thickness * 0.34),
          _paintPool.next()
            ..color = style.coreColor.withValues(
              alpha: 0.50 * strength * style.interference * flicker,
            )
            ..applyBlur(NeonBlur.normal(0.8)),
        );
      }
    }
  }

  void _paintPhotonInterference(
    Canvas canvas,
    _BeamFrame frame,
    double strength,
  ) {
    if (style.interference <= 0 || style.detail <= 0.1) return;
    final count = switch (style.quality) {
      NeonTimelineRenderQuality.balanced => 10,
      NeonTimelineRenderQuality.high => 16,
      NeonTimelineRenderQuality.ultra => 24,
    };
    for (var index = 0; index < count; index++) {
      final t = (index + 0.5) / count;
      final point = frame.pointAt(t);
      final interference =
          NeonTrig.sin(
            t * math.pi * style.waveFrequency * 2 + _phaseRadians * 1.7,
          ) *
          NeonTrig.sin(t * math.pi);
      final half =
          style.thickness *
          (0.7 + interference.abs() * (1.6 + style.photonSpread * 2.2));
      canvas.drawLine(
        point - frame.normal * half,
        point + frame.normal * half,
        _paintPool.next()
          ..strokeWidth = 0.34
          ..color = (index.isEven ? style.secondaryColor : style.endColor)
              .withValues(
                alpha:
                    0.10 *
                    strength *
                    style.interference *
                    style.detail *
                    interference.abs(),
              ),
      );
    }
  }

  void _paintPhotonPacket(
    Canvas canvas,
    _BeamFrame frame,
    double packetPhase,
    double strength,
    int packetIndex,
  ) {
    final center = frame.pointAt(packetPhase);
    final wave = NeonTrig.sin(
      packetPhase * math.pi * style.waveFrequency + _phaseRadians,
    );
    final packetCenter =
        center +
        frame.normal *
            wave *
            style.thickness *
            (0.8 + style.photonSpread * 2.4);
    final trailLength =
        frame.length *
        (0.045 + style.pulseWidth * 0.10) *
        style.trailPersistence;
    final trailStartDistance = (packetPhase * frame.length - trailLength)
        .clamp(0.0, frame.length)
        .toDouble();
    final trailStart = frame.start + frame.direction * trailStartDistance;
    final controlBase = Offset.lerp(trailStart, packetCenter, 0.58)!;
    final control = controlBase + frame.normal * wave * style.thickness * 1.6;
    final trailPath = _pathPool.next()
      ..moveTo(trailStart.dx, trailStart.dy)
      ..quadraticBezierTo(
        control.dx,
        control.dy,
        packetCenter.dx,
        packetCenter.dy,
      );
    final packetColor = switch (packetIndex % 3) {
      0 => style.color,
      1 => style.secondaryColor,
      _ => style.endColor,
    };
    canvas.drawPath(
      trailPath,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.thickness * 3.2
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          trailStart,
          packetCenter,
          <Color>[
            Colors.transparent,
            packetColor.withValues(
              alpha: 0.18 * strength * style.trailPersistence,
            ),
            style.coreColor.withValues(alpha: 0.88 * strength),
          ],
          const <double>[0, 0.62, 1],
        )
        ..applyBlur(NeonBlur.normal(math.max(2.0, style.glowRadius * 0.48))),
    );
    canvas.drawCircle(
      packetCenter,
      math.max(1.2, style.thickness * 0.86),
      _paintPool.next()
        ..color = style.coreColor.withValues(alpha: 0.94 * strength)
        ..applyBlur(NeonBlur.normal(1.4)),
    );

    final flareHalf = style.thickness * (2.2 + style.crossFlare * 4.5);
    canvas.drawLine(
      packetCenter - frame.normal * flareHalf,
      packetCenter + frame.normal * flareHalf,
      _paintPool.next()
        ..shader = ui.Gradient.linear(
          packetCenter - frame.normal * flareHalf,
          packetCenter + frame.normal * flareHalf,
          <Color>[
            Colors.transparent,
            packetColor.withValues(alpha: 0.28 * strength),
            style.coreColor.withValues(alpha: 0.82 * strength),
            packetColor.withValues(alpha: 0.28 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.36, 0.5, 0.64, 1],
        )
        ..strokeWidth = 0.72
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(1.4)),
    );
  }

  void _paintEnergyFlow(
    Canvas canvas,
    _BeamFrame frame,
    double strength, {
    double? phaseOverride,
    double opacity = 1,
    bool paintParticles = true,
  }) {
    final phase = phaseOverride ?? _phase;
    final resolvedStrength = strength * opacity;
    final segmentLength = math.min(
      frame.length * style.pulseWidth,
      math.max(22.0, style.thickness * 22),
    );
    final centerDistance =
        phase * (frame.length + segmentLength) - segmentLength / 2;
    final segmentStart = (centerDistance - segmentLength / 2)
        .clamp(0.0, frame.length)
        .toDouble();
    final segmentEnd = (centerDistance + segmentLength / 2)
        .clamp(0.0, frame.length)
        .toDouble();

    if (segmentEnd > segmentStart) {
      final from = frame.start + frame.direction * segmentStart;
      final to = frame.start + frame.direction * segmentEnd;
      final center = Offset.lerp(from, to, 0.5)!;
      canvas.drawLine(
        from,
        to,
        _paintPool.next()
          ..shader = ui.Gradient.linear(
            from,
            to,
            <Color>[
              Colors.transparent,
              style.color.withValues(alpha: 0.44 * resolvedStrength),
              style.coreColor.withValues(alpha: 0.98 * resolvedStrength),
              style.endColor.withValues(alpha: 0.44 * resolvedStrength),
              Colors.transparent,
            ],
            const <double>[0, 0.28, 0.5, 0.72, 1],
          )
          ..strokeWidth = style.thickness * 4.4
          ..strokeCap = StrokeCap.round
          ..applyBlur(NeonBlur.normal(math.max(2.0, style.glowRadius * 0.72))),
      );
      canvas.drawCircle(
        center,
        math.max(1.1, style.thickness * 0.72),
        _paintPool.next()
          ..color = style.coreColor.withValues(alpha: 0.90 * resolvedStrength)
          ..applyBlur(NeonBlur.normal(1.4)),
      );
    }

    if (paintParticles) {
      _paintParticles(canvas, frame, phase, resolvedStrength);
    }
  }

  void _paintParticles(
    Canvas canvas,
    _BeamFrame frame,
    double phase,
    double strength,
  ) {
    if (style.detail <= 0.16 || style.particleCount == 0) return;
    for (var index = 0; index < style.particleCount; index++) {
      final localPhase = (phase + index / style.particleCount) % 1.0;
      final distance = localPhase * frame.length;
      final wobble =
          NeonTrig.sin(localPhase * math.pi * 6 + index * 1.71) *
          math.max(0.8, style.thickness * (0.62 + style.turbulence));
      final position =
          frame.start + frame.direction * distance + frame.normal * wobble;
      final color = switch (index % 3) {
        0 => style.color,
        1 => style.secondaryColor,
        _ => style.endColor,
      };
      final radius = 0.48 + (index % 3) * 0.16;
      // Reuse cached Paint objects — just update color to avoid allocations.
      _particleGlowPaint
        ..color = color.withValues(alpha: 0.12 * strength * style.detail)
        ..maskFilter = null
        ..applyBlur(_particleBlur);
      canvas.drawCircle(position, radius + 1.2, _particleGlowPaint);
      _particleDotPaint.color = color.withValues(
        alpha: 0.66 * strength * style.detail,
      );
      canvas.drawCircle(position, radius, _particleDotPaint);
    }
  }

  Path _wavePath(
    _BeamFrame frame, {
    required double amplitude,
    required double frequency,
    required double phase,
  }) {
    const phaseBuckets = 72;
    final phaseBucket = ((phase / (math.pi * 2)) * phaseBuckets).round();
    final key = Object.hash(
      frame.start.dx.round(),
      frame.start.dy.round(),
      frame.end.dx.round(),
      frame.end.dy.round(),
      (amplitude * 64).round(),
      (frequency * 64).round(),
      phaseBucket,
      style.quality.index,
    );
    final cached = _wavePathCache[key];
    if (cached != null) return cached;

    final path = Path();
    final steps = switch (style.quality) {
      NeonTimelineRenderQuality.balanced => 36,
      NeonTimelineRenderQuality.high => 56,
      NeonTimelineRenderQuality.ultra => 84,
    };
    final quantizedPhase = phaseBucket / phaseBuckets * math.pi * 2;
    for (var step = 0; step <= steps; step++) {
      final t = step / steps;
      final envelope = NeonTrig.sin(t * math.pi);
      final displacement =
          NeonTrig.sin(t * math.pi * frequency + quantizedPhase) *
          amplitude *
          envelope;
      final point = frame.pointAt(t) + frame.normal * displacement;
      if (step == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    if (_wavePathCache.length >= 160) {
      _wavePathCache.remove(_wavePathCache.keys.first);
    }
    _wavePathCache[key] = path;
    return path;
  }

  void _paintLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    if (style.variant != NeonConnectorVariant.dashed) {
      canvas.drawLine(start, end, paint);
      return;
    }
    final frame = _BeamFrame.from(start, end);
    if (frame == null) return;
    _paintSegmentedLine(
      canvas,
      frame,
      paint,
      dashLength: style.dashLength,
      gapLength: style.gapLength,
      phase: 0,
    );
  }

  void _paintSegmentedLine(
    Canvas canvas,
    _BeamFrame frame,
    Paint paint, {
    required double dashLength,
    required double gapLength,
    required double phase,
  }) {
    final period = dashLength + gapLength;
    if (period <= 0) return;
    var distance = -phase * period;
    while (distance < frame.length) {
      final dashStart = distance.clamp(0.0, frame.length).toDouble();
      final dashEnd = (distance + dashLength)
          .clamp(0.0, frame.length)
          .toDouble();
      if (dashEnd > dashStart) {
        canvas.drawLine(
          frame.start + frame.direction * dashStart,
          frame.start + frame.direction * dashEnd,
          paint,
        );
      }
      distance += period;
    }
  }

  // Fast integer bit-scramble — visually identical to the old math.sin hash
  // but avoids a transcendental function call per particle/frame.
  double _hash01(int seed) {
    var n = seed ^ (seed << 13);
    n = n ^ (n >> 7);
    n = n ^ (n << 17);
    // Map to [0,1) using the low bits.
    return (n & 0x7fffffff) / 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return axis != oldDelegate.axis ||
        style != oldDelegate.style ||
        animation != oldDelegate.animation;
  }
}

class _BeamFrame {
  const _BeamFrame({
    required this.start,
    required this.end,
    required this.direction,
    required this.normal,
    required this.length,
  });

  final Offset start;
  final Offset end;
  final Offset direction;
  final Offset normal;
  final double length;

  static _BeamFrame? from(Offset start, Offset end) {
    final vector = end - start;
    final length = vector.distance;
    if (length <= 0) return null;
    final direction = vector / length;
    return _BeamFrame(
      start: start,
      end: end,
      direction: direction,
      normal: Offset(-direction.dy, direction.dx),
      length: length,
    );
  }

  Offset pointAt(double t) => start + direction * (length * t);
}

extension on NeonTimelineConnectorStyle {
  Color get tertiaryFallback => Color.lerp(secondaryColor, endColor, 0.5)!;
}

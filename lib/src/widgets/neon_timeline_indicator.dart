import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/neon_timeline_types.dart';
import '../theme/neon_timeline_theme.dart';
import '../utils/neon_perf_utils.dart';
import 'neon_timeline_motion.dart';

/// A status-aware marker with glass, quantum, singularity, hologram, and neural-core modes.
class NeonTimelineIndicator extends StatefulWidget {
  /// Creates a timeline indicator.
  const NeonTimelineIndicator({
    this.status = NeonTimelineStatus.pending,
    this.style,
    this.child,
    this.animate = true,
    this.onTap,
    this.semanticLabel,
    this.tooltip,
    super.key,
  });

  /// Status used to resolve color and the default glyph.
  final NeonTimelineStatus status;

  /// Optional style override.
  final NeonTimelineIndicatorStyle? style;

  /// Optional marker content. A status glyph is used when omitted.
  final Widget? child;

  /// Whether active markers may animate.
  final bool animate;

  /// Optional activation callback.
  final VoidCallback? onTap;

  /// Optional screen-reader label.
  final String? semanticLabel;

  /// Optional hover and long-press tooltip.
  final String? tooltip;

  @override
  State<NeonTimelineIndicator> createState() => _NeonTimelineIndicatorState();
}

class _NeonTimelineIndicatorState extends State<NeonTimelineIndicator> {
  static const Animation<double> _inactiveAnimation =
      AlwaysStoppedAnimation<double>(0);
  static const Animation<double> _activeStillAnimation =
      AlwaysStoppedAnimation<double>(0.28);

  NeonTimelineMotionClock? _localClock;
  NeonTimelineMotionData? _sharedMotion;
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  Offset _pointer = Offset.zero;
  Offset? _pendingPointer;
  bool _pointerUpdateScheduled = false;

  NeonTimelineMotionClock _ensureLocalClock() {
    final duration = NeonTimelineTheme.of(context).motionDuration;
    final clock = _localClock ??= NeonTimelineMotionClock(
      duration: duration,
      framesPerSecond: 24,
      initialValue: widget.status == NeonTimelineStatus.active ? 0.28 : 0,
    );
    clock.configure(duration: duration, framesPerSecond: 24);
    return clock;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sharedMotion = NeonTimelineMotionScope.maybeOf(context);
    _localClock?.configure(
      duration: NeonTimelineTheme.of(context).motionDuration,
      framesPerSecond: 24,
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant NeonTimelineIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.status != widget.status ||
        oldWidget.style != widget.style) {
      _syncAnimation();
    }
  }

  Animation<double> get _effectiveAnimation {
    final shouldAnimate =
        widget.animate && widget.status == NeonTimelineStatus.active;
    if (shouldAnimate && _sharedMotion?.enabled == true) {
      return _sharedMotion!.animation;
    }
    if (shouldAnimate && _sharedMotion == null) {
      return _ensureLocalClock().animation;
    }
    return widget.status == NeonTimelineStatus.active
        ? _activeStillAnimation
        : _inactiveAnimation;
  }

  void _syncAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final tickerEnabled = TickerMode.of(context);
    final shouldAnimate = widget.animate &&
        widget.status == NeonTimelineStatus.active &&
        !reduceMotion &&
        tickerEnabled &&
        _sharedMotion == null;
    if (shouldAnimate) {
      _ensureLocalClock().start();
    } else {
      _localClock?.stop(
        value: widget.status == NeonTimelineStatus.active ? 0.28 : 0,
      );
    }
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _updatePointer(PointerHoverEvent event, double extent) {
    if (extent <= 0) return;
    final center = Offset(extent / 2, extent / 2);
    _pendingPointer = Offset(
      ((event.localPosition.dx - center.dx) / center.dx)
          .clamp(-1.0, 1.0)
          .toDouble(),
      ((event.localPosition.dy - center.dy) / center.dy)
          .clamp(-1.0, 1.0)
          .toDouble(),
    );
    if (_pointerUpdateScheduled) return;
    _pointerUpdateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pointerUpdateScheduled = false;
      if (!mounted) return;
      final normalized = _pendingPointer;
      _pendingPointer = null;
      if (normalized != null &&
          (_pointer - normalized).distanceSquared > 0.0004) {
        setState(() => _pointer = normalized);
      }
    });
  }

  @override
  void dispose() {
    _localClock?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    final statusColor = theme.colorForStatus(widget.status);
    final baseStyle = widget.style ?? theme.indicatorStyle;
    final style = baseStyle.copyWith(
      color: statusColor,
      glowColor: statusColor,
    );
    final advanced = style.effect != NeonIndicatorEffect.classic;
    final visualExtent = style.visualExtent;
    final hitExtent =
        widget.onTap == null ? visualExtent : math.max(48.0, visualExtent);
    final animation = _effectiveAnimation;

    final interactionScale = _pressed
        ? 0.966
        : (_hovered || _focused)
            ? 1.018
            : 1.0;
    Widget result = SizedBox.square(
      dimension: hitExtent,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: interactionScale,
          child: _IndicatorBody(
            style: style,
            status: widget.status,
            animation: animation,
            hovered: _hovered,
            focused: _focused,
            pressed: _pressed,
            pointer: _pointer,
            child: widget.child ??
                _StatusGlyph(
                  status: widget.status,
                  hideActiveGlyph: advanced,
                  indicatorSize: style.size,
                ),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      result = FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) {
          if (_focused != value) setState(() => _focused = value);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap!();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: result,
        ),
      );
    }

    result = MouseRegion(
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onHover: (event) => _updatePointer(event, hitExtent),
      onExit: (_) {
        if (_hovered || _pressed || _pointer != Offset.zero) {
          setState(() {
            _hovered = false;
            _pressed = false;
            _pointer = Offset.zero;
          });
        }
      },
      child: result,
    );

    result = Semantics(
      button: widget.onTap != null,
      enabled: widget.status != NeonTimelineStatus.disabled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: RepaintBoundary(child: result),
    );

    if (widget.tooltip != null) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }
    return result;
  }
}

class _IndicatorBody extends StatelessWidget {
  const _IndicatorBody({
    required this.style,
    required this.status,
    required this.animation,
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.pointer,
    required this.child,
  });

  final NeonTimelineIndicatorStyle style;
  final NeonTimelineStatus status;
  final Animation<double> animation;
  final bool hovered;
  final bool focused;
  final bool pressed;
  final Offset pointer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (style.effect == NeonIndicatorEffect.classic) {
      return AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final pulse =
              0.5 + 0.5 * NeonTrig.sin(animation.value * math.pi * 2);
          return Transform.scale(
            scale: 1 + pulse * 0.07,
            child: _ClassicIndicatorBody(
              style: style,
              glowScale: 1 + pulse * 0.45,
              child: child!,
            ),
          );
        },
      );
    }

    final extent = style.visualExtent;
    return SizedBox.square(
      dimension: extent,
      child: CustomPaint(
        isComplex: true,
        willChange: status == NeonTimelineStatus.active &&
            animation is! AlwaysStoppedAnimation<double>,
        painter: _AdvancedIndicatorPainter(
          style: style,
          status: status,
          animation: animation,
          hovered: hovered,
          focused: focused,
          pressed: pressed,
          pointer: pointer,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ClassicIndicatorBody extends StatelessWidget {
  const _ClassicIndicatorBody({
    required this.style,
    required this.glowScale,
    required this.child,
  });

  final NeonTimelineIndicatorStyle style;
  final double glowScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = switch (style.shape) {
      NeonIndicatorShape.circle => BorderRadius.circular(style.size),
      NeonIndicatorShape.square => BorderRadius.circular(style.size * 0.24),
      NeonIndicatorShape.diamond => BorderRadius.circular(style.size * 0.16),
    };
    Widget body = Container(
      width: style.size,
      height: style.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: radius,
        border: Border.all(
          color: style.borderColor,
          width: style.borderWidth,
        ),
        boxShadow: style.glowRadius == 0
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: style.glowColor.withAlpha(135),
                  blurRadius: style.glowRadius * glowScale,
                  spreadRadius: style.glowRadius * 0.12 * glowScale,
                ),
              ],
      ),
      child: child,
    );
    if (style.shape == NeonIndicatorShape.diamond) {
      body = Transform.rotate(angle: math.pi / 4, child: body);
    }
    return body;
  }
}

class _AdvancedIndicatorPainter extends CustomPainter {
  _AdvancedIndicatorPainter({
    required this.style,
    required this.status,
    required this.animation,
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.pointer,
  }) : super(repaint: animation);

  final NeonTimelineIndicatorStyle style;
  final NeonTimelineStatus status;
  final Animation<double> animation;
  final NeonPaintPool _paintPool = NeonPaintPool();
  final NeonPathPool _pathPool = NeonPathPool();

  double get phase => animation.value;

  double get pulse => 0.5 + 0.5 * NeonTrig.sin(phase * math.pi * 2);
  final bool hovered;
  final bool focused;
  final bool pressed;
  final Offset pointer;

  // Cached blur filters — computed once per painter instance (i.e. once per
  // style change) instead of being allocated fresh on every paint() call.
  late final NeonBlurCache _blurs = NeonBlurCache(glowRadius: style.glowRadius);

  double get _strength {
    final statusFactor = switch (status) {
      NeonTimelineStatus.active => 0.84 + pulse * 0.16,
      NeonTimelineStatus.completed => 0.78,
      NeonTimelineStatus.error => 0.90,
      NeonTimelineStatus.pending => 0.47,
      NeonTimelineStatus.disabled => 0.24,
    };
    final interaction = (hovered ? 1.11 : 1.0) *
        (focused ? 1.08 : 1.0) *
        (pressed ? 0.94 : 1.0);
    return (statusFactor * interaction * style.intensity)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  int get _qualityFactor => switch (style.quality) {
        NeonTimelineRenderQuality.balanced => 1,
        NeonTimelineRenderQuality.high => 2,
        NeonTimelineRenderQuality.ultra => 3,
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _paintPool.reset();
    _pathPool.reset();
    final center = size.center(Offset.zero);
    final pulseScale = status == NeonTimelineStatus.active
        ? 1 + pulse * 0.012
        : 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(pulseScale);
    canvas.translate(-center.dx, -center.dy);
    final radius = style.size / 2 +
        (status == NeonTimelineStatus.active ? (pulse - 0.5) * 0.7 : 0) -
        (pressed ? style.depth * 0.65 : 0);
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final shape = _shapePath(bounds, style.shape);
    final strength = _strength;
    final parallax = pointer * (radius * 0.12 * style.parallax);

    _paintShadow(canvas, center, radius);
    _paintVolumetricAura(canvas, center, radius, strength);
    _paintBloom(canvas, shape, radius, strength);

    switch (style.effect) {
      case NeonIndicatorEffect.classic:
      case NeonIndicatorEffect.glass:
      case NeonIndicatorEffect.stellar:
        break;
      case NeonIndicatorEffect.quantum:
        _paintQuantumCorona(canvas, center, radius, strength);
        break;
      case NeonIndicatorEffect.singularity:
        _paintSingularityField(canvas, center, radius, strength);
        break;
      case NeonIndicatorEffect.hologram:
        _paintHologramOuter(canvas, center, radius, strength);
        break;
      case NeonIndicatorEffect.neuralCore:
        _paintNeuralField(canvas, center, radius, strength);
        break;
    }

    if (style.effect == NeonIndicatorEffect.neuralCore) {
      _paintNeuralBody(
        canvas,
        shape,
        bounds,
        center,
        radius,
        strength,
        parallax,
      );
    } else if (style.effect == NeonIndicatorEffect.singularity) {
      _paintSingularityBody(
        canvas,
        shape,
        bounds,
        center,
        radius,
        strength,
        parallax,
      );
    } else if (style.effect == NeonIndicatorEffect.hologram) {
      _paintHologramBody(
        canvas,
        shape,
        bounds,
        center,
        radius,
        strength,
        parallax,
      );
    } else {
      _paintGlass(
        canvas,
        shape,
        bounds,
        center,
        radius,
        strength,
        parallax,
      );
    }

    _paintChromaticFringe(canvas, shape, strength);
    _paintSpectralRing(canvas, shape, bounds, center, strength);
    _paintReflections(
      canvas,
      shape,
      bounds,
      center,
      radius,
      strength,
      parallax,
    );

    if (style.effect == NeonIndicatorEffect.stellar ||
        style.effect == NeonIndicatorEffect.quantum ||
        style.effect == NeonIndicatorEffect.singularity ||
        style.effect == NeonIndicatorEffect.neuralCore) {
      _paintLensRays(canvas, center, radius, strength);
      if (style.detail > 0.18 && style.particleCount > 0) {
        _paintOrbitParticles(canvas, center, radius, strength);
      }
    }

    if (style.effect == NeonIndicatorEffect.quantum) {
      _paintQuantumInterference(canvas, shape, center, radius, strength);
    } else if (style.effect == NeonIndicatorEffect.singularity) {
      _paintSingularityLensing(canvas, center, radius, strength);
    } else if (style.effect == NeonIndicatorEffect.hologram) {
      _paintHologramDetails(canvas, shape, center, radius, strength);
    } else if (style.effect == NeonIndicatorEffect.neuralCore) {
      _paintNeuralLattice(canvas, shape, center, radius, strength);
    }

    if (style.detail > 0.3 && style.sparkCount > 0) {
      _paintMicroSparks(canvas, center, radius, strength);
    }

    if (status == NeonTimelineStatus.active &&
        style.effect != NeonIndicatorEffect.glass) {
      _paintSpark(canvas, center, radius, strength);
    }
    if (focused) {
      _paintFocusHalo(canvas, shape, strength);
    }
    canvas.restore();
  }

  void _paintShadow(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center.translate(0, radius * (0.08 + style.depth * 0.08)),
      radius * 0.92,
      _paintPool.next()
        ..color = Colors.black.withOpacity(0.44)
        ..applyBlur(_blurs.shadow),
    );
  }

  void _paintVolumetricAura(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.glowRadius <= 0) return;
    final breath = 1 + (pulse - 0.5) * 0.04;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * 0.06),
        width: radius * 4.0 * breath,
        height: radius * 2.15 * breath,
      ),
      _paintPool.next()
        ..color = style.glowColor.withOpacity(0.055 * strength)
        ..applyBlur(_blurs.auraSoft),
    );
    canvas.drawCircle(
      center,
      radius * 1.45 * breath,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center,
          radius * 1.45,
          <Color>[
            style.secondaryColor.withOpacity(0.06 * strength),
            style.tertiaryColor.withOpacity(0.028 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.55, 1],
        ),
    );
  }

  void _paintBloom(
    Canvas canvas,
    Path shape,
    double radius,
    double strength,
  ) {
    if (style.glowRadius <= 0 || strength <= 0) return;
    final layers = <({double width, double sigma, Color color})>[
      (
        width: math.max(4.0, radius * 0.24),
        sigma: math.max(5.0, style.glowRadius * 1.38),
        color: style.glowColor.withOpacity(0.13 * strength),
      ),
      (
        width: math.max(3.0, radius * 0.15),
        sigma: math.max(3.0, style.glowRadius * 0.74),
        color: style.secondaryColor.withOpacity(0.20 * strength),
      ),
      (
        width: math.max(2.0, radius * 0.08),
        sigma: math.max(1.5, style.glowRadius * 0.32),
        color: style.color.withOpacity(0.31 * strength),
      ),
    ];
    for (final layer in layers) {
      canvas.drawPath(
        shape,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.width
          ..color = layer.color
          ..applyBlur(
            switch (layer.sigma) {
              >= 5.0 => _blurs.bloomOuter,
              >= 3.0 => _blurs.bloomMid,
              _ => _blurs.bloomInner,
            },
          ),
      );
    }
  }

  void _paintGlass(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double radius,
    double strength,
    Offset parallax,
  ) {
    final hot = Color.lerp(style.interiorColor, style.color, 0.48)!;
    final mid = Color.lerp(style.interiorColor, style.secondaryColor, 0.20)!;
    final focal = center.translate(
          -radius * (0.16 + style.depth * 0.10),
          -radius * (0.22 + style.depth * 0.13),
        ) +
        parallax;
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          focal,
          radius * (1.20 + style.refraction * 0.16),
          <Color>[
            hot.withOpacity(0.92),
            mid.withOpacity(0.88),
            style.interiorColor.withOpacity(0.99),
          ],
          const <double>[0, 0.48, 1],
        ),
    );

    canvas.save();
    canvas.clipPath(shape);
    canvas.drawCircle(
      center.translate(radius * 0.25, radius * 0.28) - parallax * 0.4,
      radius * 0.72,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center.translate(radius * 0.18, radius * 0.20),
          radius * 0.82,
          <Color>[
            style.tertiaryColor.withOpacity(0.13 * strength),
            Colors.transparent,
          ],
        ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-radius * 0.18, -radius * 0.34) + parallax,
        width: radius * 1.15,
        height: radius * 0.38,
      ),
      _paintPool.next()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.white.withOpacity(0.22 * strength),
            Colors.white.withOpacity(0.02),
          ],
        ).createShader(bounds)
        ..applyBlur(NeonBlur.normal(3)),
    );
    canvas.restore();
  }

  void _paintSingularityBody(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double radius,
    double strength,
    Offset parallax,
  ) {
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center + parallax * 0.35,
          radius * 1.16,
          <Color>[
            Color.lerp(style.color, style.interiorColor, 0.55)!
                .withOpacity(0.94),
            style.interiorColor.withOpacity(0.99),
            Colors.black.withOpacity(0.99),
          ],
          <double>[0, 0.56, 1],
        ),
    );

    canvas.save();
    canvas.clipPath(shape);
    final horizonRadius = radius * (0.24 + style.eventHorizon * 0.20);
    canvas.drawCircle(
      center + parallax * 0.18,
      horizonRadius * 1.55,
      _paintPool.next()
        ..color = style.secondaryColor.withOpacity(0.10 * strength)
        ..applyBlur(NeonBlur.normal(math.max(4.0, style.glowRadius * 0.42))),
    );
    canvas.drawCircle(
      center + parallax * 0.18,
      horizonRadius,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center + parallax * 0.18,
          horizonRadius,
          <Color>[
            Colors.black,
            Colors.black,
            style.interiorColor,
          ],
          const <double>[0, 0.78, 1],
        ),
    );

    final diskRect = Rect.fromCenter(
      center: center - parallax * 0.22,
      width: radius * 1.64,
      height: radius * 0.42,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.18 + pointer.dx * 0.06);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(
      diskRect,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, radius * 0.10)
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.transparent,
            style.secondaryColor.withOpacity(0.72 * strength),
            style.borderColor.withOpacity(0.98 * strength),
            style.color.withOpacity(0.90 * strength),
            style.tertiaryColor.withOpacity(0.70 * strength),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.16, 0.38, 0.62, 0.84, 1],
        ).createShader(bounds)
        ..applyBlur(NeonBlur.normal(math.max(1.5, style.glowRadius * 0.22))),
    );
    canvas.drawOval(
      diskRect.deflate(radius * 0.035),
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.55, style.borderWidth * 0.54)
        ..color = Colors.white.withOpacity(0.78 * strength),
    );
    canvas.restore();

    if (style.scanlineOpacity > 0 && style.detail > 0.2) {
      final spacing = math.max(2.0, radius * 0.11);
      for (double y = bounds.top; y <= bounds.bottom; y += spacing) {
        final shimmer =
            0.5 + 0.5 * NeonTrig.sin(y * 0.45 + phase * math.pi * 2 * 0.7);
        canvas.drawLine(
          Offset(bounds.left, y),
          Offset(bounds.right, y),
          _paintPool.next()
            ..strokeWidth = 0.45
            ..color = style.tertiaryColor.withOpacity(
              style.scanlineOpacity * 0.12 * shimmer * strength,
            ),
        );
      }
    }
    canvas.restore();
  }

  void _paintHologramBody(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double radius,
    double strength,
    Offset parallax,
  ) {
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center.translate(-radius * 0.18, -radius * 0.22) + parallax,
          radius * 1.28,
          <Color>[
            style.color.withOpacity(0.30 * strength),
            style.interiorColor.withOpacity(0.80),
            style.interiorColor.withOpacity(0.96),
          ],
          const <double>[0, 0.55, 1],
        ),
    );

    canvas.save();
    canvas.clipPath(shape);
    final spacing = math.max(2.0, radius * 0.10);
    for (double y = bounds.top - spacing; y <= bounds.bottom; y += spacing) {
      final phaseShift = (phase * radius * 0.8) % spacing;
      final yy = y + phaseShift;
      final shimmer = 0.45 + 0.55 * NeonTrig.sin(yy * 0.72 + phase * 8);
      canvas.drawLine(
        Offset(bounds.left, yy),
        Offset(bounds.right, yy),
        _paintPool.next()
          ..strokeWidth = 0.55
          ..color = style.color.withOpacity(
            (style.scanlineOpacity * 0.34 * shimmer * strength)
                .clamp(0.0, 1.0)
                .toDouble(),
          ),
      );
    }

    final columns = math.max(5, (6 + style.detail * 5).round());
    for (var index = 0; index < columns; index++) {
      final t = index / math.max(1, columns - 1);
      final x = bounds.left + t * bounds.width;
      final flicker = _hash01(index * 37 + (phase * 100).floor());
      canvas.drawLine(
        Offset(x, bounds.top),
        Offset(x, bounds.bottom),
        _paintPool.next()
          ..strokeWidth = 0.35
          ..color = style.tertiaryColor.withOpacity(
            0.025 * flicker * style.detail * strength,
          ),
      );
    }
    canvas.restore();
  }

  void _paintChromaticFringe(
    Canvas canvas,
    Path shape,
    double strength,
  ) {
    if (style.chromaticAberration <= 0 || style.detail <= 0.05) return;
    final shift = 0.45 + style.chromaticAberration * 0.75;
    canvas.save();
    canvas.translate(-shift, 0);
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.45, style.borderWidth * 0.52)
        ..color = style.secondaryColor.withOpacity(
          0.22 * strength * style.detail,
        ),
    );
    canvas.restore();
    canvas.save();
    canvas.translate(shift, 0);
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.45, style.borderWidth * 0.48)
        ..color = style.tertiaryColor.withOpacity(
          0.20 * strength * style.detail,
        ),
    );
    canvas.restore();
  }

  void _paintSpectralRing(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double strength,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(phase * math.pi * 0.18 * style.rotationSpeed);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, style.borderWidth * 1.35)
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: <Color>[
            style.borderColor,
            style.secondaryColor,
            style.color,
            style.tertiaryColor,
            style.secondaryColor,
            style.borderColor,
          ],
          stops: const <double>[0, 0.17, 0.42, 0.65, 0.84, 1],
        ).createShader(bounds),
    );
    canvas.restore();

    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.65, style.borderWidth * 0.58)
        ..color = Colors.white.withOpacity(0.42 * strength),
    );
  }

  void _paintReflections(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double radius,
    double strength,
    Offset parallax,
  ) {
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..color = style.borderColor.withOpacity(0.20 * strength),
    );

    if (style.shape == NeonIndicatorShape.circle && style.detail > 0.2) {
      final inner = Rect.fromCircle(
        center: center + parallax * 0.28,
        radius: radius * 0.72,
      );
      canvas.drawArc(
        inner,
        -math.pi * 0.92,
        math.pi * 0.56,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(0.65, style.borderWidth * 0.62)
          ..shader = LinearGradient(
            colors: <Color>[
              Colors.transparent,
              Colors.white.withOpacity(0.36 * strength * style.detail),
              Colors.transparent,
            ],
            stops: const <double>[0, 0.5, 1],
          ).createShader(bounds),
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: center - parallax * 0.18,
          radius: radius * 0.58,
        ),
        0.18 + phase * 0.18,
        0.92,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.62
          ..color =
              style.tertiaryColor.withOpacity(0.16 * strength * style.detail),
      );
    }
  }

  void _paintQuantumCorona(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.corona <= 0 || style.detail <= 0.05) return;
    final coronaStrength = strength * style.corona * style.detail;
    final ringRect = Rect.fromCircle(center: center, radius: radius + 7.5);
    final rotations = <double>[
      phase * math.pi * 2 * 0.18 * style.rotationSpeed,
      -phase * math.pi * 2 * 0.11 * style.rotationSpeed,
      phase * math.pi * 2 * 0.07 * style.rotationSpeed,
    ];
    final colors = <Color>[
      style.secondaryColor,
      style.tertiaryColor,
      style.borderColor,
    ];

    for (var index = 0; index < rotations.length; index++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotations[index] + index * 1.27);
      canvas.translate(-center.dx, -center.dy);
      final arcRadius = radius + 3.5 + index * 2.2;
      final rect = Rect.fromCircle(center: center, radius: arcRadius);
      final sweep = 0.64 + index * 0.16;
      canvas.drawArc(
        rect,
        -math.pi * 0.92 + index * 0.66,
        math.pi * sweep,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth =
              math.max(0.7, style.borderWidth * (0.72 - index * 0.1))
          ..color = colors[index].withOpacity(
            (0.34 - index * 0.055) * coronaStrength,
          )
          ..applyBlur(NeonBlur.normal(math.max(1.2, style.glowRadius * (0.18 + index * 0.05)))),
      );
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius + 7.5,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.45
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.transparent,
            style.secondaryColor.withOpacity(0.28 * coronaStrength),
            Colors.transparent,
            style.tertiaryColor.withOpacity(0.24 * coronaStrength),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.2, 0.43, 0.73, 1],
        ).createShader(ringRect),
    );
  }

  void _paintSingularityField(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.corona <= 0 || style.arcCount == 0) return;
    final arcCount = math.max(3, style.arcCount);
    for (var index = 0; index < arcCount; index++) {
      final normalized = index / arcCount;
      final direction = index.isEven ? 1.0 : -1.0;
      final rotation = direction *
          phase *
          math.pi *
          2 *
          (0.06 + normalized * 0.08) *
          style.rotationSpeed;
      final arcRadius = radius + 4 + normalized * radius * 0.34;
      final rect = Rect.fromCircle(center: center, radius: arcRadius);
      final start = -math.pi * 0.84 + normalized * math.pi * 1.76 + rotation;
      final sweep = math.pi * (0.18 + (index % 3) * 0.08);
      final color = switch (index % 3) {
        0 => style.secondaryColor,
        1 => style.tertiaryColor,
        _ => style.borderColor,
      };
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(0.52, style.borderWidth * 0.52)
          ..color = color.withOpacity(
            (0.16 + (1 - normalized) * 0.16) *
                strength *
                style.corona *
                style.detail,
          )
          ..applyBlur(NeonBlur.normal(math.max(0.9, style.glowRadius * 0.13))),
      );
    }

    for (var field = 0; field < 3; field++) {
      final path = _pathPool.next();
      const steps = 42;
      for (var step = 0; step <= steps; step++) {
        final t = step / steps;
        final angle = t * math.pi * 2;
        final modulation = NeonTrig.sin(
          angle * (2 + field) +
              phase * math.pi * 2 * (field.isEven ? 0.34 : -0.22),
        );
        final orbit = radius * (1.18 + field * 0.10) +
            modulation * radius * 0.035 * style.refraction;
        final point = Offset(
          center.dx + NeonTrig.cos(angle) * orbit,
          center.dy + NeonTrig.sin(angle) * orbit * (0.72 + field * 0.05),
        );
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final color = field.isEven ? style.secondaryColor : style.tertiaryColor;
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.42 + field * 0.12
          ..color = color.withOpacity(
            (0.10 - field * 0.018) * strength * style.detail,
          )
          ..applyBlur(NeonBlur.normal(1.2)),
      );
    }
  }

  void _paintHologramOuter(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.arcCount == 0) return;
    final ringRadius = radius + 5;
    final segments = math.max(6, style.arcCount * 2);
    final gap = math.pi * 2 / segments;
    for (var index = 0; index < segments; index++) {
      if ((index + (phase * segments).floor()) % 4 == 0) continue;
      final start = index * gap + phase * math.pi * 0.25 * style.rotationSpeed;
      final color = index.isEven ? style.tertiaryColor : style.secondaryColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        start,
        gap * 0.58,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(0.65, style.borderWidth * 0.58)
          ..color = color.withOpacity(0.32 * strength * style.detail)
          ..applyBlur(NeonBlur.normal(1.1)),
      );
    }

    final tickCount = math.max(12, style.arcCount * 3);
    for (var index = 0; index < tickCount; index++) {
      final angle = index / tickCount * math.pi * 2 - math.pi / 2;
      final length = index % 4 == 0 ? 3.4 : 1.8;
      final inner = Offset(
        center.dx + NeonTrig.cos(angle) * (ringRadius + 2),
        center.dy + NeonTrig.sin(angle) * (ringRadius + 2),
      );
      final outer = Offset(
        center.dx + NeonTrig.cos(angle) * (ringRadius + 2 + length),
        center.dy + NeonTrig.sin(angle) * (ringRadius + 2 + length),
      );
      canvas.drawLine(
        inner,
        outer,
        _paintPool.next()
          ..strokeWidth = index % 4 == 0 ? 0.85 : 0.48
          ..strokeCap = StrokeCap.round
          ..color = style.borderColor.withOpacity(
            (index % 4 == 0 ? 0.34 : 0.16) * strength * style.detail,
          ),
      );
    }
  }

  void _paintQuantumInterference(
    Canvas canvas,
    Path shape,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.detail < 0.25) return;
    canvas.save();
    canvas.clipPath(shape);
    final amplitude = radius * 0.08 * style.corona;
    for (var band = 0; band < 3; band++) {
      final path = _pathPool.next();
      final top = center.dy - radius * 0.48 + band * radius * 0.32;
      for (var step = 0; step <= 24; step++) {
        final t = step / 24;
        final x = center.dx - radius + t * radius * 2;
        final y = top +
            NeonTrig.sin(
                  t * math.pi * (3.2 + band * 0.7) +
                      phase * math.pi * 2 * (band.isEven ? 0.55 : -0.38),
                ) *
                amplitude;
        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.48 + band * 0.12
          ..color = (band.isEven ? style.tertiaryColor : style.secondaryColor)
              .withOpacity(0.11 * strength * style.detail)
          ..applyBlur(NeonBlur.normal(0.8)),
      );
    }
    canvas.restore();
  }

  void _paintSingularityLensing(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    final outer = Rect.fromCircle(center: center, radius: radius * 0.78);
    final inner = Rect.fromCircle(center: center, radius: radius * 0.66);
    canvas.drawArc(
      outer,
      -math.pi * 0.88 + phase * 0.20,
      math.pi * 0.72,
      false,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(0.75, style.borderWidth * 0.62)
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.transparent,
            style.borderColor.withOpacity(0.62 * strength),
            style.secondaryColor.withOpacity(0.28 * strength),
            Colors.transparent,
          ],
        ).createShader(outer),
    );
    canvas.drawArc(
      inner,
      0.24 - phase * 0.16,
      math.pi * 0.56,
      false,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.58
        ..color = style.tertiaryColor.withOpacity(
          0.22 * strength * style.refraction,
        ),
    );
  }

  void _paintHologramDetails(
    Canvas canvas,
    Path shape,
    Offset center,
    double radius,
    double strength,
  ) {
    canvas.save();
    canvas.clipPath(shape);
    final count = math.max(8, style.sparkCount);
    for (var index = 0; index < count; index++) {
      final seed = index * 97 + (phase * 60).floor();
      final x = center.dx + (_hash01(seed) * 2 - 1) * radius * 0.88;
      final y = center.dy + (_hash01(seed + 11) * 2 - 1) * radius * 0.88;
      final width = 1.2 + _hash01(seed + 29) * radius * 0.18;
      final alpha = 0.08 + _hash01(seed + 43) * 0.18;
      canvas.drawRect(
        Rect.fromLTWH(x, y, width, 0.45),
        _paintPool.next()
          ..color = (index.isEven ? style.color : style.tertiaryColor)
              .withOpacity(alpha * strength * style.detail),
      );
    }
    canvas.restore();
  }

  // ---- _paintNeuralField: replace math.sin/cos with NeonTrig ----
  void _paintNeuralField(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    final haloCount = math.min(
      12,
      style.haloRingCount + (_qualityFactor - 1),
    );
    for (var index = 0; index < haloCount; index++) {
      final normalized = haloCount <= 1 ? 0.0 : index / (haloCount - 1);
      final orbitRadius = radius * (1.16 + normalized * 0.72);
      final wobble = NeonTrig.sin(
            phase * math.pi * 2 * (0.32 + index * 0.035) + index * 1.41,
          ) *
          radius *
          0.025;
      final rect = Rect.fromCenter(
        center: center.translate(
          NeonTrig.cos(index * 1.73 + phase * 1.8) * wobble,
          NeonTrig.sin(index * 1.19 - phase * 1.4) * wobble,
        ),
        width: orbitRadius * 2,
        height: orbitRadius * (1.18 + (index.isEven ? 0.08 : -0.04)),
      );
      final sweep = math.pi * (0.72 + 0.16 * NeonTrig.sin(index + phase * 5));
      final start = phase * math.pi * 2 * (index.isEven ? 0.18 : -0.13) +
          index * math.pi * 0.37;
      final color = switch (index % 3) {
        0 => style.secondaryColor,
        1 => style.tertiaryColor,
        _ => style.color,
      };
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(0.42, style.borderWidth * 0.46)
          ..color = color.withOpacity(
            (0.08 + (1 - normalized) * 0.11) *
                strength *
                style.corona *
                style.detail,
          )
          ..applyBlur(NeonBlur.normal(0.8 + normalized * 1.7)),
      );
    }

    final lineCount = math.min(
      24,
      style.fieldLineCount + (_qualityFactor - 1) * 2,
    );
    if (lineCount <= 0) return;
    for (var index = 0; index < lineCount; index++) {
      final angle = index / lineCount * math.pi * 2 +
          phase * math.pi * 2 * (index.isEven ? 0.11 : -0.08);
      final start =
          center + Offset(NeonTrig.cos(angle), NeonTrig.sin(angle)) * (radius * 0.82);
      final endAngle = angle + math.pi * (0.82 + (index % 3) * 0.12);
      final end = center +
          Offset(NeonTrig.cos(endAngle), NeonTrig.sin(endAngle)) * (radius * 0.90);
      final tangentA = Offset(-NeonTrig.sin(angle), NeonTrig.cos(angle));
      final tangentB = Offset(-NeonTrig.sin(endAngle), NeonTrig.cos(endAngle));
      final lift = radius * (0.58 + (index % 4) * 0.09);
      final path = _pathPool.next()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + tangentA.dx * lift,
          start.dy + tangentA.dy * lift,
          end.dx - tangentB.dx * lift,
          end.dy - tangentB.dy * lift,
          end.dx,
          end.dy,
        );
      final color = index.isEven ? style.secondaryColor : style.tertiaryColor;
      canvas.drawPath(
        path,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.45 + (index % 3) * 0.12
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(
            0.12 * strength * style.refraction * style.detail,
          )
          ..applyBlur(NeonBlur.normal(0.8)),
      );
    }
  }

  void _paintNeuralBody(
    Canvas canvas,
    Path shape,
    Rect bounds,
    Offset center,
    double radius,
    double strength,
    Offset parallax,
  ) {
    final focal = center.translate(-radius * 0.18, -radius * 0.22) + parallax;
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          focal,
          radius * 1.24,
          <Color>[
            Color.lerp(style.borderColor, style.color, 0.34)!.withOpacity(0.94),
            Color.lerp(style.color, style.interiorColor, 0.58)!
                .withOpacity(0.96),
            style.interiorColor.withOpacity(0.995),
          ],
          const <double>[0, 0.42, 1],
        ),
    );

    canvas.save();
    canvas.clipPath(shape);
    final shellCount = 3 + _qualityFactor;
    for (var index = 0; index < shellCount; index++) {
      final shellPhase =
          phase * math.pi * 2 * (index.isEven ? 0.22 : -0.17) + index;
      final shellRadius = radius * (0.22 + index * 0.105);
      final shellCenter = center +
          Offset(
            NeonTrig.cos(shellPhase) * radius * 0.055,
            NeonTrig.sin(shellPhase * 1.13) * radius * 0.048,
          ) +
          parallax * (0.18 + index * 0.05);
      final color = switch (index % 3) {
        0 => style.secondaryColor,
        1 => style.tertiaryColor,
        _ => style.color,
      };
      canvas.drawCircle(
        shellCenter,
        shellRadius,
        _paintPool.next()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.52, style.borderWidth * 0.52)
          ..color = color.withOpacity(
            (0.08 + index * 0.018) * strength * style.detail,
          )
          ..applyBlur(NeonBlur.normal(0.7)),
      );
    }

    final nucleus = center + parallax * 0.18;
    canvas.drawCircle(
      nucleus,
      radius * 0.28,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          nucleus.translate(-radius * 0.07, -radius * 0.08),
          radius * 0.34,
          <Color>[
            Colors.white.withOpacity(0.98 * strength),
            style.borderColor.withOpacity(0.88 * strength),
            style.secondaryColor.withOpacity(0.42 * strength),
            style.interiorColor.withOpacity(0.0),
          ],
          const <double>[0, 0.18, 0.55, 1],
        )
        ..applyBlur(NeonBlur.normal(1.2 + style.refraction * 1.8)),
    );

    final causticCount = 4 + _qualityFactor * 2;
    for (var index = 0; index < causticCount; index++) {
      final angle =
          phase * math.pi * 2 * 0.18 + index / causticCount * math.pi * 2;
      final inner =
          center + Offset(NeonTrig.cos(angle), NeonTrig.sin(angle)) * (radius * 0.20);
      final outer = center +
          Offset(
            NeonTrig.cos(angle + 0.32) * radius * 0.74,
            NeonTrig.sin(angle + 0.32) * radius * 0.74,
          );
      canvas.drawLine(
        inner,
        outer,
        _paintPool.next()
          ..strokeWidth = 0.42 + (index.isEven ? 0.22 : 0)
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            inner,
            outer,
            <Color>[
              Colors.white.withOpacity(0.42 * strength),
              (index.isEven ? style.secondaryColor : style.tertiaryColor)
                  .withOpacity(0.17 * strength),
              Colors.transparent,
            ],
            const <double>[0, 0.48, 1],
          ),
      );
    }
    canvas.restore();

    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, style.borderWidth * 0.62)
        ..color = Colors.white.withOpacity(0.19 * strength),
    );
  }

  void _paintNeuralLattice(
    Canvas canvas,
    Path shape,
    Offset center,
    double radius,
    double strength,
  ) {
    canvas.save();
    canvas.clipPath(shape);
    final nodeCount = switch (style.quality) {
      NeonTimelineRenderQuality.balanced => 8,
      NeonTimelineRenderQuality.high => 12,
      NeonTimelineRenderQuality.ultra => 16,
    };
    final points = <Offset>[];
    for (var index = 0; index < nodeCount; index++) {
      final angle = index / nodeCount * math.pi * 2 +
          phase * math.pi * 2 * (index.isEven ? 0.08 : -0.055);
      final radialNoise = 0.48 + _hash01(index * 43 + 7) * 0.34;
      final point = center +
          Offset(NeonTrig.cos(angle), NeonTrig.sin(angle)) * (radius * radialNoise);
      points.add(point);
    }

    for (var index = 0; index < points.length; index++) {
      final from = points[index];
      for (final step in <int>[2, 3]) {
        final to = points[(index + step) % points.length];
        final distanceFactor = (1 - (from - to).distance / (radius * 1.8))
            .clamp(0.0, 1.0)
            .toDouble();
        canvas.drawLine(
          from,
          to,
          _paintPool.next()
            ..strokeWidth = 0.32 + distanceFactor * 0.24
            ..color = (step == 2 ? style.secondaryColor : style.tertiaryColor)
                .withOpacity(
              0.065 * strength * style.detail * distanceFactor,
            ),
        );
      }
    }
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final twinkle =
          0.55 + 0.45 * NeonTrig.sin(phase * math.pi * 2 * 1.4 + index * 1.61);
      final color = index.isEven ? style.secondaryColor : style.tertiaryColor;
      canvas.drawCircle(
        point,
        0.55 + (index % 3) * 0.12,
        _paintPool.next()..color = color.withOpacity(0.62 * twinkle * strength),
      );
    }
    canvas.restore();

    if (style.shockwave > 0) {
      final waves = 2 + _qualityFactor;
      for (var index = 0; index < waves; index++) {
        final progress = (phase + index / waves) % 1.0;
        final waveRadius = radius * (1.02 + progress * 0.88);
        final alpha =
            (1 - progress) * 0.20 * strength * style.shockwave * style.detail;
        canvas.drawCircle(
          center,
          waveRadius,
          _paintPool.next()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.55 + (1 - progress) * 0.7
            ..color =
                (index.isEven ? style.secondaryColor : style.tertiaryColor)
                    .withOpacity(alpha)
            ..applyBlur(NeonBlur.normal(1.2)),
        );
      }
    }

    if (style.diffraction > 0) {
      final diagonal = radius * (1.12 + style.rayLength * 0.48);
      for (final angle in <double>[
        math.pi / 4,
        -math.pi / 4,
      ]) {
        final vector = Offset(NeonTrig.cos(angle), NeonTrig.sin(angle)) * diagonal;
        canvas.drawLine(
          center - vector,
          center + vector,
          _paintPool.next()
            ..shader = ui.Gradient.linear(
              center - vector,
              center + vector,
              <Color>[
                Colors.transparent,
                style.tertiaryColor.withOpacity(
                  0.12 * strength * style.diffraction,
                ),
                Colors.white.withOpacity(
                  0.46 * strength * style.diffraction,
                ),
                style.secondaryColor.withOpacity(
                  0.12 * strength * style.diffraction,
                ),
                Colors.transparent,
              ],
              const <double>[0, 0.38, 0.5, 0.62, 1],
            )
            ..strokeWidth = 0.68
            ..strokeCap = StrokeCap.round
            ..applyBlur(NeonBlur.normal(1.4)),
        );
      }
    }
  }

  void _paintFocusHalo(Canvas canvas, Path shape, double strength) {
    canvas.drawPath(
      shape,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, style.borderWidth * 1.6)
        ..color = Colors.white.withOpacity(0.42 * strength)
        ..applyBlur(_blurs.focusHalo),
    );
  }

  void _paintLensRays(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    if (style.rayLength <= 0) return;
    final verticalLength = radius * (1.25 + style.rayLength * 0.8);
    final horizontalLength = radius * (1.05 + style.rayLength * 0.62);

    canvas.drawLine(
      center.translate(0, -verticalLength),
      center.translate(0, verticalLength),
      _paintPool.next()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            style.secondaryColor.withOpacity(0.22 * strength),
            Colors.white.withOpacity(0.78 * strength),
            style.secondaryColor.withOpacity(0.22 * strength),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.36, 0.5, 0.64, 1],
        ).createShader(
          Rect.fromCenter(
            center: center,
            width: 2,
            height: verticalLength * 2,
          ),
        )
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(2.4)),
    );

    canvas.drawLine(
      center.translate(-horizontalLength, 0),
      center.translate(horizontalLength, 0),
      _paintPool.next()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.transparent,
            style.tertiaryColor.withOpacity(0.18 * strength),
            Colors.white.withOpacity(0.62 * strength),
            style.secondaryColor.withOpacity(0.18 * strength),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.36, 0.5, 0.64, 1],
        ).createShader(
          Rect.fromCenter(
            center: center,
            width: horizontalLength * 2,
            height: 2,
          ),
        )
        ..strokeWidth = 1.05
        ..strokeCap = StrokeCap.round
        ..applyBlur(NeonBlur.normal(2)),
    );
  }

  void _paintOrbitParticles(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    for (var index = 0; index < style.particleCount; index++) {
      final direction = index.isEven ? 1.0 : -0.64;
      final speed = 0.62 + (index % 4) * 0.18;
      final angle = phase * math.pi * 2 * direction * speed +
          index / style.particleCount * math.pi * 2;
      final orbit = radius + 3.5 + (index % 3) * 1.6;
      final elliptic = style.effect == NeonIndicatorEffect.singularity
          ? 0.74 + (index % 2) * 0.08
          : style.effect == NeonIndicatorEffect.neuralCore
              ? 0.82 + (index % 3) * 0.07
              : 1.0;
      final position = Offset(
        center.dx + NeonTrig.cos(angle) * orbit,
        center.dy + NeonTrig.sin(angle) * orbit * elliptic,
      );
      final color = index.isEven ? style.secondaryColor : style.tertiaryColor;
      final dotRadius = 0.5 + (index % 3) * 0.16;
      canvas.drawCircle(
        position,
        dotRadius + 1.4,
        _paintPool.next()
          ..color = color.withOpacity(0.13 * strength * style.detail)
          ..applyBlur(NeonBlur.normal(2)),
      );
      canvas.drawCircle(
        position,
        dotRadius,
        _paintPool.next()..color = color.withOpacity(0.72 * strength * style.detail),
      );
    }
  }

  void _paintMicroSparks(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    for (var index = 0; index < style.sparkCount; index++) {
      final seed = index * 83;
      final base = index / style.sparkCount * math.pi * 2;
      final drift = phase * math.pi * 2 * (index.isEven ? 0.08 : -0.05);
      final angle = base + drift;
      final orbit = radius * (1.18 + _hash01(seed + 7) * 0.44);
      final position = Offset(
        center.dx + NeonTrig.cos(angle) * orbit,
        center.dy + NeonTrig.sin(angle) * orbit,
      );
      final twinkle = 0.45 +
          0.55 * NeonTrig.sin(phase * math.pi * 2 * 1.7 + index * 1.93).abs();
      final color = switch (index % 3) {
        0 => style.borderColor,
        1 => style.secondaryColor,
        _ => style.tertiaryColor,
      };
      final size = 0.28 + _hash01(seed + 19) * 0.65;
      canvas.drawCircle(
        position,
        size + 0.9,
        _paintPool.next()
          ..color = color.withOpacity(
            0.08 * strength * style.detail * twinkle * style.noise,
          )
          ..applyBlur(NeonBlur.normal(1.5)),
      );
      canvas.drawCircle(
        position,
        size,
        _paintPool.next()
          ..color = color.withOpacity(
            0.38 * strength * style.detail * twinkle,
          ),
      );
    }
  }

  void _paintSpark(
    Canvas canvas,
    Offset center,
    double radius,
    double strength,
  ) {
    final outer = radius * (0.47 + pulse * 0.025);
    final inner = outer * 0.28;
    final spark = _fourPointSparkle(center, outer, inner);
    final bounds = spark.getBounds();
    canvas.drawPath(
      spark,
      _paintPool.next()
        ..color = style.secondaryColor.withOpacity(0.32 * strength)
        ..applyBlur(_blurs.sparkGlow),
    );
    canvas.drawPath(
      spark,
      _paintPool.next()
        ..shader = RadialGradient(
          center: const Alignment(-0.12, -0.16),
          radius: 0.9,
          colors: <Color>[
            Colors.white,
            style.borderColor,
            style.secondaryColor,
          ],
          stops: const <double>[0, 0.48, 1],
        ).createShader(bounds),
    );
    canvas.drawCircle(
      center,
      math.max(1.6, radius * 0.08),
      _paintPool.next()
        ..color = Colors.white.withOpacity(0.92 * strength)
        ..applyBlur(NeonBlur.normal(1.8)),
    );
  }

  Path _shapePath(Rect rect, NeonIndicatorShape shape) {
    switch (shape) {
      case NeonIndicatorShape.circle:
        return _pathPool.next()..addOval(rect);
      case NeonIndicatorShape.square:
        return _pathPool.next()
          ..addRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular(rect.width * 0.24),
            ),
          );
      case NeonIndicatorShape.diamond:
        final center = rect.center;
        return _pathPool.next()
          ..moveTo(center.dx, rect.top)
          ..lineTo(rect.right, center.dy)
          ..lineTo(center.dx, rect.bottom)
          ..lineTo(rect.left, center.dy)
          ..close();
    }
  }

  Path _fourPointSparkle(Offset center, double outer, double inner) {
    return _pathPool.next()
      ..moveTo(center.dx, center.dy - outer)
      ..cubicTo(
        center.dx - inner * 0.24,
        center.dy - inner * 1.18,
        center.dx - inner * 1.18,
        center.dy - inner * 0.24,
        center.dx - outer,
        center.dy,
      )
      ..cubicTo(
        center.dx - inner * 1.18,
        center.dy + inner * 0.24,
        center.dx - inner * 0.24,
        center.dy + inner * 1.18,
        center.dx,
        center.dy + outer,
      )
      ..cubicTo(
        center.dx + inner * 0.24,
        center.dy + inner * 1.18,
        center.dx + inner * 1.18,
        center.dy + inner * 0.24,
        center.dx + outer,
        center.dy,
      )
      ..cubicTo(
        center.dx + inner * 1.18,
        center.dy - inner * 0.24,
        center.dx + inner * 0.24,
        center.dy - inner * 1.18,
        center.dx,
        center.dy - outer,
      )
      ..close();
  }

  // Fast integer bit-scramble — visually identical to the old math.sin hash
  // but avoids a transcendental function call per particle/frame.
  double _hash01(int seed) {
    var n = seed ^ (seed << 13);
    n = n ^ (n >> 7);
    n = n ^ (n << 17);
    return (n & 0x7fffffff) / 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant _AdvancedIndicatorPainter oldDelegate) {
    return style != oldDelegate.style ||
        status != oldDelegate.status ||
        animation != oldDelegate.animation ||
        hovered != oldDelegate.hovered ||
        focused != oldDelegate.focused ||
        pressed != oldDelegate.pressed ||
        pointer != oldDelegate.pointer;
  }
}

class _StatusGlyph extends StatelessWidget {
  const _StatusGlyph({
    required this.status,
    required this.hideActiveGlyph,
    required this.indicatorSize,
  });

  final NeonTimelineStatus status;
  final bool hideActiveGlyph;
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    if (status == NeonTimelineStatus.active && hideActiveGlyph) {
      return const SizedBox.shrink();
    }
    final icon = switch (status) {
      NeonTimelineStatus.completed => Icons.check_rounded,
      NeonTimelineStatus.error => Icons.priority_high_rounded,
      NeonTimelineStatus.disabled => Icons.remove_rounded,
      NeonTimelineStatus.pending => Icons.circle,
      NeonTimelineStatus.active => Icons.circle,
    };
    final size = switch (status) {
      NeonTimelineStatus.pending ||
      NeonTimelineStatus.active =>
        math.max(7.0, math.min(11.0, indicatorSize * 0.16)),
      _ => math.max(16.0, math.min(24.0, indicatorSize * 0.34)),
    };
    return Icon(icon, size: size, color: Colors.white);
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/neon_timeline_theme.dart';
import '../utils/neon_perf_utils.dart';
import '../utils/neon_timeline_duration.dart';
import 'neon_timeline_motion.dart';

/// Built-in visual treatment for [NeonTimelineCard].
enum NeonTimelineCardVariant {
  /// Translucent surface with optional backdrop blur and glow.
  glass,

  /// Opaque theme surface.
  solid,

  /// Transparent surface with an accent outline.
  outlined,

  /// Soft two-color gradient surface.
  gradient,

  /// Layered glass with a spectral border and pointer-driven refraction.
  prismatic,

  /// Transparent digital surface with scanlines and segmented corners.
  holographic,

  /// Volumetric glass with animated liquid-caustic ribbons and spectral edges.
  liquidCrystal,
}

/// Optional polished surface for timeline content.
///
/// The timeline accepts any widget; this card is a convenience, not a layout
/// requirement. Advanced variants only change rendering and interaction.
class NeonTimelineCard extends StatefulWidget {
  /// Creates a themed timeline card.
  const NeonTimelineCard({
    required this.child,
    this.variant = NeonTimelineCardVariant.glass,
    this.accentColor,
    this.secondaryAccentColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.blurSigma = 12,
    this.intensity = 1,
    this.enableParallax = true,
    this.animate = true,
    this.continuousAnimation = false,
    this.useBackdropFilter = true,
    this.animationDuration = const Duration(milliseconds: 240),
    this.onTap,
    this.semanticLabel,
    super.key,
  })  : assert(blurSigma >= 0),
        assert(intensity >= 0 && intensity <= 2);

  /// Card contents.
  final Widget child;

  /// Surface treatment.
  final NeonTimelineCardVariant variant;

  /// Optional primary accent override.
  final Color? accentColor;

  /// Optional secondary spectral accent override.
  final Color? secondaryAccentColor;

  /// Insets around [child].
  final EdgeInsetsGeometry padding;

  /// Insets outside the decorated card.
  final EdgeInsetsGeometry margin;

  /// Card clipping and decoration radius.
  final BorderRadius borderRadius;

  /// Backdrop blur used by glass-like variants.
  final double blurSigma;

  /// Light output and interaction emphasis.
  final double intensity;

  /// Whether desktop hover can refract the surface.
  final bool enableParallax;

  /// Whether advanced card effects are allowed to animate.
  ///
  /// By default, a card animates only during hover, focus, or press. Static
  /// advanced cards keep the same visual treatment without repainting every
  /// frame.
  final bool animate;

  /// Whether the advanced card keeps animating while idle.
  ///
  /// Leave this false for ordinary list cards. Set it to true for one active
  /// hero card or a short showcase timeline.
  final bool continuousAnimation;

  /// Whether glass-like variants sample the content behind the card.
  ///
  /// Disable this only on extremely constrained surfaces. When a motion scope
  /// is present, enabled filters are grouped into one shared backdrop layer.
  final bool useBackdropFilter;

  /// Duration of hover and press transitions.
  final Duration animationDuration;

  /// Optional activation callback.
  final VoidCallback? onTap;

  /// Optional screen-reader label for an interactive card.
  final String? semanticLabel;

  @override
  State<NeonTimelineCard> createState() => _NeonTimelineCardState();
}

class _NeonTimelineCardState extends State<NeonTimelineCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  Offset _pointer = Offset.zero;
  Offset? _pendingPointer;
  bool _pointerUpdateScheduled = false;

  bool get _advanced =>
      widget.variant == NeonTimelineCardVariant.prismatic ||
      widget.variant == NeonTimelineCardVariant.holographic ||
      widget.variant == NeonTimelineCardVariant.liquidCrystal;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _updatePointer(PointerHoverEvent event, Size size) {
    if (!widget.enableParallax || size.isEmpty) return;
    final center = size.center(Offset.zero);
    _pendingPointer = Offset(
      ((event.localPosition.dx - center.dx) / math.max(1, center.dx))
          .clamp(-1.0, 1.0)
          .toDouble(),
      ((event.localPosition.dy - center.dy) / math.max(1, center.dy))
          .clamp(-1.0, 1.0)
          .toDouble(),
    );
    if (_pointerUpdateScheduled) return;
    _pointerUpdateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pointerUpdateScheduled = false;
      if (!mounted) return;
      final next = _pendingPointer;
      _pendingPointer = null;
      if (next != null && (_pointer - next).distanceSquared > 0.0005) {
        setState(() => _pointer = next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    final accent = widget.accentColor ?? theme.primaryColor;
    final secondary = widget.secondaryAccentColor ?? theme.secondaryColor;
    final motion = NeonTimelineMotionScope.maybeOf(context);
    final wantsMotion = widget.animate &&
        _advanced &&
        (widget.continuousAnimation || _hovered || _focused || _pressed);
    final motionAnimation = wantsMotion && motion?.enabled == true
        ? motion!.animation
        : const AlwaysStoppedAnimation<double>(0.28);
    final interaction = (_hovered || _focused) ? 1.0 : 0.0;
    final scale = _pressed ? 0.992 : (_hovered ? 1.006 : 1.0);
    final transitionDuration = neonNonNegativeDuration(
      widget.animationDuration,
      debugLabel: 'NeonTimelineCard.animationDuration',
    );

    Widget contents = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(padding: widget.padding, child: widget.child),
    );
    final cardChild = contents;

    contents = LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );
        Widget decorated = AnimatedContainer(
          duration: transitionDuration,
          curve: Curves.easeOutCubic,
          decoration: _decoration(
            theme,
            accent,
            secondary,
            interaction,
          ),
          child: cardChild,
        );

        if (_advanced) {
          decorated = CustomPaint(
            isComplex: true,
            willChange: wantsMotion && motion?.enabled == true,
            foregroundPainter: _CardFxPainter(
              variant: widget.variant,
              borderRadius: widget.borderRadius,
              accent: accent,
              secondary: secondary,
              animation: motionAnimation,
              pointer: _pointer,
              hovered: _hovered,
              focused: _focused,
              pressed: _pressed,
              intensity: widget.intensity,
            ),
            child: decorated,
          );
        }

        return MouseRegion(
          cursor: widget.onTap == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          onEnter: (_) {
            if (!_hovered) setState(() => _hovered = true);
          },
          onHover: (event) => _updatePointer(event, size),
          onExit: (_) {
            if (_hovered || _pressed || _pointer != Offset.zero) {
              setState(() {
                _hovered = false;
                _pressed = false;
                _pointer = Offset.zero;
              });
            }
          },
          child: decorated,
        );
      },
    );

    if (widget.onTap != null) {
      contents = FocusableActionDetector(
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
          child: contents,
        ),
      );
    }

    final tiltX =
        widget.enableParallax && _advanced ? -_pointer.dy * 0.016 : 0.0;
    final tiltY =
        widget.enableParallax && _advanced ? _pointer.dx * 0.020 : 0.0;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(tiltX)
      ..rotateY(tiltY);

    Widget card = AnimatedScale(
      duration: transitionDuration,
      curve: Curves.easeOutCubic,
      scale: scale,
      child: AnimatedContainer(
        duration: transitionDuration,
        curve: Curves.easeOutCubic,
        transform: transform,
        transformAlignment: Alignment.center,
        child: contents,
      ),
    );

    final blurSigma = widget.blurSigma.isFinite
        ? math.max(0.0, widget.blurSigma)
        : 0.0;
    if (!kIsWeb && widget.useBackdropFilter && _usesBackdropBlur && blurSigma > 0) {
      final filter = ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      );
      card = BackdropGroup.of(context) == null
          ? BackdropFilter(filter: filter, child: card)
          : BackdropFilter.grouped(filter: filter, child: card);
    }
    card = ClipRRect(borderRadius: widget.borderRadius, child: card);
    card = Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: card,
    );
    return RepaintBoundary(
      child: Padding(padding: widget.margin, child: card),
    );
  }

  bool get _usesBackdropBlur =>
      widget.variant == NeonTimelineCardVariant.glass ||
      widget.variant == NeonTimelineCardVariant.prismatic ||
      widget.variant == NeonTimelineCardVariant.holographic ||
      widget.variant == NeonTimelineCardVariant.liquidCrystal;

  BoxDecoration _decoration(
    NeonTimelineThemeData theme,
    Color accent,
    Color secondary,
    double interaction,
  ) {
    final alphaBoost = (interaction * 24).round();
    final border = Border.all(
      color: accent.withAlpha(
        widget.variant == NeonTimelineCardVariant.outlined
            ? 190
            : 75 + alphaBoost,
      ),
      width: widget.variant == NeonTimelineCardVariant.outlined ? 1.5 : 1,
    );
    return switch (widget.variant) {
      NeonTimelineCardVariant.glass => BoxDecoration(
          color: theme.surfaceColor.withAlpha(205),
          borderRadius: widget.borderRadius,
          border: border,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withAlpha(38 + alphaBoost),
              blurRadius: 24 + interaction * 8,
              spreadRadius: -6,
            ),
          ],
        ),
      NeonTimelineCardVariant.solid => BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: widget.borderRadius,
          border: border,
        ),
      NeonTimelineCardVariant.outlined => BoxDecoration(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          border: border,
        ),
      NeonTimelineCardVariant.gradient => BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              accent.withAlpha(100 + alphaBoost),
              secondary.withAlpha(55 + alphaBoost ~/ 2),
              theme.surfaceColor.withAlpha(235),
            ],
          ),
          borderRadius: widget.borderRadius,
          border: border,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withAlpha(32 + alphaBoost),
              blurRadius: 20 + interaction * 8,
              spreadRadius: -5,
            ),
          ],
        ),
      NeonTimelineCardVariant.prismatic => BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.9, -0.8),
            end: const Alignment(0.9, 0.8),
            colors: <Color>[
              Color.lerp(theme.surfaceColor, accent, 0.12)!.withAlpha(230),
              theme.surfaceColor.withAlpha(214),
              Color.lerp(theme.surfaceColor, secondary, 0.10)!.withAlpha(226),
            ],
            stops: const <double>[0, 0.52, 1],
          ),
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: Colors.white.withAlpha(48 + alphaBoost),
            width: 0.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withAlpha(34 + alphaBoost),
              blurRadius: 28 + interaction * 10,
              spreadRadius: -7,
            ),
            BoxShadow(
              color: secondary.withAlpha(22 + alphaBoost ~/ 2),
              blurRadius: 18,
              offset: const Offset(8, 8),
              spreadRadius: -10,
            ),
          ],
        ),
      NeonTimelineCardVariant.holographic => BoxDecoration(
          color: Color.lerp(theme.surfaceColor, accent, 0.05)!.withAlpha(196),
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: accent.withAlpha(92 + alphaBoost),
            width: 0.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withAlpha(28 + alphaBoost),
              blurRadius: 22 + interaction * 8,
              spreadRadius: -8,
            ),
          ],
        ),
      NeonTimelineCardVariant.liquidCrystal => BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.95, -0.9),
            end: const Alignment(0.95, 0.9),
            colors: <Color>[
              Color.lerp(theme.surfaceColor, accent, 0.16)!.withAlpha(224),
              theme.surfaceColor.withAlpha(205),
              Color.lerp(theme.surfaceColor, secondary, 0.14)!.withAlpha(218),
            ],
            stops: const <double>[0, 0.48, 1],
          ),
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: Colors.white.withAlpha(54 + alphaBoost),
            width: 0.9,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withAlpha(42 + alphaBoost),
              blurRadius: 34 + interaction * 12,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: secondary.withAlpha(24 + alphaBoost ~/ 2),
              blurRadius: 28,
              offset: const Offset(-8, 10),
              spreadRadius: -12,
            ),
          ],
        ),
    };
  }
}

class _CardFxPainter extends CustomPainter {
  _CardFxPainter({
    required this.variant,
    required this.borderRadius,
    required this.accent,
    required this.secondary,
    required this.animation,
    required this.pointer,
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.intensity,
  }) : super(repaint: animation);

  final NeonTimelineCardVariant variant;
  final BorderRadius borderRadius;
  final Color accent;
  final Color secondary;
  final Animation<double> animation;
  final Offset pointer;
  final bool hovered;
  final bool focused;
  final bool pressed;
  final double intensity;

  final NeonPaintPool _paintPool = NeonPaintPool();
  final Paint _fillPaint = Paint();
  final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _glowPaint = Paint()..style = PaintingStyle.stroke;
  final Path _scanlinePath = Path();
  final Path _verticalGridPath = Path();
  final Path _horizontalGridPath = Path();
  final Map<int, List<Path>> _ribbonPathCache = <int, List<Path>>{};
  Size _ribbonCacheSize = Size.zero;
  int _ribbonCachePointerX = 0;
  int _ribbonCachePointerY = 0;

  double get phase => animation.value;

  double get _strength {
    final interaction = hovered || focused ? 1.0 : 0.72;
    return (interaction * (pressed ? 0.88 : 1.0) * intensity)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _paintPool.reset();
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect.deflate(0.5));
    final strength = _strength;

    if (variant == NeonTimelineCardVariant.prismatic) {
      _paintPrismatic(canvas, rect, rrect, strength);
    } else if (variant == NeonTimelineCardVariant.holographic) {
      _paintHolographic(canvas, rect, rrect, strength);
    } else if (variant == NeonTimelineCardVariant.liquidCrystal) {
      _paintLiquidCrystal(canvas, rect, rrect, strength);
    }
  }

  void _paintPrismatic(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double strength,
  ) {
    final center = rect.center +
        Offset(
          pointer.dx * rect.width * 0.14,
          pointer.dy * rect.height * 0.14,
        );
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawCircle(
      center,
      math.max(rect.width, rect.height) * 0.56,
      _paintPool.next()
        ..shader = ui.Gradient.radial(
          center,
          math.max(rect.width, rect.height) * 0.56,
          <Color>[
            Colors.white.withOpacity(0.10 * strength),
            accent.withOpacity(0.055 * strength),
            secondary.withOpacity(0.025 * strength),
            Colors.transparent,
          ],
          const <double>[0, 0.24, 0.58, 1],
        ),
    );
    final sheen = Rect.fromCenter(
      center: center,
      width: rect.width * 0.46,
      height: rect.height * 1.8,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.42 + pointer.dx * 0.08);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(
      sheen,
      _paintPool.next()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.transparent,
            Colors.white.withOpacity(0.075 * strength),
            accent.withOpacity(0.055 * strength),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.38, 0.62, 1],
        ).createShader(sheen),
    );
    canvas.restore();
    canvas.restore();

    canvas.drawRRect(
      rrect,
      _paintPool.next()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.white.withOpacity(0.62 * strength),
            accent.withOpacity(0.72 * strength),
            secondary.withOpacity(0.62 * strength),
            Colors.white.withOpacity(0.28 * strength),
            Colors.white.withOpacity(0.62 * strength),
          ],
        ).createShader(rect),
    );
  }

  void _paintHolographic(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double strength,
  ) {
    canvas.save();
    canvas.clipRRect(rrect);
    const spacing = 4.0;
    final shift = (phase * spacing * 2) % spacing;
    _scanlinePath.reset();
    for (double y = rect.top - spacing; y <= rect.bottom; y += spacing) {
      final yy = y + shift;
      _scanlinePath
        ..moveTo(rect.left, yy)
        ..lineTo(rect.right, yy);
    }
    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeWidth = 0.45
      ..strokeCap = StrokeCap.butt
      ..color = accent.withOpacity(0.030 * strength);
    canvas.drawPath(_scanlinePath, _strokePaint);

    // A second sparse shimmer pass preserves the moving holographic texture
    // without issuing one draw call and one Paint allocation per scanline.
    _scanlinePath.reset();
    var lineIndex = 0;
    for (double y = rect.top - spacing; y <= rect.bottom; y += spacing) {
      final yy = y + shift;
      if ((lineIndex++ & 3) == 0) {
        _scanlinePath
          ..moveTo(rect.left, yy)
          ..lineTo(rect.right, yy);
      }
    }
    _strokePaint.color = accent.withOpacity(0.025 * strength);
    canvas.drawPath(_scanlinePath, _strokePaint);
    canvas.restore();

    final primaryBrackets = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + 16, rect.top)
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right - 16, rect.top)
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left + 16, rect.bottom)
      ..moveTo(rect.right, rect.bottom)
      ..lineTo(rect.right - 16, rect.bottom);
    _strokePaint
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..color = accent.withOpacity(0.42 * strength);
    canvas.drawPath(primaryBrackets, _strokePaint);

    final secondaryBrackets = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.top + 16)
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + 16)
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.bottom - 16)
      ..moveTo(rect.right, rect.bottom)
      ..lineTo(rect.right, rect.bottom - 16);
    _strokePaint
      ..strokeWidth = 0.75
      ..color = secondary.withOpacity(0.42 * strength);
    canvas.drawPath(secondaryBrackets, _strokePaint);
  }

  void _paintLiquidCrystal(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double strength,
  ) {
    canvas.save();
    canvas.clipRRect(rrect);

    final pointerCenter = rect.center +
        Offset(
          pointer.dx * rect.width * 0.18,
          pointer.dy * rect.height * 0.20,
        );
    _fillPaint
      ..style = PaintingStyle.fill
      ..maskFilter = null
      ..shader = ui.Gradient.radial(
        pointerCenter,
        math.max(rect.width, rect.height) * 0.52,
        <Color>[
          Colors.white.withOpacity(0.11 * strength),
          accent.withOpacity(0.07 * strength),
          secondary.withOpacity(0.035 * strength),
          Colors.transparent,
        ],
        const <double>[0, 0.22, 0.58, 1],
      );
    canvas.drawCircle(
      pointerCenter,
      math.max(rect.width, rect.height) * 0.52,
      _fillPaint,
    );

    final ribbonCount = rect.width < 220 ? 4 : 6;
    final phaseBucket = NeonPhaseQuantizer.bucket(phase, buckets: 96);
    final pointerX = (pointer.dx * 32).round();
    final pointerY = (pointer.dy * 32).round();
    if (_ribbonCacheSize != rect.size ||
        _ribbonCachePointerX != pointerX ||
        _ribbonCachePointerY != pointerY) {
      _ribbonPathCache.clear();
      _ribbonCacheSize = rect.size;
      _ribbonCachePointerX = pointerX;
      _ribbonCachePointerY = pointerY;
    }
    final paths = _ribbonPathCache.putIfAbsent(
      phaseBucket,
      () => _buildRibbonPaths(
        rect: rect,
        ribbonCount: ribbonCount,
        phase: NeonPhaseQuantizer.phaseFor(phaseBucket, buckets: 96),
        pointerY: pointerY / 32,
      ),
    );
    if (_ribbonPathCache.length > 96) {
      _ribbonPathCache.remove(_ribbonPathCache.keys.first);
    }

    for (var ribbon = 0; ribbon < ribbonCount; ribbon++) {
      final ribbonColor = switch (ribbon % 3) {
        0 => accent,
        1 => secondary,
        _ => Colors.white,
      };
      _glowPaint
        ..shader = null
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5 + ribbon * 0.45
        ..strokeCap = StrokeCap.round
        ..color = ribbonColor.withOpacity(0.035 * strength)
        ..maskFilter = null
        ..applyBlur(
          NeonBlur.normal(6),
        );
      canvas.drawPath(paths[ribbon], _glowPaint);

      _strokePaint
        ..shader = null
        ..maskFilter = null
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.42 + (ribbon % 2) * 0.18
        ..strokeCap = StrokeCap.round
        ..color = ribbonColor.withOpacity(0.16 * strength);
      canvas.drawPath(paths[ribbon], _strokePaint);
    }

    final gridOpacity = 0.035 * strength;
    final spacing = math.max(14.0, rect.width / 18);
    final shift = phase * spacing;
    _verticalGridPath.reset();
    for (double x = rect.left - spacing;
        x <= rect.right + spacing;
        x += spacing) {
      final xx = x + shift % spacing;
      _verticalGridPath
        ..moveTo(xx, rect.top)
        ..lineTo(xx, rect.bottom);
    }
    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 0.35
      ..color = accent.withOpacity(gridOpacity);
    canvas.drawPath(_verticalGridPath, _strokePaint);

    _horizontalGridPath.reset();
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      _horizontalGridPath
        ..moveTo(rect.left, y)
        ..lineTo(rect.right, y);
    }
    _strokePaint
      ..strokeWidth = 0.3
      ..color = secondary.withOpacity(gridOpacity * 0.7);
    canvas.drawPath(_horizontalGridPath, _strokePaint);
    canvas.restore();

    final rotation = phase * math.pi * 0.18 + pointer.dx * 0.12;
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotation);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    _strokePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.butt
      ..maskFilter = null
      ..shader = SweepGradient(
        colors: <Color>[
          Colors.white.withOpacity(0.68 * strength),
          accent.withOpacity(0.82 * strength),
          secondary.withOpacity(0.76 * strength),
          Colors.white.withOpacity(0.30 * strength),
          Colors.white.withOpacity(0.68 * strength),
        ],
        stops: const <double>[0, 0.24, 0.56, 0.82, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, _strokePaint);
    canvas.restore();
  }

  List<Path> _buildRibbonPaths({
    required Rect rect,
    required int ribbonCount,
    required double phase,
    required double pointerY,
  }) {
    const steps = 48;
    return List<Path>.generate(ribbonCount, (ribbon) {
      final path = Path();
      final yBase = rect.top +
          (ribbon + 0.5) / ribbonCount * rect.height +
          NeonTrig.sinTurns(phase + ribbon / (math.pi * 2)) * 4;
      for (var step = 0; step <= steps; step++) {
        final t = step / steps;
        final x = rect.left + t * rect.width;
        final wave = NeonTrig.sin(
              t * math.pi * (2.2 + ribbon * 0.17) +
                  phase * math.pi * 2 * (ribbon.isEven ? 0.7 : -0.5) +
                  ribbon,
            ) *
            (4.0 + ribbon * 0.7);
        final y = yBase + wave + pointerY * 4 * (1 - t);
        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }, growable: false);
  }

  @override
  bool shouldRepaint(covariant _CardFxPainter oldDelegate) {
    return variant != oldDelegate.variant ||
        borderRadius != oldDelegate.borderRadius ||
        accent != oldDelegate.accent ||
        secondary != oldDelegate.secondary ||
        animation != oldDelegate.animation ||
        pointer != oldDelegate.pointer ||
        hovered != oldDelegate.hovered ||
        focused != oldDelegate.focused ||
        pressed != oldDelegate.pressed ||
        intensity != oldDelegate.intensity;
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Continuous edge-scroll tuning expressed in pixels per second.
@immutable
class UltimateTimelineAutoScrollConfig {
  const UltimateTimelineAutoScrollConfig({
    this.edgeZone = 128,
    this.minimumVelocity = 36,
    this.maximumVelocity = 720,
    this.acceleration = 1800,
    this.deceleration = 2400,
    this.frameInterval = const Duration(milliseconds: 16),
  }) : assert(edgeZone > 0),
       assert(minimumVelocity >= 0),
       assert(maximumVelocity >= minimumVelocity),
       assert(acceleration > 0),
       assert(deceleration > 0);

  final double edgeZone;
  final double minimumVelocity;
  final double maximumVelocity;
  final double acceleration;
  final double deceleration;
  final Duration frameInterval;

  /// Signed desired velocity for a pointer in viewport-local coordinates.
  double velocityFor({
    required double pointer,
    required double viewportExtent,
  }) {
    if (!pointer.isFinite || !viewportExtent.isFinite || viewportExtent <= 0) {
      return 0;
    }
    final edge = math.min(edgeZone, viewportExtent / 2);
    double intensity;
    double sign;
    if (pointer < edge) {
      intensity = ((edge - pointer) / edge).clamp(0.0, 1.0).toDouble();
      sign = -1;
    } else if (pointer > viewportExtent - edge) {
      intensity = ((pointer - (viewportExtent - edge)) / edge)
          .clamp(0.0, 1.0)
          .toDouble();
      sign = 1;
    } else {
      return 0;
    }
    final eased = intensity * intensity * (3 - 2 * intensity);
    return sign *
        (minimumVelocity + (maximumVelocity - minimumVelocity) * eased);
  }
}

/// Single-loop, acceleration-limited edge-scroll controller for drag/resize.
class UltimateTimelineAutoScrollController extends ChangeNotifier {
  UltimateTimelineAutoScrollController({
    required this.scrollController,
    this.config = const UltimateTimelineAutoScrollConfig(),
    this.onScrollStep,
  });

  final ScrollController scrollController;
  final UltimateTimelineAutoScrollConfig config;

  /// Invoked after a real scroll step so the host can re-hit-test geometry.
  final ValueChanged<double>? onScrollStep;

  Timer? _timer;
  double _targetVelocity = 0;
  double _velocity = 0;
  bool _disposed = false;

  double get velocity => _velocity;
  bool get active => _timer != null;

  /// Updates the latest pointer position without starting duplicate loops.
  void updatePointer({
    required double pointer,
    required double viewportExtent,
  }) {
    if (_disposed) return;
    _targetVelocity = config.velocityFor(
      pointer: pointer,
      viewportExtent: viewportExtent,
    );
    if (_targetVelocity != 0 || _velocity != 0) _ensureLoop();
  }

  void _ensureLoop() {
    if (_timer != null || _disposed) return;
    _timer = Timer.periodic(config.frameInterval, (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_disposed) return;
    final seconds =
        config.frameInterval.inMicroseconds / Duration.microsecondsPerSecond;
    final sameDirection =
        _targetVelocity == 0 ||
        _velocity == 0 ||
        _targetVelocity.sign == _velocity.sign;
    final rate = sameDirection && _targetVelocity.abs() > _velocity.abs()
        ? config.acceleration
        : config.deceleration;
    _velocity = _approach(_velocity, _targetVelocity, rate * seconds);

    if (_velocity.abs() < 0.1 && _targetVelocity == 0) {
      stop();
      return;
    }
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final current = scrollController.offset;
    final next = (current + _velocity * seconds)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (next == current) {
      _velocity = 0;
      if (_targetVelocity.sign ==
          (current <= position.minScrollExtent ? -1 : 1)) {
        _targetVelocity = 0;
      }
      return;
    }
    scrollController.jumpTo(next);
    onScrollStep?.call(next);
    notifyListeners();
  }

  /// Stops acceleration, cancels the only loop and releases velocity.
  void stop() {
    _targetVelocity = 0;
    _velocity = 0;
    final timer = _timer;
    _timer = null;
    timer?.cancel();
    if (!_disposed) notifyListeners();
  }

  static double _approach(double current, double target, double delta) {
    if (current < target) return math.min(current + delta, target);
    if (current > target) return math.max(current - delta, target);
    return target;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _velocity = 0;
    _targetVelocity = 0;
    super.dispose();
  }
}

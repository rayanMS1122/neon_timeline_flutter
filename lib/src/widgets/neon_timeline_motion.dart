import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/neon_timeline_duration.dart';

/// A shared, sampled animation clock for timeline indicators, connectors, and
/// advanced cards.
///
/// The source controller remains frame-synchronised, but descendants are only
/// notified at [framesPerSecond]. This keeps the visual motion while avoiding
/// a full repaint of every advanced painter at the display refresh rate.
/// Motion also pauses while a descendant scroll view is moving, while the app
/// is inactive, when [TickerMode] is disabled, or when reduced motion is
/// requested by the platform.
class NeonTimelineMotionScope extends StatefulWidget {
  /// Creates a synchronized motion scope.
  const NeonTimelineMotionScope({
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 4200),
    this.phaseOffset = 0,
    this.framesPerSecond = 30,
    this.pauseWhenScrolling = true,
    this.scrollResumeDelay = const Duration(milliseconds: 120),
    this.pauseWhenAppInactive = true,
    this.groupBackdropFilters = true,
    super.key,
  })  : assert(phaseOffset >= 0 && phaseOffset <= 1),
        assert(framesPerSecond >= 1 && framesPerSecond <= 120);

  /// Subtree that consumes the shared animation phase.
  final Widget child;

  /// Whether the clock is allowed to run.
  final bool enabled;

  /// Duration of one normalized motion cycle.
  final Duration duration;

  /// Initial normalized phase offset from `0` to `1`.
  final double phaseOffset;

  /// Maximum number of expensive painter notifications per second.
  ///
  /// `30` is the package default. Use `60` only for a small hero timeline.
  final int framesPerSecond;

  /// Whether motion pauses while a descendant scrollable is moving.
  final bool pauseWhenScrolling;

  /// Delay before motion resumes after scrolling stops.
  final Duration scrollResumeDelay;

  /// Whether motion pauses when the application is not resumed.
  final bool pauseWhenAppInactive;

  /// Whether advanced card backdrop filters share one backdrop input layer.
  final bool groupBackdropFilters;

  /// Returns motion data from the closest scope, or `null` when absent.
  static NeonTimelineMotionData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_NeonTimelineMotionInherited>()
        ?.data;
  }

  @override
  State<NeonTimelineMotionScope> createState() =>
      _NeonTimelineMotionScopeState();
}

class _NeonTimelineMotionScopeState extends State<NeonTimelineMotionScope>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _fallbackDuration = Duration(milliseconds: 4200);

  late final AnimationController _controller;
  late final _SampledAnimation _sampledAnimation;
  Timer? _resumeTimer;
  ValueNotifier<bool>? _ancestorScrollingNotifier;
  bool _scrolling = false;
  bool _appIsActive = true;
  int _lastDispatchMicros = -1;
  bool _reduceMotion = false;
  bool _tickerEnabled = true;

  Duration get _effectiveDuration => neonPositiveDuration(
        widget.duration,
        fallback: _fallbackDuration,
        debugLabel: 'NeonTimelineMotionScope.duration',
      );

  Duration get _effectiveResumeDelay => neonNonNegativeDuration(
        widget.scrollResumeDelay,
        debugLabel: 'NeonTimelineMotionScope.scrollResumeDelay',
      );

  int get _effectiveFramesPerSecond =>
      widget.framesPerSecond.clamp(1, 120).toInt();

  double get _effectivePhaseOffset =>
      widget.phaseOffset.clamp(0.0, 1.0).toDouble();

  int get _frameIntervalMicros =>
      (Duration.microsecondsPerSecond / _effectiveFramesPerSecond).round();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _appIsActive =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _controller = AnimationController(
      vsync: this,
      duration: _effectiveDuration,
      value: _effectivePhaseOffset,
    )..addListener(_dispatchSample);
    _sampledAnimation = _SampledAnimation(
      value: _effectivePhaseOffset,
      status: _controller.status,
      onListenerStateChanged: _sync,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _tickerEnabled = TickerMode.of(context);
    _attachAncestorScrollable();
    _sync();
  }

  @override
  void didUpdateWidget(covariant NeonTimelineMotionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = _effectiveDuration;
    }
    if (oldWidget.framesPerSecond != widget.framesPerSecond) {
      _lastDispatchMicros = -1;
    }
    if (oldWidget.pauseWhenScrolling != widget.pauseWhenScrolling) {
      _resumeTimer?.cancel();
      _resumeTimer = null;
      _scrolling = widget.pauseWhenScrolling &&
          (_ancestorScrollingNotifier?.value ?? false);
    }
    if (oldWidget.phaseOffset != widget.phaseOffset &&
        !_controller.isAnimating) {
      _controller.value = _effectivePhaseOffset;
      _sampledAnimation.update(_effectivePhaseOffset, _controller.status);
    }
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration ||
        oldWidget.pauseWhenScrolling != widget.pauseWhenScrolling ||
        oldWidget.pauseWhenAppInactive != widget.pauseWhenAppInactive) {
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsActive = state == AppLifecycleState.resumed;
    _sync();
  }

  void _attachAncestorScrollable() {
    final next = Scrollable.maybeOf(context)?.position.isScrollingNotifier;
    if (identical(next, _ancestorScrollingNotifier)) return;
    _ancestorScrollingNotifier?.removeListener(_handleAncestorScrollChanged);
    _ancestorScrollingNotifier = next;
    next?.addListener(_handleAncestorScrollChanged);
    if (widget.pauseWhenScrolling && next?.value == true) {
      _scrolling = true;
    }
  }

  void _handleAncestorScrollChanged() {
    if (!widget.pauseWhenScrolling) return;
    final scrolling = _ancestorScrollingNotifier?.value ?? false;
    if (scrolling) {
      _resumeTimer?.cancel();
      if (!_scrolling) {
        _scrolling = true;
        _sync();
      }
    } else {
      _scheduleResumeAfterScroll();
    }
  }

  void _dispatchSample() {
    final elapsedMicros =
        _controller.lastElapsedDuration?.inMicroseconds ?? 0;
    if (_lastDispatchMicros >= 0 &&
        elapsedMicros - _lastDispatchMicros < _frameIntervalMicros) {
      return;
    }
    _lastDispatchMicros = elapsedMicros;
    _sampledAnimation.update(_controller.value, _controller.status);
  }

  void _sync() {
    if (!mounted) return;
    final canRun = widget.enabled &&
        _sampledAnimation.hasConsumers &&
        !_reduceMotion &&
        _tickerEnabled &&
        (!widget.pauseWhenScrolling || !_scrolling) &&
        (!widget.pauseWhenAppInactive || _appIsActive);

    if (canRun) {
      if (!_controller.isAnimating) {
        _lastDispatchMicros = -1;
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _sampledAnimation.update(_controller.value, _controller.status);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.pauseWhenScrolling) return false;

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      _resumeTimer?.cancel();
      if (!_scrolling) {
        _scrolling = true;
        _sync();
      }
      return false;
    }

    if (notification is ScrollEndNotification) {
      _scheduleResumeAfterScroll();
    }
    return false;
  }

  void _scheduleResumeAfterScroll() {
    _resumeTimer?.cancel();
    final delay = _effectiveResumeDelay;
    if (delay == Duration.zero) {
      _resumeAfterScroll();
    } else {
      _resumeTimer = Timer(delay, _resumeAfterScroll);
    }
  }

  void _resumeAfterScroll() {
    _resumeTimer = null;
    if (!_scrolling) return;
    _scrolling = false;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeTimer?.cancel();
    _ancestorScrollingNotifier?.removeListener(_handleAncestorScrollChanged);
    _controller
      ..removeListener(_dispatchSample)
      ..dispose();
    _sampledAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: _NeonTimelineMotionInherited(
        data: NeonTimelineMotionData(
          animation: _sampledAnimation,
          duration: _effectiveDuration,
          enabled: widget.enabled,
          framesPerSecond: _effectiveFramesPerSecond,
        ),
        child: widget.child,
      ),
    );

    if (widget.groupBackdropFilters) {
      result = BackdropGroup(child: result);
    }
    return result;
  }
}

/// Immutable data exposed by [NeonTimelineMotionScope].
@immutable
class NeonTimelineMotionData {
  /// Creates shared motion data.
  const NeonTimelineMotionData({
    required this.animation,
    required this.duration,
    required this.enabled,
    required this.framesPerSecond,
  });

  /// Sampled normalized repeating phase from `0` to `1`.
  final Animation<double> animation;

  /// Duration of one complete phase cycle.
  final Duration duration;

  /// Whether motion was requested by the scope.
  final bool enabled;

  /// Maximum painter update rate.
  final int framesPerSecond;
}

class _SampledAnimation extends ChangeNotifier implements Animation<double> {
  _SampledAnimation({
    required double value,
    required AnimationStatus status,
    required this.onListenerStateChanged,
  })  : _value = value,
        _status = status;

  final VoidCallback onListenerStateChanged;
  double _value;
  AnimationStatus _status;
  int _listenerCount = 0;
  final Set<AnimationStatusListener> _statusListeners =
      <AnimationStatusListener>{};

  bool get hasConsumers =>
      _listenerCount > 0 || _statusListeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) {
    final hadConsumers = hasConsumers;
    super.addListener(listener);
    _listenerCount++;
    if (!hadConsumers) onListenerStateChanged();
  }

  @override
  void removeListener(VoidCallback listener) {
    final hadConsumers = hasConsumers;
    super.removeListener(listener);
    if (_listenerCount > 0) _listenerCount--;
    if (hadConsumers && !hasConsumers) onListenerStateChanged();
  }

  @override
  double get value => _value;

  @override
  AnimationStatus get status => _status;

  void update(double value, AnimationStatus status) {
    final valueChanged = value != _value;
    final statusChanged = status != _status;
    _value = value;
    _status = status;

    if (statusChanged) {
      for (final listener in List<AnimationStatusListener>.of(
        _statusListeners,
      )) {
        listener(status);
      }
    }
    if (valueChanged) notifyListeners();
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    final hadConsumers = hasConsumers;
    _statusListeners.add(listener);
    if (!hadConsumers && hasConsumers) onListenerStateChanged();
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    final hadConsumers = hasConsumers;
    _statusListeners.remove(listener);
    if (hadConsumers && !hasConsumers) onListenerStateChanged();
  }

  @override
  Animation<U> drive<U>(Animatable<U> child) => child.animate(this);

  @override
  bool get isAnimating => status == AnimationStatus.forward || status == AnimationStatus.reverse;

  @override
  bool get isCompleted => status == AnimationStatus.completed;

  @override
  bool get isDismissed => status == AnimationStatus.dismissed;

  @override
  bool get isForwardOrCompleted => status == AnimationStatus.forward || status == AnimationStatus.completed;

  @override
  String toStringDetails() => '$status; $value';
}

class _NeonTimelineMotionInherited extends InheritedWidget {
  const _NeonTimelineMotionInherited({
    required this.data,
    required super.child,
  });

  final NeonTimelineMotionData data;

  @override
  bool updateShouldNotify(_NeonTimelineMotionInherited oldWidget) {
    return data.animation != oldWidget.data.animation ||
        data.duration != oldWidget.data.duration ||
        data.enabled != oldWidget.data.enabled ||
        data.framesPerSecond != oldWidget.data.framesPerSecond;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/neon_timeline_duration.dart';

/// A shared, sampled animation clock for timeline indicators, connectors, and
/// advanced cards.
///
/// Unlike a normal [AnimationController], this clock does not wake up on every
/// display refresh and then throw frames away. It schedules only the painter
/// samples requested by [framesPerSecond], and completely stops when no
/// descendant listens to it. That substantially reduces idle CPU usage in long
/// timelines while keeping all widgets synchronized.
class NeonTimelineMotionScope extends StatefulWidget {
  /// Creates a synchronized motion scope.
  const NeonTimelineMotionScope({
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 4200),
    this.phaseOffset = 0,
    this.framesPerSecond = 24,
    this.pauseWhenScrolling = true,
    this.scrollResumeDelay = const Duration(milliseconds: 120),
    this.pauseWhenAppInactive = true,
    this.pauseWhenRouteInactive = true,
    this.startupDelay = const Duration(milliseconds: 120),
    this.groupBackdropFilters = true,
    super.key,
  }) : assert(phaseOffset >= 0 && phaseOffset <= 1),
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
  final int framesPerSecond;

  /// Whether motion pauses while a descendant scrollable is moving.
  final bool pauseWhenScrolling;

  /// Delay before motion resumes after scrolling stops.
  final Duration scrollResumeDelay;

  /// Whether motion pauses when the application is not resumed.
  final bool pauseWhenAppInactive;

  /// Whether motion pauses while the containing route is not current.
  final bool pauseWhenRouteInactive;

  /// Delay after the first rendered frame before continuous motion starts.
  ///
  /// This prevents expensive effects from competing with startup and first
  /// content paint. A zero duration starts immediately after the first frame.
  final Duration startupDelay;

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
    with WidgetsBindingObserver {
  static const _fallbackDuration = Duration(milliseconds: 4200);

  late final _SampledAnimation _sampledAnimation;
  Timer? _tickTimer;
  Timer? _resumeTimer;
  Timer? _startupTimer;
  ValueNotifier<bool>? _ancestorScrollingNotifier;

  bool _scrolling = false;
  bool _appIsActive = true;
  bool _reduceMotion = false;
  bool _tickerEnabled = true;
  bool _routeIsCurrent = true;
  bool _startupReady = false;
  bool _disposing = false;
  double _phase = 0;

  Duration get _effectiveDuration => neonPositiveDuration(
    widget.duration,
    fallback: _fallbackDuration,
    debugLabel: 'NeonTimelineMotionScope.duration',
  );

  Duration get _effectiveResumeDelay => neonNonNegativeDuration(
    widget.scrollResumeDelay,
    debugLabel: 'NeonTimelineMotionScope.scrollResumeDelay',
  );

  Duration get _effectiveStartupDelay => neonNonNegativeDuration(
    widget.startupDelay,
    debugLabel: 'NeonTimelineMotionScope.startupDelay',
  );

  int get _effectiveFramesPerSecond =>
      widget.framesPerSecond.clamp(1, 120).toInt();

  double get _effectivePhaseOffset =>
      widget.phaseOffset.clamp(0.0, 1.0).toDouble();

  Duration get _frameInterval {
    final micros = (Duration.microsecondsPerSecond / _effectiveFramesPerSecond)
        .round();
    return Duration(microseconds: micros.clamp(1000, 1000000).toInt());
  }

  bool get _canRun {
    return mounted &&
        !_disposing &&
        widget.enabled &&
        _startupReady &&
        _sampledAnimation.hasConsumers &&
        !_reduceMotion &&
        _tickerEnabled &&
        (!widget.pauseWhenRouteInactive || _routeIsCurrent) &&
        (!widget.pauseWhenScrolling || !_scrolling) &&
        (!widget.pauseWhenAppInactive || _appIsActive);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _appIsActive =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _phase = _effectivePhaseOffset;
    _sampledAnimation = _SampledAnimation(
      value: _phase,
      status: AnimationStatus.dismissed,
      onListenerStateChanged: _sync,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposing) return;
      _scheduleStartup();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    _attachAncestorScrollable();
    _sync();
  }

  @override
  void didUpdateWidget(covariant NeonTimelineMotionScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.framesPerSecond != widget.framesPerSecond ||
        oldWidget.duration != widget.duration) {
      _restartTimerIfRunning();
    }

    if (oldWidget.pauseWhenScrolling != widget.pauseWhenScrolling) {
      _resumeTimer?.cancel();
      _resumeTimer = null;
      _scrolling =
          widget.pauseWhenScrolling &&
          (_ancestorScrollingNotifier?.value ?? false);
    }

    if (oldWidget.phaseOffset != widget.phaseOffset && _tickTimer == null) {
      _phase = _effectivePhaseOffset;
      _sampledAnimation.update(
        _phase,
        AnimationStatus.dismissed,
        isAnimating: false,
      );
    }

    if (oldWidget.startupDelay != widget.startupDelay && !_startupReady) {
      _scheduleStartup();
    }

    _sync();
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

  void _scheduleStartup() {
    _startupTimer?.cancel();
    final delay = _effectiveStartupDelay;
    if (delay == Duration.zero) {
      _startupReady = true;
      _sync();
      return;
    }
    _startupTimer = Timer(delay, () {
      _startupTimer = null;
      if (!mounted || _disposing) return;
      _startupReady = true;
      _sync();
    });
  }

  void _scheduleTick() {
    if (!_canRun || _tickTimer != null) return;
    _tickTimer = Timer(_frameInterval, _handleTick);
  }

  void _handleTick() {
    _tickTimer = null;
    if (!_canRun) {
      _sync();
      return;
    }

    final durationMicros = _effectiveDuration.inMicroseconds;
    final step = durationMicros <= 0
        ? 0.0
        : _frameInterval.inMicroseconds / durationMicros;
    _phase = (_phase + step) % 1.0;
    _sampledAnimation.update(
      _phase,
      AnimationStatus.forward,
      isAnimating: true,
    );
    _scheduleTick();
  }

  void _restartTimerIfRunning() {
    if (_tickTimer == null) return;
    _tickTimer?.cancel();
    _tickTimer = null;
    _scheduleTick();
  }

  void _sync() {
    if (!mounted) return;
    if (_canRun) {
      _sampledAnimation.update(
        _phase,
        AnimationStatus.forward,
        isAnimating: true,
        notifyValueListeners: false,
      );
      _scheduleTick();
    } else {
      _tickTimer?.cancel();
      _tickTimer = null;
      _sampledAnimation.update(
        _phase,
        AnimationStatus.dismissed,
        isAnimating: false,
        notifyValueListeners: false,
      );
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
    _disposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _resumeTimer?.cancel();
    _startupTimer?.cancel();
    _ancestorScrollingNotifier?.removeListener(_handleAncestorScrollChanged);
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

/// Low-overhead sampled clock used by standalone indicators and connectors.
///
/// Most applications should use [NeonTimelineMotionScope]. This clock exists so
/// a standalone animated component does not fall back to a display-rate
/// [AnimationController]. It also sleeps when it has no listeners or when the
/// application is not resumed.
class NeonTimelineMotionClock with WidgetsBindingObserver {
  /// Creates a sampled local clock.
  NeonTimelineMotionClock({
    required Duration duration,
    int framesPerSecond = 24,
    double initialValue = 0,
  }) : _duration = neonPositiveDuration(
         duration,
         fallback: const Duration(milliseconds: 4200),
         debugLabel: 'NeonTimelineMotionClock.duration',
       ),
       _framesPerSecond = framesPerSecond.clamp(1, 120).toInt(),
       _phase = initialValue.clamp(0.0, 1.0).toDouble() {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _appIsActive =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _animation = _SampledAnimation(
      value: _phase,
      status: AnimationStatus.dismissed,
      onListenerStateChanged: _sync,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  late final _SampledAnimation _animation;
  Timer? _timer;
  Duration _duration;
  int _framesPerSecond;
  double _phase;
  bool _requested = false;
  bool _appIsActive = true;
  bool _disposed = false;

  /// Animation consumed by a painter or animated widget.
  Animation<double> get animation => _animation;

  Duration get _interval => Duration(
    microseconds: (Duration.microsecondsPerSecond / _framesPerSecond)
        .round()
        .clamp(1000, 1000000)
        .toInt(),
  );

  bool get _canRun =>
      !_disposed && _requested && _appIsActive && _animation.hasConsumers;

  /// Updates clock parameters without replacing the [animation] object.
  void configure({Duration? duration, int? framesPerSecond}) {
    if (_disposed) return;
    var changed = false;
    if (duration != null) {
      final normalized = neonPositiveDuration(
        duration,
        fallback: const Duration(milliseconds: 4200),
        debugLabel: 'NeonTimelineMotionClock.duration',
      );
      if (normalized != _duration) {
        _duration = normalized;
        changed = true;
      }
    }
    if (framesPerSecond != null) {
      final normalized = framesPerSecond.clamp(1, 120).toInt();
      if (normalized != _framesPerSecond) {
        _framesPerSecond = normalized;
        changed = true;
      }
    }
    if (!changed) return;
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _sync();
  }

  /// Requests continuous sampled motion.
  void start() {
    if (_disposed || _requested) return;
    _requested = true;
    _sync();
  }

  /// Stops motion and optionally selects a stable visual phase.
  void stop({double value = 0.28}) {
    if (_disposed) return;
    _requested = false;
    _timer?.cancel();
    _timer = null;
    _phase = value.clamp(0.0, 1.0).toDouble();
    _animation.update(_phase, AnimationStatus.dismissed, isAnimating: false);
  }

  void _sync() {
    if (!_canRun) {
      _timer?.cancel();
      _timer = null;
      _animation.update(
        _phase,
        AnimationStatus.dismissed,
        isAnimating: false,
        notifyValueListeners: false,
      );
      return;
    }
    _animation.update(
      _phase,
      AnimationStatus.forward,
      isAnimating: true,
      notifyValueListeners: false,
    );
    _schedule();
  }

  void _schedule() {
    if (!_canRun || _timer != null) return;
    _timer = Timer(_interval, _tick);
  }

  void _tick() {
    _timer = null;
    if (!_canRun) {
      _sync();
      return;
    }
    final durationMicros = _duration.inMicroseconds;
    final step = durationMicros <= 0
        ? 0.0
        : _interval.inMicroseconds / durationMicros;
    _phase = (_phase + step) % 1.0;
    _animation.update(_phase, AnimationStatus.forward, isAnimating: true);
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsActive = state == AppLifecycleState.resumed;
    _sync();
  }

  /// Releases timers, listeners, and lifecycle observation.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    _animation.dispose();
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
    required this._value,
    required this._status,
    required this.onListenerStateChanged,
  });

  final VoidCallback onListenerStateChanged;
  double _value;
  AnimationStatus _status;
  bool _isAnimating = false;
  int _listenerCount = 0;
  final Set<AnimationStatusListener> _statusListeners =
      <AnimationStatusListener>{};

  bool get hasConsumers => _listenerCount > 0 || _statusListeners.isNotEmpty;

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

  void update(
    double value,
    AnimationStatus status, {
    required bool isAnimating,
    bool notifyValueListeners = true,
  }) {
    final valueChanged = value != _value;
    final statusChanged = status != _status;
    _value = value;
    _status = status;
    _isAnimating = isAnimating;

    if (statusChanged) {
      for (final listener in List<AnimationStatusListener>.of(
        _statusListeners,
      )) {
        listener(status);
      }
    }
    if (valueChanged && notifyValueListeners) notifyListeners();
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
  bool get isAnimating => _isAnimating;

  @override
  bool get isCompleted => status == AnimationStatus.completed;

  @override
  bool get isDismissed => status == AnimationStatus.dismissed;

  @override
  bool get isForwardOrCompleted =>
      status == AnimationStatus.forward || status == AnimationStatus.completed;

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

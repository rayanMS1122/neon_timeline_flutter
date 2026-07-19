import 'dart:async';

import 'package:flutter/widgets.dart';

/// Injectable wall-clock source for deterministic timeline rendering/tests.
@immutable
class UltimateTimelineClock {
  const UltimateTimelineClock({this.nowProvider = DateTime.now});

  final DateTime Function() nowProvider;

  DateTime now() => nowProvider();
}

/// One lifecycle-aware timer for an entire timeline, never one per entry.
class UltimateTimelineCurrentTimeController extends ChangeNotifier
    with WidgetsBindingObserver {
  UltimateTimelineCurrentTimeController({
    this.clock = const UltimateTimelineClock(),
    this.interval = const Duration(minutes: 1),
    bool visible = true,
    bool autoStart = true,
  }) : assert(interval > Duration.zero),
       _visible = visible,
       _now = clock.now() {
    WidgetsBinding.instance.addObserver(this);
    if (autoStart && visible) _schedule();
  }

  final UltimateTimelineClock clock;
  Duration interval;
  Timer? _timer;
  bool _visible;
  bool _foreground = true;
  bool _disposed = false;
  DateTime _now;

  DateTime get now => _now;
  bool get visible => _visible;
  bool get running => _timer != null;

  void setVisible(bool value) {
    if (_visible == value || _disposed) return;
    _visible = value;
    value ? _resume() : _pause();
  }

  void setInterval(Duration value) {
    if (value <= Duration.zero) {
      throw ArgumentError.value(value, 'value', 'Must be positive.');
    }
    if (interval == value || _disposed) return;
    interval = value;
    if (running) {
      _timer?.cancel();
      _timer = null;
      _schedule();
    }
  }

  void refresh() {
    if (_disposed) return;
    _now = clock.now();
    notifyListeners();
  }

  void _schedule() {
    if (_disposed || !_visible || !_foreground || _timer != null) return;
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _resume() {
    if (_disposed || !_visible || !_foreground) return;
    refresh();
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _foreground ? _resume() : _pause();
  }

  @override
  void dispose() {
    _disposed = true;
    _pause();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

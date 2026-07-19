import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/time_scale.dart';
import 'models.dart';

/// Imperative controller for scrolling, zooming, selection, and current time.
class NeonPlannerTimelineController extends ChangeNotifier {
  /// Creates a timeline controller.
  NeonPlannerTimelineController({DateTime? currentTime})
    : _currentTime = currentTime ?? DateTime.now();

  ScrollController? _scrollController;
  NeonPlannerTimeScale? _timeScale;
  NeonPlannerZoomLevel _zoomLevel = NeonPlannerZoomLevel.balanced;
  DateTime _currentTime;
  Object? _selectedEntryId;

  /// Current semantic zoom level.
  NeonPlannerZoomLevel get zoomLevel => _zoomLevel;

  /// Current time used by the marker.
  DateTime get currentTime => _currentTime;

  /// Selected entry ID.
  Object? get selectedEntryId => _selectedEntryId;

  /// Whether the controller is attached to a timeline.
  bool get isAttached => _scrollController != null && _timeScale != null;

  /// Changes the semantic zoom level.
  void setZoomLevel(NeonPlannerZoomLevel value) {
    if (_zoomLevel == value) {
      return;
    }
    _zoomLevel = value;
    notifyListeners();
  }

  /// Updates the current-time marker without creating an internal timer.
  void setCurrentTime(DateTime value) {
    if (_currentTime == value) {
      return;
    }
    _currentTime = value;
    notifyListeners();
  }

  /// Selects an entry by stable ID.
  void selectEntry(Object? id) {
    if (_selectedEntryId == id) {
      return;
    }
    _selectedEntryId = id;
    notifyListeners();
  }

  /// Scrolls the attached timeline to [time].
  Future<void> scrollToTime(
    DateTime time, {
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
    double alignment = 0.35,
  }) async {
    final controller = _scrollController;
    final scale = _timeScale;
    if (controller == null || scale == null || !controller.hasClients) {
      return;
    }
    final viewport = controller.position.viewportDimension;
    final rawTarget = scale.timeToPixels(time) - viewport * alignment;
    final target = rawTarget
        .clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        )
        .toDouble();
    await controller.animateTo(target, duration: duration, curve: curve);
  }

  /// Jumps the attached timeline to [time].
  void jumpToTime(DateTime time, {double alignment = 0.35}) {
    final controller = _scrollController;
    final scale = _timeScale;
    if (controller == null || scale == null || !controller.hasClients) {
      return;
    }
    final viewport = controller.position.viewportDimension;
    final rawTarget = scale.timeToPixels(time) - viewport * alignment;
    controller.jumpTo(
      rawTarget
          .clamp(
            controller.position.minScrollExtent,
            controller.position.maxScrollExtent,
          )
          .toDouble(),
    );
  }

  /// Internal attachment used by the timeline widget.
  @internal
  void attach(ScrollController controller, NeonPlannerTimeScale scale) {
    assert(
      _scrollController == null || identical(_scrollController, controller),
      'A NeonPlannerTimelineController cannot control two timelines at once.',
    );
    _scrollController = controller;
    _timeScale = scale;
  }

  /// Internal detachment used by the timeline widget.
  @internal
  void detach(ScrollController controller) {
    if (identical(_scrollController, controller)) {
      _scrollController = null;
      _timeScale = null;
    }
  }
}

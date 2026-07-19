import 'package:flutter/widgets.dart';

import '../../v6/core/timeline_visual_coordinate_map.dart';
import '../../v8/core/structured_timeline_controller.dart';
import '../models/ultimate_timeline_config.dart';

/// Semantic-zoom controller with focus-preserving viewport adjustment.
class UltimateStructuredTimelineController<T>
    extends StructuredTimelineController<T> {
  UltimateStructuredTimelineController({
    UltimateTimelineZoomLevel zoomLevel = UltimateTimelineZoomLevel.normal,
    super.selectedId,
    super.focusedId,
    super.visibleRange,
  }) : _zoomLevel = zoomLevel,
       super(zoom: _zoomFor(zoomLevel));

  UltimateTimelineZoomLevel _zoomLevel;
  bool _disposed = false;

  UltimateTimelineZoomLevel get zoomLevel => _zoomLevel;

  void setZoomLevel(UltimateTimelineZoomLevel value) {
    if (_zoomLevel == value) return;
    _zoomLevel = value;
    super.setZoom(_zoomFor(value));
  }

  @override
  void zoomIn([double factor = 1.15]) {
    final index = (_zoomLevel.index + 1)
        .clamp(0, UltimateTimelineZoomLevel.values.length - 1)
        .toInt();
    setZoomLevel(UltimateTimelineZoomLevel.values[index]);
  }

  @override
  void zoomOut([double factor = 1.15]) {
    final index = (_zoomLevel.index - 1)
        .clamp(0, UltimateTimelineZoomLevel.values.length - 1)
        .toInt();
    setZoomLevel(UltimateTimelineZoomLevel.values[index]);
  }

  @override
  void resetZoom() => setZoomLevel(UltimateTimelineZoomLevel.normal);

  /// Changes semantic zoom and restores the time under [viewportOffset] after
  /// the host has rebuilt its coordinate map for the new level.
  void zoomAroundViewportPoint({
    required UltimateTimelineZoomLevel level,
    required double viewportOffset,
    required TimelineVisualCoordinateMap<T> before,
    required TimelineVisualCoordinateMap<T> Function() after,
    required ScrollController scrollController,
    double headerExtent = 0,
  }) {
    final anchorTime = before.timeForViewportOffset(
      viewportOffset,
      scrollOffset: scrollController.hasClients ? scrollController.offset : 0,
      headerExtent: headerExtent,
    );
    setZoomLevel(level);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !scrollController.hasClients) return;
      final nextMap = after();
      final contentOffset = nextMap.offsetForTime(anchorTime);
      final target = (contentOffset - viewportOffset + headerExtent).clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(target.toDouble());
    });
  }

  static double _zoomFor(UltimateTimelineZoomLevel value) {
    final metrics = UltimateTimelineZoomMetrics.forLevel(value);
    return metrics.pixelsPerMinute /
        UltimateTimelineZoomMetrics.normal.pixelsPerMinute;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

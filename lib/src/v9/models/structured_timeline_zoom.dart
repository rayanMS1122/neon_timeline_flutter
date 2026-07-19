import '../../v8/core/structured_timeline_controller.dart';

enum StructuredTimelineZoomLevel {
  overview,
  compact,
  normal,
  comfortable,
  detailed,
}

extension StructuredTimelineZoomLevelValue on StructuredTimelineZoomLevel {
  double get scale => switch (this) {
    StructuredTimelineZoomLevel.overview => 0.55,
    StructuredTimelineZoomLevel.compact => 0.78,
    StructuredTimelineZoomLevel.normal => 1,
    StructuredTimelineZoomLevel.comfortable => 1.28,
    StructuredTimelineZoomLevel.detailed => 1.7,
  };
}

extension StructuredTimelineZoomControllerX<T>
    on StructuredTimelineController<T> {
  void setZoomLevel(StructuredTimelineZoomLevel level) => setZoom(level.scale);

  StructuredTimelineZoomLevel get zoomLevel {
    final value = zoom;
    if (value < 0.67) return StructuredTimelineZoomLevel.overview;
    if (value < 0.9) return StructuredTimelineZoomLevel.compact;
    if (value < 1.14) return StructuredTimelineZoomLevel.normal;
    if (value < 1.48) return StructuredTimelineZoomLevel.comfortable;
    return StructuredTimelineZoomLevel.detailed;
  }
}

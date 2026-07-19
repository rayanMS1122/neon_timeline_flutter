import 'package:flutter/foundation.dart';

import '../domain/ultra_time_range.dart';
import '../interaction/snap/ultra_magnetic_snap_engine.dart';
import 'ultra_timeline_config.dart';

/// Editor state isolated from the timeline renderer.
@immutable
class UltraTimeRangeEditorState {
  const UltraTimeRangeEditorState({
    required this.visible,
    this.range,
    this.bounds,
    this.blockedRanges = const <UltraTimeRange>[],
  });

  const UltraTimeRangeEditorState.hidden()
      : this(visible: false);

  final bool visible;
  final UltraTimeRange? range;
  final UltraTimeRange? bounds;
  final List<UltraTimeRange> blockedRanges;

  UltraTimeRangeEditorState copyWith({
    bool? visible,
    UltraTimeRange? range,
    UltraTimeRange? bounds,
    List<UltraTimeRange>? blockedRanges,
  }) {
    return UltraTimeRangeEditorState(
      visible: visible ?? this.visible,
      range: range ?? this.range,
      bounds: bounds ?? this.bounds,
      blockedRanges: blockedRanges ?? this.blockedRanges,
    );
  }
}

/// Public v15 controller with fine-grained listenables.
///
/// The continuous slider positions are separate from semantic values. This
/// lets the thumb move every frame while the expensive timeline tree only
/// rebuilds when a semantic threshold is crossed.
class UltraTimelineController {
  UltraTimelineController({
    UltraTimelineZoomLevel initialZoom = UltraTimelineZoomLevel.balanced,
    UltraTimelineSnapStrength initialSnapStrength =
        UltraTimelineSnapStrength.balanced,
  })  : zoomPosition = ValueNotifier<double>(initialZoom.position),
        zoomLevel = ValueNotifier<UltraTimelineZoomLevel>(initialZoom),
        snapPosition = ValueNotifier<double>(
          initialSnapStrength.index /
              (UltraTimelineSnapStrength.values.length - 1),
        ),
        snapStrength =
            ValueNotifier<UltraTimelineSnapStrength>(initialSnapStrength),
        rangeEditor = ValueNotifier<UltraTimeRangeEditorState>(
          const UltraTimeRangeEditorState.hidden(),
        );

  final ValueNotifier<double> zoomPosition;
  final ValueNotifier<UltraTimelineZoomLevel> zoomLevel;
  final ValueNotifier<double> snapPosition;
  final ValueNotifier<UltraTimelineSnapStrength> snapStrength;
  final ValueNotifier<UltraTimeRangeEditorState> rangeEditor;

  void setZoomPosition(double value) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    if (zoomPosition.value != normalized) zoomPosition.value = normalized;
    final resolved = _zoomForPosition(normalized);
    if (zoomLevel.value != resolved) zoomLevel.value = resolved;
  }

  void setZoomLevel(UltraTimelineZoomLevel value) {
    if (zoomLevel.value != value) zoomLevel.value = value;
    if (zoomPosition.value != value.position) {
      zoomPosition.value = value.position;
    }
  }

  void zoomIn() {
    final next = (zoomLevel.value.index + 1)
        .clamp(0, UltraTimelineZoomLevel.values.length - 1)
        .toInt();
    setZoomLevel(UltraTimelineZoomLevel.values[next]);
  }

  void zoomOut() {
    final next = (zoomLevel.value.index - 1)
        .clamp(0, UltraTimelineZoomLevel.values.length - 1)
        .toInt();
    setZoomLevel(UltraTimelineZoomLevel.values[next]);
  }

  void resetZoom() => setZoomLevel(UltraTimelineZoomLevel.balanced);

  void setSnapPosition(double value) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    if (snapPosition.value != normalized) snapPosition.value = normalized;
    final resolved = _snapForPosition(normalized);
    if (snapStrength.value != resolved) snapStrength.value = resolved;
  }

  void setSnapStrength(UltraTimelineSnapStrength value) {
    if (snapStrength.value != value) snapStrength.value = value;
    final position = value.index /
        (UltraTimelineSnapStrength.values.length - 1);
    if (snapPosition.value != position) snapPosition.value = position;
  }

  void showTimeRangeEditor({
    required UltraTimeRange range,
    required UltraTimeRange bounds,
    List<UltraTimeRange> blockedRanges = const <UltraTimeRange>[],
  }) {
    assert(range.debugAssertIsValid());
    assert(bounds.debugAssertIsValid());
    rangeEditor.value = UltraTimeRangeEditorState(
      visible: true,
      range: range,
      bounds: bounds,
      blockedRanges: List<UltraTimeRange>.unmodifiable(blockedRanges),
    );
  }

  void updateTimeRange(UltraTimeRange range) {
    final current = rangeEditor.value;
    if (!current.visible) return;
    rangeEditor.value = current.copyWith(range: range);
  }

  void hideTimeRangeEditor() {
    if (!rangeEditor.value.visible) return;
    rangeEditor.value = const UltraTimeRangeEditorState.hidden();
  }

  void dispose() {
    zoomPosition.dispose();
    zoomLevel.dispose();
    snapPosition.dispose();
    snapStrength.dispose();
    rangeEditor.dispose();
  }

  static UltraTimelineZoomLevel _zoomForPosition(double value) {
    final index = (value * (UltraTimelineZoomLevel.values.length - 1)).round();
    return UltraTimelineZoomLevel.values[index];
  }

  static UltraTimelineSnapStrength _snapForPosition(double value) {
    final index =
        (value * (UltraTimelineSnapStrength.values.length - 1)).round();
    return UltraTimelineSnapStrength.values[index];
  }
}

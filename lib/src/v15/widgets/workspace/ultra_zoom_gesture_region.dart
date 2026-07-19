import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/ultra_timeline_controller.dart';

/// Adds Ctrl/Cmd+wheel and trackpad pinch zoom without owning timeline layout.
class UltraZoomGestureRegion extends StatefulWidget {
  const UltraZoomGestureRegion({
    required this.controller,
    required this.child,
    this.enableCtrlWheelZoom = true,
    this.enableTrackpadZoom = true,
    super.key,
  });

  final UltraTimelineController controller;
  final Widget child;
  final bool enableCtrlWheelZoom;
  final bool enableTrackpadZoom;

  @override
  State<UltraZoomGestureRegion> createState() =>
      _UltraZoomGestureRegionState();
}

class _UltraZoomGestureRegionState extends State<UltraZoomGestureRegion> {
  double _panZoomBase = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (!widget.enableCtrlWheelZoom || event is! PointerScrollEvent) return;
        final keyboard = HardwareKeyboard.instance;
        if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;
        widget.controller.setZoomPosition(
          widget.controller.zoomPosition.value - event.scrollDelta.dy * 0.0014,
        );
      },
      onPointerPanZoomStart: widget.enableTrackpadZoom
          ? (_) => _panZoomBase = widget.controller.zoomPosition.value
          : null,
      onPointerPanZoomUpdate: widget.enableTrackpadZoom
          ? (event) {
              final delta = math.log(event.scale) * 0.38;
              widget.controller.setZoomPosition(_panZoomBase + delta);
            }
          : null,
      child: widget.child,
    );
  }
}

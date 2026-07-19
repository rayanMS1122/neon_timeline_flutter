import 'dart:ui' show FontFeature, FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../api/ultra_timeline_config.dart';
import '../../api/ultra_timeline_controller.dart';
import '../../interaction/snap/ultra_magnetic_snap_engine.dart';
import '../../theme/ultra_timeline_theme.dart';

/// Lightweight profile aid for local demos and integration testing.
class UltraTimelineDiagnosticsOverlay extends StatefulWidget {
  const UltraTimelineDiagnosticsOverlay({
    required this.controller,
    required this.entryCount,
    required this.child,
    super.key,
  });

  final UltraTimelineController controller;
  final int entryCount;
  final Widget child;

  @override
  State<UltraTimelineDiagnosticsOverlay> createState() =>
      _UltraTimelineDiagnosticsOverlayState();
}

class _UltraTimelineDiagnosticsOverlayState
    extends State<UltraTimelineDiagnosticsOverlay> {
  final List<FrameTiming> _timings = <FrameTiming>[];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    super.dispose();
  }

  void _onTimings(List<FrameTiming> values) {
    if (!mounted || values.isEmpty) return;
    _timings.addAll(values);
    if (_timings.length > 90) {
      _timings.removeRange(0, _timings.length - 90);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          top: 10,
          end: 10,
          child: IgnorePointer(
            child: _DiagnosticsPanel(
              controller: widget.controller,
              entryCount: widget.entryCount,
              averageBuildMs: _average(
                _timings.map((value) => value.buildDuration.inMicroseconds),
              ),
              averageRasterMs: _average(
                _timings.map((value) => value.rasterDuration.inMicroseconds),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static double _average(Iterable<int> values) {
    var count = 0;
    var sum = 0;
    for (final value in values) {
      count += 1;
      sum += value;
    }
    if (count == 0) return 0;
    return sum / count / 1000;
  }
}

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({
    required this.controller,
    required this.entryCount,
    required this.averageBuildMs,
    required this.averageRasterMs,
  });

  final UltraTimelineController controller;
  final int entryCount;
  final double averageBuildMs;
  final double averageRasterMs;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.outline),
      ),
      child: DefaultTextStyle(
        style: (Theme.of(context).textTheme.labelSmall ??
                const TextStyle())
            .copyWith(
              color: theme.mutedText,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'V15 DIAGNOSTICS',
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text('Entries: $entryCount'),
            Text('Build avg: ${averageBuildMs.toStringAsFixed(2)} ms'),
            Text('Raster avg: ${averageRasterMs.toStringAsFixed(2)} ms'),
            ValueListenableBuilder<UltraTimelineZoomLevel>(
              valueListenable: controller.zoomLevel,
              builder: (context, value, _) => Text('Zoom: ${value.label}'),
            ),
            ValueListenableBuilder<UltraTimelineSnapStrength>(
              valueListenable: controller.snapStrength,
              builder: (context, value, _) => Text('Snap: ${value.name}'),
            ),
          ],
        ),
      ),
    );
  }
}

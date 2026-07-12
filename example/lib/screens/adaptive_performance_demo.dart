import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class AdaptivePerformanceDemo extends StatefulWidget {
  const AdaptivePerformanceDemo({super.key});

  @override
  State<AdaptivePerformanceDemo> createState() => _AdaptivePerformanceDemoState();
}

class _AdaptivePerformanceDemoState extends State<AdaptivePerformanceDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(20);
  AdaptivePerformanceMode _mode = AdaptivePerformanceMode.balanced;
  int _motionFps = 30;
  bool _showFps = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Performance'),
        backgroundColor: Colors.transparent,
        actions: [
          SegmentedButton<AdaptivePerformanceMode>(
            segments: AdaptivePerformanceMode.values
                .map((mode) => ButtonSegment(
                      value: mode,
                      label: Text(mode.name.toUpperCase()),
                      icon: Icon(_modeIcon(mode)),
                    ))
                .toList(),
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
            multiSelectionEnabled: false,
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _motionFps,
            items: [15, 20, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e FPS'))).toList(),
            onChanged: (v) => setState(() => _motionFps = v!),
            underline: const SizedBox(),
          ),
          Switch(
            value: _showFps,
            onChanged: (v) => setState(() => _showFps = v),
            activeColor: Colors.green,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          NeonTimeline.builder(
            itemCount: _items.length,
            animate: true,
            motionEnabled: true,
            motionFramesPerSecond: _motionFps,
            contentBuilder: (context, details) => _items[details.index].content,
            indicatorBuilder: (context, details) {
              final item = _items[details.index];
              return NeonTimelineIndicator(
                status: item.status,
                animate: true,
                style: NeonTimelineIndicatorStyle(
                  effect: _indicatorEffectForMode(_mode),
                  intensity: _intensityForMode(_mode),
                  detail: _detailForMode(_mode),
                  particleCount: _particlesForMode(_mode),
                  quality: _qualityForMode(_mode),
                ),
              );
            },
            statusBuilder: (index) => _items[index].status,
            connectorStyleBuilder: (context, details) {
              final item = _items[details.index];
              final color = NeonTimelineTheme.of(context).colorForStatus(item.status);
              return NeonTimelineConnectorStyle(
                effect: _connectorEffectForMode(_mode),
                color: color,
                endColor: color.withAlpha(50),
                animated: true,
                intensity: _intensityForMode(_mode),
                detail: _detailForMode(_mode),
                quality: _qualityForMode(_mode),
              );
            },
          ),
          if (_showFps) _FpsOverlay(motionFps: _motionFps, mode: _mode),
        ],
      ),
    );
  }

  IconData _modeIcon(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => Icons.battery_saver,
      AdaptivePerformanceMode.balanced => Icons.balance,
      AdaptivePerformanceMode.highQuality => Icons.high_quality,
    };
  }

  NeonIndicatorEffect _indicatorEffectForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => NeonIndicatorEffect.classic,
      AdaptivePerformanceMode.balanced => NeonIndicatorEffect.glass,
      AdaptivePerformanceMode.highQuality => NeonIndicatorEffect.neuralCore,
    };
  }

  NeonConnectorEffect _connectorEffectForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => NeonConnectorEffect.classic,
      AdaptivePerformanceMode.balanced => NeonConnectorEffect.energy,
      AdaptivePerformanceMode.highQuality => NeonConnectorEffect.photonLattice,
    };
  }

  double _intensityForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => 0.5,
      AdaptivePerformanceMode.balanced => 1.0,
      AdaptivePerformanceMode.highQuality => 1.3,
    };
  }

  double _detailForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => 0.3,
      AdaptivePerformanceMode.balanced => 0.8,
      AdaptivePerformanceMode.highQuality => 1.0,
    };
  }

  int _particlesForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => 0,
      AdaptivePerformanceMode.balanced => 4,
      AdaptivePerformanceMode.highQuality => 12,
    };
  }

  NeonTimelineRenderQuality _qualityForMode(AdaptivePerformanceMode mode) {
    return switch (mode) {
      AdaptivePerformanceMode.batterySaver => NeonTimelineRenderQuality.balanced,
      AdaptivePerformanceMode.balanced => NeonTimelineRenderQuality.high,
      AdaptivePerformanceMode.highQuality => NeonTimelineRenderQuality.ultra,
    };
  }
}

enum AdaptivePerformanceMode { batterySaver, balanced, highQuality }

class _FpsOverlay extends StatefulWidget {
  const _FpsOverlay({required this.motionFps, required this.mode});

  final int motionFps;
  final AdaptivePerformanceMode mode;

  @override
  State<_FpsOverlay> createState() => _FpsOverlayState();
}

class _FpsOverlayState extends State<_FpsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _frameCount = 0;
  double _fps = 0;
  final List<int> _frameTimes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        _frameCount++;
        final now = DateTime.now().millisecondsSinceEpoch;
        _frameTimes.add(now);
        _frameTimes.removeWhere((t) => now - t > 1000);
        _fps = _frameTimes.length.toDouble();
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      right: 16,
      child: NeonTimelineCard(
        variant: NeonTimelineCardVariant.liquidCrystal,
        intensity: 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Mode: ${widget.mode.name.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Target FPS: ${widget.motionFps}',
              style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(180)),
            ),
            const SizedBox(height: 4),
            Text(
              'Platform: ${Theme.of(context).platform.name.toUpperCase()}',
              style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
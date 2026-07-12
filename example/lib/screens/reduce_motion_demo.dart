import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class ReduceMotionDemo extends StatefulWidget {
  const ReduceMotionDemo({super.key});

  @override
  State<ReduceMotionDemo> createState() => _ReduceMotionDemoState();
}

class _ReduceMotionDemoState extends State<ReduceMotionDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(8);
  bool _reduceMotion = false;
  bool _pauseOnScroll = true;
  bool _pauseOnInactive = true;
  int _motionFps = 30;
  double _phaseOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reduce Motion & Performance'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeonTimelineCard(
              variant: NeonTimelineCardVariant.glass,
              accentColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Reduce Motion (simulated)'),
                    subtitle: const Text('Disables all continuous animations'),
                    value: _reduceMotion,
                    onChanged: (v) => setState(() => _reduceMotion = v),
                    activeColor: Colors.green,
                  ),
                  SwitchListTile(
                    title: const Text('Pause on Scroll'),
                    subtitle: const Text('Stops motion clock while scrolling'),
                    value: _pauseOnScroll,
                    onChanged: (v) => setState(() => _pauseOnScroll = v),
                    activeColor: Colors.orange,
                  ),
                  SwitchListTile(
                    title: const Text('Pause on Inactive'),
                    subtitle: const Text('Stops motion when app goes to background'),
                    value: _pauseOnInactive,
                    onChanged: (v) => setState(() => _pauseOnInactive = v),
                    activeColor: Colors.blue,
                  ),
                  ListTile(
                    title: Text('Motion FPS: $_motionFps'),
                    subtitle: Slider(
                      value: _motionFps.toDouble(),
                      min: 10,
                      max: 60,
                      divisions: 10,
                      onChanged: (v) => setState(() => _motionFps = v.round()),
                    ),
                    dense: true,
                  ),
                  ListTile(
                    title: Text('Phase Offset: ${_phaseOffset.toStringAsFixed(2)}'),
                    subtitle: Slider(
                      value: _phaseOffset,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => setState(() => _phaseOffset = v),
                    ),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: NeonTimelineMotionScope(
              enabled: !_reduceMotion,
              framesPerSecond: _motionFps,
              phaseOffset: _phaseOffset,
              pauseWhenScrolling: _pauseOnScroll,
              pauseWhenAppInactive: _pauseOnInactive,
              child: NeonTimeline.builder(
                itemCount: _items.length,
                animate: !_reduceMotion,
                motionEnabled: !_reduceMotion,
                motionFramesPerSecond: _motionFps,
                motionPhaseOffset: _phaseOffset,
                pauseMotionWhileScrolling: _pauseOnScroll,
                contentBuilder: (context, details) => _items[details.index].content,
                indicatorBuilder: (context, details) {
                  final item = _items[details.index];
                  return NeonTimelineIndicator(
                    status: item.status,
                    animate: !_reduceMotion,
                    style: NeonTimelineIndicatorStyle(
                      effect: NeonIndicatorEffect.stellar,
                      intensity: 1.0,
                      detail: 1.0,
                      particleCount: 8,
                      rayLength: 1.2,
                      rotationSpeed: 1.2,
                      quality: NeonTimelineRenderQuality.high,
                    ),
                  );
                },
                statusBuilder: (index) => _items[index].status,
                connectorStyleBuilder: (context, details) {
                  final item = _items[details.index];
                  final color = NeonTimelineTheme.of(context).colorForStatus(item.status);
                  return NeonTimelineConnectorStyle(
                    effect: NeonConnectorEffect.energy,
                    color: color,
                    endColor: color.withAlpha(50),
                    animated: !_reduceMotion,
                    intensity: 1.0,
                    detail: 0.8,
                    flowSpeed: 1.0,
                    quality: NeonTimelineRenderQuality.high,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
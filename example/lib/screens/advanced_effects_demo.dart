import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class AdvancedEffectsDemo extends StatefulWidget {
  const AdvancedEffectsDemo({super.key});

  @override
  State<AdvancedEffectsDemo> createState() => _AdvancedEffectsDemoState();
}

class _AdvancedEffectsDemoState extends State<AdvancedEffectsDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(8);
  NeonTimelineCardVariant _cardVariant = NeonTimelineCardVariant.liquidCrystal;
  NeonIndicatorEffect _indicatorEffect = NeonIndicatorEffect.neuralCore;
  NeonConnectorEffect _connectorEffect = NeonConnectorEffect.photonLattice;
  double _intensity = 1.0;
  double _detail = 1.0;
  bool _continuousAnimation = false;
  bool _parallax = true;
  bool _backdropBlur = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Neon Effects'),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<NeonTimelineCardVariant>(
            tooltip: 'Card Variant',
            initialValue: _cardVariant,
            onSelected: (v) => setState(() => _cardVariant = v),
            itemBuilder: (context) => NeonTimelineCardVariant.values
                .map((v) => PopupMenuItem(
                      value: v,
                      child: Text(v.name.toUpperCase()),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_cardVariant.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          PopupMenuButton<NeonIndicatorEffect>(
            tooltip: 'Indicator Effect',
            initialValue: _indicatorEffect,
            onSelected: (v) => setState(() => _indicatorEffect = v),
            itemBuilder: (context) => NeonIndicatorEffect.values
                .map((v) => PopupMenuItem(
                      value: v,
                      child: Text(v.name.toUpperCase()),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_indicatorEffect.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          PopupMenuButton<NeonConnectorEffect>(
            tooltip: 'Connector Effect',
            initialValue: _connectorEffect,
            onSelected: (v) => setState(() => _connectorEffect = v),
            itemBuilder: (context) => NeonConnectorEffect.values
                .map((v) => PopupMenuItem(
                      value: v,
                      child: Text(v.name.toUpperCase()),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_connectorEffect.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSlider('Intensity', _intensity, 0.0, 2.0, (v) => setState(() => _intensity = v)),
                _buildSlider('Detail', _detail, 0.0, 1.0, (v) => setState(() => _detail = v)),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Continuous Animation'),
                        value: _continuousAnimation,
                        onChanged: (v) => setState(() => _continuousAnimation = v),
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Parallax'),
                        value: _parallax,
                        onChanged: (v) => setState(() => _parallax = v),
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Backdrop Blur'),
                        value: _backdropBlur,
                        onChanged: (v) => setState(() => _backdropBlur = v),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: NeonTimeline.builder(
              itemCount: _items.length,
              contentBuilder: (context, details) {
                final item = _items[details.index];
                return NeonTimelineCard(
                  variant: _cardVariant,
                  accentColor: item.status == NeonTimelineStatus.pending
                      ? Theme.of(context).colorScheme.primary
                      : NeonTimelineTheme.of(context).colorForStatus(item.status),
                  secondaryAccentColor: NeonTimelineTheme.of(context).secondaryColor,
                  intensity: _intensity,
                  animate: true,
                  continuousAnimation: _continuousAnimation,
                  enableParallax: _parallax,
                  useBackdropFilter: _backdropBlur,
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(22),
                  child: item.content,
                );
              },
              indicatorBuilder: (context, details) {
                final item = _items[details.index];
                return NeonTimelineIndicator(
                  status: item.status,
                  animate: true,
                  style: NeonTimelineIndicatorStyle(
                    effect: _indicatorEffect,
                    intensity: _intensity,
                    detail: _detail,
                    size: 52,
                    particleCount: 12,
                    rayLength: 1.2,
                    rotationSpeed: 1.2,
                    corona: 1.0,
                    depth: 1.0,
                    chromaticAberration: 1.0,
                    refraction: 1.0,
                    quality: NeonTimelineRenderQuality.ultra,
                  ),
                );
              },
              statusBuilder: (index) => _items[index].status,
              connectorStyleBuilder: (context, details) {
                final item = _items[details.index];
                final color = item.status == NeonTimelineStatus.pending
                    ? Theme.of(context).colorScheme.primary
                    : NeonTimelineTheme.of(context).colorForStatus(item.status);
                return NeonTimelineConnectorStyle(
                  effect: _connectorEffect,
                  color: color,
                  endColor: color.withAlpha(50),
                  secondaryColor: NeonTimelineTheme.of(context).secondaryColor,
                  coreColor: Colors.white,
                  thickness: 2.5,
                  glowRadius: 12,
                  animated: true,
                  intensity: _intensity,
                  detail: _detail,
                  quality: NeonTimelineRenderQuality.ultra,
                  particleCount: 10,
                  turbulence: 0.8,
                  trailCount: 3,
                  flowSpeed: 1.1,
                );
              },
              layout: NeonTimelineLayout.center,
              motionEnabled: true,
              motionFramesPerSecond: 30,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min) * 20 ~/ 1,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 40, child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
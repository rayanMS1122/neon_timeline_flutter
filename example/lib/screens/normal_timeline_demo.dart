import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class NormalTimelineDemo extends StatefulWidget {
  const NormalTimelineDemo({super.key});

  @override
  State<NormalTimelineDemo> createState() => _NormalTimelineDemoState();
}

class _NormalTimelineDemoState extends State<NormalTimelineDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(12);
  Axis _axis = Axis.vertical;
  NeonTimelineLayout _layout = NeonTimelineLayout.adaptive;
  bool _animate = true;
  bool _motionEnabled = true;
  bool _reverse = false;
  bool _shrinkWrap = false;
  int _motionFps = 30;
  double _indicatorPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Normal Timeline'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Toggle Axis',
            icon: Icon(_axis == Axis.vertical ? Icons.horizontal_rule : Icons.vertical_align_center),
            onPressed: () => setState(() => _axis = _axis == Axis.vertical ? Axis.horizontal : Axis.vertical),
          ),
          PopupMenuButton<NeonTimelineLayout>(
            tooltip: 'Layout',
            initialValue: _layout,
            onSelected: (v) => setState(() => _layout = v),
            itemBuilder: (context) => NeonTimelineLayout.values
                .map((v) => PopupMenuItem(value: v, child: Text(v.name.toUpperCase())))
                .toList(),
            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.view_column)),
          ),
          IconButton(
            tooltip: 'Toggle Animation',
            icon: Icon(_animate ? Icons.animation : Icons.animation_outlined),
            onPressed: () => setState(() => _animate = !_animate),
          ),
          IconButton(
            tooltip: 'Toggle Motion',
            icon: Icon(_motionEnabled ? Icons.speed : Icons.speed_outlined),
            onPressed: () => setState(() => _motionEnabled = !_motionEnabled),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildToggle('Animate', _animate, (v) => setState(() => _animate = v)),
                _buildToggle('Motion', _motionEnabled, (v) => setState(() => _motionEnabled = v)),
                _buildToggle('Reverse', _reverse, (v) => setState(() => _reverse = v)),
                _buildToggle('Shrink Wrap', _shrinkWrap, (v) => setState(() => _shrinkWrap = v)),
                DropdownButton<int>(
                  value: _motionFps,
                  items: [15, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e FPS'))).toList(),
                  onChanged: (v) => setState(() => _motionFps = v!),
                  underline: const SizedBox(),
                ),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: _indicatorPosition,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: _indicatorPosition.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _indicatorPosition = v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: NeonTimeline.builder(
              itemCount: _items.length,
              axis: _axis,
              layout: _layout,
              animate: _animate,
              motionEnabled: _motionEnabled,
              motionFramesPerSecond: _motionFps,
              indicatorPosition: _indicatorPosition,
              shrinkWrap: _shrinkWrap,
              reverse: _reverse,
              contentBuilder: (context, details) {
                return _items[details.index].content;
              },
              indicatorBuilder: (context, details) {
                final item = _items[details.index];
                return NeonTimelineIndicator(
                  status: item.status,
                  animate: _animate,
                  style: NeonTimelineIndicatorStyle(
                    effect: NeonIndicatorEffect.stellar,
                    intensity: 1.0,
                    detail: 1.0,
                    particleCount: 6,
                    rayLength: 1.0,
                    rotationSpeed: 1.0,
                    quality: NeonTimelineRenderQuality.high,
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
                  effect: NeonConnectorEffect.energy,
                  color: color,
                  endColor: color.withAlpha(50),
                  secondaryColor: NeonTimelineTheme.of(context).secondaryColor,
                  coreColor: Colors.white,
                  thickness: 2.0,
                  glowRadius: 8,
                  animated: true,
                  intensity: 1.0,
                  detail: 0.8,
                  flowSpeed: 1.0,
                  quality: NeonTimelineRenderQuality.high,
                );
              },
              onItemTap: (context, details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped item ${details.index + 1}')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white.withAlpha(100)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
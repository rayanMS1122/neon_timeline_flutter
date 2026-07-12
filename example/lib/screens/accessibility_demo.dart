import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(8);
  bool _reduceMotion = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility & Keyboard'),
        backgroundColor: Colors.transparent,
        actions: [
          Switch(
            value: _reduceMotion,
            onChanged: (v) => setState(() => _reduceMotion = v),
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withAlpha(60),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withAlpha(60),
          ),
          const SizedBox(width: 8),
          const Text('Reduce Motion', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Switch(
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
            activeColor: Colors.orange,
            activeTrackColor: Colors.orange.withAlpha(60),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withAlpha(60),
          ),
          const SizedBox(width: 8),
          const Text('High Contrast', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeonTimelineCard(
              variant: NeonTimelineCardVariant.glass,
              accentColor: theme.secondaryColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keyboard Navigation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _KeyChip('Tab', 'Next focusable item'),
                      _KeyChip('Shift+Tab', 'Previous focusable item'),
                      _KeyChip('Enter/Space', 'Activate focused item'),
                      _KeyChip('Arrow Keys', 'Navigate timeline (when focused)'),
                      _KeyChip('Home/End', 'First/Last item'),
                      _KeyChip('/', 'Focus search (if implemented)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Accessibility Features', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeatureChip('Semantic Labels', 'Every item has screen-reader description'),
                      _FeatureChip('Focus Order', 'Logical Tab order through timeline'),
                      _FeatureChip('Status Announcements', 'Active/completed/error states announced'),
                      _FeatureChip('High Contrast', 'Optional high-contrast mode toggle'),
                      _FeatureChip('Reduce Motion', 'Disables continuous animations'),
                      _FeatureChip('Tooltip Support', 'Optional tooltips on indicators/actions'),
                      _FeatureChip('Touch Targets', 'Minimum 48x48dp hit areas'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: NeonTimeline.builder(
              itemCount: _items.length,
              animate: !_reduceMotion,
              motionEnabled: !_reduceMotion,
              motionFramesPerSecond: _reduceMotion ? 10 : 30,
              contentBuilder: (context, details) => _items[details.index].content,
              indicatorBuilder: (context, details) {
                final item = _items[details.index];
                return NeonTimelineIndicator(
                  status: item.status,
                  animate: !_reduceMotion,
                  style: NeonTimelineIndicatorStyle(
                    effect: NeonIndicatorEffect.stellar,
                    intensity: _highContrast ? 1.5 : 1.0,
                    detail: _highContrast ? 1.0 : 0.8,
                    quality: NeonTimelineRenderQuality.high,
                    size: _highContrast ? 56 : 48,
                  ),
                  semanticLabel: 'Timeline item ${details.index + 1}, ${item.status.name}',
                  tooltip: 'Status: ${item.status.name}',
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
                  intensity: _highContrast ? 1.5 : 1.0,
                  detail: 0.8,
                  quality: NeonTimelineRenderQuality.high,
                );
              },
              onItemTap: (context, details) => _showItemDialog(context, details.index, _items[details.index]),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(BuildContext context, int index, DemoTimelineItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeonTimelineTheme.of(context).surfaceColor,
        title: Text('Item ${index + 1}'),
        content: Text(item.semanticLabel ?? 'No semantic label'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip(this.keyLabel, this.description);
  final String keyLabel;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(keyLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(description, style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(150))),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.title, this.description);
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(150))),
        ],
      ),
    );
  }
}
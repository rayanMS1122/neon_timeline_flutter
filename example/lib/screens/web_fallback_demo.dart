import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class WebFallbackDemo extends StatelessWidget {
  const WebFallbackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Fallback Detection'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonTimelineCard(
              variant: NeonTimelineCardVariant.liquidCrystal,
              intensity: 1.2,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isWeb ? Icons.web : Icons.phone_android, size: 28, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWeb ? 'Flutter Web Detected' : 'Native Platform Detected',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isWeb
                                  ? 'Running in browser — blur effects and heavy animations automatically disabled for performance.'
                                  : 'Running on native — full visual effects available including backdrop blur and continuous animations.',
                              style: TextStyle(color: Colors.white.withAlpha(180)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoChip('Platform', isWeb ? 'Web (JS/WASM)' : 'Native (Dart AOT)'),
                      _InfoChip('Backdrop Blur', isWeb ? 'Disabled' : 'Enabled'),
                      _InfoChip('Continuous Animations', isWeb ? 'Paused' : 'Active'),
                      _InfoChip('Particle Effects', isWeb ? 'Disabled' : 'Active'),
                      _InfoChip('MaskFilter Blur', isWeb ? 'Software (slow)' : 'GPU accelerated'),
                      _InfoChip('FPS Limit', '30 FPS (configurable)'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Behavior on Web', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            NeonTimelineCard(
              variant: NeonTimelineCardVariant.glass,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('NeonBlurCache', 'All MaskFilter.blur entries return null on Web'),
                  _InfoRow('NeonPaintBlur', 'extension.applyBlur() becomes no-op on Web'),
                  _InfoRow('Continuous Animation', 'Cards only animate on hover/focus, never continuously'),
                  _InfoRow('Motion Scope', 'AnimationController stopped when no consumers'),
                  _InfoRow('Indicator/Connector', 'Advanced effects fall back to classic rendering'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Live Demo', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: NeonTimeline.builder(
                itemCount: 6,
                contentBuilder: (context, details) => _DemoItem(index: details.index, isWeb: isWeb),
                indicatorBuilder: (context, details) => NeonTimelineIndicator(
                  status: NeonTimelineStatus.pending,
                  animate: !isWeb,
                  style: NeonTimelineIndicatorStyle(
                    effect: isWeb ? NeonIndicatorEffect.classic : NeonIndicatorEffect.stellar,
                    intensity: 1.0,
                    detail: isWeb ? 0.3 : 1.0,
                    particleCount: isWeb ? 0 : 6,
                    quality: isWeb ? NeonTimelineRenderQuality.balanced : NeonTimelineRenderQuality.high,
                  ),
                ),
                statusBuilder: (index) => NeonTimelineStatus.pending,
                connectorStyleBuilder: (context, details) => NeonTimelineConnectorStyle(
                  effect: isWeb ? NeonConnectorEffect.classic : NeonConnectorEffect.energy,
                  color: theme.colorScheme.primary,
                  endColor: theme.colorScheme.primary.withAlpha(50),
                  animated: !isWeb,
                  quality: isWeb ? NeonTimelineRenderQuality.balanced : NeonTimelineRenderQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoItem extends StatelessWidget {
  const _DemoItem({required this.index, required this.isWeb});
  final int index;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return NeonTimelineCard(
      variant: isWeb ? NeonTimelineCardVariant.glass : NeonTimelineCardVariant.liquidCrystal,
      intensity: 1.0,
      animate: !isWeb,
      continuousAnimation: false,
      enableParallax: !isWeb,
      useBackdropFilter: !isWeb,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
                blurRadius: 8,
                spreadRadius: 2,
              )],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Timeline Entry ${index + 1}${isWeb ? " (Web Fallback)" : ""}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withAlpha(150))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
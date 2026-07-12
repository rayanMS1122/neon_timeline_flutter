import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class EffectsShowcase extends StatefulWidget {
  const EffectsShowcase({required this.performance, super.key});

  final NeonTimelinePerformanceConfig performance;

  @override
  State<EffectsShowcase> createState() => _EffectsShowcaseState();
}

class _EffectsShowcaseState extends State<EffectsShowcase> {
  _EffectSection _section = _EffectSection.indicators;
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final resolved = widget.performance.resolve(context, itemCount: 8);
    return NeonTimelineMotionScope(
      enabled: resolved.maxAnimatedEntries > 0,
      framesPerSecond: resolved.motionFramesPerSecond,
      pauseWhenScrolling: resolved.pauseMotionWhileScrolling,
      startupDelay: resolved.motionStartupDelay,
      child: Column(
        children: <Widget>[
          NeonTimelineHeader(
            title: 'Advanced effect gallery',
            subtitle:
                'Every renderer is available; only the selected preview moves.',
            trailing: NeonTimelineBadge(
              label: '${resolved.motionFramesPerSecond} FPS',
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_EffectSection>(
              segments: _EffectSection.values
                  .map(
                    (value) => ButtonSegment<_EffectSection>(
                      value: value,
                      label: Text(value.label),
                      icon: Icon(value.icon),
                    ),
                  )
                  .toList(growable: false),
              selected: <_EffectSection>{_section},
              onSelectionChanged: (selection) => setState(() {
                _section = selection.first;
                _activeIndex = 0;
              }),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildSection(resolved)),
        ],
      ),
    );
  }

  Widget _buildSection(NeonTimelineResolvedPerformance performance) {
    return switch (_section) {
      _EffectSection.indicators => _indicatorGallery(performance),
      _EffectSection.connectors => _connectorGallery(performance),
      _EffectSection.nodes => _nodeGallery(performance),
      _EffectSection.cards => _cardGallery(performance),
    };
  }

  Widget _indicatorGallery(NeonTimelineResolvedPerformance performance) {
    final effects = NeonIndicatorEffect.values;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 230,
        mainAxisExtent: 190,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: effects.length,
      itemBuilder: (context, index) {
        final effect = effects[index];
        final selected = index == _activeIndex;
        final base = NeonTimelineTheme.of(context).indicatorStyle;
        final style = base.copyWith(
          effect: effect,
          quality: performance.renderQuality,
          particleCount: performance.enableParticles
              ? base.particleCount.clamp(0, 6).toInt()
              : 0,
          sparkCount: performance.enableParticles
              ? base.sparkCount.clamp(0, 8).toInt()
              : 0,
        );
        return _GalleryTile(
          label: effect.name,
          selected: selected,
          onTap: () => setState(() => _activeIndex = index),
          child: Center(
            child: NeonTimelineIndicator(
              status: NeonTimelineStatus.active,
              style: style,
              animate: selected && performance.maxAnimatedEntries > 0,
              tooltip: '${effect.name} indicator',
            ),
          ),
        );
      },
    );
  }

  Widget _connectorGallery(NeonTimelineResolvedPerformance performance) {
    final effects = NeonConnectorEffect.values;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: effects.length,
      itemBuilder: (context, index) {
        final effect = effects[index];
        final selected = index == _activeIndex;
        final base = NeonTimelineTheme.of(context).connectorStyle;
        final style = base.copyWith(
          effect: effect,
          animated: selected && performance.maxAnimatedEntries > 0,
          quality: performance.renderQuality,
          particleCount: performance.enableParticles
              ? base.particleCount.clamp(0, 5).toInt()
              : 0,
          packetCount: performance.enableParticles
              ? base.packetCount.clamp(1, 4).toInt()
              : 1,
        );
        return _GalleryTile(
          label: effect.name,
          selected: selected,
          onTap: () => setState(() => _activeIndex = index),
          child: Center(
            child: SizedBox(
              width: 90,
              height: 120,
              child: NeonTimelineConnector(style: style),
            ),
          ),
        );
      },
    );
  }

  Widget _nodeGallery(NeonTimelineResolvedPerformance performance) {
    final variants = <({Axis axis, double position, String label})>[
      (axis: Axis.vertical, position: 0.25, label: 'Vertical 25%'),
      (axis: Axis.vertical, position: 0.50, label: 'Vertical center'),
      (axis: Axis.vertical, position: 0.75, label: 'Vertical 75%'),
      (axis: Axis.horizontal, position: 0.50, label: 'Horizontal center'),
    ];
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: variants.length,
      itemBuilder: (context, index) {
        final variant = variants[index];
        final selected = index == _activeIndex;
        final indicatorStyle = NeonTimelineTheme.of(context)
            .indicatorStyle
            .copyWith(
              effect: NeonIndicatorEffect.stellar,
              quality: performance.renderQuality,
              particleCount: performance.enableParticles ? 4 : 0,
            );
        final connectorStyle = NeonTimelineTheme.of(context)
            .connectorStyle
            .copyWith(
              effect: NeonConnectorEffect.energy,
              animated: selected && performance.maxAnimatedEntries > 0,
              quality: performance.renderQuality,
              particleCount: performance.enableParticles ? 3 : 0,
            );
        return _GalleryTile(
          label: variant.label,
          selected: selected,
          onTap: () => setState(() => _activeIndex = index),
          child: Center(
            child: SizedBox(
              width: variant.axis == Axis.vertical ? 96 : 210,
              height: variant.axis == Axis.vertical ? 126 : 86,
              child: NeonTimelineNode(
                axis: variant.axis,
                indicatorPosition: variant.position,
                beforeStyle: connectorStyle,
                afterStyle: connectorStyle.copyWith(phaseOffset: 0.42),
                indicator: NeonTimelineIndicator(
                  status: NeonTimelineStatus.active,
                  style: indicatorStyle,
                  animate: selected && performance.maxAnimatedEntries > 0,
                  semanticLabel: variant.label,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cardGallery(NeonTimelineResolvedPerformance performance) {
    final variants = NeonTimelineCardVariant.values;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 190,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: variants.length,
      itemBuilder: (context, index) {
        final variant = variants[index];
        final selected = index == _activeIndex;
        return GestureDetector(
          onTap: () => setState(() => _activeIndex = index),
          child: NeonTimelineCard(
            variant: variant,
            animate: selected,
            continuousAnimation:
                selected && performance.maxAnimatedEntries > 0,
            useBackdropFilter: performance.enableBackdropBlur,
            enableParallax: performance.enableParallax,
            semanticLabel: '${variant.name} card preview',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        variant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    if (selected)
                      const NeonTimelineBadge(label: 'Active'),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Same public card API, different rendering depth. Tap to move the animation budget.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = NeonTimelineTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label effect preview',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? theme.primaryColor.withOpacity(0.68)
                  : theme.primaryColor.withOpacity(0.14),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(child: child),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _EffectSection { indicators, connectors, nodes, cards }

extension on _EffectSection {
  String get label => switch (this) {
        _EffectSection.indicators => 'Indicators',
        _EffectSection.connectors => 'Connectors',
        _EffectSection.nodes => 'Nodes',
        _EffectSection.cards => 'Cards',
      };

  IconData get icon => switch (this) {
        _EffectSection.indicators => Icons.radio_button_checked_rounded,
        _EffectSection.connectors => Icons.linear_scale_rounded,
        _EffectSection.nodes => Icons.hub_rounded,
        _EffectSection.cards => Icons.view_agenda_rounded,
      };
}

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class ThemeShowcaseDemo extends StatefulWidget {
  const ThemeShowcaseDemo({super.key});

  @override
  State<ThemeShowcaseDemo> createState() => _ThemeShowcaseDemoState();
}

class _ThemeShowcaseDemoState extends State<ThemeShowcaseDemo> {
  final List<DemoTimelineItem> _items = demoRepo.generateTimelineItems(6);
  int _selectedIndex = 0;
  bool _animate = true;

  _ThemePreset get preset => _ThemePreset.all[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        backgroundColor: Colors.transparent,
        actions: [
          DropdownButton<int>(
            value: _selectedIndex,
            items: _ThemePreset.all.asMap().entries.map((e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value.name),
            )).toList(),
            onChanged: (v) => setState(() => _selectedIndex = v!),
            underline: const SizedBox(),
          ),
          Switch(value: _animate, onChanged: (v) => setState(() => _animate = v)),
          const SizedBox(width: 8),
          const Text('Animate', style: TextStyle(fontSize: 12)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeonTimelineCard(
              variant: NeonTimelineCardVariant.liquidCrystal,
              intensity: 1.2,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: preset.theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: preset.theme.primaryColor.withAlpha(100), blurRadius: 12, spreadRadius: 2)],
                    ),
                    child: Center(
                      child: Text(preset.name.substring(0, 1),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(preset.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(preset.description, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _Chip('Primary', preset.theme.primaryColor),
                            _Chip('Secondary', preset.theme.secondaryColor),
                            _Chip('Surface', preset.theme.surfaceColor),
                            _Chip('Completed', preset.theme.completedColor),
                            _Chip('Error', preset.theme.errorColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: NeonTimelineTheme(
              data: preset.theme,
              child: NeonTimeline.builder(
                itemCount: _items.length,
                animate: _animate,
                motionEnabled: true,
                motionFramesPerSecond: 30,
                contentBuilder: (context, details) => _items[details.index].content,
                indicatorBuilder: (context, details) {
                  final item = _items[details.index];
                  return NeonTimelineIndicator(
                    status: item.status,
                    animate: _animate,
                    style: preset.theme.indicatorStyle,
                  );
                },
                statusBuilder: (index) => _items[index].status,
                connectorStyleBuilder: (context, details) {
                  final item = _items[details.index];
                  final color = NeonTimelineTheme.of(context).colorForStatus(item.status);
                  return preset.theme.connectorStyle.copyWith(
                    color: color,
                    endColor: color.withAlpha(50),
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

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _ThemePreset {
  const _ThemePreset({required this.name, required this.description, required this.theme});
  final String name;
  final String description;
  final NeonTimelineThemeData theme;

  static List<_ThemePreset> get all => [
    _ThemePreset(
      name: 'Neon (Default)',
      description: 'Dark neon preset with glass indicators',
      theme: NeonTimelineThemeData.neon(),
    ),
    _ThemePreset(
      name: 'Spectral',
      description: 'Cinematic spectral preset with layered glass and energy rendering',
      theme: NeonTimelineThemeData.spectral(),
    ),
    _ThemePreset(
      name: 'Quantum',
      description: 'Maximum-depth quantum preset with synchronized corona and plasma',
      theme: NeonTimelineThemeData.quantum(),
    ),
    _ThemePreset(
      name: 'Hyperion',
      description: 'Maximum-depth singularity with braided warp rail',
      theme: NeonTimelineThemeData.hyperion(),
    ),
    _ThemePreset(
      name: 'Omniverse',
      description: 'Ultra-depth neural-core with photon-lattice connector',
      theme: NeonTimelineThemeData.omniverse(),
    ),
    _ThemePreset(
      name: 'Light',
      description: 'Clean light preset for light mode',
      theme: NeonTimelineThemeData.light(),
    ),
    _ThemePreset(
      name: 'Midnight',
      description: 'Restrained dark preset with reduced glow',
      theme: NeonTimelineThemeData.midnight(),
    ),
    _ThemePreset(
      name: 'Holographic',
      description: 'Transparent cyan-violet hologram preset',
      theme: NeonTimelineThemeData.holographic(),
    ),
    _ThemePreset(
      name: 'Aurora',
      description: 'Cool green-blue quantum variant',
      theme: NeonTimelineThemeData.aurora(),
    ),
    _ThemePreset(
      name: 'Ember',
      description: 'Warm orange-pink quantum variant',
      theme: NeonTimelineThemeData.ember(),
    ),
    _ThemePreset(
      name: 'Neural Aurora',
      description: 'Cyan-green neural-core colorway',
      theme: NeonTimelineThemeData.neuralAurora(),
    ),
    _ThemePreset(
      name: 'Neural Ember',
      description: 'Gold-rose neural-core with stronger diffraction',
      theme: NeonTimelineThemeData.neuralEmber(),
    ),
    _ThemePreset(
      name: 'Solar Flare',
      description: 'Hot gold-magenta singularity variant',
      theme: NeonTimelineThemeData.solarFlare(),
    ),
    _ThemePreset(
      name: 'Cryogenic',
      description: 'Ice-blue singularity with restrained motion',
      theme: NeonTimelineThemeData.cryogenic(),
    ),
    _ThemePreset(
      name: 'Void Pulse',
      description: 'Near-black violet focused on event horizon',
      theme: NeonTimelineThemeData.voidPulse(),
    ),
  ];
}
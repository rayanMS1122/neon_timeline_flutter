import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import 'screens/effects_showcase.dart';
import 'screens/generic_showcase.dart';
import 'screens/performance_showcase.dart';
import 'screens/schedule_showcase.dart';

void main() => runApp(const NeonTimelineExampleApp());

class NeonTimelineExampleApp extends StatefulWidget {
  const NeonTimelineExampleApp({super.key});

  @override
  State<NeonTimelineExampleApp> createState() =>
      _NeonTimelineExampleAppState();
}

class _NeonTimelineExampleAppState extends State<NeonTimelineExampleApp> {
  DemoThemePreset _themePreset = DemoThemePreset.omniverse;
  NeonTimelinePerformanceProfile _performanceProfile =
      NeonTimelinePerformanceProfile.adaptive;
  bool _reduceMotion = false;

  NeonTimelinePerformanceConfig get _performanceConfig {
    return switch (_performanceProfile) {
      NeonTimelinePerformanceProfile.adaptive =>
        const NeonTimelinePerformanceConfig.adaptive(),
      NeonTimelinePerformanceProfile.batterySaver =>
        const NeonTimelinePerformanceConfig.batterySaver(),
      NeonTimelinePerformanceProfile.balanced =>
        const NeonTimelinePerformanceConfig.balanced(),
      NeonTimelinePerformanceProfile.highQuality =>
        const NeonTimelinePerformanceConfig.highQuality(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final timelineTheme = _themePreset.data;
    final brightness = _themePreset == DemoThemePreset.light
        ? Brightness.light
        : Brightness.dark;
    final materialTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: timelineTheme.primaryColor,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF08070E)
          : const Color(0xFFF5F3FA),
      extensions: <ThemeExtension<dynamic>>[timelineTheme],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Timeline Flutter',
      theme: materialTheme,
      home: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(disableAnimations: _reduceMotion),
            child: _ShowcaseShell(
              themePreset: _themePreset,
              performanceProfile: _performanceProfile,
              performance: _performanceConfig,
              reduceMotion: _reduceMotion,
              onThemeChanged: (value) => setState(() => _themePreset = value),
              onPerformanceChanged: (value) =>
                  setState(() => _performanceProfile = value),
              onReduceMotionChanged: (value) =>
                  setState(() => _reduceMotion = value),
            ),
          );
        },
      ),
    );
  }
}

class _ShowcaseShell extends StatefulWidget {
  const _ShowcaseShell({
    required this.themePreset,
    required this.performanceProfile,
    required this.performance,
    required this.reduceMotion,
    required this.onThemeChanged,
    required this.onPerformanceChanged,
    required this.onReduceMotionChanged,
  });

  final DemoThemePreset themePreset;
  final NeonTimelinePerformanceProfile performanceProfile;
  final NeonTimelinePerformanceConfig performance;
  final bool reduceMotion;
  final ValueChanged<DemoThemePreset> onThemeChanged;
  final ValueChanged<NeonTimelinePerformanceProfile> onPerformanceChanged;
  final ValueChanged<bool> onReduceMotionChanged;

  @override
  State<_ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<_ShowcaseShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ScheduleShowcase(performance: widget.performance),
      GenericShowcase(performance: widget.performance),
      EffectsShowcase(performance: widget.performance),
      PerformanceShowcase(performance: widget.performance),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Neon Timeline Flutter',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          if (kIsWeb)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Center(
                child: NeonTimelineBadge(
                  label: 'Web glow',
                  icon: Icons.language_rounded,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Showcase settings',
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NeonTimelineSurface(
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.calendar_view_day_outlined),
            selectedIcon: Icon(Icons.calendar_view_day_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline_rounded),
            label: 'Timelines',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Effects',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed_rounded),
            label: 'Performance',
          ),
        ],
      ),
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Showcase settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DemoThemePreset.values.map((preset) {
                    return ChoiceChip(
                      label: Text(preset.label),
                      selected: widget.themePreset == preset,
                      onSelected: (_) => widget.onThemeChanged(preset),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 20),
                Text(
                  'Performance profile',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NeonTimelinePerformanceProfile.values.map((mode) {
                    return ChoiceChip(
                      label: Text(_profileLabel(mode)),
                      selected: widget.performanceProfile == mode,
                      onSelected: (_) => widget.onPerformanceChanged(mode),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduce motion'),
                  subtitle: const Text(
                    'Simulates the operating-system accessibility preference.',
                  ),
                  value: widget.reduceMotion,
                  onChanged: widget.onReduceMotionChanged,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum DemoThemePreset {
  neon,
  spectral,
  quantum,
  hyperion,
  omniverse,
  neuralAurora,
  neuralEmber,
  holographic,
  solarFlare,
  cryogenic,
  voidPulse,
  aurora,
  ember,
  midnight,
  light,
  seeded,
}

extension on DemoThemePreset {
  String get label => switch (this) {
        DemoThemePreset.neon => 'Neon',
        DemoThemePreset.spectral => 'Spectral',
        DemoThemePreset.quantum => 'Quantum',
        DemoThemePreset.hyperion => 'Hyperion',
        DemoThemePreset.omniverse => 'Omniverse',
        DemoThemePreset.neuralAurora => 'Neural Aurora',
        DemoThemePreset.neuralEmber => 'Neural Ember',
        DemoThemePreset.holographic => 'Hologram',
        DemoThemePreset.solarFlare => 'Solar Flare',
        DemoThemePreset.cryogenic => 'Cryogenic',
        DemoThemePreset.voidPulse => 'Void Pulse',
        DemoThemePreset.aurora => 'Aurora',
        DemoThemePreset.ember => 'Ember',
        DemoThemePreset.midnight => 'Midnight',
        DemoThemePreset.light => 'Light',
        DemoThemePreset.seeded => 'Seeded',
      };

  NeonTimelineThemeData get data => switch (this) {
        DemoThemePreset.neon => NeonTimelineThemeData.neon(),
        DemoThemePreset.spectral => NeonTimelineThemeData.spectral(),
        DemoThemePreset.quantum => NeonTimelineThemeData.quantum(),
        DemoThemePreset.hyperion => NeonTimelineThemeData.hyperion(),
        DemoThemePreset.omniverse => NeonTimelineThemeData.omniverse(),
        DemoThemePreset.neuralAurora => NeonTimelineThemeData.neuralAurora(),
        DemoThemePreset.neuralEmber => NeonTimelineThemeData.neuralEmber(),
        DemoThemePreset.holographic => NeonTimelineThemeData.holographic(),
        DemoThemePreset.solarFlare => NeonTimelineThemeData.solarFlare(),
        DemoThemePreset.cryogenic => NeonTimelineThemeData.cryogenic(),
        DemoThemePreset.voidPulse => NeonTimelineThemeData.voidPulse(),
        DemoThemePreset.aurora => NeonTimelineThemeData.aurora(),
        DemoThemePreset.ember => NeonTimelineThemeData.ember(),
        DemoThemePreset.midnight => NeonTimelineThemeData.midnight(),
        DemoThemePreset.light => NeonTimelineThemeData.light(),
        DemoThemePreset.seeded => NeonTimelineThemeData.fromSeed(
          const Color(0xFFFF5FB9),
        ),
      };
}

String _profileLabel(NeonTimelinePerformanceProfile profile) {
  return switch (profile) {
    NeonTimelinePerformanceProfile.adaptive => 'Adaptive',
    NeonTimelinePerformanceProfile.batterySaver => 'Battery',
    NeonTimelinePerformanceProfile.balanced => 'Balanced',
    NeonTimelinePerformanceProfile.highQuality => 'High quality',
  };
}

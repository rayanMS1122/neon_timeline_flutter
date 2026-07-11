# Advanced timeline rendering

Version 3.0 keeps the existing timeline data, layout, tile, status, builder,
sliver, and accessibility APIs. The advanced layer changes only the rendering
of the existing timeline rail, marker, and optional content card.

## Renderer tiers

| Tier | Indicator | Connector | Recommended use |
| --- | --- | --- | --- |
| Lightweight | `classic` | `classic` | Dense feeds and low-power devices |
| Polished | `glass` | `energy` | General product timelines |
| Cinematic | `stellar` | `energy` | Hero sections and active milestones |
| Quantum | `quantum` | `plasma` | High-detail animated timelines |
| Hyperion | `singularity` | `warp` | Maximum-depth focal timelines |
| Hologram | `hologram` | `hologram` | Technical and sci-fi data rails |
| Omniverse | `neuralCore` | `photonLattice` | Maximum vector depth and motion |

## Presets

| Preset | Indicator | Connector | Character |
| --- | --- | --- | --- |
| `omniverse()` | Neural core | Photon lattice | Ultra-quality vector field and trails |
| `neuralAurora()` | Neural core | Photon lattice | Cyan-green, slower motion |
| `neuralEmber()` | Neural core | Photon lattice | Gold-rose, stronger diffraction |
| `hyperion()` | Singularity | Warp | Pink/cyan event horizon, maximum depth |
| `holographic()` | Hologram | Hologram | Cyan/violet segmented data rail |
| `solarFlare()` | Singularity | Warp | Gold, orange, and magenta |
| `cryogenic()` | Singularity | Warp | Ice blue, slower motion |
| `voidPulse()` | Singularity | Warp | Near-black violet event horizon |
| `quantum()` | Quantum | Plasma | Counter-rotating coronae |
| `spectral()` | Stellar | Energy | Cinematic pink/violet glass |
| `aurora()` | Quantum | Plasma | Green/blue, calmer motion |
| `ember()` | Quantum | Plasma | Warm orange/pink |
| `neon()` | Classic | Classic | Lightweight default |
| `midnight()` | Classic | Classic | Restrained dark |
| `light()` | Classic | Classic | Clean light surface |

## Maximum-depth preset

```dart
NeonTimeline(
  items: items,
  theme: NeonTimelineThemeData.omniverse(),
)
```

The preset does not create another screen or dashboard. It upgrades the same
rail with:

- neural vector-field arcs and concentric halo rings
- internal lattice nodes, caustics, and shockwaves
- diagonal diffraction and pointer-reactive refraction
- orbit particles, deterministic sparks, and lens rays
- multi-strand photon paths and luminous cross-links
- persistent packet trails and interference highlights
- transverse packet flares and moving rail particles
- one synchronized animation clock

## Custom singularity indicator

```dart
const NeonTimelineIndicatorStyle(
  size: 64,
  effect: NeonIndicatorEffect.singularity,
  color: Color(0xFFFF5ACA),
  borderColor: Colors.white,
  glowColor: Color(0xFFFF28A9),
  secondaryColor: Color(0xFFFFB45D),
  tertiaryColor: Color(0xFF5DE5FF),
  interiorColor: Color(0xFF070914),
  glowRadius: 24,
  intensity: 1.28,
  detail: 1,
  rayLength: 1.18,
  particleCount: 14,
  rotationSpeed: 1.34,
  corona: 1,
  depth: 1,
  chromaticAberration: 1.1,
  refraction: 0.96,
  scanlineOpacity: 0.13,
  arcCount: 9,
  sparkCount: 16,
  noise: 0.5,
  parallax: 0.92,
  eventHorizon: 0.94,
)
```

### Indicator tuning

| Field | Effect |
| --- | --- |
| `intensity` | Overall emitted light |
| `detail` | Global micro-detail multiplier |
| `rayLength` | Horizontal and vertical lens-ray reach |
| `particleCount` | Orbiting particles |
| `rotationSpeed` | Spectral and corona rotation |
| `corona` | Outer magnetic/corona strength |
| `depth` | Glass depth and press compression |
| `chromaticAberration` | Spectral edge separation |
| `refraction` | Internal highlight and field distortion |
| `scanlineOpacity` | Hologram/singularity scanlines |
| `arcCount` | Corona or segmented ring count |
| `sparkCount` | Deterministic micro sparks |
| `noise` | Shimmer and micro-texture strength |
| `parallax` | Pointer-driven highlight displacement |
| `eventHorizon` | Singularity core darkness/compression |

## Custom warp connector

```dart
const NeonTimelineConnectorStyle(
  effect: NeonConnectorEffect.warp,
  animated: true,
  color: Color(0xFFFF62CF),
  endColor: Color(0xFF596FFF),
  secondaryColor: Color(0xFF5DE5FF),
  coreColor: Colors.white,
  thickness: 2.35,
  glowRadius: 13,
  intensity: 1.24,
  detail: 1,
  flowSpeed: 1.12,
  particleCount: 12,
  turbulence: 0.78,
  strandCount: 5,
  waveFrequency: 7.4,
  chromaticAberration: 1.05,
  packetCount: 4,
  scanlineOpacity: 0.15,
  refraction: 0.92,
  crossFlare: 0.92,
  noise: 0.42,
  pulseWidth: 0.48,
)
```

### Connector tuning

| Field | Effect |
| --- | --- |
| `flowSpeed` | Shared normalized phase multiplier |
| `particleCount` | Moving rail particles |
| `turbulence` | Plasma and warp wave displacement |
| `trailCount` | Plasma energy trails |
| `phaseOffset` | Stagger between adjacent segments |
| `strandCount` | Braided warp strands |
| `waveFrequency` | Oscillations along the rail |
| `chromaticAberration` | Spectral fringe separation |
| `packetCount` | Warp/hologram moving packets |
| `scanlineOpacity` | Data ticks and hologram scanlines |
| `refraction` | Shimmer field strength |
| `crossFlare` | Transverse packet flare width |
| `noise` | Deterministic digital micro-noise |
| `pulseWidth` | Moving packet length |

## Neural-core indicator

```dart
const NeonTimelineIndicatorStyle(
  size: 66,
  effect: NeonIndicatorEffect.neuralCore,
  quality: NeonTimelineRenderQuality.ultra,
  haloRingCount: 7,
  fieldLineCount: 14,
  diffraction: 0.94,
  shockwave: 0.92,
  detail: 1,
)
```

## Photon-lattice connector

```dart
const NeonTimelineConnectorStyle(
  effect: NeonConnectorEffect.photonLattice,
  animated: true,
  quality: NeonTimelineRenderQuality.ultra,
  strandCount: 6,
  latticeDensity: 11,
  trailPersistence: 0.92,
  photonSpread: 0.92,
  interference: 0.94,
)
```

The quality profile controls vector sample counts only. Layout, hit targets,
semantics, and item ordering remain unchanged.

## Advanced cards

The optional content surface supports `prismatic`, `holographic`, and
`liquidCrystal` variants without changing timeline layout:

```dart
const NeonTimelineCard(
  variant: NeonTimelineCardVariant.prismatic,
  blurSigma: 10,
  intensity: 1.05,
  enableParallax: true,
  child: Text('Active milestone'),
)
```

Prismatic cards use a pointer-reactive highlight, spectral border, and layered
glass. Holographic cards use animated scanlines and segmented corner marks.
Liquid-crystal cards add animated caustic ribbons, a micro-grid, volumetric
lighting, and a rotating spectral edge. All advanced variants honor the shared
motion scope and reduced-motion settings.

## Synchronized standalone primitives

High-level timelines install a shared motion clock automatically. For manually
composed primitives:

```dart
NeonTimelineMotionScope(
  duration: const Duration(milliseconds: 4800),
  child: Row(
    children: const [
      NeonTimelineIndicator(
        status: NeonTimelineStatus.active,
        style: NeonTimelineIndicatorStyle(
          effect: NeonIndicatorEffect.singularity,
        ),
      ),
      Expanded(
        child: NeonTimelineConnector(
          axis: Axis.horizontal,
          style: NeonTimelineConnectorStyle(
            effect: NeonConnectorEffect.warp,
            animated: true,
          ),
        ),
      ),
    ],
  ),
)
```

The scope honors `MediaQuery.disableAnimations` and `TickerMode`. Standalone
widgets outside a scope retain their local animation fallback.

High-level timelines also expose deterministic motion control without manual
composition:

```dart
NeonTimeline(
  items: items,
  theme: NeonTimelineThemeData.hyperion(),
  motionEnabled: true,
  motionPhaseOffset: 0.25,
)
```

Set `motionEnabled: false` for static exports and golden tests. Use
`motionPhaseOffset` to stagger multiple timelines while keeping every marker,
connector, and advanced card phase-locked within its own timeline.

## Performance profiles

Hyperion intentionally spends more GPU time than the classic renderer. Use it
for active or visually important nodes. A practical dense-feed profile:

```dart
final tuned = NeonTimelineThemeData.hyperion().copyWith(
  indicatorStyle: NeonTimelineThemeData.hyperion().indicatorStyle.copyWith(
    detail: 0.62,
    particleCount: 5,
    arcCount: 5,
    sparkCount: 6,
    noise: 0.2,
  ),
  connectorStyle: NeonTimelineThemeData.hyperion().connectorStyle.copyWith(
    detail: 0.55,
    particleCount: 4,
    strandCount: 3,
    packetCount: 2,
    crossFlare: 0.5,
    noise: 0.15,
  ),
);
```

For very long timelines:

1. Use `classic`, `energy`, or `spectral()` for non-active segments.
2. Keep advanced motion only on segments touching the active item.
3. Lower card `blurSigma` or use solid cards.
4. Reduce particles before reducing core glow; particles cost more draw calls.
5. Reduce `arcCount`, `strandCount`, and `packetCount` on mobile.
6. Keep `RepaintBoundary` enabled for lazy lists.

## Renderer implementation

The advanced indicator, connector, and card painters use `dart:math` for
orbital, braided, wave, and deterministic-noise geometry. They use `dart:ui`
for radial, linear, and sweep shaders and blur filters. Those imports remain in
renderer files; users import only:

```dart
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
```

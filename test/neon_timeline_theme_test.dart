import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  group('NeonTimelineThemeData', () {
    test('copyWith replaces selected values and preserves the rest', () {
      const base = NeonTimelineThemeData();
      const indicator = NeonTimelineIndicatorStyle(
        size: 30,
        shape: NeonIndicatorShape.square,
      );
      const connector = NeonTimelineConnectorStyle(
        variant: NeonConnectorVariant.dashed,
        thickness: 4,
      );
      final copy = base.copyWith(
        primaryColor: const Color(0xFF010203),
        secondaryColor: const Color(0xFF040506),
        indicatorStyle: indicator,
        connectorStyle: connector,
        tilePadding: const EdgeInsets.all(12),
        contentGap: 20,
        nodeLaneExtent: 50,
        verticalMinExtent: 120,
        horizontalItemExtent: 300,
        adaptiveBreakpoint: 600,
        animationDuration: const Duration(milliseconds: 700),
        animationCurve: Curves.linear,
        motionDuration: const Duration(milliseconds: 5000),
      );

      expect(copy.primaryColor, const Color(0xFF010203));
      expect(copy.secondaryColor, const Color(0xFF040506));
      expect(copy.indicatorStyle, indicator);
      expect(copy.connectorStyle, connector);
      expect(copy.tilePadding, const EdgeInsets.all(12));
      expect(copy.contentGap, 20);
      expect(copy.nodeLaneExtent, 50);
      expect(copy.verticalMinExtent, 120);
      expect(copy.horizontalItemExtent, 300);
      expect(copy.adaptiveBreakpoint, 600);
      expect(copy.animationDuration, const Duration(milliseconds: 700));
      expect(copy.animationCurve, Curves.linear);
      expect(copy.motionDuration, const Duration(milliseconds: 5000));
      expect(copy.textColor, base.textColor);
      expect(copy.completedColor, base.completedColor);
    });

    test('lerp interpolates continuous fields and switches discrete fields', () {
      const start = NeonTimelineThemeData(
        primaryColor: Color(0xFF000000),
        contentGap: 10,
        tilePadding: EdgeInsets.zero,
        animationDuration: Duration(milliseconds: 100),
        animationCurve: Curves.linear,
        motionDuration: Duration(milliseconds: 2000),
        indicatorStyle: NeonTimelineIndicatorStyle(
          size: 20,
          shape: NeonIndicatorShape.circle,
        ),
        connectorStyle: NeonTimelineConnectorStyle(
          thickness: 2,
          variant: NeonConnectorVariant.solid,
        ),
      );
      const end = NeonTimelineThemeData(
        primaryColor: Color(0xFFFFFFFF),
        contentGap: 30,
        tilePadding: EdgeInsets.all(20),
        animationDuration: Duration(milliseconds: 900),
        animationCurve: Curves.bounceIn,
        motionDuration: Duration(milliseconds: 6000),
        indicatorStyle: NeonTimelineIndicatorStyle(
          size: 40,
          shape: NeonIndicatorShape.diamond,
        ),
        connectorStyle: NeonTimelineConnectorStyle(
          thickness: 6,
          variant: NeonConnectorVariant.dashed,
        ),
      );

      final beforeSwitch = start.lerp(end, 0.49);
      final midpoint = start.lerp(end, 0.5);

      expect(midpoint.primaryColor.red, closeTo(128, 2));
      expect(midpoint.primaryColor.green, closeTo(128, 2));
      expect(midpoint.primaryColor.blue, closeTo(128, 2));
      expect(midpoint.contentGap, 20);
      expect(midpoint.tilePadding, const EdgeInsets.all(10));
      expect(midpoint.indicatorStyle.size, 30);
      expect(midpoint.connectorStyle.thickness, 4);
      expect(beforeSwitch.indicatorStyle.shape, NeonIndicatorShape.circle);
      expect(midpoint.indicatorStyle.shape, NeonIndicatorShape.diamond);
      expect(beforeSwitch.connectorStyle.variant,
          NeonConnectorVariant.solid);
      expect(midpoint.connectorStyle.variant, NeonConnectorVariant.dashed);
      expect(beforeSwitch.animationDuration,
          const Duration(milliseconds: 100));
      expect(midpoint.animationDuration, const Duration(milliseconds: 900));
      expect(midpoint.animationCurve, Curves.bounceIn);
      expect(midpoint.motionDuration, const Duration(milliseconds: 4000));
      expect(start.lerp(null, 0.5), same(start));
    });

    test('colorForStatus maps every status to its semantic color', () {
      const theme = NeonTimelineThemeData(
        mutedColor: Color(0xFF000001),
        primaryColor: Color(0xFF000002),
        completedColor: Color(0xFF000003),
        errorColor: Color(0xFF000004),
        disabledColor: Color(0xFF000005),
      );

      expect(theme.colorForStatus(NeonTimelineStatus.pending),
          theme.mutedColor);
      expect(theme.colorForStatus(NeonTimelineStatus.active),
          theme.primaryColor);
      expect(theme.colorForStatus(NeonTimelineStatus.completed),
          theme.completedColor);
      expect(theme.colorForStatus(NeonTimelineStatus.error), theme.errorColor);
      expect(theme.colorForStatus(NeonTimelineStatus.disabled),
          theme.disabledColor);
    });

    test('spectral preset enables the advanced renderer', () {
      final theme = NeonTimelineThemeData.spectral();

      expect(theme.indicatorStyle.effect, NeonIndicatorEffect.stellar);
      expect(theme.indicatorStyle.detail, 1);
      expect(theme.connectorStyle.effect, NeonConnectorEffect.energy);
      expect(theme.connectorStyle.animated, isTrue);
      expect(theme.nodeLaneExtent, greaterThan(theme.indicatorStyle.visualExtent));
    });

    test('quantum preset enables maximum-depth synchronized rendering', () {
      final theme = NeonTimelineThemeData.quantum();

      expect(theme.indicatorStyle.effect, NeonIndicatorEffect.quantum);
      expect(theme.indicatorStyle.corona, 1);
      expect(theme.connectorStyle.effect, NeonConnectorEffect.plasma);
      expect(theme.connectorStyle.trailCount, 3);
      expect(theme.connectorStyle.animated, isTrue);
      expect(theme.motionDuration, theme.connectorStyle.animationDuration);
      expect(theme.nodeLaneExtent, greaterThan(theme.indicatorStyle.visualExtent));
    });

    test('hyperion enables singularity and warp rendering', () {
      final theme = NeonTimelineThemeData.hyperion();

      expect(theme.indicatorStyle.effect, NeonIndicatorEffect.singularity);
      expect(theme.indicatorStyle.eventHorizon, greaterThan(0.9));
      expect(theme.indicatorStyle.arcCount, greaterThanOrEqualTo(8));
      expect(theme.connectorStyle.effect, NeonConnectorEffect.warp);
      expect(theme.connectorStyle.strandCount, greaterThanOrEqualTo(4));
      expect(theme.connectorStyle.packetCount, greaterThanOrEqualTo(3));
      expect(theme.connectorStyle.animated, isTrue);
      expect(theme.motionDuration, theme.connectorStyle.animationDuration);
      expect(theme.nodeLaneExtent,
          greaterThan(theme.indicatorStyle.visualExtent));
    });

    test('omniverse enables neural-core and photon-lattice rendering', () {
      final theme = NeonTimelineThemeData.omniverse();

      expect(theme.indicatorStyle.effect, NeonIndicatorEffect.neuralCore);
      expect(
        theme.indicatorStyle.quality,
        NeonTimelineRenderQuality.ultra,
      );
      expect(theme.indicatorStyle.haloRingCount, greaterThanOrEqualTo(6));
      expect(theme.indicatorStyle.fieldLineCount, greaterThanOrEqualTo(12));
      expect(
        theme.connectorStyle.effect,
        NeonConnectorEffect.photonLattice,
      );
      expect(
        theme.connectorStyle.quality,
        NeonTimelineRenderQuality.ultra,
      );
      expect(theme.connectorStyle.latticeDensity, greaterThanOrEqualTo(10));
      expect(theme.connectorStyle.trailPersistence, greaterThan(0.8));
      expect(theme.connectorStyle.animated, isTrue);
      expect(theme.motionDuration, theme.connectorStyle.animationDuration);
      expect(
        theme.nodeLaneExtent,
        greaterThan(theme.indicatorStyle.visualExtent),
      );
    });

    test('neural colorways preserve the ultra renderers', () {
      for (final theme in <NeonTimelineThemeData>[
        NeonTimelineThemeData.neuralAurora(),
        NeonTimelineThemeData.neuralEmber(),
      ]) {
        expect(theme.indicatorStyle.effect, NeonIndicatorEffect.neuralCore);
        expect(
          theme.connectorStyle.effect,
          NeonConnectorEffect.photonLattice,
        );
      }
    });

    test('holographic preset uses segmented renderers', () {
      final theme = NeonTimelineThemeData.holographic();

      expect(theme.indicatorStyle.effect, NeonIndicatorEffect.hologram);
      expect(theme.indicatorStyle.scanlineOpacity, greaterThan(0.4));
      expect(theme.connectorStyle.effect, NeonConnectorEffect.hologram);
      expect(theme.connectorStyle.scanlineOpacity, greaterThan(0.5));
      expect(theme.connectorStyle.animated, isTrue);
    });

    test('singularity color variants preserve the advanced renderers', () {
      for (final theme in <NeonTimelineThemeData>[
        NeonTimelineThemeData.solarFlare(),
        NeonTimelineThemeData.cryogenic(),
        NeonTimelineThemeData.voidPulse(),
      ]) {
        expect(theme.indicatorStyle.effect, NeonIndicatorEffect.singularity);
        expect(theme.connectorStyle.effect, NeonConnectorEffect.warp);
      }
    });

    test('aurora and ember remain quantum/plasma variants', () {
      for (final theme in <NeonTimelineThemeData>[
        NeonTimelineThemeData.aurora(),
        NeonTimelineThemeData.ember(),
      ]) {
        expect(theme.indicatorStyle.effect, NeonIndicatorEffect.quantum);
        expect(theme.connectorStyle.effect, NeonConnectorEffect.plasma);
        expect(theme.connectorStyle.animated, isTrue);
      }
    });

    testWidgets('local theme overrides ThemeData extension', (tester) async {
      const appTheme = NeonTimelineThemeData(primaryColor: Color(0xFF101010));
      const localTheme =
          NeonTimelineThemeData(primaryColor: Color(0xFF202020));
      NeonTimelineThemeData? resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: const <ThemeExtension<dynamic>>[appTheme],
          ),
          home: NeonTimelineTheme(
            data: localTheme,
            child: Builder(
              builder: (context) {
                resolved = NeonTimelineTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved, same(localTheme));
    });

    testWidgets('ThemeData extension is used when no local theme exists',
        (tester) async {
      const appTheme = NeonTimelineThemeData(primaryColor: Color(0xFF303030));
      NeonTimelineThemeData? resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: const <ThemeExtension<dynamic>>[appTheme],
          ),
          home: Builder(
            builder: (context) {
              resolved = NeonTimelineTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, same(appTheme));
    });
  });

  group('indicator and connector styles', () {
    test('indicator copy, equality, hashCode, and lerp are stable', () {
      const base = NeonTimelineIndicatorStyle();
      final copy = base.copyWith(
        size: 44,
        color: const Color(0xFF112233),
        borderWidth: 3,
        glowRadius: 0,
        shape: NeonIndicatorShape.diamond,
        effect: NeonIndicatorEffect.singularity,
        rotationSpeed: 1.5,
        corona: 0.9,
        depth: 0.8,
        chromaticAberration: 1.2,
        refraction: 0.95,
        scanlineOpacity: 0.4,
        arcCount: 10,
        sparkCount: 14,
        noise: 0.6,
        parallax: 0.9,
        eventHorizon: 0.98,
        quality: NeonTimelineRenderQuality.ultra,
        haloRingCount: 9,
        fieldLineCount: 18,
        diffraction: 0.92,
        shockwave: 0.88,
      );
      final equivalent = copy.copyWith();

      expect(copy.size, 44);
      expect(copy.color, const Color(0xFF112233));
      expect(copy.borderWidth, 3);
      expect(copy.glowRadius, 0);
      expect(copy.shape, NeonIndicatorShape.diamond);
      expect(copy.effect, NeonIndicatorEffect.singularity);
      expect(copy.rotationSpeed, 1.5);
      expect(copy.corona, 0.9);
      expect(copy.depth, 0.8);
      expect(copy.chromaticAberration, 1.2);
      expect(copy.refraction, 0.95);
      expect(copy.scanlineOpacity, 0.4);
      expect(copy.arcCount, 10);
      expect(copy.sparkCount, 14);
      expect(copy.noise, 0.6);
      expect(copy.parallax, 0.9);
      expect(copy.eventHorizon, 0.98);
      expect(copy.quality, NeonTimelineRenderQuality.ultra);
      expect(copy.haloRingCount, 9);
      expect(copy.fieldLineCount, 18);
      expect(copy.diffraction, 0.92);
      expect(copy.shockwave, 0.88);
      expect(copy, equivalent);
      expect(copy.hashCode, equivalent.hashCode);

      final midpoint = NeonTimelineIndicatorStyle.lerp(base, copy, 0.5);
      expect(midpoint.size, 35);
      expect(midpoint.borderWidth, 2.25);
      expect(midpoint.shape, NeonIndicatorShape.diamond);
    });

    test('connector copy, equality, hashCode, and lerp are stable', () {
      const base = NeonTimelineConnectorStyle();
      final copy = base.copyWith(
        variant: NeonConnectorVariant.dashed,
        thickness: 6,
        dashLength: 10,
        gapLength: 2,
        glowRadius: 0,
        lineCap: StrokeCap.square,
        effect: NeonConnectorEffect.warp,
        turbulence: 0.8,
        trailCount: 4,
        phaseOffset: 0.25,
        strandCount: 5,
        waveFrequency: 7.5,
        chromaticAberration: 1.1,
        packetCount: 4,
        scanlineOpacity: 0.3,
        refraction: 0.9,
        crossFlare: 0.85,
        noise: 0.55,
        pulseWidth: 0.5,
        quality: NeonTimelineRenderQuality.ultra,
        latticeDensity: 12,
        trailPersistence: 0.9,
        photonSpread: 0.85,
        interference: 0.95,
      );
      final equivalent = copy.copyWith();

      expect(copy.variant, NeonConnectorVariant.dashed);
      expect(copy.thickness, 6);
      expect(copy.dashLength, 10);
      expect(copy.gapLength, 2);
      expect(copy.glowRadius, 0);
      expect(copy.lineCap, StrokeCap.square);
      expect(copy.effect, NeonConnectorEffect.warp);
      expect(copy.turbulence, 0.8);
      expect(copy.trailCount, 4);
      expect(copy.phaseOffset, 0.25);
      expect(copy.strandCount, 5);
      expect(copy.waveFrequency, 7.5);
      expect(copy.chromaticAberration, 1.1);
      expect(copy.packetCount, 4);
      expect(copy.scanlineOpacity, 0.3);
      expect(copy.refraction, 0.9);
      expect(copy.crossFlare, 0.85);
      expect(copy.noise, 0.55);
      expect(copy.pulseWidth, 0.5);
      expect(copy.quality, NeonTimelineRenderQuality.ultra);
      expect(copy.latticeDensity, 12);
      expect(copy.trailPersistence, 0.9);
      expect(copy.photonSpread, 0.85);
      expect(copy.interference, 0.95);
      expect(copy, equivalent);
      expect(copy.hashCode, equivalent.hashCode);

      final midpoint = NeonTimelineConnectorStyle.lerp(base, copy, 0.5);
      expect(midpoint.thickness, 4);
      expect(midpoint.dashLength, 8);
      expect(midpoint.gapLength, 3);
      expect(midpoint.variant, NeonConnectorVariant.dashed);
      expect(midpoint.lineCap, StrokeCap.square);
    });
  });

  group('public rendering primitives', () {
    testWidgets('all connector variants render on both axes', (tester) async {
      final connectors = <Widget>[
        for (final axis in Axis.values)
          for (final variant in NeonConnectorVariant.values)
            SizedBox(
              width: axis == Axis.vertical ? 20 : 100,
              height: axis == Axis.vertical ? 70 : 20,
              child: NeonTimelineConnector(
                axis: axis,
                style: NeonTimelineConnectorStyle(
                  variant: variant,
                  glowRadius: 0,
                ),
              ),
            ),
      ];

      await tester.pumpWidget(
        _materialHost(
          Wrap(spacing: 8, runSpacing: 8, children: connectors),
        ),
      );

      expect(find.byType(NeonTimelineConnector), findsNWidgets(6));
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('all connector effects render on both axes', (tester) async {
      await tester.pumpWidget(
        _materialHost(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final axis in Axis.values)
                for (final effect in NeonConnectorEffect.values)
                  SizedBox(
                    width: axis == Axis.vertical ? 32 : 120,
                    height: axis == Axis.vertical ? 90 : 32,
                    child: NeonTimelineConnector(
                      axis: axis,
                      style: NeonTimelineConnectorStyle(
                        effect: effect,
                        animated: false,
                        detail: 1,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      );

      expect(
        find.byType(NeonTimelineConnector),
        findsNWidgets(Axis.values.length * NeonConnectorEffect.values.length),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('all indicator effects render', (tester) async {
      await tester.pumpWidget(
        _materialHost(
          Wrap(
            children: <Widget>[
              for (final effect in NeonIndicatorEffect.values)
                NeonTimelineIndicator(
                  status: NeonTimelineStatus.active,
                  animate: false,
                  style: NeonTimelineIndicatorStyle(
                    effect: effect,
                    size: 48,
                    detail: 1,
                  ),
                ),
            ],
          ),
        ),
      );

      expect(
        find.byType(NeonTimelineIndicator),
        findsNWidgets(NeonIndicatorEffect.values.length),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('all status and shape combinations render', (tester) async {
      await tester.pumpWidget(
        _materialHost(
          Wrap(
            children: [
              for (final status in NeonTimelineStatus.values)
                for (final shape in NeonIndicatorShape.values)
                  NeonTimelineIndicator(
                    status: status,
                    animate: false,
                    style: NeonTimelineIndicatorStyle(shape: shape),
                  ),
            ],
          ),
        ),
      );

      expect(find.byType(NeonTimelineIndicator), findsNWidgets(15));
      expect(tester.takeException(), isNull);
    });

    testWidgets('quantum indicators and plasma connectors render safely',
        (tester) async {
      await tester.pumpWidget(
        _materialHost(
          const Row(
            children: [
              NeonTimelineIndicator(
                status: NeonTimelineStatus.active,
                animate: false,
                style: NeonTimelineIndicatorStyle(
                  size: 54,
                  effect: NeonIndicatorEffect.quantum,
                  detail: 1,
                  particleCount: 7,
                ),
              ),
              SizedBox(
                width: 120,
                height: 30,
                child: NeonTimelineConnector(
                  axis: Axis.horizontal,
                  style: NeonTimelineConnectorStyle(
                    effect: NeonConnectorEffect.plasma,
                    animated: false,
                    detail: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(NeonTimelineIndicator), findsOneWidget);
      expect(find.byType(NeonTimelineConnector), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('high-level timelines install one shared motion scope',
        (tester) async {
      await tester.pumpWidget(
        _materialHost(
          NeonTimeline(
            animate: false,
            theme: NeonTimelineThemeData.quantum(),
            items: const <NeonTimelineItem>[
              NeonTimelineItem(
                status: NeonTimelineStatus.active,
                content: Text('Synchronized'),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(NeonTimelineMotionScope), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('all card variants render and interactive card activates',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _materialHost(
          Column(
            children: [
              for (final variant in NeonTimelineCardVariant.values)
                NeonTimelineCard(
                  key: ValueKey<NeonTimelineCardVariant>(variant),
                  variant: variant,
                  blurSigma: variant == NeonTimelineCardVariant.glass ? 4 : 0,
                  padding: const EdgeInsets.all(4),
                  semanticLabel:
                      variant == NeonTimelineCardVariant.solid
                          ? 'Interactive card'
                          : null,
                  onTap: variant == NeonTimelineCardVariant.solid
                      ? () => taps++
                      : null,
                  child: Text('Card ${variant.name}'),
                ),
            ],
          ),
        ),
      );

      for (final variant in NeonTimelineCardVariant.values) {
        expect(find.text('Card ${variant.name}'), findsOneWidget);
      }
      expect(
        find.byType(NeonTimelineCard),
        findsNWidgets(NeonTimelineCardVariant.values.length),
      );
      await tester.tap(find.text('Card solid'));
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('standalone node renders custom indicator and both segments',
        (tester) async {
      await tester.pumpWidget(
        _materialHost(
          const SizedBox(
            width: 60,
            height: 180,
            child: NeonTimelineNode(
              indicator: Icon(Icons.star, key: ValueKey<String>('node-star')),
              beforeStyle: NeonTimelineConnectorStyle(
                variant: NeonConnectorVariant.solid,
              ),
              afterStyle: NeonTimelineConnectorStyle(
                variant: NeonConnectorVariant.dashed,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey<String>('node-star')), findsOneWidget);
      expect(find.byType(NeonTimelineConnector), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _materialHost(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(body: child),
  );
}

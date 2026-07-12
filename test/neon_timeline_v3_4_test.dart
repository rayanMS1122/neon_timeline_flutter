import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('battery saver resolves to a static low-cost budget',
      (tester) async {
    NeonTimelineResolvedPerformance? resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = const NeonTimelinePerformanceConfig.batterySaver()
                .resolve(context, itemCount: 500);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, isNotNull);
    expect(resolved!.motionFramesPerSecond, 12);
    expect(resolved!.maxAnimatedEntries, 0);
    expect(resolved!.enableBackdropBlur, isFalse);
    expect(resolved!.enableParallax, isFalse);
    expect(resolved!.enableParticles, isFalse);
  });

  testWidgets('reduced motion overrides explicit expensive settings',
      (tester) async {
    NeonTimelineResolvedPerformance? resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              resolved = const NeonTimelinePerformanceConfig(
                motionFramesPerSecond: 120,
                maxAnimatedEntries: 20,
                enableBackdropBlur: true,
                enableParallax: true,
                enableParticles: true,
              ).resolve(context, itemCount: 4);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(resolved, isNotNull);
    expect(resolved!.motionFramesPerSecond, 1);
    expect(resolved!.maxAnimatedEntries, 0);
    expect(resolved!.enableBackdropBlur, isFalse);
    expect(resolved!.enableParallax, isFalse);
    expect(resolved!.enableParticles, isFalse);
  });

  testWidgets('explicit animated indexes avoid animating other active rows',
      (tester) async {
    await tester.pumpWidget(
      _host(
        NeonTimeline.builder(
          itemCount: 4,
          itemExtent: 100,
          animatedItemIndexes: const <int>[2],
          maxAnimatedItems: 1,
          statusBuilder: (_) => NeonTimelineStatus.active,
          contentBuilder: (context, details) => Text('Row ${details.index}'),
        ),
      ),
    );
    await tester.pump();

    final indicators = tester
        .widgetList<NeonTimelineIndicator>(
          find.byType(NeonTimelineIndicator),
        )
        .toList(growable: false);
    expect(indicators, hasLength(4));
    expect(indicators.where((indicator) => indicator.animate), hasLength(1));
    expect(indicators[2].animate, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('optional presentation widgets remain independently usable',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const NeonTimelineSurface(
          child: Column(
            children: <Widget>[
              NeonTimelineHeader(
                title: 'Timeline',
                trailing: NeonTimelineBadge(label: 'Live'),
              ),
              Expanded(
                child: NeonTimelineEmptyState(
                  title: 'Nothing here',
                  message: 'Add the first entry.',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: <ThemeExtension<dynamic>>[
        NeonTimelineThemeData.spectral(),
      ],
    ),
    home: Scaffold(
      body: SizedBox(width: 430, height: 720, child: child),
    ),
  );
}

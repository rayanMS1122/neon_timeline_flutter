import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  group('NeonTimeline items constructor', () {
    testWidgets('renders direct content, opposite content, and indicators',
        (tester) async {
      await tester.pumpWidget(
        _host(
          child: NeonTimeline(
            animate: false,
            layout: NeonTimelineLayout.center,
            items: const [
              NeonTimelineItem(
                id: 'pending',
                content: Text('Pending content'),
                oppositeContent: Text('09:00'),
                status: NeonTimelineStatus.pending,
              ),
              NeonTimelineItem(
                id: 'custom',
                content: Text('Active content'),
                oppositeContent: Text('10:00'),
                indicator: SizedBox(
                  key: ValueKey<String>('custom-indicator'),
                  width: 18,
                  height: 18,
                ),
                status: NeonTimelineStatus.active,
              ),
              NeonTimelineItem(
                id: 'completed',
                content: Text('Completed content'),
                oppositeContent: Text('11:00'),
                status: NeonTimelineStatus.completed,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pending content'), findsOneWidget);
      expect(find.text('Active content'), findsOneWidget);
      expect(find.text('Completed content'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('custom-indicator')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<Object>('pending')), findsOneWidget);
      expect(find.byKey(const ValueKey<Object>('completed')), findsOneWidget);
      expect(find.byType(NeonTimelineTile), findsNWidgets(3));
      expect(find.byType(NeonTimelineConnector), findsWidgets);

      final defaultIndicators = tester
          .widgetList<NeonTimelineIndicator>(
            find.byType(NeonTimelineIndicator),
          )
          .toList();
      expect(
        defaultIndicators.map((indicator) => indicator.status),
        containsAll(<NeonTimelineStatus>[
          NeonTimelineStatus.pending,
          NeonTimelineStatus.completed,
        ]),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('NeonTimeline.builder', () {
    testWidgets('provides complete details, statuses, keys, and transitions',
        (tester) async {
      final contentDetails = <int, NeonTimelineItemDetails>{};
      final oppositeDetails = <int, NeonTimelineItemDetails>{};
      final indicatorDetails = <int, NeonTimelineItemDetails>{};
      final semanticDetails = <int, NeonTimelineItemDetails>{};
      final connectorDetails = <int, NeonTimelineItemDetails>{};
      const statuses = <NeonTimelineStatus>[
        NeonTimelineStatus.pending,
        NeonTimelineStatus.active,
        NeonTimelineStatus.completed,
      ];
      const theme = NeonTimelineThemeData(
        mutedColor: Color(0xFF111111),
        primaryColor: Color(0xFF222222),
        completedColor: Color(0xFF333333),
      );

      await tester.pumpWidget(
        _host(
          direction: TextDirection.rtl,
          child: NeonTimeline.builder(
            itemCount: statuses.length,
            animate: false,
            layout: NeonTimelineLayout.alternating,
            theme: theme,
            contentBuilder: (context, details) {
              contentDetails[details.index] = details;
              return Text('Content ${details.index}');
            },
            oppositeContentBuilder: (context, details) {
              oppositeDetails[details.index] = details;
              return Text('Opposite ${details.index}');
            },
            indicatorBuilder: (context, details) {
              indicatorDetails[details.index] = details;
              return Text('Indicator ${details.index}');
            },
            statusBuilder: (index) => statuses[index],
            semanticLabelBuilder: (context, details) {
              semanticDetails[details.index] = details;
              return 'Builder item ${details.index + 1}';
            },
            connectorStyleBuilder: (context, details) {
              connectorDetails[details.index] = details;
              return const NeonTimelineConnectorStyle(
                variant: NeonConnectorVariant.dashed,
                thickness: 3,
                glowRadius: 0,
              );
            },
            keyBuilder: (context, details) =>
                ValueKey<String>('builder-${details.index}'),
          ),
        ),
      );
      await tester.pump();

      expect(contentDetails.keys, containsAll(<int>[0, 1, 2]));
      expect(oppositeDetails.keys, containsAll(<int>[0, 1, 2]));
      expect(indicatorDetails.keys, containsAll(<int>[0, 1, 2]));
      expect(semanticDetails.keys, containsAll(<int>[0, 1, 2]));
      expect(connectorDetails.keys, containsAll(<int>[0, 1, 2]));

      final middle = contentDetails[1]!;
      expect(middle.index, 1);
      expect(middle.itemCount, 3);
      expect(middle.axis, Axis.vertical);
      expect(middle.layout, NeonTimelineLayout.alternating);
      expect(middle.textDirection, TextDirection.rtl);
      expect(middle.status, NeonTimelineStatus.active);
      expect(middle.previousStatus, NeonTimelineStatus.pending);
      expect(middle.nextStatus, NeonTimelineStatus.completed);
      expect(middle.isFirst, isFalse);
      expect(middle.isLast, isFalse);
      expect(middle.isEven, isFalse);
      expect(contentDetails[0]!.isFirst, isTrue);
      expect(contentDetails[2]!.isLast, isTrue);

      expect(find.byKey(const ValueKey<String>('builder-1')), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Opposite 1'), findsOneWidget);
      expect(find.text('Indicator 1'), findsOneWidget);

      final middleConnectors = tester
          .widgetList<NeonTimelineConnector>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('builder-1')),
              matching: find.byType(NeonTimelineConnector),
            ),
          )
          .toList();
      expect(middleConnectors, hasLength(2));
      expect(middleConnectors[0].style!.variant,
          NeonConnectorVariant.dashed);
      expect(middleConnectors[0].style!.thickness, 3);
      expect(middleConnectors[0].style!.color, theme.mutedColor);
      expect(middleConnectors[0].style!.endColor, theme.primaryColor);
      expect(middleConnectors[1].style!.color, theme.primaryColor);
      expect(middleConnectors[1].style!.endColor, theme.completedColor);
      expect(tester.takeException(), isNull);
    });
  });

  group('layout and directionality', () {
    testWidgets('vertical, horizontal, alternating, and RTL layouts are safe',
        (tester) async {
      final configurations = <({
        Axis axis,
        NeonTimelineLayout layout,
        TextDirection direction,
        Size size,
      })>[
        (
          axis: Axis.vertical,
          layout: NeonTimelineLayout.start,
          direction: TextDirection.ltr,
          size: const Size(320, 500),
        ),
        (
          axis: Axis.vertical,
          layout: NeonTimelineLayout.end,
          direction: TextDirection.rtl,
          size: const Size(320, 500),
        ),
        (
          axis: Axis.vertical,
          layout: NeonTimelineLayout.center,
          direction: TextDirection.rtl,
          size: const Size(800, 500),
        ),
        (
          axis: Axis.vertical,
          layout: NeonTimelineLayout.alternating,
          direction: TextDirection.ltr,
          size: const Size(800, 500),
        ),
        (
          axis: Axis.horizontal,
          layout: NeonTimelineLayout.start,
          direction: TextDirection.ltr,
          size: const Size(700, 260),
        ),
        (
          axis: Axis.horizontal,
          layout: NeonTimelineLayout.center,
          direction: TextDirection.rtl,
          size: const Size(700, 260),
        ),
        (
          axis: Axis.horizontal,
          layout: NeonTimelineLayout.alternating,
          direction: TextDirection.rtl,
          size: const Size(700, 260),
        ),
      ];

      for (final configuration in configurations) {
        await tester.pumpWidget(
          _host(
            size: configuration.size,
            direction: configuration.direction,
            child: NeonTimeline.builder(
              itemCount: 2,
              animate: false,
              axis: configuration.axis,
              layout: configuration.layout,
              contentBuilder: (context, details) =>
                  Text('Layout content ${details.index}'),
              oppositeContentBuilder: (context, details) =>
                  Text('Layout opposite ${details.index}'),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Layout content 0'), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason:
                '${configuration.axis}/${configuration.layout}/${configuration.direction}');
      }
    });

    testWidgets('adaptive start mirrors in RTL and centers when wide',
        (tester) async {
      Future<double> indicatorX({
        required Size size,
        required TextDirection direction,
      }) async {
        await tester.pumpWidget(
          _host(
            size: size,
            direction: direction,
            child: NeonTimeline(
              animate: false,
              items: const [
                NeonTimelineItem(content: Text('Adaptive content')),
              ],
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        return tester
            .getCenter(find.byType(NeonTimelineIndicator).first)
            .dx;
      }

      final narrowLtr = await indicatorX(
        size: const Size(320, 300),
        direction: TextDirection.ltr,
      );
      final narrowRtl = await indicatorX(
        size: const Size(320, 300),
        direction: TextDirection.rtl,
      );
      final wide = await indicatorX(
        size: const Size(800, 300),
        direction: TextDirection.ltr,
      );

      expect(narrowLtr, lessThan(80));
      expect(narrowRtl, greaterThan(240));
      expect(wide, inInclusiveRange(350, 450));
    });
  });

  group('empty state', () {
    testWidgets('emptyBuilder replaces the list and builders stay lazy',
        (tester) async {
      var contentBuilds = 0;
      await tester.pumpWidget(
        _host(
          child: NeonTimeline.builder(
            itemCount: 0,
            contentBuilder: (context, details) {
              contentBuilds++;
              return const Text('Unexpected content');
            },
            emptyBuilder: (context) => const Text('Nothing scheduled'),
          ),
        ),
      );

      expect(find.text('Nothing scheduled'), findsOneWidget);
      expect(find.text('Unexpected content'), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(contentBuilds, 0);

      await tester.pumpWidget(
        _host(child: NeonTimeline(items: const [])),
      );
      expect(find.byType(ListView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('activation and semantics', () {
    testWidgets('tap and keyboard activation invoke callback',
        (tester) async {
      var activations = 0;

      await tester.pumpWidget(
        _host(
          child: NeonTimeline(
            animate: false,
            items: [
              NeonTimelineItem(
                id: 'interactive',
                content: const Text('Open item'),
                semanticLabel: 'Open milestone',
                status: NeonTimelineStatus.active,
                onTap: () => activations++,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open item'));
      await tester.pump();
      expect(activations, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(activations, 2);
    });

    testWidgets('disabled item suppresses pointer activation',
        (tester) async {
      var activations = 0;

      await tester.pumpWidget(
        _host(
          child: NeonTimeline(
            animate: false,
            items: [
              NeonTimelineItem(
                content: const Text('Disabled item'),
                semanticLabel: 'Disabled milestone',
                status: NeonTimelineStatus.disabled,
                onTap: () => activations++,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Disabled item'));
      await tester.pump();
      // Disabled items must not fire the callback.
      expect(activations, 0);
    });
  });



  group('sliver integration', () {
    testWidgets('builder composes with CustomScrollView and remains lazy',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final built = <int>{};

      await tester.pumpWidget(
        _host(
          child: CustomScrollView(
            controller: controller,
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 40, child: Text('Before sliver')),
              ),
              NeonSliverTimeline.builder(
                itemCount: 30,
                itemExtent: 80,
                animate: false,
                layout: NeonTimelineLayout.start,
                contentBuilder: (context, details) {
                  built.add(details.index);
                  return Text('Sliver item ${details.index}');
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40, child: Text('After sliver')),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Before sliver'), findsOneWidget);
      expect(find.text('Sliver item 0'), findsOneWidget);
      expect(built.length, lessThan(30));

      controller.jumpTo(840);
      await tester.pump();
      expect(find.text('Sliver item 10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty sliver uses SliverToBoxAdapter emptyBuilder',
        (tester) async {
      await tester.pumpWidget(
        _host(
          child: CustomScrollView(
            slivers: [
              NeonSliverTimeline(
                items: const [],
                emptyBuilder: (context) => const SizedBox(
                  height: 80,
                  child: Text('No sliver items'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('No sliver items'), findsOneWidget);
      expect(find.byType(SliverToBoxAdapter), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('high-level timelines expose deterministic motion controls',
      (tester) async {
    await tester.pumpWidget(
      _host(
        child: NeonTimeline(
          motionEnabled: false,
          motionPhaseOffset: 0.375,
          animate: false,
          items: const [
            NeonTimelineItem(
              content: Text('Static cinematic item'),
              status: NeonTimelineStatus.active,
            ),
          ],
        ),
      ),
    );

    final scope = tester.widget<NeonTimelineMotionScope>(
      find.byType(NeonTimelineMotionScope),
    );
    expect(scope.enabled, isFalse);
    expect(scope.phaseOffset, 0.375);
    expect(find.text('Static cinematic item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disableAnimations removes reveal motion and stops active pulse',
      (tester) async {
    await tester.pumpWidget(
      _host(
        disableAnimations: true,
        child: NeonTimeline.builder(
          itemCount: 1,
          animate: true,
          statusBuilder: (_) => NeonTimelineStatus.active,
          contentBuilder: (context, details) =>
              const Text('Reduced-motion item'),
        ),
      ),
    );

    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Reduced-motion item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host({
  required Widget child,
  Size size = const Size(800, 600),
  TextDirection direction = TextDirection.ltr,
  bool disableAnimations = false,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? ThemeData.dark(),
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        disableAnimations: disableAnimations,
      ),
      child: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

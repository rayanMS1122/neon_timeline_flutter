import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('schedule creates content only for visible rows', (tester) async {
    final day = DateTime(2026, 7, 11);
    final entries = List<NeonScheduleEntry<int>>.generate(
      500,
      (index) => NeonScheduleEntry<int>(
        id: index,
        value: index,
        start: day.add(Duration(minutes: index * 2)),
        duration: const Duration(minutes: 1),
      ),
      growable: false,
    );
    var builtEntries = 0;

    await tester.pumpWidget(
      _host(
        NeonScheduleTimeline<int>(
          entries: entries,
          selectedDate: day,
          now: day.subtract(const Duration(days: 1)),
          motionEnabled: false,
          useDefaultCard: false,
          style: const NeonScheduleTimelineStyle(
            animateLayout: false,
            showGapLabels: false,
            showDurationRail: false,
          ),
          itemBuilder: (context, details) {
            builtEntries++;
            return Text('Entry ${details.entry.value}');
          },
        ),
      ),
    );
    await tester.pump();

    expect(builtEntries, greaterThan(0));
    expect(builtEntries, lessThan(40));
    expect(find.text('Entry 499'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlap sweep handles nested intervals', (tester) async {
    final day = DateTime(2026, 7, 11);
    final seen = <String, NeonScheduleEntryDetails<String>>{};

    await tester.pumpWidget(
      _host(
        NeonScheduleTimeline<String>(
          entries: <NeonScheduleEntry<String>>[
            NeonScheduleEntry<String>(
              id: 'long',
              value: 'long',
              start: DateTime(2026, 7, 11, 9),
              duration: const Duration(hours: 3),
            ),
            NeonScheduleEntry<String>(
              id: 'short-a',
              value: 'short-a',
              start: DateTime(2026, 7, 11, 10),
              duration: const Duration(minutes: 15),
            ),
            NeonScheduleEntry<String>(
              id: 'short-b',
              value: 'short-b',
              start: DateTime(2026, 7, 11, 11),
              duration: const Duration(minutes: 15),
            ),
          ],
          selectedDate: day,
          now: day.subtract(const Duration(days: 1)),
          motionEnabled: false,
          useDefaultCard: false,
          style: const NeonScheduleTimelineStyle(
            animateLayout: false,
            showDurationRail: false,
          ),
          itemBuilder: (context, details) {
            seen[details.entry.value] = details;
            return Text(details.entry.value);
          },
        ),
      ),
    );
    await tester.pump();

    expect(seen['short-a']?.overlapsPrevious, isTrue);
    expect(seen['short-b']?.overlapsPrevious, isTrue);
    expect(seen['long']?.overlapsNext, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('schedule caps continuously animated rows', (tester) async {
    final day = DateTime(2026, 7, 11);

    await tester.pumpWidget(
      _host(
        NeonScheduleTimeline<String>(
          entries: <NeonScheduleEntry<String>>[
            NeonScheduleEntry<String>(
              id: 'active-a',
              value: 'A',
              start: DateTime(2026, 7, 11, 9),
              status: NeonTimelineStatus.active,
            ),
            NeonScheduleEntry<String>(
              id: 'active-b',
              value: 'B',
              start: DateTime(2026, 7, 11, 10),
              status: NeonTimelineStatus.active,
            ),
          ],
          selectedDate: day,
          now: day.subtract(const Duration(days: 1)),
          maxAnimatedEntries: 1,
          itemBuilder: (context, details) => Text(details.entry.value),
        ),
      ),
    );
    await tester.pump();

    final indicators = tester
        .widgetList<NeonTimelineIndicator>(
          find.byType(NeonTimelineIndicator),
        )
        .toList(growable: false);
    expect(indicators.where((indicator) => indicator.animate), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  test('tuneTheme can disable connector packets without asserting', () {
    const resolved = NeonTimelineResolvedPerformance(
      motionFramesPerSecond: 12,
      maxAnimatedEntries: 0,
      pauseMotionWhileScrolling: true,
      enableBackdropBlur: false,
      enableParallax: false,
      enableParticles: false,
      cacheExtent: 80,
      motionStartupDelay: Duration(milliseconds: 220),
      webGlowStrategy: NeonTimelineWebGlowStrategy.layeredContours,
      renderQuality: NeonTimelineRenderQuality.balanced,
      reduceMotion: false,
    );

    final tuned = resolved.tuneTheme(const NeonTimelineThemeData());

    expect(tuned.indicatorStyle.particleCount, 0);
    expect(tuned.connectorStyle.packetCount, 0);
  });

  testWidgets('shared motion publishes at the configured sample rate',
      (tester) async {
    var notifications = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: NeonTimelineMotionScope(
          framesPerSecond: 20,
          pauseWhenScrolling: false,
          child: Builder(
            builder: (context) {
              final animation =
                  NeonTimelineMotionScope.maybeOf(context)!.animation;
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  notifications++;
                  return const SizedBox();
                },
              );
            },
          ),
        ),
      ),
    );

    for (var index = 0; index < 100; index++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(notifications, inInclusiveRange(15, 30));
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

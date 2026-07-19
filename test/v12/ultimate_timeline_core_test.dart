import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v12.dart';

void main() {
  test('production config exposes coherent semantic zoom metrics', () {
    const config = UltimateStructuredTimelineConfig.production();
    expect(config.zoomLevel, UltimateTimelineZoomLevel.comfortable);
    expect(config.zoomMetrics.minimumEntryHeight, greaterThanOrEqualTo(48));
    expect(config.interaction.longPressDuration.inMilliseconds, lessThan(300));
  });

  test('weighted snap prefers a conflict-free neighbour boundary', () {
    final day = DateTime(2026, 7, 17);
    final moving = TimelineEntry<String>(
      id: 'moving',
      value: 'moving',
      start: day.add(const Duration(hours: 8)),
      duration: const Duration(minutes: 30),
    );
    final next = TimelineEntry<String>(
      id: 'next',
      value: 'next',
      start: day.add(const Duration(hours: 9, minutes: 30)),
      duration: const Duration(hours: 1),
    );
    const engine = UltimateTimelineSnapEngine<String>();
    final result = engine.resolve(
      UltimateTimelineSnapRequest<String>(
        entry: moving,
        rawStart: day.add(const Duration(hours: 9, minutes: 4)),
        bounds: TimelineDateRange(day, day.add(const Duration(days: 1))),
        entries: [next],
        direction: UltimateTimelinePointerDirection.forward,
      ),
    );

    expect(result.start, day.add(const Duration(hours: 9)));
    expect(result.target.kind, UltimateTimelineSnapKind.nextStart);
    expect(result.conflicts, isEmpty);
    expect(result.allowed, isTrue);
  });

  test('snap hysteresis retains the effective target without flicker', () {
    final day = DateTime(2026, 7, 17);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'entry',
      start: day,
      duration: const Duration(minutes: 30),
    );
    const engine = UltimateTimelineSnapEngine<String>();
    final first = engine.resolve(
      UltimateTimelineSnapRequest<String>(
        entry: entry,
        rawStart: day.add(const Duration(hours: 10)),
        bounds: TimelineDateRange(day, day.add(const Duration(days: 1))),
        entries: const [],
      ),
    );
    final retained = engine.resolve(
      UltimateTimelineSnapRequest<String>(
        entry: entry,
        rawStart: day.add(const Duration(hours: 10, minutes: 1)),
        bounds: TimelineDateRange(day, day.add(const Duration(days: 1))),
        entries: const [],
        previousResult: first,
      ),
    );

    expect(retained.start, first.start);
    expect(retained.retainedByHysteresis, isTrue);
  });

  test('focus-aware gaps preserve more detail near focus', () {
    const layout = UltimateTimelineGapLayout.focusAware();
    final near = layout.extentFor(
      const Duration(hours: 4),
      distanceFromFocus: const Duration(minutes: 20),
    );
    final far = layout.extentFor(
      const Duration(hours: 4),
      distanceFromFocus: const Duration(hours: 8),
    );
    final active = layout.extentFor(
      const Duration(hours: 4),
      distanceFromFocus: const Duration(hours: 8),
      activeDropTarget: true,
    );

    expect(near, greaterThan(far));
    expect(active, greaterThanOrEqualTo(far));
  });

  test('availability reports working-time and blocked-range reasons', () {
    final day = DateTime(2026, 7, 17);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'entry',
      start: day,
    );
    final rules = UltimateTimelineAvailabilityRules(
      workingHours: const [
        UltimateTimelineWorkingHours(weekday: DateTime.friday),
      ],
      blockedRanges: [
        UltimateTimelineBlockedRange(
          range: TimelineDateRange(
            day.add(const Duration(hours: 12)),
            day.add(const Duration(hours: 13)),
          ),
          reason: 'Lunch break',
        ),
      ],
    );

    expect(
      rules
          .validate(
            entry,
            day.add(const Duration(hours: 7)),
            day.add(const Duration(hours: 8)),
          )
          .reason,
      'outsideWorkingHours',
    );
    expect(
      rules
          .validate(
            entry,
            day.add(const Duration(hours: 12, minutes: 15)),
            day.add(const Duration(hours: 12, minutes: 45)),
          )
          .reason,
      'Lunch break',
    );
  });

  test('resize remains correct across midnight', () {
    final day = DateTime(2026, 7, 17);
    final entry = TimelineEntry<String>(
      id: 'overnight',
      value: 'overnight',
      start: day.add(const Duration(hours: 23, minutes: 24)),
      duration: const Duration(minutes: 55),
    );
    final session = UltimateTimelineResizeSession<String>(
      entry: entry,
      edge: TimelineResizeEdge.end,
      bounds: TimelineDateRange(day, day.add(const Duration(days: 2))),
      entries: [entry],
    );
    final preview = session.update(const Duration(minutes: 5));

    expect(preview.duration, const Duration(minutes: 60));
    expect(preview.end.day, day.day + 1);
    expect(preview.end.hour, 0);
    expect(preview.end.minute, 24);
  });

  test('auto-scroll uses a calm nonlinear edge curve', () {
    const config = UltimateTimelineAutoScrollConfig();
    final center = config.velocityFor(pointer: 400, viewportExtent: 800);
    final shallow = config.velocityFor(pointer: 40, viewportExtent: 800);
    final edge = config.velocityFor(pointer: 0, viewportExtent: 800);

    expect(center, 0);
    expect(shallow, lessThan(0));
    expect(edge.abs(), greaterThan(shallow.abs()));
    expect(edge.abs(), lessThanOrEqualTo(config.maximumVelocity));
  });

  testWidgets('public drag feedback exposes non-color semantics', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 17);
    await tester.pumpWidget(
      MaterialApp(
        home: UltimateTimelineTheme(
          data: UltimateTimelineThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          child: UltimateTimelineDragFeedback<String>(
            start: day.add(const Duration(hours: 10, minutes: 30)),
            end: day.add(const Duration(hours: 11, minutes: 15)),
            timeFormatter: (value) =>
                '${value.hour}:${value.minute.toString().padLeft(2, '0')}',
            allowed: false,
            blockReason: 'Outside working hours',
            child: const SizedBox(width: 220, height: 80),
          ),
        ),
      ),
    );

    expect(find.text('Outside working hours'), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
  });
}

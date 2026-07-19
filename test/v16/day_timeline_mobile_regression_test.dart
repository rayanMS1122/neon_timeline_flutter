import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  final day = DateTime(2026, 7, 3);

  for (final width in <double>[320, 360, 375, 390, 412, 480, 768]) {
    testWidgets('mobile timeline has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          width: width,
          child: _timeline(day: day),
        ),
      );
      await tester.pump();

      final surface = find.byKey(
        const ValueKey<String>('neon-day-timeline-surface'),
      );
      expect(surface, findsOneWidget);
      expect(tester.getSize(surface).width, lessThanOrEqualTo(width));
      expect(tester.takeException(), isNull);

      final entryIcon = tester.widget<Icon>(
        find.byIcon(Icons.work_rounded).first,
      );
      final firstRow = find.byKey(const ValueKey<Object>('first'));
      if (width <= 360) {
        expect(entryIcon.size, lessThanOrEqualTo(15));
        expect(tester.getSize(firstRow).height, lessThanOrEqualTo(52));
        expect(
          tester.getSize(find.textContaining('Sehr langer')).width,
          greaterThan(120),
        );
      } else if (width <= 480) {
        expect(entryIcon.size, lessThanOrEqualTo(16));
        expect(tester.getSize(firstRow).height, lessThanOrEqualTo(58));
      }
    });
  }


  testWidgets('mobile chrome keeps small visuals and full touch targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        width: 390,
        child: _timeline(day: day),
      ),
    );
    await tester.pump();

    final calendarIcon = tester.widget<Icon>(
      find.byIcon(Icons.calendar_today_outlined),
    );
    final metricIcon = tester.widget<Icon>(
      find.byIcon(Icons.bedtime_outlined),
    );
    expect(calendarIcon.size, lessThanOrEqualTo(15));
    expect(metricIcon.size, lessThanOrEqualTo(11));
    expect(
      tester.getSize(find.byTooltip('Kalender öffnen')).height,
      greaterThanOrEqualTo(44),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('200 percent text remains bounded on a 320 px timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        width: 320,
        textScaler: const TextScaler.linear(2),
        child: _timeline(day: day),
      ),
    );
    await tester.pump();

    final surface = find.byKey(
      const ValueKey<String>('neon-day-timeline-surface'),
    );
    expect(tester.getSize(surface).width, lessThanOrEqualTo(320));
    expect(find.textContaining('Sehr langer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag keeps row geometry and feedback inside the timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        width: 320,
        child: _timeline(
          day: day,
          chrome: false,
          dragActivation: NeonPlannerDragActivation.immediate,
          onMove: (_) => const NeonPlannerMutationResult.accepted(),
        ),
      ),
    );
    await tester.pump();

    final first = find.byKey(const ValueKey<Object>('first'));
    final secondTitle = find.text('Zweiter paralleler Termin');
    final firstSize = tester.getSize(first);
    final secondRect = tester.getRect(secondTitle);
    final surfaceRect = tester.getRect(
      find.byKey(const ValueKey<String>('neon-day-timeline-surface')),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('Sehr langer')),
    );
    await gesture.moveBy(const Offset(120, 44));
    await tester.pump();

    expect(tester.getSize(first), firstSize);
    expect(tester.getRect(secondTitle), secondRect);
    final feedbackRect = tester.getRect(
      find.byKey(const ValueKey<String>('neon-drag-feedback')),
    );
    expect(feedbackRect.width, lessThanOrEqualTo(172));
    expect(feedbackRect.left, greaterThanOrEqualTo(surfaceRect.left));
    expect(feedbackRect.right, lessThanOrEqualTo(surfaceRect.right));
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag feedback follows horizontal pointer movement', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        width: 390,
        child: _timeline(
          day: day,
          chrome: false,
          dragActivation: NeonPlannerDragActivation.immediate,
          onMove: (_) => const NeonPlannerMutationResult.accepted(),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('Sehr langer')),
    );
    await gesture.moveBy(const Offset(0, 1));
    await tester.pump();

    final feedback = find.byKey(
      const ValueKey<String>('neon-drag-feedback'),
    );
    final initialRect = tester.getRect(feedback);

    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    final rightRect = tester.getRect(feedback);
    expect(rightRect.left, greaterThan(initialRect.left));

    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();
    final leftRect = tester.getRect(feedback);
    expect(leftRect.left, lessThan(rightRect.left));
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('drag feedback stays inside the safe area', (tester) async {
    const safePadding = EdgeInsets.only(top: 24, bottom: 34);
    await tester.pumpWidget(
      _host(
        width: 320,
        viewPadding: safePadding,
        child: _timeline(
          day: day,
          chrome: false,
          dragActivation: NeonPlannerDragActivation.immediate,
          onMove: (_) => const NeonPlannerMutationResult.accepted(),
        ),
      ),
    );
    await tester.pump();

    final surfaceRect = tester.getRect(
      find.byKey(const ValueKey<String>('neon-day-timeline-surface')),
    );
    final screenRect = tester.getRect(find.byType(Scaffold));
    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('Sehr langer')),
    );
    await gesture.moveTo(Offset(surfaceRect.center.dx, screenRect.bottom - 2));
    await tester.pump();

    var feedbackRect = tester.getRect(
      find.byKey(const ValueKey<String>('neon-drag-feedback')),
    );
    expect(
      feedbackRect.bottom,
      lessThanOrEqualTo(screenRect.bottom - safePadding.bottom - 8),
    );

    await gesture.moveTo(Offset(surfaceRect.center.dx, screenRect.top + 2));
    await tester.pump();
    feedbackRect = tester.getRect(
      find.byKey(const ValueKey<String>('neon-drag-feedback')),
    );
    expect(
      feedbackRect.top,
      greaterThanOrEqualTo(screenRect.top + safePadding.top + 8),
    );
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('resize keeps neighboring rows fixed', (tester) async {
    await tester.pumpWidget(
      _host(
        width: 320,
        child: _timeline(
          day: day,
          chrome: false,
          onResize: (_) => const NeonPlannerMutationResult.accepted(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.textContaining('Sehr langer'));
    await tester.pump();

    final first = find.byKey(const ValueKey<Object>('first'));
    final secondTitle = find.text('Zweiter paralleler Termin');
    final firstSize = tester.getSize(first);
    final secondRect = tester.getRect(secondTitle);
    final handle = find.byKey(
      const ValueKey<String>('neon-resize-end-first'),
    );
    expect(handle, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(0, 32));
    await tester.pump();

    expect(tester.getSize(first), firstSize);
    expect(tester.getRect(secondTitle), secondRect);
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'micro time lens is compact and respects reduced motion',
    (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        width: 320,
        disableAnimations: true,
        child: _timeline(
          day: day,
          chrome: false,
          dragActivation: NeonPlannerDragActivation.immediate,
          onMove: (_) => const NeonPlannerMutationResult.accepted(),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('Sehr langer')),
    );
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();

    final lens = find.byKey(
      const ValueKey<String>('neon-adaptive-time-lens'),
    );
    expect(lens, findsOneWidget);
    expect(tester.getSize(lens).height, lessThanOrEqualTo(26));
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('neon-move-confirmation')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _host({
  required double width,
  required Widget child,
  TextScaler textScaler = TextScaler.noScaling,
  EdgeInsets viewPadding = EdgeInsets.zero,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          height: 1000,
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 1000),
              textScaler: textScaler,
              viewPadding: viewPadding,
              disableAnimations: disableAnimations,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

Widget _timeline({
  required DateTime day,
  bool chrome = true,
  NeonPlannerDragActivation dragActivation =
      NeonPlannerDragActivation.longPress,
  NeonPlannerDayMoveCallback<_MobileEntry>? onMove,
  NeonPlannerDayResizeCallback<_MobileEntry>? onResize,
}) {
  return NeonPlannerDayTimeline<_MobileEntry>(
    entries: _entries(day),
    adapter: const _MobileAdapter(),
    selectedDate: day,
    fit: NeonPlannerDayFit.content,
    showGrabber: chrome,
    showHeader: chrome,
    showMetrics: chrome,
    currentTime: day.add(const Duration(hours: 8, minutes: 40)),
    metrics: const <NeonPlannerDayMetric>[
      NeonPlannerDayMetric(
        label: 'Termine',
        value: '3',
        helper: 'geplant',
        icon: Icons.check_circle_outline_rounded,
      ),
      NeonPlannerDayMetric(
        label: 'Schlaf',
        value: '7h 30m',
        helper: 'gesamt',
        icon: Icons.bedtime_outlined,
      ),
      NeonPlannerDayMetric(
        label: 'Fokus',
        value: '3h',
        helper: 'heute',
        icon: Icons.center_focus_strong_rounded,
      ),
    ],
    dragActivation: dragActivation,
    onEntryMove: onMove,
    onEntryResize: onResize,
  );
}

List<_MobileEntry> _entries(DateTime day) {
  return <_MobileEntry>[
    _MobileEntry(
      id: 'first',
      title: 'Sehr langer deutscher Terminname für die mobile Timeline',
      subtitle: 'Primäre Metadaten bleiben nur sichtbar, '
          'wenn Platz vorhanden ist.',
      start: day.add(const Duration(hours: 8)),
      end: day.add(const Duration(hours: 9)),
      completion: 0.6,
    ),
    _MobileEntry(
      id: 'second',
      title: 'Zweiter paralleler Termin',
      subtitle: 'Overlap-Test',
      start: day.add(const Duration(hours: 8, minutes: 30)),
      end: day.add(const Duration(hours: 9, minutes: 15)),
      completion: 0.25,
    ),
    _MobileEntry(
      id: 'third',
      title: 'Nachmittagstermin',
      subtitle: 'Keine Kollision',
      start: day.add(const Duration(hours: 13)),
      end: day.add(const Duration(hours: 13, minutes: 30)),
      completion: null,
    ),
  ];
}

@immutable
class _MobileEntry {
  const _MobileEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.end,
    required this.completion,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime start;
  final DateTime end;
  final double? completion;
}

class _MobileAdapter extends NeonPlannerEntryAdapter<_MobileEntry> {
  const _MobileAdapter();

  @override
  Object idOf(_MobileEntry entry) => entry.id;

  @override
  DateTime startOf(_MobileEntry entry) => entry.start;

  @override
  DateTime endOf(_MobileEntry entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_MobileEntry entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      subtitle: entry.subtitle,
      metadata: 'Erinnerung aktiviert',
      icon: Icons.work_rounded,
      kind: NeonPlannerEntryKind.appointment,
      completion: entry.completion,
    );
  }
}

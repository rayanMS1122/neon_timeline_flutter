import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  testWidgets('advanced compact timeline API renders overlap and current state', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_Entry>[
      _Entry(
        id: 'a',
        title: 'Design Review',
        start: day.add(const Duration(hours: 9)),
        end: day.add(const Duration(hours: 10)),
      ),
      _Entry(
        id: 'b',
        title: 'Parallel Call',
        start: day.add(const Duration(hours: 9, minutes: 30)),
        end: day.add(const Duration(hours: 10, minutes: 30)),
      ),
      _Entry(
        id: 'c',
        title: 'Independent Task',
        start: day.add(const Duration(hours: 15)),
        end: day.add(const Duration(hours: 15, minutes: 30)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NeonPlannerDayTimeline<_Entry>(
              entries: entries,
              adapter: const _Adapter(),
              selectedDate: day,
              currentTime: day.add(const Duration(hours: 9, minutes: 40)),
              fit: NeonPlannerDayFit.content,
              density: NeonPlannerDayDensity.compact,
              overlapPresentation: NeonPlannerOverlapPresentation.stacked,
              dragActivation: NeonPlannerDragActivation.immediate,
              onEntryMove: (_) =>
                  const NeonPlannerMutationResult.accepted(),
              onEntryResize: (_) =>
                  const NeonPlannerMutationResult.accepted(),
              onUndoMove: (_) =>
                  const NeonPlannerMutationResult.accepted(),
              onEntryTimeEdit: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('1/3'), findsNothing);
    expect(find.text('Independent Task'), findsOneWidget);
    expect(find.text('Jetzt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard movement emits a snapped move proposal', (tester) async {
    final day = DateTime(2026, 7, 3);
    final entry = _Entry(
      id: 'a',
      title: 'Keyboard Task',
      start: day.add(const Duration(hours: 9)),
      end: day.add(const Duration(hours: 9, minutes: 30)),
    );
    NeonPlannerMoveProposal<_Entry>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 700,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: <_Entry>[entry],
              adapter: const _Adapter(),
              selectedDate: day,
              snapInterval: const Duration(minutes: 5),
              onEntryMove: (proposal) {
                received = proposal;
                return const NeonPlannerMutationResult.accepted();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Keyboard Task'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(received, isNotNull);
    expect(received!.proposedStart, day.add(const Duration(hours: 9, minutes: 5)));
  });

  testWidgets('selected entry exposes resize handles and emits proposal', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entry = _Entry(
      id: 'a',
      title: 'Resizable Task',
      start: day.add(const Duration(hours: 9)),
      end: day.add(const Duration(hours: 9, minutes: 30)),
    );
    NeonPlannerResizeProposal<_Entry>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 700,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: <_Entry>[entry],
              adapter: const _Adapter(),
              selectedDate: day,
              dragMinutesPerPixel: 1,
              snapInterval: const Duration(minutes: 5),
              onEntryResize: (proposal) {
                received = proposal;
                return const NeonPlannerMutationResult.accepted();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Resizable Task'));
    await tester.pump();

    final handle = find.byKey(const ValueKey<String>('neon-resize-end-a'));
    expect(handle, findsOneWidget);
    await tester.drag(handle, const Offset(0, 30));
    await tester.pumpAndSettle();

    expect(received, isNotNull);
    expect(received!.proposedEnd, day.add(const Duration(hours: 10)));
  });

  testWidgets('Alt plus arrow resizes the selected entry end', (tester) async {
    final day = DateTime(2026, 7, 3);
    final entry = _Entry(
      id: 'a',
      title: 'Keyboard Resize',
      start: day.add(const Duration(hours: 9)),
      end: day.add(const Duration(hours: 9, minutes: 30)),
    );
    NeonPlannerResizeProposal<_Entry>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 700,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: <_Entry>[entry],
              adapter: const _Adapter(),
              selectedDate: day,
              snapInterval: const Duration(minutes: 5),
              onEntryResize: (proposal) {
                received = proposal;
                return const NeonPlannerMutationResult.accepted();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Keyboard Resize'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pump();

    expect(received, isNotNull);
    expect(
      received!.proposedEnd,
      day.add(const Duration(hours: 9, minutes: 35)),
    );
  });

  testWidgets('smart fit keeps a short day visually compact in a tall parent', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entry = _Entry(
      id: 'a',
      title: 'Short Day',
      start: day.add(const Duration(hours: 9)),
      end: day.add(const Duration(hours: 9, minutes: 30)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 1100,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: <_Entry>[entry],
              adapter: const _Adapter(),
              selectedDate: day,
              fit: NeonPlannerDayFit.smart,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    final surface = find.byKey(
      const ValueKey<String>('neon-day-timeline-surface'),
    );
    expect(surface, findsOneWidget);
    expect(tester.getSize(surface).height, lessThan(1000));
  });

  testWidgets('empty timeline offers an optional create action', (tester) async {
    var tapped = false;
    final day = DateTime(2026, 7, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 600,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: const <_Entry>[],
              adapter: const _Adapter(),
              selectedDate: day,
              onCreateTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Freier Tag'), findsOneWidget);
    await tester.tap(find.text('Termin erstellen'));
    expect(tapped, isTrue);
  });
}

@immutable
class _Entry {
  const _Entry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
}

class _Adapter extends NeonPlannerEntryAdapter<_Entry> {
  const _Adapter();

  @override
  Object idOf(_Entry entry) => entry.id;

  @override
  DateTime startOf(_Entry entry) => entry.start;

  @override
  DateTime endOf(_Entry entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_Entry entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      icon: Icons.event_rounded,
      kind: NeonPlannerEntryKind.appointment,
    );
  }
}

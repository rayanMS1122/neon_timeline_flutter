import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  testWidgets('compact day timeline renders reference structure', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_Entry>[
      _Entry(
        id: 'sleep',
        title: 'Schlafen gehen',
        start: day,
        end: day.add(const Duration(minutes: 1)),
        kind: NeonPlannerEntryKind.sleep,
        icon: Icons.nightlight_round,
      ),
      _Entry(
        id: 'meeting',
        title: 'Termin um 11:15',
        start: day.add(const Duration(hours: 6, minutes: 40)),
        end: day.add(const Duration(hours: 6, minutes: 55)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 1000,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: entries,
              adapter: const _Adapter(),
              selectedDate: day,
              metrics: const <NeonPlannerDayMetric>[
                NeonPlannerDayMetric(
                  label: 'Termine',
                  value: '1',
                  helper: 'geplant',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
              entryDurationLabelBuilder: (entry, duration) =>
                  entry.id == 'sleep' ? '7h 00m' : '15 Min.',
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Do, 03. Juli 2026'), findsOneWidget);
    expect(find.text('Termine'), findsOneWidget);
    expect(find.text('Schlafen gehen'), findsOneWidget);
    expect(find.text('Termin um 11:15'), findsOneWidget);
    expect(find.textContaining('Nachtruhe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact time dragging exposes drag sources without block drop zones', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_Entry>[
      _Entry(
        id: 'first',
        title: 'Erster Termin',
        start: day.add(const Duration(hours: 8)),
        end: day.add(const Duration(hours: 8, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
      _Entry(
        id: 'second',
        title: 'Zweiter Termin',
        start: day.add(const Duration(hours: 11)),
        end: day.add(const Duration(hours: 11, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 900,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: entries,
              adapter: const _Adapter(),
              selectedDate: day,
              dragActivation: NeonPlannerDragActivation.immediate,
              onEntryMove: (proposal) =>
                  const NeonPlannerMutationResult.accepted(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byWidgetPredicate((widget) => widget is Draggable<Object>),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is DragTarget<Object>),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });


  testWidgets('time drag emits a snapped overlap proposal', (tester) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_Entry>[
      _Entry(
        id: 'first',
        title: 'Erster Termin',
        start: day.add(const Duration(hours: 8)),
        end: day.add(const Duration(hours: 8, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
      _Entry(
        id: 'second',
        title: 'Zweiter Termin',
        start: day.add(const Duration(hours: 11)),
        end: day.add(const Duration(hours: 11, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
    ];
    NeonPlannerMoveProposal<_Entry>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 900,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: entries,
              adapter: const _Adapter(),
              selectedDate: day,
              dragActivation: NeonPlannerDragActivation.immediate,
              dragMode: NeonPlannerDayDragMode.time,
              dragMinutesPerPixel: 0.75,
              snapInterval: const Duration(minutes: 5),
              conflictPolicy: NeonPlannerConflictPolicy.allow,
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
    await tester.drag(find.text('Erster Termin'), const Offset(0, 240));
    await tester.pumpAndSettle();

    expect(received, isNotNull);
    expect(received!.proposedStart, day.add(const Duration(hours: 11)));
    expect(received!.hasConflict, isTrue);
  });

  testWidgets('slot mode keeps explicit drop targets available', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_Entry>[
      _Entry(
        id: 'first',
        title: 'Erster Termin',
        start: day.add(const Duration(hours: 8)),
        end: day.add(const Duration(hours: 8, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
      _Entry(
        id: 'second',
        title: 'Zweiter Termin',
        start: day.add(const Duration(hours: 11)),
        end: day.add(const Duration(hours: 11, minutes: 15)),
        kind: NeonPlannerEntryKind.appointment,
        icon: Icons.groups_rounded,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 900,
            child: NeonPlannerDayTimeline<_Entry>(
              entries: entries,
              adapter: const _Adapter(),
              selectedDate: day,
              dragMode: NeonPlannerDayDragMode.slots,
              dragActivation: NeonPlannerDragActivation.immediate,
              onEntryMove: (proposal) =>
                  const NeonPlannerMutationResult.accepted(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(
      find.byWidgetPredicate((widget) => widget is DragTarget<Object>),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

}

@immutable
class _Entry {
  const _Entry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.kind,
    required this.icon,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final NeonPlannerEntryKind kind;
  final IconData icon;
}

class _Adapter extends NeonPlannerEntryAdapter<_Entry> {
  const _Adapter();

  @override
  DateTime endOf(_Entry entry) => entry.end;

  @override
  Object idOf(_Entry entry) => entry.id;

  @override
  NeonPlannerEntryPresentation presentationOf(_Entry entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      icon: entry.icon,
      kind: entry.kind,
    );
  }

  @override
  DateTime startOf(_Entry entry) => entry.start;
}

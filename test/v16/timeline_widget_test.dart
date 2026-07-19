import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  final day = DateTime(2026, 7, 18);
  const adapter = _Adapter();

  testWidgets('renders the timeline and virtualizes entry widgets', (tester) async {
    final entries = List<_Item>.generate(1000, (index) {
      final start = day.add(Duration(minutes: index * 5));
      return _Item(
        id: '$index',
        title: 'Task $index',
        start: start,
        end: start.add(const Duration(minutes: 5)),
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            width: 420,
            child: NeonPlannerTimeline<_Item>(
              entries: entries,
              adapter: adapter,
              selectedDate: day,
              config: const NeonPlannerTimelineConfig.production(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NeonPlannerTimeline<_Item>), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsWidgets);
    expect(find.byIcon(Icons.bookmark_rounded).evaluate().length, lessThan(200));
  });

  testWidgets('exposes labeled, adequately sized interactive targets', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final entries = <_Item>[
      _Item(
        id: 'one',
        title: 'Accessible event',
        start: day.add(const Duration(hours: 9)),
        end: day.add(const Duration(hours: 10)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            width: 420,
            child: NeonPlannerTimeline<_Item>(
              entries: entries,
              adapter: adapter,
              selectedDate: day,
              onEntryTap: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Accessible event, 09:00–10:00, 1 Std.'),
      findsOneWidget,
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('supports 200 percent text scaling without overflow', (
    tester,
  ) async {
    final entries = <_Item>[
      _Item(
        id: 'one',
        title: 'A long event title that must adapt to limited space',
        start: day.add(const Duration(hours: 9)),
        end: day.add(const Duration(hours: 10)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              height: 600,
              width: 380,
              child: NeonPlannerTimeline<_Item>(
                entries: entries,
                adapter: adapter,
                selectedDate: day,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

@immutable
class _Item {
  const _Item({
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

class _Adapter extends NeonPlannerEntryAdapter<_Item> {
  const _Adapter();

  @override
  Object idOf(_Item entry) => entry.id;

  @override
  DateTime startOf(_Item entry) => entry.start;

  @override
  DateTime endOf(_Item entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_Item entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      icon: Icons.bookmark_rounded,
    );
  }
}

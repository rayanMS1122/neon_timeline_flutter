import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('CalendarDayView lays out overlapping entries', (tester) async {
    final day = DateTime(2026, 7, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 700,
            child: TimelineTheme(
              data: TimelineThemeData.modern(),
              child: CalendarDayView<String>(
                entries: <TimelineEntry<String>>[
                  TimelineEntry<String>(
                    id: 'a',
                    value: 'Architecture',
                    start: DateTime(2026, 7, 13, 9),
                    duration: const Duration(hours: 2),
                  ),
                  TimelineEntry<String>(
                    id: 'b',
                    value: 'Design',
                    start: DateTime(2026, 7, 13, 9, 30),
                    duration: const Duration(hours: 1),
                  ),
                ],
                selectedDate: day,
                now: DateTime(2026, 7, 13, 10),
                startHour: 8,
                endHour: 13,
                itemBuilder: (context, details) => ColoredBox(
                  color: Colors.blue,
                  child: Text(details.entryDetails.entry.value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Architecture'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ResourceTimelineView renders resource assignments', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: TimelineTheme(
              data: TimelineThemeData.enterprise(),
              child: ResourceTimelineView<String>(
                resources: const <TimelineResource>[
                  TimelineResource(id: 'room', label: 'Room A'),
                ],
                entries: <TimelineEntry<String>>[
                  TimelineEntry<String>(
                    id: 'meeting',
                    value: 'Planning meeting',
                    start: DateTime(2026, 7, 13, 9),
                    duration: const Duration(hours: 1),
                    resourceIds: const <Object>{'room'},
                  ),
                ],
                selectedDate: day,
                startHour: 8,
                endHour: 12,
                itemBuilder: (context, details) =>
                    Text(details.entryDetails.entry.value),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Room A'), findsOneWidget);
    expect(find.text('Planning meeting'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('advanced fallbacks use host-supplied localization', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineLocalization(
          data: const TimelineLocalizationData(
            resourcesLabel: 'Ressourcen',
            noResourcesConfigured: 'Keine Ressourcen konfiguriert',
            noEntriesInTimeRange: 'Keine Einträge in diesem Zeitraum',
          ),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: CalendarDayView<String>(
                    entries: const <TimelineEntry<String>>[],
                    selectedDate: DateTime(2026, 7, 13),
                    itemBuilder: (context, details) => const SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: ResourceTimelineView<String>(
                    resources: const <TimelineResource>[],
                    entries: const <TimelineEntry<String>>[],
                    selectedDate: DateTime(2026, 7, 13),
                    itemBuilder: (context, details) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Keine Einträge in diesem Zeitraum'), findsOneWidget);
    expect(find.text('Keine Ressourcen konfiguriert'), findsOneWidget);
  });

  testWidgets('TimelineWorkspace switches destinations', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return TimelineTheme(
              data: TimelineThemeData.softProfessional(),
              child: TimelineWorkspace(
                destinations: const <TimelineWorkspaceDestination>[
                  TimelineWorkspaceDestination(
                    label: 'Day',
                    icon: Icons.today_outlined,
                  ),
                  TimelineWorkspaceDestination(
                    label: 'Roadmap',
                    icon: Icons.route_outlined,
                  ),
                ],
                selectedIndex: selected,
                onDestinationSelected: (value) {
                  setState(() => selected = value);
                },
                body: Text('Page $selected'),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Page 0'), findsOneWidget);
    await tester.tap(find.text('Roadmap'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
  });

  testWidgets('DependencyTimelineView renders graph layers and connectors', (
    tester,
  ) async {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'foundation',
        value: 'Foundation',
        start: DateTime(2026, 7, 13, 9),
        duration: const Duration(hours: 1),
      ),
      TimelineEntry<String>(
        id: 'ui',
        value: 'Advanced UI',
        start: DateTime(2026, 7, 13, 10),
        duration: const Duration(hours: 1),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 420,
            child: TimelineTheme(
              data: TimelineThemeData.aurora(),
              child: DependencyTimelineView<String>(
                entries: entries,
                dependencies: const <TimelineDependency>[
                  TimelineDependency(
                    id: 'foundation-ui',
                    predecessorId: 'foundation',
                    successorId: 'ui',
                  ),
                ],
                itemBuilder: (context, details) => TimelineCard(
                  title: details.entryDetails.entry.value,
                  category: 'Layer ${details.depth + 1}',
                  timeLabel: '10:00',
                  status: TimelineStatus.active,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Foundation'), findsOneWidget);
    expect(find.text('Advanced UI'), findsOneWidget);
    expect(find.text('Layer 1'), findsOneWidget);
    expect(find.text('Layer 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v15.dart';

void main() {
  testWidgets('time range slider supports narrow large-text layouts', (tester) async {
    final day = DateTime(2026, 7, 18);
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: scheme),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 360,
              child: UltraTimelineTheme(
                data: UltraTimelineThemeData.fromColorScheme(scheme),
                child: UltraTimeRangeSlider(
                  range: UltraTimeRange(
                    start: day.add(const Duration(hours: 9)),
                    end: day.add(const Duration(hours: 10)),
                  ),
                  bounds: UltraTimeRange(
                    start: day.add(const Duration(hours: 6)),
                    end: day.add(const Duration(hours: 22)),
                  ),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('1h'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

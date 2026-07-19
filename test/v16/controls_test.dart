import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  testWidgets('zoom slider changes semantic level', (tester) async {
    var value = NeonPlannerZoomLevel.balanced;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 400,
            child: NeonPlannerZoomSlider(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(value, NeonPlannerZoomLevel.comfortable);
  });

  testWidgets('time range slider enforces minimum duration', (tester) async {
    var start = const Duration(hours: 8);
    var end = const Duration(hours: 9);
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 400,
            child: NeonPlannerTimeRangeSlider(
              minimum: const Duration(hours: 6),
              maximum: const Duration(hours: 22),
              start: start,
              end: end,
              minimumDuration: const Duration(minutes: 30),
              onChanged: (nextStart, nextEnd) => setState(() {
                start = nextStart;
                end = nextEnd;
              }),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(NeonPlannerTimeRangeSlider), const Offset(250, 0));
    await tester.pump();
    expect(end - start, greaterThanOrEqualTo(const Duration(minutes: 30)));
  });
}

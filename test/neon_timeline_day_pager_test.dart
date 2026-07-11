import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('left and right swipes change the selected day', (tester) async {
    var selected = DateTime(2026, 7, 11);

    Widget build() {
      return MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return NeonTimelineDayPager(
                selectedDate: selected,
                haptics: false,
                onDateChanged: (value) => setState(() => selected = value),
                child: const SizedBox.expand(child: Text('Timeline')),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(build());
    await tester.drag(find.text('Timeline'), const Offset(-180, 0));
    await tester.pumpAndSettle();
    expect(selected, DateTime(2026, 7, 12));

    await tester.drag(find.text('Timeline'), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(selected, DateTime(2026, 7, 11));
  });
}

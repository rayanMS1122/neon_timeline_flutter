import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('reveals and invokes end actions', (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 84,
              child: NeonSlidableTimeline(
                endExtentRatio: 0.34,
                endActions: <NeonTimelineAction>[
                  NeonTimelineAction(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.red,
                    onPressed: (_) => deleted = true,
                  ),
                ],
                child: const ColoredBox(
                  color: Colors.black,
                  child: Center(child: Text('Slide card')),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Slide card'), const Offset(-220, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
    expect(tester.takeException(), isNull);
  });
}

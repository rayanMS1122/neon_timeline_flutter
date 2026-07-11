import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
import 'package:neon_timeline_flutter_example/main.dart';

void main() {
  testWidgets('planner showcase renders schedule interactions', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Neon Schedule Timeline'), findsOneWidget);
    expect(find.text('Deep work block'), findsOneWidget);
    expect(find.byType(NeonTimelineDayPager), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is NeonScheduleTimeline<Object?>,
      ),
      findsOneWidget,
    );
    expect(find.byType(NeonTimelineIndicator), findsWidgets);
    expect(find.byType(NeonTimelineConnector), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

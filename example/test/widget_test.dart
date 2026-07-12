import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
import 'package:neon_timeline_flutter_example/main.dart';
import 'package:neon_timeline_flutter_example/models/demo_task.dart';

void main() {
  testWidgets('schedule showcase exposes planner interactions', (tester) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 160));

    expect(find.text('Neon Schedule Timeline'), findsOneWidget);
    expect(find.text('Deep work block'), findsOneWidget);
    expect(find.byType(NeonTimelineDayPager), findsOneWidget);
    expect(find.byType(NeonScheduleTimeline<DemoTask>), findsOneWidget);
    expect(find.byType(NeonTimelineIndicator), findsWidgets);
    expect(find.byType(NeonTimelineConnector), findsWidgets);
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });

  testWidgets('all showcase destinations are reachable', (tester) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 40));

    await tester.tap(find.text('Timelines'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Core timeline variants'), findsOneWidget);
    expect(find.byType(NeonTimeline), findsOneWidget);

    await tester.tap(find.text('Effects'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Advanced effect gallery'), findsOneWidget);
    expect(find.byType(NeonTimelineIndicator), findsWidgets);
    await tester.tap(find.text('Nodes'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(NeonTimelineNode), findsWidgets);

    await tester.tap(find.text('Performance'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Lazy performance showcase'), findsOneWidget);
    expect(find.text('500 lazy rows'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });

  testWidgets('reduce-motion setting is exposed', (tester) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 40));

    await tester.tap(find.byTooltip('Showcase settings'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Adaptive'), findsOneWidget);
    expect(find.text('Omniverse'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });
}

Future<void> _setPhoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

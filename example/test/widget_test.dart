import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
import 'package:neon_timeline_flutter_example/main.dart';

void main() {
  testWidgets('13.0 catalog opens the advanced compact timeline', (
    tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Neon Timeline Flutter'), findsOneWidget);
    expect(find.text('13.0.0'), findsWidgets);
    expect(find.text('Advanced Timeline UI 13'), findsOneWidget);

    await tester.ensureVisible(find.text('Advanced Timeline UI 13'));
    await tester.tap(find.text('Advanced Timeline UI 13'));
    await tester.pumpAndSettle();

    expect(find.text('Advanced Timeline UI 13.0'), findsOneWidget);
    expect(find.text('Daily check-in'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is UltimateStructuredTimeline),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });

  testWidgets('v13 exposes visible offline persistence feedback', (
    tester,
  ) async {
    await _setPhoneSurface(tester);
    await _openV13(tester);

    await tester.tap(find.byTooltip('Preview modes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate offline'));
    await tester.pumpAndSettle();

    expect(
      find.text('Saved locally. Sync resumes when online.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });

  testWidgets('catalog search preserves legacy showcase navigation', (
    tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(const NeonTimelineExampleApp());
    await tester.pump(const Duration(milliseconds: 160));

    await tester.enterText(find.byType(TextField), 'Timeline Platform Studio');
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Timeline Platform Studio'), findsNWidgets(2));

    await tester.tap(find.text('Timeline Platform Studio').last);
    await tester.pumpAndSettle();
    expect(find.text('Timeline Studio 4.0'), findsWidgets);
    expect(find.byType(TimelineWorkspace), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });

  testWidgets('v13 remains stable at 200 percent text in RTL', (tester) async {
    await _setPhoneSurface(tester);
    await _openV13(tester);

    await _selectPreviewMode(tester, 'Toggle 200% text');
    await _selectPreviewMode(tester, 'Toggle RTL');

    final timelineContext = tester.element(
      find.byWidgetPredicate((widget) => widget is UltimateStructuredTimeline),
    );
    expect(Directionality.of(timelineContext), TextDirection.rtl);
    expect(MediaQuery.textScalerOf(timelineContext).scale(10), 20);
    expect(tester.takeException(), isNull);

    await _disposeApp(tester);
  });
}

Future<void> _openV13(WidgetTester tester) async {
  await tester.pumpWidget(const NeonTimelineExampleApp());
  await tester.pump(const Duration(milliseconds: 180));
  await tester.ensureVisible(find.text('Advanced Timeline UI 13'));
  await tester.tap(find.text('Advanced Timeline UI 13'));
  await tester.pumpAndSettle();
}

Future<void> _selectPreviewMode(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Preview modes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
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

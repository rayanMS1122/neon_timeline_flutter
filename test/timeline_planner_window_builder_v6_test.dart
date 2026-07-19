import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  testWidgets('window builder exposes one prepared expansion', (tester) async {
    final engine = TimelinePlannerEngine<String>(
      adapter: TimelineSeriesAdapter<String>(
        entryAdapter: TimelineEntryAdapter<String>(
          id: (value) => value,
          start: (_) => DateTime(2026, 7, 16, 9),
        ),
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TimelinePlannerWindowBuilder<String>(
          values: const <String>['task'],
          engine: engine,
          windowStart: DateTime(2026, 7),
          windowEnd: DateTime(2026, 8),
          dataRevision: 1,
          builder: (context, window) {
            return Text('${window.expansion.entries.length}');
          },
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
  });
}

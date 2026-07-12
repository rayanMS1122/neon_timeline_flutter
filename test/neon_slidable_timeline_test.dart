import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('reveals and invokes end actions', (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      _host(
        NeonSlidableTimeline(
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
    );

    await tester.drag(find.text('Slide card'), const Offset(-220, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('async slide action cannot run twice concurrently',
      (tester) async {
    final gate = Completer<void>();
    var calls = 0;

    await tester.pumpWidget(
      _host(
        NeonSlidableTimeline(
          endExtentRatio: 0.55,
          endActions: <NeonTimelineAction>[
            NeonTimelineAction(
              icon: Icons.archive,
              label: 'Archive',
              color: Colors.blue,
              autoClose: false,
              onPressed: (_) async {
                calls++;
                await gate.future;
              },
            ),
            NeonTimelineAction(
              icon: Icons.delete,
              label: 'Delete',
              color: Colors.red,
              autoClose: false,
              onPressed: (_) async {
                calls++;
              },
            ),
          ],
          child: const ColoredBox(
            color: Colors.black,
            child: Center(child: Text('Async card')),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Async card'), const Offset(-260, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Archive'));
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.tap(find.text('Archive'));
    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('async action errors are routed to the public callback',
      (tester) async {
    Object? reported;

    await tester.pumpWidget(
      _host(
        NeonSlidableTimeline(
          endExtentRatio: 0.34,
          onError: (error, stackTrace) => reported = error,
          endActions: <NeonTimelineAction>[
            NeonTimelineAction(
              icon: Icons.warning_rounded,
              label: 'Fail',
              color: Colors.orange,
              onPressed: (_) async {
                throw StateError('expected test failure');
              },
            ),
          ],
          child: const ColoredBox(
            color: Colors.black,
            child: Center(child: Text('Error card')),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Error card'), const Offset(-220, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fail'));
    await tester.pumpAndSettle();

    expect(reported, isA<StateError>());
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: <ThemeExtension<dynamic>>[
        NeonTimelineThemeData.spectral(),
      ],
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 340, height: 84, child: child),
      ),
    ),
  );
}

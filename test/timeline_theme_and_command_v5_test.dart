import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('5.0 visual systems expose distinct tokens', () {
    final themes = <TimelineThemeData>[
      TimelineThemeData.horizon(),
      TimelineThemeData.obsidian(),
      TimelineThemeData.paper(),
      TimelineThemeData.signal(),
    ];

    expect(
      themes.map((theme) => theme.visualStyle).toSet(),
      <TimelineVisualStyle>{
        TimelineVisualStyle.horizon,
        TimelineVisualStyle.obsidian,
        TimelineVisualStyle.paper,
        TimelineVisualStyle.signal,
      },
    );
    expect(themes.every((theme) => theme.cardRadius >= 6), isTrue);
  });

  testWidgets('command palette filters and executes a command', (tester) async {
    var executed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineTheme(
          data: TimelineThemeData.obsidian(),
          child: Scaffold(
            body: TimelineCommandPalette(
              commands: <TimelinePaletteCommand>[
                TimelinePaletteCommand(
                  id: 'release',
                  label: 'Open release view',
                  onSelected: () => executed = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'release');
    await tester.tap(find.text('Open release view'));
    await tester.pump();

    expect(executed, isTrue);
  });
}

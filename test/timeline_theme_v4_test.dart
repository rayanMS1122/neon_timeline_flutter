import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('modern theme bridges to a restrained legacy renderer', () {
    final theme = TimelineThemeData.modern();
    final legacy = theme.toLegacyTheme();

    expect(theme.visualStyle, TimelineVisualStyle.modern);
    expect(legacy.indicatorStyle.effect, NeonIndicatorEffect.classic);
    expect(legacy.connectorStyle.animated, isFalse);
    expect(legacy.indicatorStyle.particleCount, 0);
  });

  test('glass and enterprise presets change real rendering policy', () {
    final glass = TimelineThemeData.glass();
    final enterprise = TimelineThemeData.enterprise();

    expect(glass.useBlur, isTrue);
    expect(glass.toLegacyScheduleStyle().useBackdropFilter, isTrue);
    expect(enterprise.compact, isTrue);
    expect(
      enterprise.toLegacyScheduleStyle().cardVariant,
      NeonTimelineCardVariant.solid,
    );
  });

  testWidgets('TimelineTheme overrides the app extension', (tester) async {
    final appTheme = TimelineThemeData.modern();
    final localTheme = TimelineThemeData.highContrast();
    TimelineThemeData? seen;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: <ThemeExtension<dynamic>>[appTheme]),
        home: TimelineTheme(
          data: localTheme,
          child: Builder(
            builder: (context) {
              seen = TimelineTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(seen, same(localTheme));
  });
}

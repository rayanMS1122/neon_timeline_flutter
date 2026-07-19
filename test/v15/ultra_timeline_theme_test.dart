import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v15.dart';

void main() {
  test('v15 theme exposes every immutable design token', () {
    const theme = UltraTimelineThemeData(
      background: Color(0xFF000001),
      canvas: Color(0xFF000002),
      panel: Color(0xFF000003),
      panelStrong: Color(0xFF000004),
      outline: Color(0xFF000005),
      text: Color(0xFF000006),
      mutedText: Color(0xFF000007),
      primary: Color(0xFF000008),
      violet: Color(0xFF000009),
      mint: Color(0xFF00000A),
      coral: Color(0xFF00000B),
      amber: Color(0xFF00000C),
      sky: Color(0xFF00000D),
      shadow: Color(0xFF00000E),
      radiusSmall: 11,
      radiusMedium: 17,
      radiusLarge: 25,
      radiusPanel: 31,
      commandHeight: 64,
    );

    expect(theme.background, const Color(0xFF000001));
    expect(theme.canvas, const Color(0xFF000002));
    expect(theme.panel, const Color(0xFF000003));
    expect(theme.panelStrong, const Color(0xFF000004));
    expect(theme.outline, const Color(0xFF000005));
    expect(theme.text, const Color(0xFF000006));
    expect(theme.mutedText, const Color(0xFF000007));
    expect(theme.primary, const Color(0xFF000008));
    expect(theme.violet, const Color(0xFF000009));
    expect(theme.mint, const Color(0xFF00000A));
    expect(theme.coral, const Color(0xFF00000B));
    expect(theme.amber, const Color(0xFF00000C));
    expect(theme.sky, const Color(0xFF00000D));
    expect(theme.shadow, const Color(0xFF00000E));
    expect(theme.radiusSmall, 11);
    expect(theme.radiusMedium, 17);
    expect(theme.radiusLarge, 25);
    expect(theme.radiusPanel, 31);
    expect(theme.commandHeight, 64);
    expect(theme.tone(UltraTimelineTone.violet), theme.violet);
    expect(theme.copyWith(radiusMedium: 20).radiusMedium, 20);
  });
}

import 'package:flutter/material.dart';

import '../presentation/ultra_timeline_presentation.dart';

/// Immutable v15 design tokens.
@immutable
class UltraTimelineThemeData {
  const UltraTimelineThemeData({
    required this.background,
    required this.canvas,
    required this.panel,
    required this.panelStrong,
    required this.outline,
    required this.text,
    required this.mutedText,
    required this.primary,
    required this.violet,
    required this.mint,
    required this.coral,
    required this.amber,
    required this.sky,
    required this.shadow,
    this.radiusSmall = 12,
    this.radiusMedium = 18,
    this.radiusLarge = 26,
    this.radiusPanel = 30,
    this.commandHeight = 66,
  });

  final Color background;
  final Color canvas;
  final Color panel;
  final Color panelStrong;
  final Color outline;
  final Color text;
  final Color mutedText;
  final Color primary;
  final Color violet;
  final Color mint;
  final Color coral;
  final Color amber;
  final Color sky;
  final Color shadow;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusPanel;
  final double commandHeight;

  factory UltraTimelineThemeData.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return UltraTimelineThemeData(
      background: dark ? const Color(0xFF090C13) : const Color(0xFFF3F5F9),
      canvas: dark ? const Color(0xFF101520) : const Color(0xFFFDFEFF),
      panel: dark ? const Color(0xFF151B27) : const Color(0xFFFFFFFF),
      panelStrong: dark ? const Color(0xFF1A2231) : const Color(0xFFF8FAFD),
      outline: dark ? const Color(0xFF2B3546) : const Color(0xFFDDE3EC),
      text: dark ? const Color(0xFFF5F7FB) : const Color(0xFF172033),
      mutedText: dark ? const Color(0xFF9BA7B8) : const Color(0xFF667085),
      primary: scheme.primary,
      violet: const Color(0xFF7957E8),
      mint: const Color(0xFF149978),
      coral: const Color(0xFFE05F70),
      amber: const Color(0xFFC48720),
      sky: const Color(0xFF2D83C7),
      shadow: Colors.black.withValues(alpha: dark ? 0.32 : 0.10),
    );
  }

  Color tone(UltraTimelineTone tone) {
    return switch (tone) {
      UltraTimelineTone.primary => primary,
      UltraTimelineTone.violet => violet,
      UltraTimelineTone.mint => mint,
      UltraTimelineTone.coral => coral,
      UltraTimelineTone.amber => amber,
      UltraTimelineTone.sky => sky,
      UltraTimelineTone.neutral => mutedText,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is UltraTimelineThemeData &&
        other.background == background &&
        other.canvas == canvas &&
        other.panel == panel &&
        other.panelStrong == panelStrong &&
        other.outline == outline &&
        other.text == text &&
        other.mutedText == mutedText &&
        other.primary == primary &&
        other.violet == violet &&
        other.mint == mint &&
        other.coral == coral &&
        other.amber == amber &&
        other.sky == sky &&
        other.shadow == shadow &&
        other.radiusSmall == radiusSmall &&
        other.radiusMedium == radiusMedium &&
        other.radiusLarge == radiusLarge &&
        other.radiusPanel == radiusPanel &&
        other.commandHeight == commandHeight;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        background,
        canvas,
        panel,
        panelStrong,
        outline,
        text,
        mutedText,
        primary,
        violet,
        mint,
        coral,
        amber,
        sky,
        shadow,
        radiusSmall,
        radiusMedium,
        radiusLarge,
        radiusPanel,
        commandHeight,
      ]);

  UltraTimelineThemeData copyWith({
    Color? background,
    Color? canvas,
    Color? panel,
    Color? panelStrong,
    Color? outline,
    Color? text,
    Color? mutedText,
    Color? primary,
    Color? violet,
    Color? mint,
    Color? coral,
    Color? amber,
    Color? sky,
    Color? shadow,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusPanel,
    double? commandHeight,
  }) {
    return UltraTimelineThemeData(
      background: background ?? this.background,
      canvas: canvas ?? this.canvas,
      panel: panel ?? this.panel,
      panelStrong: panelStrong ?? this.panelStrong,
      outline: outline ?? this.outline,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      primary: primary ?? this.primary,
      violet: violet ?? this.violet,
      mint: mint ?? this.mint,
      coral: coral ?? this.coral,
      amber: amber ?? this.amber,
      sky: sky ?? this.sky,
      shadow: shadow ?? this.shadow,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusPanel: radiusPanel ?? this.radiusPanel,
      commandHeight: commandHeight ?? this.commandHeight,
    );
  }
}

class UltraTimelineTheme extends InheritedWidget {
  const UltraTimelineTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final UltraTimelineThemeData data;

  static UltraTimelineThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<UltraTimelineTheme>();
    return inherited?.data ??
        UltraTimelineThemeData.fromColorScheme(Theme.of(context).colorScheme);
  }

  @override
  bool updateShouldNotify(UltraTimelineTheme oldWidget) {
    return data != oldWidget.data;
  }
}

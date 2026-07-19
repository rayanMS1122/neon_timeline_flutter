import 'package:flutter/material.dart';

import '../models/friendly_timeline_ui_models.dart';

/// Density presets for the v14 friendly planner workspace.
enum FriendlyTimelineWorkspaceDensity { compact, comfortable, spacious }

/// Public v14 design tokens.
@immutable
class FriendlyTimelineUiThemeData {
  const FriendlyTimelineUiThemeData({
    required this.canvas,
    required this.canvasAccent,
    required this.panel,
    required this.panelStrong,
    required this.text,
    required this.mutedText,
    required this.outline,
    required this.primary,
    required this.primarySoft,
    required this.lavender,
    required this.lavenderSoft,
    required this.mint,
    required this.mintSoft,
    required this.coral,
    required this.coralSoft,
    required this.amber,
    required this.amberSoft,
    required this.sky,
    required this.skySoft,
    required this.success,
    required this.warning,
    required this.error,
    required this.shadow,
    this.workspaceRadius = 32,
    this.panelRadius = 26,
    this.cardRadius = 20,
    this.controlRadius = 16,
    this.workspacePadding = const EdgeInsets.all(14),
    this.panelPadding = const EdgeInsets.all(14),
    this.compactBreakpoint = 900,
    this.navigationBreakpoint = 1160,
    this.density = FriendlyTimelineWorkspaceDensity.comfortable,
  }) : assert(workspaceRadius >= 0),
       assert(panelRadius >= 0),
       assert(cardRadius >= 0),
       assert(controlRadius >= 0),
       assert(compactBreakpoint > 0),
       assert(navigationBreakpoint >= compactBreakpoint);

  factory FriendlyTimelineUiThemeData.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final primary = scheme.primary;
    return FriendlyTimelineUiThemeData(
      canvas: dark ? const Color(0xFF0B1020) : const Color(0xFFF7F7FC),
      canvasAccent: dark ? const Color(0xFF151B32) : const Color(0xFFF0EEFF),
      panel: dark ? const Color(0xFF131A2B) : const Color(0xFFFCFCFF),
      panelStrong: dark ? const Color(0xFF1A2237) : Colors.white,
      text: dark ? const Color(0xFFF8FAFC) : const Color(0xFF1E2235),
      mutedText: dark ? const Color(0xFFA6B0C3) : const Color(0xFF70778B),
      outline: dark ? const Color(0xFF2B3650) : const Color(0xFFE4E5EF),
      primary: primary,
      primarySoft: Color.alphaBlend(
        primary.withValues(alpha: dark ? 0.22 : 0.12),
        dark ? const Color(0xFF1A2237) : Colors.white,
      ),
      lavender: dark ? const Color(0xFFB8A5FF) : const Color(0xFF7357D9),
      lavenderSoft: dark ? const Color(0xFF292342) : const Color(0xFFF0EBFF),
      mint: dark ? const Color(0xFF6EE7C4) : const Color(0xFF168F73),
      mintSoft: dark ? const Color(0xFF17372F) : const Color(0xFFE5F8F2),
      coral: dark ? const Color(0xFFFF9A9F) : const Color(0xFFD95368),
      coralSoft: dark ? const Color(0xFF41252E) : const Color(0xFFFFEBEE),
      amber: dark ? const Color(0xFFF9CA67) : const Color(0xFFB7791F),
      amberSoft: dark ? const Color(0xFF3B3020) : const Color(0xFFFFF4D8),
      sky: dark ? const Color(0xFF7CC4FF) : const Color(0xFF2D7FC1),
      skySoft: dark ? const Color(0xFF183248) : const Color(0xFFE7F4FF),
      success: dark ? const Color(0xFF6EE7B7) : const Color(0xFF159A72),
      warning: dark ? const Color(0xFFFCD071) : const Color(0xFFB7791F),
      error: dark ? const Color(0xFFFF8FA3) : const Color(0xFFD94B66),
      shadow: dark ? const Color(0xB0000000) : const Color(0x1A252A44),
    );
  }

  factory FriendlyTimelineUiThemeData.sunrise(ColorScheme scheme) {
    return FriendlyTimelineUiThemeData.fromColorScheme(scheme).copyWith(
      canvas: const Color(0xFFFFFAF7),
      canvasAccent: const Color(0xFFFFF0EB),
      primary: const Color(0xFF7558E8),
      primarySoft: const Color(0xFFF0EBFF),
      coral: const Color(0xFFD95368),
      coralSoft: const Color(0xFFFFEBEE),
      density: FriendlyTimelineWorkspaceDensity.spacious,
    );
  }

  factory FriendlyTimelineUiThemeData.compact(ColorScheme scheme) {
    return FriendlyTimelineUiThemeData.fromColorScheme(scheme).copyWith(
      workspaceRadius: 26,
      panelRadius: 22,
      cardRadius: 17,
      controlRadius: 14,
      workspacePadding: const EdgeInsets.all(10),
      panelPadding: const EdgeInsets.all(10),
      density: FriendlyTimelineWorkspaceDensity.compact,
    );
  }

  final Color canvas;
  final Color canvasAccent;
  final Color panel;
  final Color panelStrong;
  final Color text;
  final Color mutedText;
  final Color outline;
  final Color primary;
  final Color primarySoft;
  final Color lavender;
  final Color lavenderSoft;
  final Color mint;
  final Color mintSoft;
  final Color coral;
  final Color coralSoft;
  final Color amber;
  final Color amberSoft;
  final Color sky;
  final Color skySoft;
  final Color success;
  final Color warning;
  final Color error;
  final Color shadow;
  final double workspaceRadius;
  final double panelRadius;
  final double cardRadius;
  final double controlRadius;
  final EdgeInsetsGeometry workspacePadding;
  final EdgeInsetsGeometry panelPadding;
  final double compactBreakpoint;
  final double navigationBreakpoint;
  final FriendlyTimelineWorkspaceDensity density;

  double get sectionGap => switch (density) {
    FriendlyTimelineWorkspaceDensity.compact => 9,
    FriendlyTimelineWorkspaceDensity.comfortable => 13,
    FriendlyTimelineWorkspaceDensity.spacious => 17,
  };

  double get controlHeight => switch (density) {
    FriendlyTimelineWorkspaceDensity.compact => 42,
    FriendlyTimelineWorkspaceDensity.comfortable => 46,
    FriendlyTimelineWorkspaceDensity.spacious => 50,
  };

  Color foregroundFor(FriendlyTimelineIconTone tone) => switch (tone) {
    FriendlyTimelineIconTone.primary => primary,
    FriendlyTimelineIconTone.lavender => lavender,
    FriendlyTimelineIconTone.mint => mint,
    FriendlyTimelineIconTone.coral => coral,
    FriendlyTimelineIconTone.amber => amber,
    FriendlyTimelineIconTone.sky => sky,
    FriendlyTimelineIconTone.neutral => mutedText,
  };

  Color backgroundFor(FriendlyTimelineIconTone tone) => switch (tone) {
    FriendlyTimelineIconTone.primary => primarySoft,
    FriendlyTimelineIconTone.lavender => lavenderSoft,
    FriendlyTimelineIconTone.mint => mintSoft,
    FriendlyTimelineIconTone.coral => coralSoft,
    FriendlyTimelineIconTone.amber => amberSoft,
    FriendlyTimelineIconTone.sky => skySoft,
    FriendlyTimelineIconTone.neutral => panel,
  };

  FriendlyTimelineUiThemeData copyWith({
    Color? canvas,
    Color? canvasAccent,
    Color? panel,
    Color? panelStrong,
    Color? text,
    Color? mutedText,
    Color? outline,
    Color? primary,
    Color? primarySoft,
    Color? lavender,
    Color? lavenderSoft,
    Color? mint,
    Color? mintSoft,
    Color? coral,
    Color? coralSoft,
    Color? amber,
    Color? amberSoft,
    Color? sky,
    Color? skySoft,
    Color? success,
    Color? warning,
    Color? error,
    Color? shadow,
    double? workspaceRadius,
    double? panelRadius,
    double? cardRadius,
    double? controlRadius,
    EdgeInsetsGeometry? workspacePadding,
    EdgeInsetsGeometry? panelPadding,
    double? compactBreakpoint,
    double? navigationBreakpoint,
    FriendlyTimelineWorkspaceDensity? density,
  }) {
    return FriendlyTimelineUiThemeData(
      canvas: canvas ?? this.canvas,
      canvasAccent: canvasAccent ?? this.canvasAccent,
      panel: panel ?? this.panel,
      panelStrong: panelStrong ?? this.panelStrong,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      outline: outline ?? this.outline,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      lavender: lavender ?? this.lavender,
      lavenderSoft: lavenderSoft ?? this.lavenderSoft,
      mint: mint ?? this.mint,
      mintSoft: mintSoft ?? this.mintSoft,
      coral: coral ?? this.coral,
      coralSoft: coralSoft ?? this.coralSoft,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      sky: sky ?? this.sky,
      skySoft: skySoft ?? this.skySoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      shadow: shadow ?? this.shadow,
      workspaceRadius: workspaceRadius ?? this.workspaceRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      workspacePadding: workspacePadding ?? this.workspacePadding,
      panelPadding: panelPadding ?? this.panelPadding,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      navigationBreakpoint: navigationBreakpoint ?? this.navigationBreakpoint,
      density: density ?? this.density,
    );
  }
}

/// Inherited theme boundary for all public version 14 UI components.
class FriendlyTimelineUiTheme extends InheritedTheme {
  const FriendlyTimelineUiTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final FriendlyTimelineUiThemeData data;

  static FriendlyTimelineUiThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<FriendlyTimelineUiTheme>();
    return inherited?.data ??
        FriendlyTimelineUiThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
  }

  @override
  bool updateShouldNotify(FriendlyTimelineUiTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FriendlyTimelineUiTheme(data: data, child: child);
}

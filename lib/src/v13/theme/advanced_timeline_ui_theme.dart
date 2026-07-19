import 'package:flutter/material.dart';

/// Visual density used by the 13.x workspace shell.
enum AdvancedTimelineWorkspaceDensity { compact, balanced, spacious }

/// Public design tokens for the 13.x advanced timeline workspace.
@immutable
class AdvancedTimelineUiThemeData {
  const AdvancedTimelineUiThemeData({
    required this.canvas,
    required this.canvasAccent,
    required this.panel,
    required this.panelElevated,
    required this.text,
    required this.mutedText,
    required this.outline,
    required this.primary,
    required this.primarySoft,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.shadow,
    this.workspaceRadius = 28,
    this.panelRadius = 22,
    this.controlRadius = 14,
    this.workspacePadding = const EdgeInsets.all(14),
    this.panelPadding = const EdgeInsets.all(14),
    this.compactBreakpoint = 920,
    this.navigationBreakpoint = 1180,
    this.density = AdvancedTimelineWorkspaceDensity.balanced,
  }) : assert(workspaceRadius >= 0),
       assert(panelRadius >= 0),
       assert(controlRadius >= 0),
       assert(compactBreakpoint > 0),
       assert(navigationBreakpoint >= compactBreakpoint);

  /// Creates a quiet, high-contrast workspace palette from the app scheme.
  factory AdvancedTimelineUiThemeData.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final primary = scheme.primary;
    return AdvancedTimelineUiThemeData(
      canvas: dark ? const Color(0xFF07101D) : const Color(0xFFF3F6FB),
      canvasAccent: dark ? const Color(0xFF0C1930) : const Color(0xFFE9EEFF),
      panel: dark ? const Color(0xFF0D1726) : const Color(0xFFF9FBFF),
      panelElevated: dark ? const Color(0xFF132033) : Colors.white,
      text: dark ? const Color(0xFFF7F9FC) : const Color(0xFF111827),
      mutedText: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      outline: dark ? const Color(0xFF26364D) : const Color(0xFFDCE3EF),
      primary: primary,
      primarySoft: Color.alphaBlend(
        primary.withValues(alpha: dark ? 0.18 : 0.11),
        dark ? const Color(0xFF132033) : Colors.white,
      ),
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF59E0B),
      error: dark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
      info: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      shadow: dark ? const Color(0xA6000000) : const Color(0x1A0F172A),
    );
  }

  /// Dense operations preset for dashboards and desktop planner views.
  factory AdvancedTimelineUiThemeData.operations(ColorScheme scheme) {
    return AdvancedTimelineUiThemeData.fromColorScheme(scheme).copyWith(
      workspaceRadius: 24,
      panelRadius: 18,
      controlRadius: 12,
      workspacePadding: const EdgeInsets.all(10),
      panelPadding: const EdgeInsets.all(10),
      density: AdvancedTimelineWorkspaceDensity.compact,
    );
  }

  /// Spacious preset for touch-first planning surfaces.
  factory AdvancedTimelineUiThemeData.focus(ColorScheme scheme) {
    return AdvancedTimelineUiThemeData.fromColorScheme(scheme).copyWith(
      workspaceRadius: 32,
      panelRadius: 26,
      controlRadius: 16,
      workspacePadding: const EdgeInsets.all(18),
      panelPadding: const EdgeInsets.all(18),
      density: AdvancedTimelineWorkspaceDensity.spacious,
    );
  }

  final Color canvas;
  final Color canvasAccent;
  final Color panel;
  final Color panelElevated;
  final Color text;
  final Color mutedText;
  final Color outline;
  final Color primary;
  final Color primarySoft;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color shadow;
  final double workspaceRadius;
  final double panelRadius;
  final double controlRadius;
  final EdgeInsetsGeometry workspacePadding;
  final EdgeInsetsGeometry panelPadding;
  final double compactBreakpoint;
  final double navigationBreakpoint;
  final AdvancedTimelineWorkspaceDensity density;

  double get sectionGap => switch (density) {
    AdvancedTimelineWorkspaceDensity.compact => 8,
    AdvancedTimelineWorkspaceDensity.balanced => 12,
    AdvancedTimelineWorkspaceDensity.spacious => 16,
  };

  double get controlHeight => switch (density) {
    AdvancedTimelineWorkspaceDensity.compact => 42,
    AdvancedTimelineWorkspaceDensity.balanced => 46,
    AdvancedTimelineWorkspaceDensity.spacious => 50,
  };

  AdvancedTimelineUiThemeData copyWith({
    Color? canvas,
    Color? canvasAccent,
    Color? panel,
    Color? panelElevated,
    Color? text,
    Color? mutedText,
    Color? outline,
    Color? primary,
    Color? primarySoft,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? shadow,
    double? workspaceRadius,
    double? panelRadius,
    double? controlRadius,
    EdgeInsetsGeometry? workspacePadding,
    EdgeInsetsGeometry? panelPadding,
    double? compactBreakpoint,
    double? navigationBreakpoint,
    AdvancedTimelineWorkspaceDensity? density,
  }) {
    return AdvancedTimelineUiThemeData(
      canvas: canvas ?? this.canvas,
      canvasAccent: canvasAccent ?? this.canvasAccent,
      panel: panel ?? this.panel,
      panelElevated: panelElevated ?? this.panelElevated,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      outline: outline ?? this.outline,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      shadow: shadow ?? this.shadow,
      workspaceRadius: workspaceRadius ?? this.workspaceRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      workspacePadding: workspacePadding ?? this.workspacePadding,
      panelPadding: panelPadding ?? this.panelPadding,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      navigationBreakpoint: navigationBreakpoint ?? this.navigationBreakpoint,
      density: density ?? this.density,
    );
  }
}

/// Inherited theme boundary for all public 13.x workspace components.
class AdvancedTimelineUiTheme extends InheritedTheme {
  const AdvancedTimelineUiTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final AdvancedTimelineUiThemeData data;

  static AdvancedTimelineUiThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<AdvancedTimelineUiTheme>();
    return inherited?.data ??
        AdvancedTimelineUiThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
  }

  @override
  bool updateShouldNotify(AdvancedTimelineUiTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return AdvancedTimelineUiTheme(data: data, child: child);
  }
}

import 'package:flutter/material.dart';

/// Theme extension for the timeline package.
@immutable
class NeonPlannerTimelineThemeData
    extends ThemeExtension<NeonPlannerTimelineThemeData> {
  /// Creates timeline theme data.
  const NeonPlannerTimelineThemeData({
    required this.canvasColor,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.dayAccentColor,
    required this.nightAccentColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.gridColor,
    required this.focusColor,
    required this.selectionColor,
    required this.gapTextColor,
    required this.shadowColor,
    required this.titleStyle,
    required this.timeStyle,
    required this.metadataStyle,
    required this.gapStyle,
    required this.surfaceRadius,
    required this.nodeRadius,
    required this.lineWidth,
  });

  /// Default light theme tuned for a soft, premium mobile timeline.
  factory NeonPlannerTimelineThemeData.light() {
    const primary = Color(0xFF141820);
    const secondary = Color(0xFF657083);
    return const NeonPlannerTimelineThemeData(
      canvasColor: Color(0xFFF6F8FC),
      surfaceColor: Color(0xFFFFFFFF),
      primaryTextColor: primary,
      secondaryTextColor: secondary,
      dayAccentColor: Color(0xFFFF867A),
      nightAccentColor: Color(0xFF3E8EEC),
      successColor: Color(0xFF7C6BF2),
      warningColor: Color(0xFF55BFB4),
      errorColor: Color(0xFFE85A72),
      gridColor: Color(0xFFE8EEF7),
      focusColor: Color(0xFF2B6EF3),
      selectionColor: Color(0x142B6EF3),
      gapTextColor: Color(0xFF6E7C91),
      shadowColor: Color(0x160B1220),
      titleStyle: TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      timeStyle: TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      metadataStyle: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      gapStyle: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6E7C91),
      ),
      surfaceRadius: 34,
      nodeRadius: 29,
      lineWidth: 3,
    );
  }

  /// Default dark theme.
  factory NeonPlannerTimelineThemeData.dark() {
    const primary = Color(0xFFF5F7FB);
    const secondary = Color(0xFFB8C0CF);
    return const NeonPlannerTimelineThemeData(
      canvasColor: Color(0xFF0D1118),
      surfaceColor: Color(0xFF141A24),
      primaryTextColor: primary,
      secondaryTextColor: secondary,
      dayAccentColor: Color(0xFFFF978E),
      nightAccentColor: Color(0xFF67AFFF),
      successColor: Color(0xFF9B8BFF),
      warningColor: Color(0xFF72D5CA),
      errorColor: Color(0xFFFF7D92),
      gridColor: Color(0xFF253044),
      focusColor: Color(0xFF7BAEFF),
      selectionColor: Color(0x287BAEFF),
      gapTextColor: Color(0xFFBBC6D8),
      shadowColor: Color(0x48000000),
      titleStyle: TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      timeStyle: TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      metadataStyle: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      gapStyle: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: Color(0xFFBBC6D8),
      ),
      surfaceRadius: 34,
      nodeRadius: 29,
      lineWidth: 3,
    );
  }

  /// High-contrast light theme.
  factory NeonPlannerTimelineThemeData.highContrastLight() {
    return NeonPlannerTimelineThemeData.light().copyWith(
      primaryTextColor: Colors.black,
      secondaryTextColor: const Color(0xFF253041),
      dayAccentColor: const Color(0xFFC53F2E),
      nightAccentColor: const Color(0xFF0C56C9),
      gridColor: const Color(0xFF93A0B5),
      focusColor: const Color(0xFF0039CC),
      lineWidth: 4,
    );
  }

  /// High-contrast dark theme.
  factory NeonPlannerTimelineThemeData.highContrastDark() {
    return NeonPlannerTimelineThemeData.dark().copyWith(
      primaryTextColor: Colors.white,
      secondaryTextColor: const Color(0xFFE5ECF8),
      dayAccentColor: const Color(0xFFFFB0A8),
      nightAccentColor: const Color(0xFFB5D7FF),
      gridColor: const Color(0xFFD1D7E5),
      focusColor: const Color(0xFFFFFF00),
      lineWidth: 4,
    );
  }

  /// Canvas outside the surface.
  final Color canvasColor;

  /// Timeline surface.
  final Color surfaceColor;

  /// Main text.
  final Color primaryTextColor;

  /// Secondary text.
  final Color secondaryTextColor;

  /// Day accent.
  final Color dayAccentColor;

  /// Night accent.
  final Color nightAccentColor;

  /// Success state.
  final Color successColor;

  /// Warning state.
  final Color warningColor;

  /// Error state.
  final Color errorColor;

  /// Hour grid.
  final Color gridColor;

  /// Keyboard focus indicator.
  final Color focusColor;

  /// Selected background.
  final Color selectionColor;

  /// Gap copy.
  final Color gapTextColor;

  /// Subtle surface shadow.
  final Color shadowColor;

  /// Entry title style.
  final TextStyle titleStyle;

  /// Entry time style.
  final TextStyle timeStyle;

  /// Entry metadata style.
  final TextStyle metadataStyle;

  /// Gap label style.
  final TextStyle gapStyle;

  /// Surface radius.
  final double surfaceRadius;

  /// Default circular node radius.
  final double nodeRadius;

  /// Main line width.
  final double lineWidth;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NeonPlannerTimelineThemeData &&
            canvasColor == other.canvasColor &&
            surfaceColor == other.surfaceColor &&
            primaryTextColor == other.primaryTextColor &&
            secondaryTextColor == other.secondaryTextColor &&
            dayAccentColor == other.dayAccentColor &&
            nightAccentColor == other.nightAccentColor &&
            successColor == other.successColor &&
            warningColor == other.warningColor &&
            errorColor == other.errorColor &&
            gridColor == other.gridColor &&
            focusColor == other.focusColor &&
            selectionColor == other.selectionColor &&
            gapTextColor == other.gapTextColor &&
            shadowColor == other.shadowColor &&
            titleStyle == other.titleStyle &&
            timeStyle == other.timeStyle &&
            metadataStyle == other.metadataStyle &&
            gapStyle == other.gapStyle &&
            surfaceRadius == other.surfaceRadius &&
            nodeRadius == other.nodeRadius &&
            lineWidth == other.lineWidth;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    canvasColor,
    surfaceColor,
    primaryTextColor,
    secondaryTextColor,
    dayAccentColor,
    nightAccentColor,
    successColor,
    warningColor,
    errorColor,
    gridColor,
    focusColor,
    selectionColor,
    gapTextColor,
    shadowColor,
    titleStyle,
    timeStyle,
    metadataStyle,
    gapStyle,
    surfaceRadius,
    nodeRadius,
    lineWidth,
  ]);

  @override
  NeonPlannerTimelineThemeData copyWith({
    Color? canvasColor,
    Color? surfaceColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? dayAccentColor,
    Color? nightAccentColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? gridColor,
    Color? focusColor,
    Color? selectionColor,
    Color? gapTextColor,
    Color? shadowColor,
    TextStyle? titleStyle,
    TextStyle? timeStyle,
    TextStyle? metadataStyle,
    TextStyle? gapStyle,
    double? surfaceRadius,
    double? nodeRadius,
    double? lineWidth,
  }) {
    return NeonPlannerTimelineThemeData(
      canvasColor: canvasColor ?? this.canvasColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      dayAccentColor: dayAccentColor ?? this.dayAccentColor,
      nightAccentColor: nightAccentColor ?? this.nightAccentColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      gridColor: gridColor ?? this.gridColor,
      focusColor: focusColor ?? this.focusColor,
      selectionColor: selectionColor ?? this.selectionColor,
      gapTextColor: gapTextColor ?? this.gapTextColor,
      shadowColor: shadowColor ?? this.shadowColor,
      titleStyle: titleStyle ?? this.titleStyle,
      timeStyle: timeStyle ?? this.timeStyle,
      metadataStyle: metadataStyle ?? this.metadataStyle,
      gapStyle: gapStyle ?? this.gapStyle,
      surfaceRadius: surfaceRadius ?? this.surfaceRadius,
      nodeRadius: nodeRadius ?? this.nodeRadius,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }

  @override
  NeonPlannerTimelineThemeData lerp(
    covariant NeonPlannerTimelineThemeData? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return NeonPlannerTimelineThemeData(
      canvasColor: Color.lerp(canvasColor, other.canvasColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      primaryTextColor: Color.lerp(
        primaryTextColor,
        other.primaryTextColor,
        t,
      )!,
      secondaryTextColor: Color.lerp(
        secondaryTextColor,
        other.secondaryTextColor,
        t,
      )!,
      dayAccentColor: Color.lerp(dayAccentColor, other.dayAccentColor, t)!,
      nightAccentColor: Color.lerp(
        nightAccentColor,
        other.nightAccentColor,
        t,
      )!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      gridColor: Color.lerp(gridColor, other.gridColor, t)!,
      focusColor: Color.lerp(focusColor, other.focusColor, t)!,
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t)!,
      gapTextColor: Color.lerp(gapTextColor, other.gapTextColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      timeStyle: TextStyle.lerp(timeStyle, other.timeStyle, t)!,
      metadataStyle: TextStyle.lerp(metadataStyle, other.metadataStyle, t)!,
      gapStyle: TextStyle.lerp(gapStyle, other.gapStyle, t)!,
      surfaceRadius: _lerpDouble(surfaceRadius, other.surfaceRadius, t),
      nodeRadius: _lerpDouble(nodeRadius, other.nodeRadius, t),
      lineWidth: _lerpDouble(lineWidth, other.lineWidth, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Supplies a timeline-specific theme below the nearest Material theme.
class NeonPlannerTimelineTheme extends InheritedTheme {
  /// Creates a timeline theme.
  const NeonPlannerTimelineTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Theme data.
  final NeonPlannerTimelineThemeData data;

  /// Resolves the nearest package theme or a brightness-aware default.
  static NeonPlannerTimelineThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<NeonPlannerTimelineTheme>();
    if (inherited != null) {
      return inherited.data;
    }
    final extension = Theme.of(context).extension<NeonPlannerTimelineThemeData>();
    if (extension != null) {
      return extension;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? NeonPlannerTimelineThemeData.dark()
        : NeonPlannerTimelineThemeData.light();
  }

  @override
  bool updateShouldNotify(NeonPlannerTimelineTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NeonPlannerTimelineTheme(data: data, child: child);
  }
}

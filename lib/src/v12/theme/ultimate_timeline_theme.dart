import 'package:flutter/material.dart';

/// Position of the compact task accent. The v13 workspace preset uses a top
/// signal instead of the older full-height leading stripe.
enum UltimateTimelineAccentPlacement { leading, top, none }

/// Card geometry tokens shared by every 12.x entry representation.
@immutable
class UltimateTimelineEntryTheme {
  const UltimateTimelineEntryTheme({
    this.radius = 20,
    this.compactRadius = 15,
    this.borderWidth = 1,
    this.selectedBorderWidth = 2,
    this.accentWidth = 4,
    this.elevation = 2,
    this.selectedElevation = 8,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 11, 14, 11),
    this.accentPlacement = UltimateTimelineAccentPlacement.leading,
    this.tintOpacity = 0.065,
    this.completedTintOpacity = 0.025,
  }) : assert(radius >= 0),
       assert(compactRadius >= 0),
       assert(accentWidth >= 0),
       assert(tintOpacity >= 0 && tintOpacity <= 1),
       assert(completedTintOpacity >= 0 && completedTintOpacity <= 1);

  final double radius;
  final double compactRadius;
  final double borderWidth;
  final double selectedBorderWidth;
  final double accentWidth;
  final double elevation;
  final double selectedElevation;
  final EdgeInsetsGeometry contentPadding;
  final UltimateTimelineAccentPlacement accentPlacement;
  final double tintOpacity;
  final double completedTintOpacity;

  UltimateTimelineEntryTheme copyWith({
    double? radius,
    double? compactRadius,
    double? borderWidth,
    double? selectedBorderWidth,
    double? accentWidth,
    double? elevation,
    double? selectedElevation,
    EdgeInsetsGeometry? contentPadding,
    UltimateTimelineAccentPlacement? accentPlacement,
    double? tintOpacity,
    double? completedTintOpacity,
  }) {
    return UltimateTimelineEntryTheme(
      radius: radius ?? this.radius,
      compactRadius: compactRadius ?? this.compactRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
      accentWidth: accentWidth ?? this.accentWidth,
      elevation: elevation ?? this.elevation,
      selectedElevation: selectedElevation ?? this.selectedElevation,
      contentPadding: contentPadding ?? this.contentPadding,
      accentPlacement: accentPlacement ?? this.accentPlacement,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      completedTintOpacity:
          completedTintOpacity ?? this.completedTintOpacity,
    );
  }
}

/// Gap presentation tokens.
@immutable
class UltimateTimelineGapTheme {
  const UltimateTimelineGapTheme({
    this.radius = 14,
    this.guideThickness = 1,
    this.expandedOpacity = 0.08,
  });

  final double radius;
  final double guideThickness;
  final double expandedOpacity;

  UltimateTimelineGapTheme copyWith({
    double? radius,
    double? guideThickness,
    double? expandedOpacity,
  }) {
    return UltimateTimelineGapTheme(
      radius: radius ?? this.radius,
      guideThickness: guideThickness ?? this.guideThickness,
      expandedOpacity: expandedOpacity ?? this.expandedOpacity,
    );
  }
}

/// Drag overlay tokens.
@immutable
class UltimateTimelineDragTheme {
  const UltimateTimelineDragTheme({
    this.focusBorderWidth = 2,
    this.guideThickness = 2,
    this.scrimOpacity = 0.035,
    this.allowedOpacity = 0.1,
    this.blockedOpacity = 0.12,
    this.feedbackElevation = 24,
  });

  final double focusBorderWidth;
  final double guideThickness;
  final double scrimOpacity;
  final double allowedOpacity;
  final double blockedOpacity;
  final double feedbackElevation;

  UltimateTimelineDragTheme copyWith({
    double? focusBorderWidth,
    double? guideThickness,
    double? scrimOpacity,
    double? allowedOpacity,
    double? blockedOpacity,
    double? feedbackElevation,
  }) {
    return UltimateTimelineDragTheme(
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
      guideThickness: guideThickness ?? this.guideThickness,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
      allowedOpacity: allowedOpacity ?? this.allowedOpacity,
      blockedOpacity: blockedOpacity ?? this.blockedOpacity,
      feedbackElevation: feedbackElevation ?? this.feedbackElevation,
    );
  }
}

/// Resize handle and preview tokens.
@immutable
class UltimateTimelineResizeTheme {
  const UltimateTimelineResizeTheme({
    this.visualHandleWidth = 44,
    this.visualHandleHeight = 4,
    this.hitTargetHeight = 24,
    this.previewOpacity = 0.1,
  });

  final double visualHandleWidth;
  final double visualHandleHeight;
  final double hitTargetHeight;
  final double previewOpacity;

  UltimateTimelineResizeTheme copyWith({
    double? visualHandleWidth,
    double? visualHandleHeight,
    double? hitTargetHeight,
    double? previewOpacity,
  }) {
    return UltimateTimelineResizeTheme(
      visualHandleWidth: visualHandleWidth ?? this.visualHandleWidth,
      visualHandleHeight: visualHandleHeight ?? this.visualHandleHeight,
      hitTargetHeight: hitTargetHeight ?? this.hitTargetHeight,
      previewOpacity: previewOpacity ?? this.previewOpacity,
    );
  }
}

/// Header layout tokens.
@immutable
class UltimateTimelineHeaderTheme {
  const UltimateTimelineHeaderTheme({
    this.radius = 24,
    this.compactBreakpoint = 620,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 12, 14),
    this.controlSpacing = 8,
  });

  final double radius;
  final double compactBreakpoint;
  final EdgeInsetsGeometry padding;
  final double controlSpacing;

  UltimateTimelineHeaderTheme copyWith({
    double? radius,
    double? compactBreakpoint,
    EdgeInsetsGeometry? padding,
    double? controlSpacing,
  }) {
    return UltimateTimelineHeaderTheme(
      radius: radius ?? this.radius,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      padding: padding ?? this.padding,
      controlSpacing: controlSpacing ?? this.controlSpacing,
    );
  }
}

/// State-specific motion tokens. Durations become zero through [reduced].
@immutable
class UltimateTimelineMotionTheme {
  const UltimateTimelineMotionTheme({
    this.hover = const Duration(milliseconds: 90),
    this.focus = const Duration(milliseconds: 120),
    this.dragStart = const Duration(milliseconds: 110),
    this.snap = const Duration(milliseconds: 80),
    this.drop = const Duration(milliseconds: 150),
    this.cancel = const Duration(milliseconds: 140),
    this.rollback = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
  });

  final Duration hover;
  final Duration focus;
  final Duration dragStart;
  final Duration snap;
  final Duration drop;
  final Duration cancel;
  final Duration rollback;
  final Curve curve;

  UltimateTimelineMotionTheme reduced(bool value) {
    if (!value) return this;
    return const UltimateTimelineMotionTheme(
      hover: Duration.zero,
      focus: Duration.zero,
      dragStart: Duration.zero,
      snap: Duration.zero,
      drop: Duration.zero,
      cancel: Duration.zero,
      rollback: Duration.zero,
      curve: Curves.linear,
    );
  }
}

/// Complete, model-independent visual token set for the ultimate timeline.
@immutable
class UltimateTimelineThemeData {
  const UltimateTimelineThemeData({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.text,
    required this.mutedText,
    required this.border,
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
    required this.blocked,
    required this.shadow,
    this.entry = const UltimateTimelineEntryTheme(),
    this.gap = const UltimateTimelineGapTheme(),
    this.drag = const UltimateTimelineDragTheme(),
    this.resize = const UltimateTimelineResizeTheme(),
    this.header = const UltimateTimelineHeaderTheme(),
    this.motion = const UltimateTimelineMotionTheme(),
  });

  factory UltimateTimelineThemeData.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return UltimateTimelineThemeData(
      background: dark ? const Color(0xFF0B0C0F) : const Color(0xFFF7F7F8),
      surface: dark ? const Color(0xFF14161B) : Colors.white,
      surfaceElevated: dark ? const Color(0xFF1B1E24) : const Color(0xFFFEFEFF),
      text: dark ? const Color(0xFFF6F7F9) : const Color(0xFF17181C),
      mutedText: dark ? const Color(0xFFA4A8B2) : const Color(0xFF686D78),
      border: dark ? const Color(0xFF2B2F38) : const Color(0xFFE2E4E9),
      primary: scheme.primary,
      success: const Color(0xFF16A36A),
      warning: const Color(0xFFB76E00),
      error: scheme.error,
      blocked: dark ? const Color(0xFFFF8A9B) : const Color(0xFFC72C48),
      shadow: dark ? const Color(0x8A000000) : const Color(0x240F172A),
    );
  }

  /// Compact 13.x token set for dense planner and operations views.
  factory UltimateTimelineThemeData.advancedCompact(ColorScheme scheme) {
    final base = UltimateTimelineThemeData.fromColorScheme(scheme);
    final dark = scheme.brightness == Brightness.dark;
    return base.copyWith(
      background: dark ? const Color(0xFF0A1020) : const Color(0xFFF6F7FB),
      surface: dark ? const Color(0xFF111827) : const Color(0xFFFAFBFF),
      surfaceElevated: dark
          ? const Color(0xFF172033)
          : const Color(0xFFFFFFFF),
      text: dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      mutedText: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      border: dark ? const Color(0xFF29364D) : const Color(0xFFE2E8F0),
      success: const Color(0xFF059669),
      warning: const Color(0xFFD97706),
      blocked: dark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
      shadow: dark ? const Color(0x73000000) : const Color(0x1A0F172A),
      entry: base.entry.copyWith(
        radius: 16,
        compactRadius: 14,
        accentWidth: 3,
        elevation: 0.5,
        selectedElevation: 7,
        contentPadding: const EdgeInsets.fromLTRB(12, 9, 11, 9),
        accentPlacement: UltimateTimelineAccentPlacement.top,
        tintOpacity: 0.018,
        completedTintOpacity: 0.008,
      ),
      gap: base.gap.copyWith(radius: 12, expandedOpacity: 0.035),
      drag: base.drag.copyWith(
        focusBorderWidth: 1,
        guideThickness: 1,
        scrimOpacity: 0.04,
        allowedOpacity: 0.07,
        blockedOpacity: 0.08,
        feedbackElevation: 22,
      ),
      resize: base.resize.copyWith(
        visualHandleWidth: 34,
        visualHandleHeight: 3,
        hitTargetHeight: 20,
      ),
      header: base.header.copyWith(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        controlSpacing: 4,
      ),
    );
  }

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color text;
  final Color mutedText;
  final Color border;
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
  final Color blocked;
  final Color shadow;
  final UltimateTimelineEntryTheme entry;
  final UltimateTimelineGapTheme gap;
  final UltimateTimelineDragTheme drag;
  final UltimateTimelineResizeTheme resize;
  final UltimateTimelineHeaderTheme header;
  final UltimateTimelineMotionTheme motion;

  UltimateTimelineThemeData copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? text,
    Color? mutedText,
    Color? border,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Color? blocked,
    Color? shadow,
    UltimateTimelineEntryTheme? entry,
    UltimateTimelineGapTheme? gap,
    UltimateTimelineDragTheme? drag,
    UltimateTimelineResizeTheme? resize,
    UltimateTimelineHeaderTheme? header,
    UltimateTimelineMotionTheme? motion,
  }) {
    return UltimateTimelineThemeData(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      blocked: blocked ?? this.blocked,
      shadow: shadow ?? this.shadow,
      entry: entry ?? this.entry,
      gap: gap ?? this.gap,
      drag: drag ?? this.drag,
      resize: resize ?? this.resize,
      header: header ?? this.header,
      motion: motion ?? this.motion,
    );
  }
}

/// Inherited theme boundary used by public 12.x composition widgets.
class UltimateTimelineTheme extends InheritedTheme {
  const UltimateTimelineTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final UltimateTimelineThemeData data;

  static UltimateTimelineThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<UltimateTimelineTheme>();
    return inherited?.data ??
        UltimateTimelineThemeData.fromColorScheme(
          Theme.of(context).colorScheme,
        );
  }

  @override
  bool updateShouldNotify(UltimateTimelineTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return UltimateTimelineTheme(data: data, child: child);
  }
}

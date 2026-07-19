import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../models/neon_timeline_types.dart';
import '../../theme/neon_schedule_timeline_style.dart';
import '../../theme/neon_timeline_theme.dart';
import '../../widgets/neon_timeline_card.dart';
import '../models/timeline_types.dart';

/// Complete design-token set for the neutral 4.x UI layer.
@immutable
class TimelineThemeData extends ThemeExtension<TimelineThemeData> {
  const TimelineThemeData({
    required this.visualStyle,
    required this.brightness,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.surfaceVariantColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.dividerColor,
    required this.selectionColor,
    required this.focusColor,
    this.titleStyle,
    this.bodyStyle,
    this.metaStyle,
    this.cardRadius = 18,
    this.cardPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.itemSpacing = 12,
    this.railExtent = 48,
    this.connectorThickness = 2,
    this.indicatorSize = 24,
    this.elevation = 0,
    this.blurSigma = 0,
    this.glowRadius = 0,
    this.compact = false,
    this.useBlur = false,
    this.useGlow = false,
    this.motionDuration = const Duration(milliseconds: 280),
    this.motionCurve = Curves.easeOutCubic,
  }) : assert(cardRadius >= 0),
       assert(itemSpacing >= 0),
       assert(railExtent > 0),
       assert(connectorThickness > 0),
       assert(indicatorSize > 0),
       assert(elevation >= 0),
       assert(blurSigma >= 0),
       assert(glowRadius >= 0);

  factory TimelineThemeData.modern({
    Brightness brightness = Brightness.light,
    Color seed = const Color(0xFF635BFF),
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.modern,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF0C0F14) : const Color(0xFFF6F7FB),
      surfaceColor: dark ? const Color(0xFF151922) : Colors.white,
      surfaceVariantColor: dark
          ? const Color(0xFF1C2230)
          : const Color(0xFFF0F2F8),
      primaryColor: scheme.primary,
      secondaryColor: scheme.secondary,
      textColor: dark ? const Color(0xFFF7F8FC) : const Color(0xFF171A22),
      mutedTextColor: dark ? const Color(0xFFA0A8B8) : const Color(0xFF687083),
      successColor: const Color(0xFF16A36A),
      warningColor: const Color(0xFFE09B22),
      errorColor: scheme.error,
      dividerColor: dark ? const Color(0xFF2A3140) : const Color(0xFFDDE1EA),
      selectionColor: scheme.primaryContainer,
      focusColor: scheme.primary,
      cardRadius: 18,
      itemSpacing: 12,
      railExtent: 48,
      indicatorSize: 22,
      elevation: dark ? 0 : 1,
    );
  }

  factory TimelineThemeData.minimal({
    Brightness brightness = Brightness.light,
  }) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.minimal,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF111111) : const Color(0xFFFAFAFA),
      surfaceColor: dark ? const Color(0xFF181818) : Colors.white,
      surfaceVariantColor: dark
          ? const Color(0xFF222222)
          : const Color(0xFFF3F3F3),
      primaryColor: dark ? const Color(0xFFF0F0F0) : const Color(0xFF202020),
      secondaryColor: const Color(0xFF7A7A7A),
      textColor: dark ? Colors.white : const Color(0xFF151515),
      mutedTextColor: dark ? const Color(0xFF9A9A9A) : const Color(0xFF707070),
      successColor: const Color(0xFF28875D),
      warningColor: const Color(0xFFAA7825),
      errorColor: const Color(0xFFC74848),
      dividerColor: dark ? const Color(0xFF333333) : const Color(0xFFE2E2E2),
      selectionColor: dark ? const Color(0xFF303030) : const Color(0xFFEAEAEA),
      focusColor: dark ? Colors.white : Colors.black,
      cardRadius: 10,
      cardPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemSpacing: 8,
      railExtent: 40,
      connectorThickness: 1.25,
      indicatorSize: 14,
      compact: true,
    );
  }

  factory TimelineThemeData.editorial({
    Brightness brightness = Brightness.light,
  }) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.editorial,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF12110F) : const Color(0xFFF8F4EC),
      surfaceColor: dark ? const Color(0xFF1C1A17) : const Color(0xFFFFFCF6),
      surfaceVariantColor: dark
          ? const Color(0xFF28251F)
          : const Color(0xFFF0E8D8),
      primaryColor: const Color(0xFF9A4E2E),
      secondaryColor: const Color(0xFF3E675C),
      textColor: dark ? const Color(0xFFF7F0E5) : const Color(0xFF241F19),
      mutedTextColor: dark ? const Color(0xFFB8AB99) : const Color(0xFF766A5B),
      successColor: const Color(0xFF3E765A),
      warningColor: const Color(0xFFB37A20),
      errorColor: const Color(0xFFB64F45),
      dividerColor: dark ? const Color(0xFF3A342C) : const Color(0xFFE0D4C1),
      selectionColor: const Color(0xFFE7C7B5),
      focusColor: const Color(0xFF9A4E2E),
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      bodyStyle: const TextStyle(height: 1.35),
      cardRadius: 4,
      itemSpacing: 18,
      railExtent: 52,
      indicatorSize: 18,
    );
  }

  factory TimelineThemeData.glass({Brightness brightness = Brightness.dark}) {
    final base = TimelineThemeData.modern(
      brightness: brightness,
      seed: const Color(0xFF65D1FF),
    );
    return base.copyWith(
      visualStyle: TimelineVisualStyle.glass,
      surfaceColor: brightness == Brightness.dark
          ? const Color(0xB31A2030)
          : const Color(0xCCFFFFFF),
      surfaceVariantColor: brightness == Brightness.dark
          ? const Color(0x8F252D3E)
          : const Color(0xB3EFF4FA),
      cardRadius: 24,
      blurSigma: 12,
      glowRadius: 4,
      useBlur: true,
      useGlow: true,
    );
  }

  factory TimelineThemeData.enterprise({
    Brightness brightness = Brightness.light,
  }) {
    final base = TimelineThemeData.modern(
      brightness: brightness,
      seed: const Color(0xFF2457A7),
    );
    return base.copyWith(
      visualStyle: TimelineVisualStyle.enterprise,
      cardRadius: 8,
      cardPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemSpacing: 6,
      railExtent: 42,
      indicatorSize: 16,
      compact: true,
      motionDuration: const Duration(milliseconds: 180),
    );
  }

  factory TimelineThemeData.highContrast({
    Brightness brightness = Brightness.dark,
  }) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.highContrast,
      brightness: brightness,
      backgroundColor: dark ? Colors.black : Colors.white,
      surfaceColor: dark ? const Color(0xFF111111) : Colors.white,
      surfaceVariantColor: dark
          ? const Color(0xFF222222)
          : const Color(0xFFF1F1F1),
      primaryColor: dark ? const Color(0xFFFFFF00) : const Color(0xFF0000CC),
      secondaryColor: dark ? const Color(0xFF00FFFF) : const Color(0xFF7A008E),
      textColor: dark ? Colors.white : Colors.black,
      mutedTextColor: dark ? const Color(0xFFD7D7D7) : const Color(0xFF333333),
      successColor: dark ? const Color(0xFF66FF99) : const Color(0xFF006B35),
      warningColor: dark ? const Color(0xFFFFD54A) : const Color(0xFF704A00),
      errorColor: dark ? const Color(0xFFFF7070) : const Color(0xFFB00020),
      dividerColor: dark ? Colors.white : Colors.black,
      selectionColor: dark ? const Color(0xFF343400) : const Color(0xFFDDE1FF),
      focusColor: dark ? const Color(0xFFFFFF00) : const Color(0xFF0000CC),
      cardRadius: 4,
      connectorThickness: 3,
      indicatorSize: 26,
    );
  }

  factory TimelineThemeData.darkProfessional() {
    return const TimelineThemeData(
      visualStyle: TimelineVisualStyle.darkProfessional,
      brightness: Brightness.dark,
      backgroundColor: Color(0xFF090C11),
      surfaceColor: Color(0xFF121720),
      surfaceVariantColor: Color(0xFF1A2230),
      primaryColor: Color(0xFF7AA7FF),
      secondaryColor: Color(0xFF56C7B7),
      textColor: Color(0xFFF4F6FA),
      mutedTextColor: Color(0xFF94A0B3),
      successColor: Color(0xFF43C58B),
      warningColor: Color(0xFFE5A84B),
      errorColor: Color(0xFFFF6C78),
      dividerColor: Color(0xFF283244),
      selectionColor: Color(0xFF22375D),
      focusColor: Color(0xFF8BB4FF),
      cardRadius: 14,
      itemSpacing: 10,
      railExtent: 46,
      indicatorSize: 20,
    );
  }

  factory TimelineThemeData.aurora({Brightness brightness = Brightness.dark}) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.aurora,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF071018) : const Color(0xFFF1F8FA),
      surfaceColor: dark ? const Color(0xFF10202A) : const Color(0xFFF9FEFF),
      surfaceVariantColor: dark
          ? const Color(0xFF162D38)
          : const Color(0xFFE3F3F5),
      primaryColor: const Color(0xFF42E8C3),
      secondaryColor: const Color(0xFF8B7CFF),
      textColor: dark ? const Color(0xFFF4FFFD) : const Color(0xFF102326),
      mutedTextColor: dark ? const Color(0xFF9AB8B5) : const Color(0xFF5E7476),
      successColor: const Color(0xFF37D391),
      warningColor: const Color(0xFFFFC857),
      errorColor: const Color(0xFFFF7188),
      dividerColor: dark ? const Color(0xFF24414A) : const Color(0xFFCDE2E4),
      selectionColor: dark ? const Color(0xFF173F43) : const Color(0xFFD8F8F0),
      focusColor: const Color(0xFF42E8C3),
      cardRadius: 24,
      itemSpacing: 14,
      railExtent: 50,
      indicatorSize: 22,
      glowRadius: 5,
      useGlow: true,
      motionDuration: const Duration(milliseconds: 260),
    );
  }

  factory TimelineThemeData.softProfessional({
    Brightness brightness = Brightness.light,
  }) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.softProfessional,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF111318) : const Color(0xFFF7F5F2),
      surfaceColor: dark ? const Color(0xFF1A1D24) : const Color(0xFFFFFEFC),
      surfaceVariantColor: dark
          ? const Color(0xFF232832)
          : const Color(0xFFF0ECE7),
      primaryColor: dark ? const Color(0xFFB6A7FF) : const Color(0xFF6656C8),
      secondaryColor: dark ? const Color(0xFF80D8C8) : const Color(0xFF2F8378),
      textColor: dark ? const Color(0xFFF5F3F7) : const Color(0xFF26222B),
      mutedTextColor: dark ? const Color(0xFFA9A3B0) : const Color(0xFF746D79),
      successColor: const Color(0xFF3A9B72),
      warningColor: const Color(0xFFC4862D),
      errorColor: const Color(0xFFC95F6D),
      dividerColor: dark ? const Color(0xFF34303A) : const Color(0xFFE3DDD7),
      selectionColor: dark ? const Color(0xFF34304C) : const Color(0xFFE9E4FF),
      focusColor: dark ? const Color(0xFFC4B8FF) : const Color(0xFF6656C8),
      cardRadius: 20,
      cardPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemSpacing: 12,
      railExtent: 46,
      indicatorSize: 18,
      elevation: dark ? 0 : 1,
    );
  }

  factory TimelineThemeData.horizon({
    Brightness brightness = Brightness.light,
  }) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.horizon,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF07131F) : const Color(0xFFF3F8FC),
      surfaceColor: dark ? const Color(0xFF102235) : const Color(0xFFFFFFFF),
      surfaceVariantColor: dark
          ? const Color(0xFF193149)
          : const Color(0xFFE8F2F8),
      primaryColor: dark ? const Color(0xFF62D8FF) : const Color(0xFF0877B9),
      secondaryColor: dark ? const Color(0xFFFFB86B) : const Color(0xFFD66719),
      textColor: dark ? const Color(0xFFF4FBFF) : const Color(0xFF10212D),
      mutedTextColor: dark ? const Color(0xFF9EB6C7) : const Color(0xFF607686),
      successColor: const Color(0xFF31B77A),
      warningColor: const Color(0xFFF0A63A),
      errorColor: const Color(0xFFE95F6C),
      dividerColor: dark ? const Color(0xFF29465D) : const Color(0xFFD5E4ED),
      selectionColor: dark ? const Color(0xFF153D57) : const Color(0xFFD9F1FC),
      focusColor: dark ? const Color(0xFF62D8FF) : const Color(0xFF0877B9),
      cardRadius: 26,
      cardPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemSpacing: 14,
      railExtent: 50,
      indicatorSize: 20,
      elevation: dark ? 0 : 1,
      motionDuration: const Duration(milliseconds: 240),
    );
  }

  factory TimelineThemeData.obsidian() {
    return const TimelineThemeData(
      visualStyle: TimelineVisualStyle.obsidian,
      brightness: Brightness.dark,
      backgroundColor: Color(0xFF050608),
      surfaceColor: Color(0xFF101216),
      surfaceVariantColor: Color(0xFF191C22),
      primaryColor: Color(0xFFD9FF55),
      secondaryColor: Color(0xFF7C8CFF),
      textColor: Color(0xFFF8F9FB),
      mutedTextColor: Color(0xFF979CA8),
      successColor: Color(0xFF54D99B),
      warningColor: Color(0xFFFFC15A),
      errorColor: Color(0xFFFF6F7D),
      dividerColor: Color(0xFF2A2E36),
      selectionColor: Color(0xFF283019),
      focusColor: Color(0xFFD9FF55),
      cardRadius: 16,
      cardPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemSpacing: 10,
      railExtent: 46,
      indicatorSize: 18,
      connectorThickness: 1.5,
      motionDuration: Duration(milliseconds: 190),
    );
  }

  factory TimelineThemeData.paper({Brightness brightness = Brightness.light}) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.paper,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF171512) : const Color(0xFFF5F0E7),
      surfaceColor: dark ? const Color(0xFF211F1B) : const Color(0xFFFFFCF5),
      surfaceVariantColor: dark
          ? const Color(0xFF2C2923)
          : const Color(0xFFEDE5D7),
      primaryColor: dark ? const Color(0xFFFFB48A) : const Color(0xFFB14A27),
      secondaryColor: dark ? const Color(0xFF9BC6B0) : const Color(0xFF3C7560),
      textColor: dark ? const Color(0xFFF7F0E5) : const Color(0xFF2A241D),
      mutedTextColor: dark ? const Color(0xFFB7AA9A) : const Color(0xFF7C6F60),
      successColor: const Color(0xFF4A8E67),
      warningColor: const Color(0xFFC1842D),
      errorColor: const Color(0xFFB95C50),
      dividerColor: dark ? const Color(0xFF3B362E) : const Color(0xFFDDD1BF),
      selectionColor: dark ? const Color(0xFF493026) : const Color(0xFFF2D8C8),
      focusColor: dark ? const Color(0xFFFFB48A) : const Color(0xFFB14A27),
      cardRadius: 6,
      cardPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      itemSpacing: 16,
      railExtent: 52,
      connectorThickness: 1.25,
      indicatorSize: 16,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.45,
      ),
      bodyStyle: const TextStyle(height: 1.45),
    );
  }

  factory TimelineThemeData.signal({Brightness brightness = Brightness.dark}) {
    final dark = brightness == Brightness.dark;
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.signal,
      brightness: brightness,
      backgroundColor: dark ? const Color(0xFF070A12) : const Color(0xFFF5F7FF),
      surfaceColor: dark ? const Color(0xFF101727) : const Color(0xFFFFFFFF),
      surfaceVariantColor: dark
          ? const Color(0xFF172139)
          : const Color(0xFFE9EDFA),
      primaryColor: const Color(0xFF7C5CFF),
      secondaryColor: const Color(0xFF00D6C9),
      textColor: dark ? const Color(0xFFF7F7FF) : const Color(0xFF17172B),
      mutedTextColor: dark ? const Color(0xFFA8A9C0) : const Color(0xFF6D6F86),
      successColor: const Color(0xFF32CF8E),
      warningColor: const Color(0xFFFFBD57),
      errorColor: const Color(0xFFFF667A),
      dividerColor: dark ? const Color(0xFF2A3450) : const Color(0xFFDCE1F0),
      selectionColor: dark ? const Color(0xFF2B2456) : const Color(0xFFE7E1FF),
      focusColor: const Color(0xFF8F76FF),
      cardRadius: 22,
      cardPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemSpacing: 12,
      railExtent: 48,
      indicatorSize: 21,
      glowRadius: 4,
      useGlow: true,
      motionDuration: const Duration(milliseconds: 220),
    );
  }

  factory TimelineThemeData.neonLegacy() {
    final legacy = NeonTimelineThemeData.neon();
    return TimelineThemeData(
      visualStyle: TimelineVisualStyle.neonLegacy,
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF08070E),
      surfaceColor: legacy.surfaceColor,
      surfaceVariantColor: const Color(0xFF1A1626),
      primaryColor: legacy.primaryColor,
      secondaryColor: legacy.secondaryColor,
      textColor: legacy.textColor,
      mutedTextColor: legacy.mutedColor,
      successColor: legacy.completedColor,
      warningColor: const Color(0xFFFFB74D),
      errorColor: legacy.errorColor,
      dividerColor: const Color(0xFF352E4B),
      selectionColor: const Color(0xFF342A59),
      focusColor: legacy.primaryColor,
      cardRadius: 22,
      itemSpacing: 14,
      railExtent: legacy.nodeLaneExtent,
      connectorThickness: legacy.connectorStyle.thickness,
      indicatorSize: legacy.indicatorStyle.size,
      blurSigma: 12,
      glowRadius: legacy.indicatorStyle.glowRadius,
      useBlur: true,
      useGlow: true,
      motionDuration: legacy.animationDuration,
      motionCurve: legacy.animationCurve,
    );
  }

  final TimelineVisualStyle visualStyle;
  final Brightness brightness;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color surfaceVariantColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color mutedTextColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color dividerColor;
  final Color selectionColor;
  final Color focusColor;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final TextStyle? metaStyle;
  final double cardRadius;
  final EdgeInsetsGeometry cardPadding;
  final double itemSpacing;
  final double railExtent;
  final double connectorThickness;
  final double indicatorSize;
  final double elevation;
  final double blurSigma;
  final double glowRadius;
  final bool compact;
  final bool useBlur;
  final bool useGlow;
  final Duration motionDuration;
  final Curve motionCurve;

  Color colorForStatus(TimelineStatus status) {
    return switch (status) {
      TimelineStatus.pending => mutedTextColor,
      TimelineStatus.active => primaryColor,
      TimelineStatus.completed => successColor,
      TimelineStatus.error => errorColor,
      TimelineStatus.disabled => dividerColor,
    };
  }

  NeonTimelineThemeData toLegacyTheme() {
    if (visualStyle == TimelineVisualStyle.neonLegacy) {
      return NeonTimelineThemeData.neon();
    }
    return NeonTimelineThemeData(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      mutedColor: mutedTextColor,
      completedColor: successColor,
      errorColor: errorColor,
      disabledColor: dividerColor,
      indicatorStyle: NeonTimelineIndicatorStyle(
        size: indicatorSize,
        color: primaryColor,
        borderColor: focusColor,
        glowColor: primaryColor,
        secondaryColor: secondaryColor,
        interiorColor: surfaceColor,
        glowRadius: useGlow ? glowRadius : 0,
        effect: useBlur
            ? NeonIndicatorEffect.glass
            : NeonIndicatorEffect.classic,
        particleCount: 0,
        sparkCount: 0,
        detail: useGlow ? 0.45 : 0,
      ),
      connectorStyle: NeonTimelineConnectorStyle(
        color: primaryColor,
        endColor: dividerColor,
        secondaryColor: secondaryColor,
        thickness: connectorThickness,
        glowRadius: useGlow ? glowRadius * 0.5 : 0,
        effect: useGlow
            ? NeonConnectorEffect.energy
            : NeonConnectorEffect.classic,
        animated: false,
        particleCount: 0,
        packetCount: 0,
        detail: useGlow ? 0.35 : 0,
      ),
      tilePadding: EdgeInsets.symmetric(
        vertical: compact ? 4 : itemSpacing * 0.5,
        horizontal: 4,
      ),
      contentGap: compact ? 8 : 12,
      nodeLaneExtent: railExtent,
      verticalMinExtent: compact ? 72 : 96,
      horizontalItemExtent: compact ? 230 : 280,
      animationDuration: motionDuration,
      animationCurve: motionCurve,
      motionDuration: const Duration(milliseconds: 4200),
    );
  }

  NeonScheduleTimelineStyle toLegacyScheduleStyle({int snapMinutes = 5}) {
    return NeonScheduleTimelineStyle(
      pixelsPerMinute: compact ? 1.05 : 1.25,
      minimumEntryExtent: compact ? 48 : 64,
      maximumEntryExtent: compact ? 190 : 260,
      timeColumnWidth: compact ? 44 : 52,
      railLaneExtent: railExtent,
      contentGap: compact ? 8 : 12,
      horizontalPadding: compact ? 10 : 16,
      topPadding: compact ? 10 : 18,
      bottomPadding: 96,
      minimumGapExtent: compact ? 12 : 18,
      maximumGapExtent: compact ? 100 : 150,
      gapScale: compact ? 0.58 : 0.72,
      snapMinutes: snapMinutes,
      overlapIndent: compact ? 6 : 10,
      cardVariant: switch (visualStyle) {
        TimelineVisualStyle.glass => NeonTimelineCardVariant.glass,
        TimelineVisualStyle.neonLegacy => NeonTimelineCardVariant.liquidCrystal,
        TimelineVisualStyle.minimal => NeonTimelineCardVariant.outlined,
        TimelineVisualStyle.editorial => NeonTimelineCardVariant.outlined,
        _ => NeonTimelineCardVariant.solid,
      },
      cardBorderRadius: BorderRadius.circular(cardRadius),
      cardPadding: cardPadding,
      cardBlurSigma: blurSigma,
      useBackdropFilter: useBlur,
      enableCardParallax: false,
      nowColor: primaryColor,
      conflictColor: errorColor,
    );
  }

  @override
  TimelineThemeData copyWith({
    TimelineVisualStyle? visualStyle,
    Brightness? brightness,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? surfaceVariantColor,
    Color? primaryColor,
    Color? secondaryColor,
    Color? textColor,
    Color? mutedTextColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? dividerColor,
    Color? selectionColor,
    Color? focusColor,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
    TextStyle? metaStyle,
    double? cardRadius,
    EdgeInsetsGeometry? cardPadding,
    double? itemSpacing,
    double? railExtent,
    double? connectorThickness,
    double? indicatorSize,
    double? elevation,
    double? blurSigma,
    double? glowRadius,
    bool? compact,
    bool? useBlur,
    bool? useGlow,
    Duration? motionDuration,
    Curve? motionCurve,
  }) {
    return TimelineThemeData(
      visualStyle: visualStyle ?? this.visualStyle,
      brightness: brightness ?? this.brightness,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfaceVariantColor: surfaceVariantColor ?? this.surfaceVariantColor,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      dividerColor: dividerColor ?? this.dividerColor,
      selectionColor: selectionColor ?? this.selectionColor,
      focusColor: focusColor ?? this.focusColor,
      titleStyle: titleStyle ?? this.titleStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      metaStyle: metaStyle ?? this.metaStyle,
      cardRadius: cardRadius ?? this.cardRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      railExtent: railExtent ?? this.railExtent,
      connectorThickness: connectorThickness ?? this.connectorThickness,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      elevation: elevation ?? this.elevation,
      blurSigma: blurSigma ?? this.blurSigma,
      glowRadius: glowRadius ?? this.glowRadius,
      compact: compact ?? this.compact,
      useBlur: useBlur ?? this.useBlur,
      useGlow: useGlow ?? this.useGlow,
      motionDuration: motionDuration ?? this.motionDuration,
      motionCurve: motionCurve ?? this.motionCurve,
    );
  }

  @override
  TimelineThemeData lerp(covariant TimelineThemeData? other, double t) {
    if (other == null) return this;
    return TimelineThemeData(
      visualStyle: t < 0.5 ? visualStyle : other.visualStyle,
      brightness: t < 0.5 ? brightness : other.brightness,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      surfaceVariantColor: Color.lerp(
        surfaceVariantColor,
        other.surfaceVariantColor,
        t,
      )!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      mutedTextColor: Color.lerp(mutedTextColor, other.mutedTextColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t)!,
      focusColor: Color.lerp(focusColor, other.focusColor, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t),
      metaStyle: TextStyle.lerp(metaStyle, other.metaStyle, t),
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      cardPadding: EdgeInsetsGeometry.lerp(cardPadding, other.cardPadding, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
      railExtent: lerpDouble(railExtent, other.railExtent, t)!,
      connectorThickness: lerpDouble(
        connectorThickness,
        other.connectorThickness,
        t,
      )!,
      indicatorSize: lerpDouble(indicatorSize, other.indicatorSize, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      glowRadius: lerpDouble(glowRadius, other.glowRadius, t)!,
      compact: t < 0.5 ? compact : other.compact,
      useBlur: t < 0.5 ? useBlur : other.useBlur,
      useGlow: t < 0.5 ? useGlow : other.useGlow,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimelineThemeData &&
            other.visualStyle == visualStyle &&
            other.brightness == brightness &&
            other.backgroundColor == backgroundColor &&
            other.surfaceColor == surfaceColor &&
            other.surfaceVariantColor == surfaceVariantColor &&
            other.primaryColor == primaryColor &&
            other.secondaryColor == secondaryColor &&
            other.textColor == textColor &&
            other.mutedTextColor == mutedTextColor &&
            other.successColor == successColor &&
            other.warningColor == warningColor &&
            other.errorColor == errorColor &&
            other.dividerColor == dividerColor &&
            other.selectionColor == selectionColor &&
            other.focusColor == focusColor &&
            other.titleStyle == titleStyle &&
            other.bodyStyle == bodyStyle &&
            other.metaStyle == metaStyle &&
            other.cardRadius == cardRadius &&
            other.cardPadding == cardPadding &&
            other.itemSpacing == itemSpacing &&
            other.railExtent == railExtent &&
            other.connectorThickness == connectorThickness &&
            other.indicatorSize == indicatorSize &&
            other.elevation == elevation &&
            other.blurSigma == blurSigma &&
            other.glowRadius == glowRadius &&
            other.compact == compact &&
            other.useBlur == useBlur &&
            other.useGlow == useGlow &&
            other.motionDuration == motionDuration &&
            other.motionCurve == motionCurve;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    visualStyle,
    brightness,
    backgroundColor,
    surfaceColor,
    surfaceVariantColor,
    primaryColor,
    secondaryColor,
    textColor,
    mutedTextColor,
    successColor,
    warningColor,
    errorColor,
    dividerColor,
    selectionColor,
    focusColor,
    titleStyle,
    bodyStyle,
    metaStyle,
    cardRadius,
    cardPadding,
    itemSpacing,
    railExtent,
    connectorThickness,
    indicatorSize,
    elevation,
    blurSigma,
    glowRadius,
    compact,
    useBlur,
    useGlow,
    motionDuration,
    motionCurve,
  ]);
}

class TimelineTheme extends InheritedTheme {
  const TimelineTheme({required this.data, required super.child, super.key});

  final TimelineThemeData data;

  static TimelineThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<TimelineTheme>();
    if (inherited != null) return inherited.data;
    final extension = Theme.of(context).extension<TimelineThemeData>();
    if (extension != null) return extension;
    return TimelineThemeData.modern(brightness: Theme.of(context).brightness);
  }

  @override
  bool updateShouldNotify(TimelineTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TimelineTheme(data: data, child: child);
  }
}

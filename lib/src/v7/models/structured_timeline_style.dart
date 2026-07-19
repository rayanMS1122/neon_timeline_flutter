import 'package:flutter/material.dart';

/// Design tokens for the Structured-style planner timeline introduced in 7.x.
///
/// The preset intentionally mirrors the warm ivory, burgundy, rose, compact
/// time rail, and softly tinted task cards used by planner applications while
/// remaining independent from any application-owned theme or task model.
@immutable
class StructuredTimelineStyle {
  const StructuredTimelineStyle({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.borderColor,
    required this.railColor,
    required this.conflictColor,
    required this.completedColor,
    required this.disabledColor,
    required this.shadowColor,
    this.pixelsPerMinute = 1.35,
    this.minimumEntryExtent = 72,
    this.maximumEntryExtent = 260,
    this.minimumGapExtent = 58,
    this.maximumGapExtent = 190,
    this.horizontalPadding = 16,
    this.timeColumnWidth = 44,
    this.markerWidth = 46,
    this.columnGap = 10,
    this.cardRadius = 20,
    this.cardMinimumHeight = 62,
    this.markerHeight = 58,
    this.completionSize = 22,
    this.dragScale = 1.035,
    this.cardTintOpacity = 0.085,
    this.cardBorderOpacity = 0.18,
    this.dragAnimationDuration = const Duration(milliseconds: 180),
  }) : assert(pixelsPerMinute > 0),
       assert(minimumEntryExtent > 0),
       assert(maximumEntryExtent >= minimumEntryExtent),
       assert(minimumGapExtent >= 0),
       assert(maximumGapExtent >= minimumGapExtent),
       assert(horizontalPadding >= 0),
       assert(timeColumnWidth > 0),
       assert(markerWidth > 0),
       assert(columnGap >= 0),
       assert(cardRadius >= 0),
       assert(cardMinimumHeight > 0),
       assert(markerHeight > 0),
       assert(completionSize > 0),
       assert(dragScale > 0),
       assert(cardTintOpacity >= 0 && cardTintOpacity <= 1),
       assert(cardBorderOpacity >= 0 && cardBorderOpacity <= 1);

  factory StructuredTimelineStyle.light({
    Color primaryColor = const Color(0xFF5B2135),
    Color accentColor = const Color(0xFFE11D48),
  }) {
    return StructuredTimelineStyle(
      backgroundColor: const Color(0xFFF9F8F6),
      surfaceColor: Colors.white,
      cardColor: Colors.white,
      primaryColor: primaryColor,
      accentColor: accentColor,
      textColor: const Color(0xFF1C1917),
      mutedTextColor: const Color(0xFF78716C),
      borderColor: const Color(0xFFE7E2DF),
      railColor: const Color(0xFFE8E3E0),
      conflictColor: const Color(0xFFBE123C),
      completedColor: const Color(0xFF9CA3AF),
      disabledColor: const Color(0xFFB8B2AE),
      shadowColor: const Color(0x22000000),
    );
  }

  factory StructuredTimelineStyle.dark({
    Color primaryColor = const Color(0xFFFB7185),
    Color accentColor = const Color(0xFFE11D48),
  }) {
    return StructuredTimelineStyle(
      backgroundColor: const Color(0xFF09090B),
      surfaceColor: const Color(0xFF151216),
      cardColor: const Color(0xFF1C181D),
      primaryColor: primaryColor,
      accentColor: accentColor,
      textColor: const Color(0xFFFAFAFA),
      mutedTextColor: const Color(0xFFA8A1A7),
      borderColor: const Color(0xFF332B31),
      railColor: const Color(0xFF302930),
      conflictColor: const Color(0xFFFB7185),
      completedColor: const Color(0xFF71717A),
      disabledColor: const Color(0xFF52525B),
      shadowColor: const Color(0x66000000),
      cardTintOpacity: 0.16,
      cardBorderOpacity: 0.28,
    );
  }

  factory StructuredTimelineStyle.warm({
    Color primaryColor = const Color(0xFF6B283D),
    Color accentColor = const Color(0xFFD95D75),
  }) {
    return StructuredTimelineStyle(
      backgroundColor: const Color(0xFFFBF7F3),
      surfaceColor: const Color(0xFFFFFCF9),
      cardColor: const Color(0xFFFFFDFC),
      primaryColor: primaryColor,
      accentColor: accentColor,
      textColor: const Color(0xFF24191C),
      mutedTextColor: const Color(0xFF7D6C70),
      borderColor: const Color(0xFFE8DDD8),
      railColor: const Color(0xFFE7DCD7),
      conflictColor: const Color(0xFFB42345),
      completedColor: const Color(0xFF9A8F91),
      disabledColor: const Color(0xFFB9ADAF),
      shadowColor: const Color(0x1F4C1D2A),
      cardTintOpacity: 0.075,
    );
  }

  factory StructuredTimelineStyle.delight({
    Color primaryColor = const Color(0xFF6A2441),
    Color accentColor = const Color(0xFFE94F78),
  }) {
    return StructuredTimelineStyle(
      backgroundColor: const Color(0xFFF8F4F1),
      surfaceColor: const Color(0xFFFFFCFA),
      cardColor: const Color(0xFFFFFFFF),
      primaryColor: primaryColor,
      accentColor: accentColor,
      textColor: const Color(0xFF211A1D),
      mutedTextColor: const Color(0xFF766A6E),
      borderColor: const Color(0xFFE9DDDF),
      railColor: const Color(0xFFE6DADD),
      conflictColor: const Color(0xFFC61F4A),
      completedColor: const Color(0xFF9A8E92),
      disabledColor: const Color(0xFFB7AAAE),
      shadowColor: const Color(0x1F441326),
      pixelsPerMinute: 1.42,
      minimumEntryExtent: 76,
      maximumEntryExtent: 280,
      minimumGapExtent: 50,
      maximumGapExtent: 150,
      horizontalPadding: 14,
      timeColumnWidth: 48,
      markerWidth: 50,
      columnGap: 9,
      cardRadius: 22,
      cardMinimumHeight: 68,
      markerHeight: 60,
      completionSize: 24,
      dragScale: 1.055,
      cardTintOpacity: 0.07,
      cardBorderOpacity: 0.2,
      dragAnimationDuration: const Duration(milliseconds: 140),
    );
  }

  factory StructuredTimelineStyle.neon({
    Color primaryColor = const Color(0xFFE879F9),
    Color accentColor = const Color(0xFF22D3EE),
  }) {
    return StructuredTimelineStyle(
      backgroundColor: const Color(0xFF080A12),
      surfaceColor: const Color(0xFF111522),
      cardColor: const Color(0xFF151B2A),
      primaryColor: primaryColor,
      accentColor: accentColor,
      textColor: const Color(0xFFF8FAFC),
      mutedTextColor: const Color(0xFF94A3B8),
      borderColor: const Color(0xFF263246),
      railColor: const Color(0xFF243047),
      conflictColor: const Color(0xFFFB7185),
      completedColor: const Color(0xFF64748B),
      disabledColor: const Color(0xFF475569),
      shadowColor: const Color(0x88000000),
      cardTintOpacity: 0.14,
      cardBorderOpacity: 0.34,
    );
  }

  factory StructuredTimelineStyle.highContrast({
    Brightness brightness = Brightness.light,
  }) {
    final dark = brightness == Brightness.dark;
    return StructuredTimelineStyle(
      backgroundColor: dark ? Colors.black : Colors.white,
      surfaceColor: dark ? Colors.black : Colors.white,
      cardColor: dark ? const Color(0xFF111111) : Colors.white,
      primaryColor: dark ? Colors.yellowAccent : const Color(0xFF5B0030),
      accentColor: dark ? Colors.cyanAccent : const Color(0xFF0047AB),
      textColor: dark ? Colors.white : Colors.black,
      mutedTextColor: dark ? const Color(0xFFE5E7EB) : const Color(0xFF292929),
      borderColor: dark ? Colors.white : Colors.black,
      railColor: dark ? Colors.white70 : Colors.black54,
      conflictColor: dark ? Colors.orangeAccent : const Color(0xFFB00020),
      completedColor: dark ? Colors.white70 : const Color(0xFF444444),
      disabledColor: dark ? Colors.white54 : const Color(0xFF666666),
      shadowColor: Colors.transparent,
      cardTintOpacity: 0,
      cardBorderOpacity: 1,
    );
  }

  final Color backgroundColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color mutedTextColor;
  final Color borderColor;
  final Color railColor;
  final Color conflictColor;
  final Color completedColor;
  final Color disabledColor;
  final Color shadowColor;

  final double pixelsPerMinute;
  final double minimumEntryExtent;
  final double maximumEntryExtent;
  final double minimumGapExtent;
  final double maximumGapExtent;
  final double horizontalPadding;
  final double timeColumnWidth;
  final double markerWidth;
  final double columnGap;
  final double cardRadius;
  final double cardMinimumHeight;
  final double markerHeight;
  final double completionSize;
  final double dragScale;
  final double cardTintOpacity;
  final double cardBorderOpacity;
  final Duration dragAnimationDuration;

  StructuredTimelineStyle copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? cardColor,
    Color? primaryColor,
    Color? accentColor,
    Color? textColor,
    Color? mutedTextColor,
    Color? borderColor,
    Color? railColor,
    Color? conflictColor,
    Color? completedColor,
    Color? disabledColor,
    Color? shadowColor,
    double? pixelsPerMinute,
    double? minimumEntryExtent,
    double? maximumEntryExtent,
    double? minimumGapExtent,
    double? maximumGapExtent,
    double? horizontalPadding,
    double? timeColumnWidth,
    double? markerWidth,
    double? columnGap,
    double? cardRadius,
    double? cardMinimumHeight,
    double? markerHeight,
    double? completionSize,
    double? dragScale,
    double? cardTintOpacity,
    double? cardBorderOpacity,
    Duration? dragAnimationDuration,
  }) {
    return StructuredTimelineStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      cardColor: cardColor ?? this.cardColor,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      borderColor: borderColor ?? this.borderColor,
      railColor: railColor ?? this.railColor,
      conflictColor: conflictColor ?? this.conflictColor,
      completedColor: completedColor ?? this.completedColor,
      disabledColor: disabledColor ?? this.disabledColor,
      shadowColor: shadowColor ?? this.shadowColor,
      pixelsPerMinute: pixelsPerMinute ?? this.pixelsPerMinute,
      minimumEntryExtent: minimumEntryExtent ?? this.minimumEntryExtent,
      maximumEntryExtent: maximumEntryExtent ?? this.maximumEntryExtent,
      minimumGapExtent: minimumGapExtent ?? this.minimumGapExtent,
      maximumGapExtent: maximumGapExtent ?? this.maximumGapExtent,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      timeColumnWidth: timeColumnWidth ?? this.timeColumnWidth,
      markerWidth: markerWidth ?? this.markerWidth,
      columnGap: columnGap ?? this.columnGap,
      cardRadius: cardRadius ?? this.cardRadius,
      cardMinimumHeight: cardMinimumHeight ?? this.cardMinimumHeight,
      markerHeight: markerHeight ?? this.markerHeight,
      completionSize: completionSize ?? this.completionSize,
      dragScale: dragScale ?? this.dragScale,
      cardTintOpacity: cardTintOpacity ?? this.cardTintOpacity,
      cardBorderOpacity: cardBorderOpacity ?? this.cardBorderOpacity,
      dragAnimationDuration:
          dragAnimationDuration ?? this.dragAnimationDuration,
    );
  }
}

/// Package-owned default labels. Applications can replace every visible word
/// without depending on `intl` or a specific localization framework.
@immutable
class StructuredTimelineStrings {
  const StructuredTimelineStrings({
    this.nowActive = 'NOW ACTIVE',
    this.next = 'Next',
    this.nextIn = 'Next task in',
    this.done = 'Done',
    this.addTask = 'Add task',
    this.freeToPlan = 'to plan',
    this.conflict = 'Conflict',
    this.overlap = 'overlap',
    this.recurring = 'Recurring',
    this.external = 'External event',
    this.moveBlocked = 'This task cannot be moved here',
    this.delete = 'Delete',
    this.noTasks = 'No tasks',
    this.noTasksDescription = 'Add a task to start planning your day.',
    this.moveEarlier = 'Move earlier',
    this.moveLater = 'Move later',
    this.completeTask = 'Complete task',
    this.timeLeft = 'left',
    this.resizeStart = 'Resize task start',
    this.resizeEnd = 'Resize task end',
    this.resizeBlocked = 'This task cannot be resized here',
    this.saving = 'Saving',
    this.selected = 'Selected',
    this.locked = 'Locked',
    this.startsAt = 'Starts at',
    this.endsAt = 'Ends at',
    this.durationLabel = 'Duration',
    this.retry = 'Retry',
    this.compressedFreeTime = 'Compressed free time',
    this.continuesNextDay = 'Continues into the next day',
  });

  final String nowActive;
  final String next;
  final String nextIn;
  final String done;
  final String addTask;
  final String freeToPlan;
  final String conflict;
  final String overlap;
  final String recurring;
  final String external;
  final String moveBlocked;
  final String delete;
  final String noTasks;
  final String noTasksDescription;
  final String moveEarlier;
  final String moveLater;
  final String completeTask;
  final String timeLeft;
  final String resizeStart;
  final String resizeEnd;
  final String resizeBlocked;
  final String saving;
  final String selected;
  final String locked;
  final String startsAt;
  final String endsAt;
  final String durationLabel;
  final String retry;
  final String compressedFreeTime;
  final String continuesNextDay;
}

enum StructuredTimelineInitialScroll { none, current, next, first }

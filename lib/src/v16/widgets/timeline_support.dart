part of 'timeline.dart';

final class _IndexedEntry<T> implements NeonPlannerInterval {
  _IndexedEntry(this.snapshot);

  final NeonPlannerEntrySnapshot<T> snapshot;

  @override
  int get startMicros => snapshot.start.microsecondsSinceEpoch;

  @override
  int get endMicros => snapshot.end.microsecondsSinceEpoch;
}

final class _Gap {
  const _Gap({required this.start, required this.end, required this.message});

  final DateTime start;
  final DateTime end;
  final String message;

  Duration get duration => end.difference(start);
}

final class _RangeSession {
  const _RangeSession({
    required this.start,
    required this.end,
    required this.hasConflict,
  });

  final DateTime start;
  final DateTime end;
  final bool hasConflict;
}

String _defaultGapMessage(int index) {
  const messages = <String>[
    'Vergangene Momente, gewonnene Erkenntnisse.',
    'Auszeit – Erholung abgeschlossen.',
    'Eine gut verbrachte Pause.',
    'Freie Zeit für das, was jetzt wichtig ist.',
  ];
  return messages[index % messages.length];
}

Color _accentFor<T>(
  NeonPlannerEntrySnapshot<T> snapshot,
  NeonPlannerTimelineThemeData theme,
) {
  final override = snapshot.presentation.accentColor;
  if (override != null) {
    return override;
  }
  return switch (snapshot.presentation.kind) {
    NeonPlannerEntryKind.sleep => theme.nightAccentColor,
    NeonPlannerEntryKind.breakTime => theme.secondaryTextColor,
    NeonPlannerEntryKind.focus => theme.successColor,
    _ => theme.dayAccentColor,
  };
}

double _pixelsPerMinute(NeonPlannerZoomLevel level) {
  return switch (level) {
    NeonPlannerZoomLevel.overview => 0.58,
    NeonPlannerZoomLevel.compact => 0.9,
    NeonPlannerZoomLevel.balanced => 1.35,
    NeonPlannerZoomLevel.comfortable => 2.0,
    NeonPlannerZoomLevel.detailed => 2.8,
    NeonPlannerZoomLevel.cinematic => 4.0,
  };
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

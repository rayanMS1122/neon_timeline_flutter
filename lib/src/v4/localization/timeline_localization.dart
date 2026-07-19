import 'package:flutter/widgets.dart';

/// Host-supplied strings used by package-owned neutral UI fallbacks.
///
/// The package deliberately does not depend on `intl`, Flutter's generated
/// localization pipeline, or any application localization framework. Apps can
/// derive this data from whichever system they already use.
@immutable
class TimelineLocalizationData {
  const TimelineLocalizationData({
    this.resourcesLabel = 'Resources',
    this.noResourcesConfigured = 'No resources configured',
    this.noEntriesInTimeRange = 'No entries in this time range',
  });

  final String resourcesLabel;
  final String noResourcesConfigured;
  final String noEntriesInTimeRange;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimelineLocalizationData &&
            resourcesLabel == other.resourcesLabel &&
            noResourcesConfigured == other.noResourcesConfigured &&
            noEntriesInTimeRange == other.noEntriesInTimeRange;
  }

  @override
  int get hashCode =>
      Object.hash(resourcesLabel, noResourcesConfigured, noEntriesInTimeRange);

  TimelineLocalizationData copyWith({
    String? resourcesLabel,
    String? noResourcesConfigured,
    String? noEntriesInTimeRange,
  }) {
    return TimelineLocalizationData(
      resourcesLabel: resourcesLabel ?? this.resourcesLabel,
      noResourcesConfigured:
          noResourcesConfigured ?? this.noResourcesConfigured,
      noEntriesInTimeRange: noEntriesInTimeRange ?? this.noEntriesInTimeRange,
    );
  }
}

/// Injects package-owned fallback strings below a subtree.
class TimelineLocalization extends InheritedWidget {
  const TimelineLocalization({
    required this.data,
    required super.child,
    super.key,
  });

  static const TimelineLocalizationData fallback = TimelineLocalizationData();

  final TimelineLocalizationData data;

  static TimelineLocalizationData of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<TimelineLocalization>()
            ?.data ??
        fallback;
  }

  @override
  bool updateShouldNotify(TimelineLocalization oldWidget) {
    return data != oldWidget.data;
  }
}

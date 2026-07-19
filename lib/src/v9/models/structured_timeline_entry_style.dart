import 'package:flutter/foundation.dart';

@immutable
class StructuredTimelineEntryStyle {
  const StructuredTimelineEntryStyle({
    this.minimumHeight = 64,
    this.horizontalPadding = 16,
    this.verticalPadding = 10,
    this.titleSize = 15,
    this.subtitleSize = 11,
    this.metaSize = 10,
    this.maximumTitleLines = 2,
    this.maximumSubtitleLines = 2,
    this.showSubtitle = true,
    this.showProgress = true,
    this.showMetadata = true,
    this.actionAreaWidth = 38,
  });

  const StructuredTimelineEntryStyle.compact()
    : this(
        minimumHeight: 52,
        horizontalPadding: 13,
        verticalPadding: 7,
        titleSize: 13.5,
        subtitleSize: 10,
        metaSize: 9.5,
        maximumTitleLines: 1,
        maximumSubtitleLines: 1,
        showSubtitle: false,
        showProgress: false,
        actionAreaWidth: 32,
      );

  const StructuredTimelineEntryStyle.comfortable() : this();

  const StructuredTimelineEntryStyle.delight()
    : this(
        minimumHeight: 76,
        horizontalPadding: 17,
        verticalPadding: 11,
        titleSize: 15.5,
        subtitleSize: 11.5,
        metaSize: 10,
        maximumTitleLines: 2,
        maximumSubtitleLines: 2,
        showSubtitle: true,
        showProgress: true,
        showMetadata: true,
        actionAreaWidth: 42,
      );

  const StructuredTimelineEntryStyle.detailed()
    : this(
        minimumHeight: 92,
        horizontalPadding: 18,
        verticalPadding: 13,
        titleSize: 16,
        subtitleSize: 12,
        metaSize: 10.5,
        maximumTitleLines: 2,
        maximumSubtitleLines: 3,
        actionAreaWidth: 44,
      );

  const StructuredTimelineEntryStyle.minimal()
    : this(
        minimumHeight: 48,
        horizontalPadding: 12,
        verticalPadding: 7,
        titleSize: 14,
        subtitleSize: 10,
        metaSize: 9,
        maximumTitleLines: 1,
        maximumSubtitleLines: 1,
        showSubtitle: false,
        showProgress: false,
        showMetadata: false,
        actionAreaWidth: 28,
      );

  final double minimumHeight;
  final double horizontalPadding;
  final double verticalPadding;
  final double titleSize;
  final double subtitleSize;
  final double metaSize;
  final int maximumTitleLines;
  final int maximumSubtitleLines;
  final bool showSubtitle;
  final bool showProgress;
  final bool showMetadata;
  final double actionAreaWidth;

  StructuredTimelineEntryStyle copyWith({
    double? minimumHeight,
    double? horizontalPadding,
    double? verticalPadding,
    double? titleSize,
    double? subtitleSize,
    double? metaSize,
    int? maximumTitleLines,
    int? maximumSubtitleLines,
    bool? showSubtitle,
    bool? showProgress,
    bool? showMetadata,
    double? actionAreaWidth,
  }) {
    return StructuredTimelineEntryStyle(
      minimumHeight: minimumHeight ?? this.minimumHeight,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      titleSize: titleSize ?? this.titleSize,
      subtitleSize: subtitleSize ?? this.subtitleSize,
      metaSize: metaSize ?? this.metaSize,
      maximumTitleLines: maximumTitleLines ?? this.maximumTitleLines,
      maximumSubtitleLines: maximumSubtitleLines ?? this.maximumSubtitleLines,
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showProgress: showProgress ?? this.showProgress,
      showMetadata: showMetadata ?? this.showMetadata,
      actionAreaWidth: actionAreaWidth ?? this.actionAreaWidth,
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/neon_timeline_item.dart';
import '../models/neon_timeline_types.dart';
import '../theme/neon_timeline_theme.dart';
import 'internal/neon_timeline_source.dart';
import 'neon_timeline_motion.dart';

/// A lazy, scrollable, status-aware timeline.
///
/// Use the default constructor for a small declarative list, and
/// [NeonTimeline.builder] for large or dynamic data sets.
class NeonTimeline extends StatelessWidget {
  /// Creates a timeline from declarative [items].
  NeonTimeline({
    required List<NeonTimelineItem> items,
    this.axis = Axis.vertical,
    this.layout = NeonTimelineLayout.adaptive,
    this.theme,
    this.controller,
    this.physics,
    this.padding,
    this.primary,
    this.reverse = false,
    this.shrinkWrap = false,
    this.itemExtent,
    this.indicatorPosition = 0.5,
    this.animate = true,
    this.motionEnabled = true,
    this.motionPhaseOffset = 0,
    this.motionFramesPerSecond = 30,
    this.pauseMotionWhileScrolling = true,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    super.key,
  })  : assert(itemExtent == null || itemExtent > 0),
        assert(indicatorPosition >= 0 && indicatorPosition <= 1),
        assert(motionPhaseOffset >= 0 && motionPhaseOffset <= 1),
        assert(motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
        _source = NeonTimelineSource.items(items);

  /// Creates a lazily built timeline.
  NeonTimeline.builder({
    required int itemCount,
    required NeonTimelineContentBuilder contentBuilder,
    NeonTimelineContentBuilder? oppositeContentBuilder,
    NeonTimelineContentBuilder? indicatorBuilder,
    NeonTimelineStatusBuilder? statusBuilder,
    NeonTimelineSemanticLabelBuilder? semanticLabelBuilder,
    NeonTimelineItemCallback? onItemTap,
    NeonTimelineConnectorStyleBuilder? connectorStyleBuilder,
    NeonTimelineKeyBuilder? keyBuilder,
    this.axis = Axis.vertical,
    this.layout = NeonTimelineLayout.adaptive,
    this.theme,
    this.controller,
    this.physics,
    this.padding,
    this.primary,
    this.reverse = false,
    this.shrinkWrap = false,
    this.itemExtent,
    this.indicatorPosition = 0.5,
    this.animate = true,
    this.motionEnabled = true,
    this.motionPhaseOffset = 0,
    this.motionFramesPerSecond = 30,
    this.pauseMotionWhileScrolling = true,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    super.key,
  })  : assert(itemCount >= 0),
        assert(itemExtent == null || itemExtent > 0),
        assert(indicatorPosition >= 0 && indicatorPosition <= 1),
        assert(motionPhaseOffset >= 0 && motionPhaseOffset <= 1),
        assert(motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
        _source = NeonTimelineSource.builder(
          itemCount: itemCount,
          contentBuilder: contentBuilder,
          oppositeContentBuilder: oppositeContentBuilder,
          indicatorBuilder: indicatorBuilder,
          statusBuilder: statusBuilder,
          semanticLabelBuilder: semanticLabelBuilder,
          onItemTap: onItemTap,
          connectorStyleBuilder: connectorStyleBuilder,
          keyBuilder: keyBuilder,
        );

  final NeonTimelineSource _source;

  /// Main scroll and connector axis.
  final Axis axis;

  /// Rail and content placement strategy.
  final NeonTimelineLayout layout;

  /// Optional local theme override.
  final NeonTimelineThemeData? theme;

  /// Scroll position controller.
  final ScrollController? controller;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Insets around the complete scrollable list.
  final EdgeInsetsGeometry? padding;

  /// Whether this is the primary scroll view.
  final bool? primary;

  /// Whether the scroll direction is reversed.
  final bool reverse;

  /// Whether the scroll view should size itself to its children.
  final bool shrinkWrap;

  /// Optional fixed main-axis extent for every item.
  final double? itemExtent;

  /// Marker position within each item's main-axis extent.
  final double indicatorPosition;

  /// Whether newly built entries reveal with a short transition.
  final bool animate;

  /// Whether the shared indicator and connector motion clock is enabled.
  ///
  /// Disable this for static captures, golden tests, or battery-sensitive
  /// surfaces.
  final bool motionEnabled;

  /// Normalized starting phase from `0` to `1` for deterministic staggering.
  final double motionPhaseOffset;

  /// Maximum expensive painter updates per second.
  final int motionFramesPerSecond;

  /// Whether painter motion pauses while a descendant scrollable moves.
  final bool pauseMotionWhileScrolling;

  /// Optional replacement shown when there are no items.
  final WidgetBuilder? emptyBuilder;

  /// Maps a child key back to its new index after reordering.
  final ChildIndexGetter? findChildIndexCallback;

  /// Whether lazy children should be kept alive automatically.
  final bool addAutomaticKeepAlives;

  /// Whether lazy children should receive repaint boundaries automatically.
  final bool addRepaintBoundaries;

  /// Whether lazy children should receive semantic indexes automatically.
  final bool addSemanticIndexes;

  /// Viewport cache extent in logical pixels.
  final double? cacheExtent;

  /// Keyboard dismissal behavior while scrolling.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// How content outside the viewport is clipped.
  final Clip clipBehavior;

  /// Restoration identifier for the scroll position.
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? NeonTimelineTheme.of(context);
    Widget result;
    if (_source.length == 0) {
      result = emptyBuilder?.call(context) ?? const SizedBox.shrink();
    } else {
      final configuredItemExtent = itemExtent;
      final resolvedItemExtent = configuredItemExtent != null &&
              configuredItemExtent.isFinite &&
              configuredItemExtent > 0
          ? configuredItemExtent
          : (axis == Axis.horizontal
              ? resolvedTheme.horizontalItemExtent
              : null);
      final resolvedCacheExtent = cacheExtent == null || !cacheExtent!.isFinite
          ? null
          : math.max(0.0, cacheExtent!);
      result = ListView.builder(
        scrollDirection: axis,
        controller: controller,
        physics: physics,
        padding: padding,
        primary: primary,
        reverse: reverse,
        shrinkWrap: shrinkWrap,
        itemCount: _source.length,
        itemExtent: resolvedItemExtent,
        findChildIndexCallback: findChildIndexCallback,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: resolvedCacheExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        itemBuilder: (context, index) {
          return _source.buildTile(
            context,
            index,
            axis: axis,
            layout: layout,
            theme: resolvedTheme,
            animate: animate,
            itemExtent: resolvedItemExtent,
            indicatorPosition: indicatorPosition,
          );
        },
      );
    }
    return NeonTimelineTheme(
      data: resolvedTheme,
      child: NeonTimelineMotionScope(
        enabled: motionEnabled,
        duration: resolvedTheme.motionDuration,
        phaseOffset: motionPhaseOffset,
        framesPerSecond: motionFramesPerSecond,
        pauseWhenScrolling: pauseMotionWhileScrolling,
        child: result,
      ),
    );
  }
}

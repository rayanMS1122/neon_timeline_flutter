import 'package:flutter/material.dart';

import '../models/neon_timeline_item.dart';
import '../models/neon_timeline_types.dart';
import '../performance/neon_timeline_performance_config.dart';
import '../theme/neon_timeline_theme.dart';
import 'internal/neon_timeline_source.dart';
import 'neon_timeline_motion.dart';

/// Sliver counterpart to `NeonTimeline` for `CustomScrollView` composition.
///
/// Set [axis] to the surrounding scroll view's `scrollDirection`.
class NeonSliverTimeline extends StatelessWidget {
  /// Creates a sliver timeline from declarative [items].
  NeonSliverTimeline({
    required List<NeonTimelineItem> items,
    this.axis = Axis.vertical,
    this.layout = NeonTimelineLayout.adaptive,
    this.theme,
    this.itemExtent,
    this.indicatorPosition = 0.5,
    this.animate = true,
    this.motionEnabled = true,
    this.motionPhaseOffset = 0,
    this.motionFramesPerSecond = 24,
    this.pauseMotionWhileScrolling = true,
    this.maxAnimatedItems = 1,
    this.animateOnlyActiveItems = true,
    this.animatedItemIndexes,
    this.performance,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  }) : assert(itemExtent == null || itemExtent > 0),
       assert(indicatorPosition >= 0 && indicatorPosition <= 1),
       assert(motionPhaseOffset >= 0 && motionPhaseOffset <= 1),
       assert(motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
       assert(maxAnimatedItems >= 0),
       _source = NeonTimelineSource.items(items);

  /// Creates a lazily built sliver timeline.
  NeonSliverTimeline.builder({
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
    this.itemExtent,
    this.indicatorPosition = 0.5,
    this.animate = true,
    this.motionEnabled = true,
    this.motionPhaseOffset = 0,
    this.motionFramesPerSecond = 24,
    this.pauseMotionWhileScrolling = true,
    this.maxAnimatedItems = 1,
    this.animateOnlyActiveItems = true,
    this.animatedItemIndexes,
    this.performance,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  }) : assert(itemCount >= 0),
       assert(itemExtent == null || itemExtent > 0),
       assert(indicatorPosition >= 0 && indicatorPosition <= 1),
       assert(motionPhaseOffset >= 0 && motionPhaseOffset <= 1),
       assert(motionFramesPerSecond >= 1 && motionFramesPerSecond <= 120),
       assert(maxAnimatedItems >= 0),
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

  /// Maximum number of items allowed to repaint continuously.
  final int maxAnimatedItems;

  /// Whether only active items are eligible for continuous motion.
  final bool animateOnlyActiveItems;

  /// Optional application-provided animated indexes. Supplying this avoids a
  /// full status scan for very large builder timelines. Invalid indexes are
  /// ignored and [maxAnimatedItems] is still enforced.
  final Iterable<int>? animatedItemIndexes;

  /// Optional adaptive rendering policy.
  final NeonTimelinePerformanceConfig? performance;

  /// Optional box child shown through `SliverToBoxAdapter` when empty.
  final WidgetBuilder? emptyBuilder;

  /// Maps a child key back to its new index after reordering.
  final ChildIndexGetter? findChildIndexCallback;

  /// Whether lazy children should be kept alive automatically.
  final bool addAutomaticKeepAlives;

  /// Whether lazy children should receive repaint boundaries automatically.
  final bool addRepaintBoundaries;

  /// Whether lazy children should receive semantic indexes automatically.
  final bool addSemanticIndexes;

  Set<int> _resolveAnimatedIndexes(int requestedLimit) {
    if (!motionEnabled || requestedLimit <= 0 || _source.length == 0) {
      return const <int>{};
    }
    final limit = requestedLimit.clamp(0, _source.length).toInt();
    final indexes = <int>{};
    final providedIndexes = animatedItemIndexes;
    if (providedIndexes != null) {
      for (final index in providedIndexes) {
        if (index < 0 || index >= _source.length) continue;
        if (!animateOnlyActiveItems ||
            _source.statusAt(index) == NeonTimelineStatus.active) {
          indexes.add(index);
          if (indexes.length >= limit) break;
        }
      }
      return indexes;
    }
    for (var index = 0; index < _source.length; index++) {
      final status = _source.statusAt(index);
      if (!animateOnlyActiveItems || status == NeonTimelineStatus.active) {
        indexes.add(index);
        if (indexes.length >= limit) break;
      }
    }
    return indexes;
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = theme ?? NeonTimelineTheme.of(context);
    final resolvedPerformance = performance?.resolve(
      context,
      itemCount: _source.length,
    );
    final resolvedTheme =
        resolvedPerformance?.tuneTheme(baseTheme) ?? baseTheme;
    final animatedIndexes = _resolveAnimatedIndexes(
      resolvedPerformance?.maxAnimatedEntries ?? maxAnimatedItems,
    );
    Widget sliver;
    if (_source.length == 0) {
      sliver = SliverToBoxAdapter(
        child: emptyBuilder?.call(context) ?? const SizedBox.shrink(),
      );
    } else {
      final configuredItemExtent = itemExtent;
      final resolvedItemExtent =
          configuredItemExtent != null &&
              configuredItemExtent.isFinite &&
              configuredItemExtent > 0
          ? configuredItemExtent
          : (axis == Axis.horizontal
                ? resolvedTheme.horizontalItemExtent
                : null);
      final delegate = SliverChildBuilderDelegate(
        (context, index) {
          return _source.buildTile(
            context,
            index,
            axis: axis,
            layout: layout,
            theme: resolvedTheme,
            animate: animate,
            animatedIndexes: animatedIndexes,
            itemExtent: resolvedItemExtent,
            indicatorPosition: indicatorPosition,
          );
        },
        childCount: _source.length,
        findChildIndexCallback: findChildIndexCallback,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
      sliver = resolvedItemExtent == null
          ? SliverList(delegate: delegate)
          : SliverFixedExtentList(
              delegate: delegate,
              itemExtent: resolvedItemExtent,
            );
    }
    return NeonTimelineTheme(
      data: resolvedTheme,
      child: NeonTimelineMotionScope(
        enabled: motionEnabled && animatedIndexes.isNotEmpty,
        duration: resolvedTheme.motionDuration,
        phaseOffset: motionPhaseOffset,
        framesPerSecond:
            resolvedPerformance?.motionFramesPerSecond ?? motionFramesPerSecond,
        pauseWhenScrolling:
            resolvedPerformance?.pauseMotionWhileScrolling ??
            pauseMotionWhileScrolling,
        startupDelay:
            resolvedPerformance?.motionStartupDelay ??
            const Duration(milliseconds: 120),
        child: sliver,
      ),
    );
  }
}

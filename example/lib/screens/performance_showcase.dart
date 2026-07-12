import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class PerformanceShowcase extends StatefulWidget {
  const PerformanceShowcase({required this.performance, super.key});

  final NeonTimelinePerformanceConfig performance;

  @override
  State<PerformanceShowcase> createState() => _PerformanceShowcaseState();
}

class _PerformanceShowcaseState extends State<PerformanceShowcase> {
  final ScrollController _controller = ScrollController();
  int _itemCount = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.performance.resolve(
      context,
      itemCount: _itemCount,
    );
    return Column(
      children: <Widget>[
        NeonTimelineHeader(
          title: 'Lazy performance showcase',
          subtitle:
              'Up to 500 rows; offscreen cards are not built or animated.',
          trailing: IconButton(
            tooltip: 'Jump to top',
            icon: const Icon(Icons.vertical_align_top_rounded),
            onPressed: () {
              if (!_controller.hasClients) return;
              _controller.animateTo(
                0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ),
        _PerformanceSummary(
          itemCount: _itemCount,
          resolved: resolved,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 20, label: Text('20')),
              ButtonSegment<int>(value: 100, label: Text('100')),
              ButtonSegment<int>(value: 500, label: Text('500')),
            ],
            selected: <int>{_itemCount},
            onSelectionChanged: (selection) {
              setState(() => _itemCount = selection.first);
            },
          ),
        ),
        Expanded(
          child: NeonTimeline.builder(
            controller: _controller,
            itemCount: _itemCount,
            itemExtent: 104,
            performance: widget.performance,
            animatedItemIndexes: const <int>[2],
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            cacheExtent: resolved.cacheExtent,
            statusBuilder: (index) => index == 2
                ? NeonTimelineStatus.active
                : index < 2
                    ? NeonTimelineStatus.completed
                    : index % 37 == 0
                        ? NeonTimelineStatus.error
                        : NeonTimelineStatus.pending,
            keyBuilder: (context, details) => ValueKey<int>(details.index),
            oppositeContentBuilder: (context, details) => Text(
              '#${details.index + 1}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            contentBuilder: (context, details) {
              final status = details.status;
              final color =
                  NeonTimelineTheme.of(context).colorForStatus(status);
              return NeonTimelineCard(
                variant: NeonTimelineCardVariant.liquidCrystal,
                accentColor: color,
                animate: status == NeonTimelineStatus.active,
                continuousAnimation: false,
                useBackdropFilter: resolved.enableBackdropBlur,
                enableParallax: resolved.enableParallax,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Virtualized item ${details.index + 1}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Built lazily near the viewport',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.55),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    NeonTimelineBadge(
                      label: status.name,
                      color: color,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PerformanceSummary extends StatelessWidget {
  const _PerformanceSummary({
    required this.itemCount,
    required this.resolved,
  });

  final int itemCount;
  final NeonTimelineResolvedPerformance resolved;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      NeonTimelineBadge(
        label: kIsWeb ? 'Web' : defaultTargetPlatform.name,
        icon: kIsWeb ? Icons.language_rounded : Icons.devices_rounded,
      ),
      NeonTimelineBadge(
        label: '${resolved.motionFramesPerSecond} FPS',
        icon: Icons.speed_rounded,
      ),
      NeonTimelineBadge(
        label: '${resolved.maxAnimatedEntries} animated',
        icon: Icons.motion_photos_on_rounded,
      ),
      NeonTimelineBadge(
        label: '$itemCount lazy rows',
        icon: Icons.view_stream_rounded,
      ),
      NeonTimelineBadge(
        label: resolved.enableBackdropBlur ? 'Native blur' : 'Contour glow',
        icon: Icons.blur_on_rounded,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }
}

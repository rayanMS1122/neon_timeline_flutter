import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

class GenericShowcase extends StatefulWidget {
  const GenericShowcase({required this.performance, super.key});

  final NeonTimelinePerformanceConfig performance;

  @override
  State<GenericShowcase> createState() => _GenericShowcaseState();
}

class _GenericShowcaseState extends State<GenericShowcase> {
  _TimelineDemoMode _mode = _TimelineDemoMode.lazy;

  static const _labels = <String>[
    'Project created',
    'Public API designed',
    'Performance architecture',
    'Accessibility review',
    'Tests and documentation',
    'Ready for integration',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NeonTimelineHeader(
          title: 'Core timeline variants',
          subtitle:
              'Lazy, horizontal, fixed, and sliver APIs use the same theme.',
          trailing: PopupMenuButton<_TimelineDemoMode>(
            tooltip: 'Choose timeline type',
            initialValue: _mode,
            onSelected: (value) => setState(() => _mode = value),
            itemBuilder: (context) => _TimelineDemoMode.values
                .map(
                  (mode) => PopupMenuItem<_TimelineDemoMode>(
                    value: mode,
                    child: Text(mode.label),
                  ),
                )
                .toList(growable: false),
            child: NeonTimelineBadge(
              label: _mode.label,
              icon: _mode.icon,
            ),
          ),
        ),
        Expanded(child: _buildDemo()),
      ],
    );
  }

  Widget _buildDemo() {
    return switch (_mode) {
      _TimelineDemoMode.lazy => _buildLazy(),
      _TimelineDemoMode.horizontal => _buildHorizontal(),
      _TimelineDemoMode.fixed => _buildFixed(),
      _TimelineDemoMode.sliver => _buildSliver(),
    };
  }

  Widget _buildLazy() {
    return NeonTimeline.builder(
      itemCount: _labels.length,
      performance: widget.performance,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      statusBuilder: _statusAt,
      keyBuilder: (context, details) => ValueKey<String>(
        'lazy-${details.index}',
      ),
      semanticLabelBuilder: (context, details) =>
          '${_labels[details.index]}, ${_statusAt(details.index).name}',
      oppositeContentBuilder: (context, details) => Text(
        '${9 + details.index}:00',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      contentBuilder: (context, details) => _DemoContentCard(
        title: _labels[details.index],
        subtitle: 'Lazy builder item ${details.index + 1}',
        status: details.status,
      ),
      onItemTap: (context, details) => _showMessage(
        'Tapped ${_labels[details.index]}',
      ),
    );
  }

  Widget _buildHorizontal() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      child: NeonTimeline.builder(
        axis: Axis.horizontal,
        layout: NeonTimelineLayout.center,
        itemExtent: 230,
        itemCount: _labels.length,
        performance: widget.performance,
        addAutomaticKeepAlives: false,
        statusBuilder: _statusAt,
        contentBuilder: (context, details) => SizedBox(
          width: 190,
          child: _DemoContentCard(
            title: _labels[details.index],
            subtitle: 'Horizontal timeline',
            status: details.status,
          ),
        ),
        oppositeContentBuilder: (context, details) => Text(
          'STEP ${details.index + 1}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
      ),
    );
  }

  Widget _buildFixed() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      child: NeonFixedTimeline.builder(
        itemCount: 4,
        performance: widget.performance,
        statusBuilder: _statusAt,
        oppositeContentBuilder: (context, details) => Text(
          '0${details.index + 1}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        contentBuilder: (context, details) => _DemoContentCard(
          title: _labels[details.index],
          subtitle: 'Non-scrolling fixed timeline',
          status: details.status,
        ),
      ),
    );
  }

  Widget _buildSliver() {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
          sliver: SliverToBoxAdapter(
            child: Text(
              'The sliver variant composes directly with other slivers.',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: NeonSliverTimeline.builder(
            itemCount: _labels.length,
            performance: widget.performance,
            addAutomaticKeepAlives: false,
            statusBuilder: _statusAt,
            oppositeContentBuilder: (context, details) => Text(
              '${details.index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            contentBuilder: (context, details) => _DemoContentCard(
              title: _labels[details.index],
              subtitle: 'Sliver child ${details.index + 1}',
              status: details.status,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  NeonTimelineStatus _statusAt(int index) {
    return switch (index) {
      0 || 1 => NeonTimelineStatus.completed,
      2 => NeonTimelineStatus.active,
      4 => NeonTimelineStatus.error,
      _ => NeonTimelineStatus.pending,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DemoContentCard extends StatelessWidget {
  const _DemoContentCard({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final NeonTimelineStatus status;

  @override
  Widget build(BuildContext context) {
    final timelineTheme = NeonTimelineTheme.of(context);
    final color = timelineTheme.colorForStatus(status);
    return NeonTimelineCard(
      variant: NeonTimelineCardVariant.glass,
      accentColor: color,
      animate: status == NeonTimelineStatus.active,
      continuousAnimation: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.58),
                ),
          ),
        ],
      ),
    );
  }
}

enum _TimelineDemoMode { lazy, horizontal, fixed, sliver }

extension on _TimelineDemoMode {
  String get label => switch (this) {
        _TimelineDemoMode.lazy => 'Lazy',
        _TimelineDemoMode.horizontal => 'Horizontal',
        _TimelineDemoMode.fixed => 'Fixed',
        _TimelineDemoMode.sliver => 'Sliver',
      };

  IconData get icon => switch (this) {
        _TimelineDemoMode.lazy => Icons.view_agenda_rounded,
        _TimelineDemoMode.horizontal => Icons.swap_horiz_rounded,
        _TimelineDemoMode.fixed => Icons.vertical_align_center_rounded,
        _TimelineDemoMode.sliver => Icons.layers_rounded,
      };
}

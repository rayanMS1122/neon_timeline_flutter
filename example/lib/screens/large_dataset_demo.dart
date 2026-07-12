import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

import '../demo_data.dart';

class LargeDatasetDemo extends StatefulWidget {
  const LargeDatasetDemo({super.key});

  @override
  State<LargeDatasetDemo> createState() => _LargeDatasetDemoState();
}

class _LargeDatasetDemoState extends State<LargeDatasetDemo> {
  static const int _itemCount = 500;
  late final List<NeonScheduleEntry<DemoTask>> _entries;
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _autoScroll = false;
  bool _showPerformance = true;
  int _scrollDirection = 0;

  @override
  void initState() {
    super.initState();
    _entries = demoRepo.generateLargeScheduleEntries(_itemCount);
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_autoScroll || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 100) {
        _scrollDirection = -1;
      } else if (position.pixels <= 100) {
        _scrollDirection = 1;
      }
      final newOffset = (position.pixels + _scrollDirection * 2).clamp(0.0, position.maxScrollExtent);
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Large Dataset (500 entries)'),
        backgroundColor: Colors.transparent,
        actions: [
          _buildToggle('Auto Scroll', _autoScroll, (v) => setState(() => _autoScroll = v)),
          _buildToggle('Show Perf', _showPerformance, (v) => setState(() => _showPerformance = v)),
          IconButton(
            tooltip: 'Jump to Middle',
            icon: const Icon(Icons.vertical_align_center),
            onPressed: () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent / 2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ),
          ),
          IconButton(
            tooltip: 'Jump to End',
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onPressed: () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          NeonScheduleTimeline<DemoTask>(
            entries: _entries,
            selectedDate: DateTime(2026, 7, 12),
            now: DateTime(2026, 7, 12, 14, 30),
            emptyBuilder: (context) => const _EmptyState(
              icon: Icons.data_usage,
              title: 'No entries',
              message: 'Dataset is empty',
            ),
            itemBuilder: (context, details) => _VirtualizedEntry(entry: details.entry),
            style: NeonScheduleTimelineStyle(
              pixelsPerMinute: 1.2,
              cardVariant: NeonTimelineCardVariant.glass,
              cardBlurSigma: 8,
              useBackdropFilter: true,
              showGapLabels: true,
              showDurationRail: true,
            ),
            startActionsBuilder: (context, details) => [
              NeonTimelineAction(
                icon: Icons.check,
                label: 'DONE',
                color: Colors.green,
                semanticLabel: 'Complete',
                onPressed: (_) {},
              ),
            ],
            endActionsBuilder: (context, details) => [
              NeonTimelineAction(
                icon: Icons.delete,
                label: 'DELETE',
                color: Colors.red,
                semanticLabel: 'Delete',
                onPressed: (_) {},
              ),
            ],
            cacheExtent: 500,
          ),
          if (_showPerformance) _PerformanceOverlay(entryCount: _itemCount),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ],
      ),
    );
  }
}

class _VirtualizedEntry extends StatelessWidget {
  const _VirtualizedEntry({required this.entry});

  final NeonScheduleEntry<DemoTask> entry;

  @override
  Widget build(BuildContext context) {
    final task = entry.value;
    return NeonTimelineCard(
      variant: NeonTimelineCardVariant.glass,
      accentColor: task.color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: task.color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: task.color.withAlpha(100), blurRadius: 6, spreadRadius: 1)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceOverlay extends StatefulWidget {
  const _PerformanceOverlay({required this.entryCount});

  final int entryCount;

  @override
  State<_PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<_PerformanceOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _frameCount = 0;
  double _fps = 0;
  final List<int> _frameTimes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        _frameCount++;
        final now = DateTime.now().millisecondsSinceEpoch;
        _frameTimes.add(now);
        _frameTimes.removeWhere((t) => now - t > 1000);
        _fps = _frameTimes.length.toDouble();
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 16,
      child: NeonTimelineCard(
        variant: NeonTimelineCardVariant.liquidCrystal,
        intensity: 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text('FPS: ${_fps.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Entries: ${widget.entryCount}', style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(180))),
            const SizedBox(height: 4),
            Text('Virtualized: YES', style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150))),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white.withAlpha(100)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
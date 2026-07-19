import 'package:flutter/material.dart';

import '../showcase/showcase_preview.dart';
import 'unified_dashboard.dart';
import 'v10/v10_delight_timeline_showcase.dart';
import 'v11/v11_ultimate_timeline_showcase.dart';
import 'v12/v12_ultimate_timeline_showcase.dart';
import 'v13/v13_advanced_ui_timeline_showcase.dart';
import 'v14/v14_friendly_ui_timeline_showcase.dart';
import 'v15/v15_ultra_timeline_showcase.dart';
import 'v16/v16_compact_planner_showcase.dart';
import 'v4_platform_showcase.dart';
import 'v5_command_center.dart';
import 'v6_structured_planner_lab.dart';
import 'v7_structured_timeline_showcase.dart';
import 'v8/v8_advanced_structured_showcase.dart';
import 'v9/v9_production_structured_showcase.dart';

class VersionGallery extends StatefulWidget {
  const VersionGallery({super.key});

  @override
  State<VersionGallery> createState() => _VersionGalleryState();
}

class _VersionGalleryState extends State<VersionGallery> {
  final TextEditingController _searchController = TextEditingController();

  late final List<_CatalogItem> _items = <_CatalogItem>[
    _CatalogItem(
      version: 'Featured',
      title: 'Unified Timeline Hub',
      initialViewport: ShowcaseViewportPreset.desktop,
      subtitle:
          'Compare six generations with shared tasks, matching interactions and a single theme switcher.',
      icon: Icons.dashboard_customize_rounded,
      color: const Color(0xFF0F9F77),
      badges: const <String>['ALL IN ONE', 'COMPARE', 'THEMES', 'FEATURED'],
      builder: (_) => const UnifiedTimelineDashboard(),
    ),
    _CatalogItem(
      version: '16.0.0',
      title: 'Compact Planner 16',
      initialViewport: ShowcaseViewportPreset.mobile,
      subtitle:
          'Mobile-first planner with compact cards, stable free drag, resize, overlap handling and smart fit.',
      icon: Icons.view_timeline_rounded,
      color: const Color(0xFF5B5FEF),
      badges: const <String>['RECOMMENDED', 'MOBILE', 'DRAG', 'SMART FIT'],
      builder: (_) => const V16CompactPlannerShowcase(),
    ),
    _CatalogItem(
      version: '15.0.1',
      title: 'Ultra Adaptive Planner 15',
      subtitle:
          'Continuous semantic zoom, magnetic snap strength, range editing and live diagnostics for power users.',
      icon: Icons.tune_rounded,
      color: const Color(0xFF4338CA),
      badges: const <String>['ZOOM', 'RANGE EDITOR', 'DIAGNOSTICS'],
      builder: (_) => const V15UltraTimelineShowcase(),
    ),
    _CatalogItem(
      version: '14.0.0',
      title: 'Friendly Timeline 14',
      initialViewport: ShowcaseViewportPreset.mobile,
      subtitle:
          'Soft icon-led planning, guided drag feedback and accessible responsive navigation for consumer apps.',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF8B5CF6),
      badges: const <String>['FRIENDLY UI', 'GUIDED DRAG', 'A11Y'],
      builder: (_) => const V14FriendlyUiTimelineShowcase(),
    ),
    _CatalogItem(
      version: '13.0.0',
      title: 'Advanced Timeline UI 13',
      initialViewport: ShowcaseViewportPreset.desktop,
      subtitle:
          'Responsive B2B workspace with navigation, command bar, KPI cards, sync states and production interactions.',
      icon: Icons.view_week_rounded,
      color: const Color(0xFF2563EB),
      badges: const <String>['WORKSPACE', 'RESPONSIVE', 'OFFLINE'],
      builder: (_) => const V13AdvancedUiTimelineShowcase(),
    ),
    _CatalogItem(
      version: '12.0.0',
      title: 'Ultimate Structured Timeline 12',
      subtitle:
          'Adaptive micro-to-detailed cards, weighted snapping, natural auto-scroll and public drag layers.',
      icon: Icons.auto_awesome_motion_rounded,
      color: const Color(0xFF4F46E5),
      badges: const <String>['ADAPTIVE UI', 'SNAP', 'A11Y'],
      builder: (_) => const V12UltimateTimelineShowcase(),
    ),
    _CatalogItem(
      version: '11.0.0',
      title: 'Ultimate Timeline 11',
      subtitle:
          'Stable live drag, semantic zoom, undo and redo, selection, work constraints and offline feedback.',
      icon: Icons.workspace_premium_rounded,
      color: const Color(0xFFBE123C),
      badges: const <String>['UNDO', 'LIVE DATA', 'ACCESSIBLE'],
      builder: (_) => const V11UltimateTimelineShowcase(),
    ),
    _CatalogItem(
      version: '10.0.0',
      title: 'Delight Timeline 10',
      subtitle:
          'Magnetic drag, snap guides, conflict-aware drops, adaptive cards and faster edge scrolling.',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFFC026D3),
      badges: const <String>['MAGNETIC DRAG', 'DELIGHT', 'LIVE APP'],
      builder: (_) => const V10DelightTimelineShowcase(),
    ),
    _CatalogItem(
      version: '9.0.0',
      title: 'Production Timeline 9',
      subtitle:
          'Public components, overflow-safe cards, compressed gaps, midnight segments and composition APIs.',
      icon: Icons.widgets_rounded,
      color: const Color(0xFFDB2777),
      badges: const <String>['PUBLIC WIDGETS', 'SAFE CARDS', 'COMPOSITION'],
      builder: (_) => const V9ProductionStructuredShowcase(),
    ),
    _CatalogItem(
      version: '8.0.0',
      title: 'Advanced Timeline 8',
      subtitle:
          'Resize, controlled navigation, mutation locks, slot suggestions and builder-first integration.',
      icon: Icons.auto_awesome_motion_rounded,
      color: const Color(0xFFEA580C),
      badges: const <String>['DRAG', 'RESIZE', 'CONTROLLER'],
      builder: (_) => const V8AdvancedStructuredShowcase(),
    ),
    _CatalogItem(
      version: '7.0.0',
      title: 'Structured Timeline 7',
      initialViewport: ShowcaseViewportPreset.mobile,
      subtitle:
          'A warm, focused day planner with long-press movement, five-minute snapping and clear visual rhythm.',
      icon: Icons.view_timeline_rounded,
      color: const Color(0xFFE11D48),
      badges: const <String>['LONG PRESS', '5 MIN SNAP', 'MOBILE'],
      builder: (_) => const V7StructuredTimelineShowcase(),
    ),
    _CatalogItem(
      version: '6.0.0',
      title: 'Structured Planner Engine 6',
      subtitle:
          'Recurring series, virtual IDs, day and week plans, conflict insight and drag previews.',
      icon: Icons.calendar_view_week_rounded,
      color: const Color(0xFF7C3AED),
      badges: const <String>['RECURRENCE', 'ENGINE', 'CONFLICTS'],
      builder: (context) => _catalogShell(
        context,
        title: 'Structured Planner 6.0',
        child: const V6StructuredPlannerLab(),
      ),
    ),
    _CatalogItem(
      version: '5.0.0',
      title: 'Timeline Command Center 5',
      initialViewport: ShowcaseViewportPreset.desktop,
      subtitle:
          'Temporal queries, scenarios, board, matrix and command palette in one productivity workspace.',
      icon: Icons.dashboard_customize_rounded,
      color: const Color(0xFF2563EB),
      badges: const <String>['QUERY', 'SCENARIO', 'BOARD'],
      builder: (context) => _catalogShell(
        context,
        title: 'Command Center 5.0',
        child: const V5CommandCenter(),
      ),
    ),
    _CatalogItem(
      version: '4.0.0',
      title: 'Timeline Platform Studio',
      initialViewport: ShowcaseViewportPreset.desktop,
      subtitle:
          'Enterprise views, resources, dependencies, diagnostics and multiple visual systems.',
      icon: Icons.hub_rounded,
      color: const Color(0xFF0891B2),
      badges: const <String>['PLATFORM', 'RESOURCES', 'THEMES'],
      builder: (context) => _catalogShell(
        context,
        title: 'Timeline Studio 4.0',
        child: const V4PlatformShowcase(),
      ),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = _items.where((item) {
      if (query.isEmpty) return true;
      return '${item.version} ${item.title} ${item.subtitle} ${item.badges.join(' ')}'
          .toLowerCase()
          .contains(query);
    }).toList(growable: false);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF8FAFF), Color(0xFFF2F5FA)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: _header(context)),
              if (visible.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptySearchState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.crossAxisExtent < 520;
                      return SliverGrid.builder(
                        itemCount: visible.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 430,
                          mainAxisExtent: narrow ? 258 : 248,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) =>
                            _CatalogCard(item: visible[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          return Container(
            padding: EdgeInsets.all(compact ? 20 : 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF111827),
                  Color(0xFF202A44),
                  Color(0xFF34317C),
                ],
              ),
              borderRadius: BorderRadius.circular(compact ? 28 : 34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF312E81).withValues(alpha: 0.22),
                  blurRadius: 38,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: compact ? 52 : 62,
                      height: compact ? 52 : 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFF8176FF), Color(0xFF5B5FEF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF7168F7).withValues(alpha: 0.36),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.view_timeline_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Neon Timeline Flutter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 24 : 34,
                              height: 1.02,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.1,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Every generation in a responsive, screenshot-ready preview.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: compact ? 12 : 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Text(
                          'v16.0.0',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: compact ? 20 : 26),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search versions, features or use cases…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B83FF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const <Widget>[
                    _HeroPill(icon: Icons.phone_iphone_rounded, label: 'Mobile'),
                    _HeroPill(icon: Icons.tablet_mac_rounded, label: 'Tablet'),
                    _HeroPill(icon: Icons.desktop_windows_rounded, label: 'Desktop'),
                    _HeroPill(icon: Icons.fullscreen_rounded, label: 'Screenshot mode'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _catalogShell(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFFB7B1FF), size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogItem {
  const _CatalogItem({
    required this.version,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
    this.badges = const <String>[],
    this.initialViewport = ShowcaseViewportPreset.tablet,
  });

  final String version;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  final List<String> badges;
  final ShowcaseViewportPreset initialViewport;
}

class _CatalogCard extends StatefulWidget {
  const _CatalogCard({required this.item});

  final _CatalogItem item;

  @override
  State<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<_CatalogCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.012 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _hovered
                  ? item.color.withValues(alpha: 0.32)
                  : const Color(0xFFE5EAF2),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _hovered
                    ? item.color.withValues(alpha: 0.13)
                    : const Color(0xFF111827).withValues(alpha: 0.055),
                blurRadius: _hovered ? 30 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ShowcasePreview(
                      version: item.version,
                      title: item.title,
                      subtitle: item.subtitle,
                      accent: item.color,
                      badges: item.badges,
                      initialViewport: item.initialViewport,
                      builder: item.builder,
                    ),
                  ),
                );
              },
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -55,
                    right: -40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withValues(alpha: 0.065),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 5, color: item.color),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    item.color.withValues(alpha: 0.16),
                                    item.color.withValues(alpha: 0.07),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: item.color.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Icon(item.icon, color: item.color, size: 23),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                item.version,
                                style: TextStyle(
                                  color: item.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_outward_rounded,
                              size: 19,
                              color: _hovered
                                  ? item.color
                                  : const Color(0xFF98A2B3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.42,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.badges.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: item.badges.take(3).map((badge) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: const Color(0xFFE7EBF1),
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: item.color,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.18,
                                  ),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.search_off_rounded, size: 44, color: Color(0xFF98A2B3)),
            const SizedBox(height: 12),
            Text('No matching showcase', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Try a version number or a feature such as drag, zoom, workspace or mobile.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

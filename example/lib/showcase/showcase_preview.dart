import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Screenshot-friendly viewport presets shared by every example generation.
enum ShowcaseViewportPreset {
  mobile('Mobile', Icons.phone_iphone_rounded, Size(390, 844)),
  tablet('Tablet', Icons.tablet_mac_rounded, Size(1024, 768)),
  desktop('Desktop', Icons.desktop_windows_rounded, Size(1440, 900));

  const ShowcaseViewportPreset(this.label, this.icon, this.logicalSize);

  final String label;
  final IconData icon;
  final Size logicalSize;
}

/// Hosts any legacy or current example in a predictable, polished viewport.
///
/// This avoids giant controls on wide monitors and clipped workspaces on small
/// screens while keeping the underlying package examples completely real and
/// interactive.
class ShowcasePreview extends StatefulWidget {
  const ShowcasePreview({
    required this.version,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.builder,
    this.badges = const <String>[],
    this.initialViewport = ShowcaseViewportPreset.tablet,
    super.key,
  });

  final String version;
  final String title;
  final String subtitle;
  final Color accent;
  final WidgetBuilder builder;
  final List<String> badges;
  final ShowcaseViewportPreset initialViewport;

  @override
  State<ShowcasePreview> createState() => _ShowcasePreviewState();
}

class _ShowcasePreviewState extends State<ShowcasePreview> {
  late ShowcaseViewportPreset _viewport;
  bool _presentationMode = false;

  @override
  void initState() {
    super.initState();
    _viewport = widget.initialViewport;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: widget.accent,
      brightness: Brightness.dark,
      surface: const Color(0xFF111827),
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF070B14),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.72, -0.84),
              radius: 1.45,
              colors: <Color>[
                widget.accent.withValues(alpha: 0.22),
                const Color(0xFF0A1020),
                const Color(0xFF05070D),
              ],
              stops: const <double>[0, 0.48, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final phone = constraints.maxWidth < 560;
                final compact = constraints.maxWidth < 900;
                final effectiveViewport = phone
                    ? ShowcaseViewportPreset.mobile
                    : _viewport;

                if (_presentationMode) {
                  return _buildPresentation(
                    context,
                    constraints,
                    effectiveViewport,
                  );
                }

                return Column(
                  children: <Widget>[
                    _PreviewToolbar(
                      version: widget.version,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      accent: widget.accent,
                      badges: widget.badges,
                      viewport: effectiveViewport,
                      compact: compact,
                      onBack: () {
                        Navigator.of(context).maybePop();
                      },
                      onViewportChanged: phone
                          ? null
                          : (value) => setState(() => _viewport = value),
                      onPresent: () =>
                          setState(() => _presentationMode = true),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 10 : 24,
                          compact ? 4 : 12,
                          compact ? 10 : 24,
                          compact ? 10 : 24,
                        ),
                        child: _DeviceCanvas(
                          viewport: effectiveViewport,
                          accent: widget.accent,
                          title: '${widget.title} · ${widget.version}',
                          builder: widget.builder,
                          showDeviceBar: !compact,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresentation(
    BuildContext context,
    BoxConstraints constraints,
    ShowcaseViewportPreset viewport,
  ) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(constraints.maxWidth < 720 ? 4 : 16),
            child: _DeviceCanvas(
              viewport: viewport,
              accent: widget.accent,
              title: '${widget.title} · ${widget.version}',
              builder: widget.builder,
              showDeviceBar: false,
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Tooltip(
            message: 'Exit presentation mode',
            child: Material(
              color: const Color(0xFF0F172A).withValues(alpha: 0.84),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () => setState(() => _presentationMode = false),
                icon: const Icon(Icons.close_fullscreen_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.version,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.badges,
    required this.viewport,
    required this.compact,
    required this.onBack,
    required this.onViewportChanged,
    required this.onPresent,
  });

  final String version;
  final String title;
  final String subtitle;
  final Color accent;
  final List<String> badges;
  final ShowcaseViewportPreset viewport;
  final bool compact;
  final VoidCallback onBack;
  final ValueChanged<ShowcaseViewportPreset>? onViewportChanged;
  final VoidCallback onPresent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 10 : 24, 12, compact ? 10 : 24, 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101827).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back to version gallery',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[accent, accent.withValues(alpha: 0.62)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              version == 'Featured' ? '★' : 'v${version.split('.').first}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                if (!compact)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (!compact && badges.isNotEmpty) ...<Widget>[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Text(
                badges.first,
                style: TextStyle(
                  color: accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
          if (!compact) ...<Widget>[
            const SizedBox(width: 12),
            _ViewportSelector(
              selected: viewport,
              accent: accent,
              onChanged: onViewportChanged!,
            ),
          ] else if (onViewportChanged != null)
            PopupMenuButton<ShowcaseViewportPreset>(
              tooltip: 'Select preview viewport',
              initialValue: viewport,
              onSelected: onViewportChanged,
              itemBuilder: (context) => ShowcaseViewportPreset.values
                  .map(
                    (preset) => PopupMenuItem<ShowcaseViewportPreset>(
                      value: preset,
                      child: Row(
                        children: <Widget>[
                          Icon(preset.icon, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            '${preset.label} · '
                            '${preset.logicalSize.width.toInt()}×'
                            '${preset.logicalSize.height.toInt()}',
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              icon: Icon(viewport.icon),
            ),
          IconButton(
            tooltip: 'Presentation mode for screenshots',
            onPressed: onPresent,
            icon: const Icon(Icons.fullscreen_rounded),
          ),
        ],
      ),
    );
  }
}

class _ViewportSelector extends StatelessWidget {
  const _ViewportSelector({
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final ShowcaseViewportPreset selected;
  final Color accent;
  final ValueChanged<ShowcaseViewportPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ShowcaseViewportPreset.values.map((preset) {
          final active = preset == selected;
          return Tooltip(
            message: '${preset.label} · '
                '${preset.logicalSize.width.toInt()}×${preset.logicalSize.height.toInt()}',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  preset.icon,
                  size: 17,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.58),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _DeviceCanvas extends StatelessWidget {
  const _DeviceCanvas({
    required this.viewport,
    required this.accent,
    required this.title,
    required this.builder,
    required this.showDeviceBar,
  });

  final ShowcaseViewportPreset viewport;
  final Color accent;
  final String title;
  final WidgetBuilder builder;
  final bool showDeviceBar;

  @override
  Widget build(BuildContext context) {
    final logicalSize = viewport.logicalSize;
    final deviceBarHeight = showDeviceBar ? 38.0 : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            math.max(1.0, constraints.maxWidth).toDouble();
        final availableHeight =
            math.max(1.0, constraints.maxHeight).toDouble();
        final totalHeight = logicalSize.height + deviceBarHeight;
        final scale = math
            .min(
              availableWidth / logicalSize.width,
              availableHeight / totalHeight,
            )
            .toDouble();
        final renderedWidth = logicalSize.width * scale;
        final renderedHeight = totalHeight * scale;

        return Center(
          child: SizedBox(
            width: renderedWidth,
            height: renderedHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: Container(
                  width: logicalSize.width,
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: BorderRadius.circular(
                      viewport == ShowcaseViewportPreset.mobile ? 34 : 22,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                      width: 1.25,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.52),
                        blurRadius: 48,
                        offset: const Offset(0, 22),
                      ),
                      BoxShadow(
                        color: accent.withValues(alpha: 0.13),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      if (showDeviceBar)
                        _DeviceBar(
                          title: title,
                          accent: accent,
                          viewport: viewport,
                        ),
                      Expanded(
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: logicalSize,
                            padding: EdgeInsets.zero,
                            viewPadding: EdgeInsets.zero,
                            viewInsets: EdgeInsets.zero,
                            textScaler: TextScaler.noScaling,
                          ),
                          child: Theme(
                            data: _exampleTheme(accent),
                            child: Builder(builder: builder),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeData _exampleTheme(Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE6EAF1)),
        ),
      ),
      dividerColor: const Color(0xFFE6EAF1),
    );
  }
}

class _DeviceBar extends StatelessWidget {
  const _DeviceBar({
    required this.title,
    required this.accent,
    required this.viewport,
  });

  final String title;
  final Color accent;
  final ShowcaseViewportPreset viewport;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: <Widget>[
          for (final color in const <Color>[
            Color(0xFFFF6B6B),
            Color(0xFFFFC857),
            Color(0xFF45D483),
          ]) ...<Widget>[
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(viewport.icon, size: 15, color: accent),
        ],
      ),
    );
  }
}

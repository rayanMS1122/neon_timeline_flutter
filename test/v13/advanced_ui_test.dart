import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v13.dart';

void main() {
  test('advanced compact config exposes dense timeline metrics', () {
    const config = UltimateStructuredTimelineConfig.advancedCompact();

    expect(config.zoomLevel, UltimateTimelineZoomLevel.compact);
    expect(config.visualDensity, UltimateTimelineVisualDensity.compact);
    expect(config.entryHeightFactor, lessThan(1));
    expect(config.horizontalSpacingFactor, lessThan(1));
    expect(config.minimumTouchTarget, 44);
    expect(config.interaction.showDropPreview, isTrue);
    expect(config.interaction.dropSnapInterval, const Duration(minutes: 5));
    expect(config.interaction.allowConflictingDrops, isFalse);
    expect(config.interaction.preferConflictFreeDrop, isTrue);
    expect(config.interaction.showConflictPreview, isTrue);
    expect(config.interaction.announceDragChanges, isTrue);
    expect(config.interaction.showSnapGuide, isFalse);
  });

  test('advanced compact theme tightens card and header geometry', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    final base = UltimateTimelineThemeData.fromColorScheme(scheme);
    final compact = UltimateTimelineThemeData.advancedCompact(scheme);

    expect(compact.entry.radius, lessThan(base.entry.radius));
    expect(compact.entry.accentWidth, lessThan(base.entry.accentWidth));
    expect(compact.header.radius, lessThan(base.header.radius));
    expect(compact.resize.hitTargetHeight, lessThan(base.resize.hitTargetHeight));
    expect(
      compact.entry.accentPlacement,
      UltimateTimelineAccentPlacement.top,
    );
    expect(compact.entry.tintOpacity, lessThan(base.entry.tintOpacity));
  });

  testWidgets('drop preview shows magnetized target and conflict count', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UltimateTimelineTheme(
          data: UltimateTimelineThemeData.advancedCompact(
            ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: UltimateTimelineDropPreview<String>(
              height: 52,
              label: 'Drop at 10:15',
              magnetized: true,
              conflictCount: 2,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Drop at 10:15'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.vertical_align_center_rounded), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('small placeholders avoid center label overlap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UltimateTimelineTheme(
          data: UltimateTimelineThemeData.advancedCompact(
            ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: const SizedBox(
            width: 180,
            height: 36,
            child: UltimateTimelineDragPlaceholder<String>(
              child: ColoredBox(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Original position'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag placeholder sizes from its child in a vertical list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UltimateTimelineTheme(
          data: UltimateTimelineThemeData.advancedCompact(
            ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: ListView(
            children: const [
              UltimateTimelineDragPlaceholder<String>(
                key: ValueKey<String>('unbounded-placeholder'),
                child: SizedBox(width: 180, height: 72),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('unbounded-placeholder'))).height,
      72,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('drop preview preserves a readable status at compact height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UltimateTimelineTheme(
          data: UltimateTimelineThemeData.advancedCompact(
            ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 220,
              child: UltimateTimelineDropPreview<String>(
                height: 54,
                label: 'Snap to 10:15',
                magnetized: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Snap to 10:15'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Snap to 10:15. Magnetic target. Drop available.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete target stays compact with 200 percent text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: UltimateTimelineTheme(
            data: UltimateTimelineThemeData.advancedCompact(
              ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
            ),
            child: const SizedBox(
              width: 320,
              height: 100,
              child: UltimateTimelineDeleteTarget(active: false),
            ),
          ),
        ),
      ),
    );

    final target = find.ancestor(
      of: find.text('Delete area'),
      matching: find.byType(AnimatedContainer),
    );
    expect(target, findsOneWidget);
    expect(tester.getSize(target).height, 46);
    expect(tester.takeException(), isNull);
  });

  test('workspace theme exposes a real 13.x operations system', () {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5CE2),
    );
    final theme = AdvancedTimelineUiThemeData.operations(scheme);

    expect(theme.density, AdvancedTimelineWorkspaceDensity.compact);
    expect(theme.panelRadius, lessThan(theme.workspaceRadius));
    expect(theme.controlHeight, 42);
    expect(theme.navigationBreakpoint, greaterThan(theme.compactBreakpoint));
  });

  testWidgets('workspace stays readable on a narrow screen at 200% text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 760),
            textScaler: TextScaler.linear(2),
          ),
          child: AdvancedTimelineWorkspace(
            title: 'Orbit Planner',
            subtitle: 'A focused day without calendar noise',
            dateLabel: 'Friday, July 17',
            status: AdvancedTimelineWorkspaceStatus.saving,
            navigationItems: const [
              AdvancedTimelineNavigationItem(
                label: 'Timeline',
                icon: Icons.view_timeline_outlined,
              ),
              AdvancedTimelineNavigationItem(
                label: 'Focus',
                icon: Icons.center_focus_weak_outlined,
              ),
            ],
            metrics: const [
              AdvancedTimelineMetric(
                label: 'Scheduled',
                value: '4h 47m',
                icon: Icons.schedule_rounded,
              ),
              AdvancedTimelineMetric(
                label: 'Completed',
                value: '1 / 5',
                progress: 0.2,
              ),
            ],
            onPreviousDate: () {},
            onNextDate: () {},
            onToday: () {},
            onSearch: () {},
            onCreate: () {},
            onOpenSettings: () {},
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    expect(find.text('Orbit Planner'), findsOneWidget);
    expect(find.text('Friday, July 17'), findsOneWidget);
    expect(find.text('Saving'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workspace exposes labeled navigation destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1280,
          height: 800,
          child: AdvancedTimelineWorkspace(
            title: 'Planner',
            navigationItems: const [
              AdvancedTimelineNavigationItem(
                label: 'Timeline',
                icon: Icons.view_timeline_outlined,
                selectedIcon: Icons.view_timeline_rounded,
              ),
              AdvancedTimelineNavigationItem(
                label: 'Insights',
                icon: Icons.insights_outlined,
                badge: '3',
              ),
            ],
            onNavigationSelected: (_) {},
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.bySemanticsLabel('Timeline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

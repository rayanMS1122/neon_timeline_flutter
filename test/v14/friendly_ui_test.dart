import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v14.dart';

void main() {
  test('friendly config enables guided five minute dragging', () {
    const config = UltimateStructuredTimelineConfig.friendly();

    expect(config.zoomLevel, UltimateTimelineZoomLevel.normal);
    expect(config.minimumTouchTarget, 48);
    expect(config.interaction.longPressDuration, const Duration(milliseconds: 160));
    expect(config.interaction.dropSnapInterval, const Duration(minutes: 5));
    expect(config.interaction.showSnapGuide, isTrue);
    expect(config.interaction.allowConflictingDrops, isFalse);
  });

  test('friendly theme exposes distinct icon tones', () {
    final theme = FriendlyTimelineUiThemeData.fromColorScheme(
      ColorScheme.fromSeed(seedColor: const Color(0xFF7558E8)),
    );

    expect(
      theme.foregroundFor(FriendlyTimelineIconTone.mint),
      isNot(theme.foregroundFor(FriendlyTimelineIconTone.coral)),
    );
    expect(theme.panelRadius, greaterThan(theme.controlRadius));
    expect(theme.navigationBreakpoint, greaterThan(theme.compactBreakpoint));
  });

  testWidgets('friendly workspace remains usable at 200 percent text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 760),
            textScaler: TextScaler.linear(2),
          ),
          child: FriendlyTimelineWorkspace(
            title: 'Bloom Planner',
            subtitle: 'A friendly day',
            dateLabel: 'Friday, July 17',
            status: FriendlyTimelineWorkspaceStatus.saving,
            navigationItems: const <FriendlyTimelineNavigationItem>[
              FriendlyTimelineNavigationItem(
                label: 'Today',
                icon: Icons.today_outlined,
              ),
              FriendlyTimelineNavigationItem(
                label: 'Focus',
                icon: Icons.self_improvement_outlined,
                tone: FriendlyTimelineIconTone.lavender,
              ),
            ],
            metrics: const <FriendlyTimelineMetric>[
              FriendlyTimelineMetric(
                label: 'Planned',
                value: '4h 20m',
                icon: Icons.schedule_rounded,
                tone: FriendlyTimelineIconTone.sky,
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

    expect(find.text('Bloom Planner'), findsOneWidget);
    expect(find.text('Friday, July 17'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guided placeholder sizes from its child in a list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendlyTimelineUiTheme(
          data: FriendlyTimelineUiThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: const Color(0xFF7558E8)),
          ),
          child: ListView(
            children: const <Widget>[
              FriendlyTimelineDragPlaceholder<String>(
                key: ValueKey<String>('friendly-placeholder'),
                child: SizedBox(height: 72, width: 220),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('friendly-placeholder'))).height,
      72,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag companion communicates smart snap with text and icon', (
    tester,
  ) async {
    const state = StructuredTimelineDragState<Object?>(
      phase: StructuredTimelineDragPhase.dragging,
      magnetized: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FriendlyTimelineUiTheme(
          data: FriendlyTimelineUiThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: const Color(0xFF7558E8)),
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: FriendlyTimelineDragCompanion(
              state: state,
              title: 'Design review',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Design review'), findsOneWidget);
    expect(find.textContaining('Magnetic target locked'), findsOneWidget);
    expect(find.byIcon(Icons.auto_fix_high_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('ultimate copyWith preserves version 14 interaction settings', () {
    const config = UltimateStructuredTimelineConfig.friendly();
    final workspaceConfig = config.copyWith(showResponsiveHeader: false);

    expect(workspaceConfig.showResponsiveHeader, isFalse);
    expect(workspaceConfig.interaction, same(config.interaction));
    expect(workspaceConfig.visualDensity, config.visualDensity);
    expect(workspaceConfig.enableLiveDataStability, isTrue);
  });

  test('drag UI projection has stable value equality', () {
    const source = StructuredTimelineDragState<String>(
      phase: StructuredTimelineDragPhase.dragging,
      value: 'Design review',
      conflictCount: 1,
      magnetized: true,
    );
    final first = FriendlyTimelineDragUiState.fromDragState<String>(
      source,
      title: 'Design review',
    );
    final second = FriendlyTimelineDragUiState.fromDragState<String>(
      source,
      title: 'Design review',
    );

    expect(first, second);
    expect(first.active, isTrue);
    expect(first.magnetized, isTrue);
  });

  testWidgets('drag companion updates without rebuilding timeline content', (
    tester,
  ) async {
    final state = ValueNotifier<FriendlyTimelineDragUiState>(
      const FriendlyTimelineDragUiState.idle(),
    );
    var contentBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: FriendlyTimelineWorkspace(
          title: 'Bloom Planner',
          dragStateListenable: state,
          child: _BuildProbe(onBuild: () => contentBuilds++),
        ),
      ),
    );
    expect(contentBuilds, 1);

    state.value = const FriendlyTimelineDragUiState(
      phase: StructuredTimelineDragPhase.dragging,
      title: 'Design review',
      magnetized: true,
    );
    await tester.pump();

    expect(contentBuilds, 1);
    expect(find.text('Design review'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

}


class _BuildProbe extends StatelessWidget {
  const _BuildProbe({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return const ColoredBox(color: Colors.white);
  }
}

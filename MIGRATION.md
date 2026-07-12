# Migrating from timelines_plus

`neon_timeline_flutter` is an independently designed package. It provides a
familiar Flutter timeline workflow, but it is **not** a drop-in replacement,
fork, compatibility layer, or re-export of `timelines_plus`.

Plan a source migration: change imports, class names, builder callbacks,
themes, and some layout decisions. Run visual, interaction, accessibility, and
scrolling tests after each converted timeline.

## Dependency and import

Replace the dependency:

```yaml
dependencies:
  neon_timeline_flutter: ^3.3.0
```

Replace the import:

```dart
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';
```

Do not keep both packages unprefixed in the same library while migrating; many
timeline concepts have similar names even though their APIs differ.



## Upgrading from 3.2.x to 3.3.0

The update is source-compatible for normal integrations. Visual presets and
layout remain unchanged. The default sampled motion rate is now 24 Hz, and
`NeonScheduleTimeline` limits continuous animation to one focal row.

```dart
NeonScheduleTimeline<Task>(
  motionFramesPerSecond: 24,
  maxAnimatedEntries: 1,
  pauseMotionWhileScrolling: true,
  // ...
)
```

Set `maxAnimatedEntries` higher only after profiling a release build on the
slowest supported device. Use `0` for a static timeline while retaining the same
active colors and advanced surfaces. Rapid async slide-action taps are now
coalesced until the first operation completes.

## Upgrading from 3.1.0 to 3.2.0

Version 3.2.0 is source-compatible with normal 3.1.0 integrations. The
visual presets remain the same, while painter scheduling and schedule-list
construction are substantially cheaper.

The new defaults are:

```dart
NeonScheduleTimeline<Task>(
  motionFramesPerSecond: 30,
  pauseMotionWhileScrolling: true,
  animateOnlyCurrentEntry: true,
  addAutomaticKeepAlives: false,
  // ...
)
```

Treat the `entries` list as immutable: replace the list when data changes. This
lets the package reuse its normalized O(n) render plan safely. For a static or
battery-sensitive surface, set `motionEnabled: false`. To retain the advanced
painted card while removing backdrop compositing, use
`NeonScheduleTimelineStyle(useBackdropFilter: false)`.

See `PERFORMANCE.md` for profiles and profiling instructions.

## Upgrading from 3.0.1 to 3.1.0

Version 3.1.0 is additive for the existing generic timeline APIs. It adds the
planner-focused `NeonScheduleTimeline<T>`, `NeonScheduleEntry<T>`,
`NeonSlidableTimeline`, and `NeonTimelineDayPager`. Existing
`NeonTimeline`, fixed, and sliver integrations do not need to change.

The package now depends on `flutter_slidable >=3.1.2 <4.0.0`. Applications
already using `flutter_slidable: ^3.1.2` can normally resolve one shared
version. Run `flutter pub get` and inspect the solver output before release.

Application models remain outside the package. Adapt them into
`NeonScheduleEntry<T>` and persist changes from `onEntryMoved` or action
callbacks. See `FOCUSFORGE_INTEGRATION.md` for a full staged migration.

## Upgrading from 2.x to 3.0.0

The update remains source-compatible for existing timelines. New enum values
only affect exhaustive switches written by your application. Add cases for:

- `NeonIndicatorEffect.neuralCore`
- `NeonConnectorEffect.photonLattice`
- `NeonTimelineCardVariant.liquidCrystal`
- `NeonTimelineRenderQuality`

To use the new renderer without changing data or layout:

```dart
NeonTimeline(
  items: items,
  theme: NeonTimelineThemeData.omniverse(),
)
```

For dense timelines, keep `quality` at
`NeonTimelineRenderQuality.balanced` or `high`. Use `ultra` for active hero
nodes rather than every item in a long list.

## Upgrading from 1.1.x to 1.2.0

The update is source-compatible for existing timelines. The new rendering
values are optional. High-level timelines now install a shared motion scope
automatically, reducing duplicate animation controllers and keeping active
effects synchronized.

Use the stronger preset without changing timeline data or layout:

```dart
NeonTimeline(
  items: items,
  theme: NeonTimelineThemeData.quantum(),
)
```

For standalone indicators and connectors, wrap related primitives in
`NeonTimelineMotionScope` when they should share one phase. Existing standalone
widgets continue to use their local animation fallback.

## Concept mapping

| timelines_plus concept | neon_timeline_flutter equivalent | Migration note |
| --- | --- | --- |
| `Timeline` | `NeonTimeline` | Scrollable high-level timeline |
| `Timeline.builder` / `Timeline.tileBuilder` | `NeonTimeline.builder` | Builders receive `NeonTimelineItemDetails` rather than only an index |
| `FixedTimeline` | No exact equivalent | Prefer `NeonSliverTimeline`; for a short embedded list, use shrink-wrap with non-scrollable physics |
| `TimelineTile` | `NeonTimelineTile` | `contents` becomes `content`; `oppositeContents` becomes `oppositeContent` |
| `TimelineNode` | `NeonTimelineNode` | Before/after connectors are managed as independent styled segments |
| `DotIndicator`, `OutlinedDotIndicator`, `ContainerIndicator` | `NeonTimelineIndicator` | Choose a style/shape or supply `child`; any widget can also be an item indicator |
| `SolidLineConnector`, `DashedLineConnector`, `DecoratedLineConnector` | `NeonTimelineConnector` | Configure `NeonTimelineConnectorStyle` and `NeonConnectorVariant` |
| `TimelineThemeData` | `NeonTimelineThemeData` | A Material `ThemeExtension` with local override support |
| `IndicatorThemeData` | `NeonTimelineIndicatorStyle` | Stored in `NeonTimelineThemeData.indicatorStyle` |
| `ConnectorThemeData` | `NeonTimelineConnectorStyle` | Stored in `NeonTimelineThemeData.connectorStyle` |
| `ContentsAlign.basic` | `NeonTimelineLayout.center` | Primary and opposite content remain on their logical sides |
| `ContentsAlign.reverse` | `NeonTimelineLayout.center` plus swapped builders/content | There is no global reverse-content flag |
| `ContentsAlign.alternating` | `NeonTimelineLayout.alternating` | Alternation is automatic by item index |
| `ConnectionDirection.before/after` | Automatic | Neighboring states determine both connector segments |
| `IndicatorStyle` | `NeonTimelineIndicatorStyle` or `indicatorBuilder` | Style objects carry dimensions and colors rather than a small preset enum |
| `ConnectorStyle` | `NeonTimelineConnectorStyle` | `variant` is solid, dashed, or gradient |
| `TimelineTileBuilder.themeBuilder` | No direct equivalent | Use global/local theme plus per-item indicator and connector builders |
| `TimelineTileBuilderDelegate` | Internal Flutter delegates | Delegate implementation is intentionally not public |

## Basic builder migration

A typical `timelines_plus` builder:

```dart
// Previous package
Timeline.tileBuilder(
  builder: TimelineTileBuilder.fromStyle(
    itemCount: events.length,
    contentsAlign: ContentsAlign.alternating,
    contentsBuilder: (context, index) => Text(events[index].title),
  ),
)
```

Becomes:

```dart
NeonTimeline.builder(
  itemCount: events.length,
  layout: NeonTimelineLayout.alternating,
  statusBuilder: (index) => events[index].status,
  contentBuilder: (context, details) {
    return Text(events[details.index].title);
  },
  oppositeContentBuilder: (context, details) {
    return Text(events[details.index].timeLabel);
  },
)
```

The new builder details expose:

- `index` and `itemCount`
- `isFirst`, `isLast`, and `isEven`
- `axis`, requested `layout`, and `textDirection`
- `status`, `previousStatus`, and `nextStatus`

Use those values instead of recalculating timeline boundaries and neighboring
state in multiple callbacks.

## Move visual state into statuses

In `timelines_plus`, applications often choose indicator and connector styles
for every index. `neon_timeline_flutter` gives each item an explicit semantic
state:

```dart
NeonTimeline.builder(
  itemCount: events.length,
  statusBuilder: (index) {
    final event = events[index];
    if (event.failed) return NeonTimelineStatus.error;
    if (event.completed) return NeonTimelineStatus.completed;
    if (event.isCurrent) return NeonTimelineStatus.active;
    return NeonTimelineStatus.pending;
  },
  contentBuilder: (context, details) {
    return Text(events[details.index].title);
  },
)
```

The package then chooses the default glyph and blends connector colors between
adjacent states. Override visuals only where the domain requires it:

```dart
NeonTimeline.builder(
  itemCount: events.length,
  statusBuilder: (index) => events[index].status,
  contentBuilder: (context, details) {
    return Text(events[details.index].title);
  },
  indicatorBuilder: (context, details) {
    return NeonTimelineIndicator(
      status: details.status,
      child: Icon(events[details.index].icon, size: 15),
    );
  },
  connectorStyleBuilder: (context, details) {
    return const NeonTimelineConnectorStyle(
      variant: NeonConnectorVariant.dashed,
      dashLength: 5,
      gapLength: 3,
    );
  },
)
```

## Theme migration

Instead of wrapping every timeline in the old package theme, install an
app-wide extension:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      NeonTimelineThemeData.fromSeed(const Color(0xFF7C5CFF)),
    ],
  ),
  home: const HomePage(),
)
```

For one subtree, use a local scope:

```dart
NeonTimelineTheme(
  data: NeonTimelineThemeData.midnight().copyWith(
    indicatorStyle: const NeonTimelineIndicatorStyle(
      shape: NeonIndicatorShape.diamond,
    ),
    connectorStyle: const NeonTimelineConnectorStyle(
      variant: NeonConnectorVariant.gradient,
    ),
  ),
  child: NeonTimeline(items: items),
)
```

Theme resolution order is:

1. The `theme` argument on `NeonTimeline` or `NeonSliverTimeline`.
2. The nearest `NeonTimelineTheme`.
3. `ThemeData.extensions`.
4. A light or neon fallback based on Material brightness.

There is no indexed full-theme builder. Use `indicatorBuilder` and
`connectorStyleBuilder` for per-item visual differences. If every property,
including layout metrics, must vary by item, compose `NeonTimelineTile`
instances directly.

## Scroll and sliver migration

For a standalone timeline, use `NeonTimeline`. For a timeline inside an
existing `CustomScrollView`, migrate to `NeonSliverTimeline` rather than
nesting scrollables:

```dart
CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('History')),
    NeonSliverTimeline.builder(
      itemCount: events.length,
      statusBuilder: (index) => events[index].status,
      contentBuilder: (context, details) {
        return Text(events[details.index].title);
      },
    ),
  ],
)
```

If replacing a small `FixedTimeline` inside another box scroll view, the
temporary equivalent is:

```dart
NeonTimeline(
  items: items,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
)
```

Use this only for short lists. Shrink-wrap performs more layout work; a sliver
is the scalable migration.

For a horizontal timeline, provide bounded height. If `itemExtent` is omitted,
item width comes from `NeonTimelineThemeData.horizontalItemExtent`.

## Direct item migration

Where the old code manually assembled tiles, a declarative item list may be
simpler:

```dart
final items = events.map((event) {
  return NeonTimelineItem(
    id: event.id,
    status: event.status,
    content: EventCard(event: event),
    oppositeContent: Text(event.timeLabel),
    semanticLabel: event.accessibleDescription,
    onTap: () => openEvent(event),
  );
}).toList(growable: false);

final timeline = NeonTimeline(items: items);
```

Use an immutable, stable `id` for state preservation. For builder data that can
reorder, also provide `keyBuilder` and `findChildIndexCallback`.

## Behavioral differences to verify

- The default layout is `adaptive`, not a permanently centered rail. Below the
  theme breakpoint, a vertical timeline becomes one-sided at logical start.
- Horizontal `adaptive` layout resolves to `center`.
- Entry reveal animation is enabled by default; active default indicators may
  pulse. Both honor `MediaQuery.disableAnimations` and can be disabled with
  `animate: false`.
- First and last connector segments are suppressed automatically.
- Connector colors follow current and neighboring statuses unless overridden.
- The default semantic label is English. Supply `semanticLabel` or
  `semanticLabelBuilder` for localization and domain meaning.
- Disabled high-level tiles suppress their item activation callback.
- `start` and `end` are logical positions and mirror in RTL.
- Low-level nodes and connectors require finite main-axis constraints.
- Public builder delegates and implementation mixins from `timelines_plus` do
  not have public equivalents.
- There is no per-item indicator-position builder in the high-level API;
  `indicatorPosition` applies to the whole timeline. Use custom tile
  composition when positions must vary per entry.

## Recommended migration sequence

1. Replace dependency and import.
2. Convert one timeline to `NeonTimeline.builder` without custom visuals.
3. Map domain state to `NeonTimelineStatus`.
4. Choose the matching layout and axis.
5. Install the app-wide or local theme.
6. Add only the required indicator and connector overrides.
7. Move nested timelines to `NeonSliverTimeline`.
8. Add localized semantic labels.
9. Test LTR, RTL, large text, reduced motion, empty/single-item data, and the
   target platforms.
10. Remove `timelines_plus` after every import and behavior is migrated.

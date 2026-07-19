# API Changes 5.0

## Core

- `TimelineTemporalIndex<T>`
- `TimelineTemporalHit<T>`
- `TimelineQuery<T>`
- `TimelineQueryResult<T>`
- `TimelineQuerySort`
- `TimelineRecurrenceRule`
- `TimelineRecurrenceFrequency`
- `TimelineScenario<T>`
- `TimelineScenarioChange<T>`
- `TimelineScenarioComparison<T>`
- `TimelineScenarioEngine`

## Views

- `TimelineFocusView<T>`
- `TimelineBoardView<T>`
- `TimelineMatrixView<T>`
- `TimelineOverviewStrip<T>`
- `TimelineScenarioCompareView<T>`
- `TimelinePaletteCommand`
- `TimelineCommandPalette`
- `showTimelineCommandPalette`

## Themes

- `TimelineThemeData.horizon`
- `TimelineThemeData.obsidian`
- `TimelineThemeData.paper`
- `TimelineThemeData.signal`

## Entry points

- `timeline_v5.dart`
- existing aggregate and focused entry points continue to export compatible
  4.x and legacy APIs.

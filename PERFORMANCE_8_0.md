# Performance 8.0

## Safeguards

- lazy row construction through `ListView.builder`;
- no timer or animation controller per card;
- one lifecycle-aware planner clock;
- O(log n + k) viewport interval queries;
- recurrence and day plans remain reusable from the 6.x prepared-window engine;
- resize checks query a temporal index instead of scanning geometry in widgets;
- mutation state is tracked by entry ID and never duplicates app data;
- controller invalidation requests are targeted;
- bounded zoom and layout geometry;
- no background work after coordinator disposal.

## Reproducible benchmark

```bash
dart run benchmark/advanced_structured_timeline_benchmark.dart
```

The benchmark covers day-plan preparation, viewport queries, slot suggestions and resize conflict previews for 100, 500, 1,000 and 5,000 entries. This repository does not contain invented timing claims; measurements must be produced on the release machine.

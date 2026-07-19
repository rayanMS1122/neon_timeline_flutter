# Performance 5.0

No performance numbers are claimed until the release is measured with Flutter
profile and release builds.

## Implemented performance work

- immutable temporal index;
- binary-search entry into range queries;
- one query pass for text, status, resource, predicate, counts, and duration;
- recurrence expansion constrained by a requested window and hard occurrence
  limit;
- immutable scenario diff;
- custom-painted overview strip;
- lazy rows within each board column;
- lazy resource rows in the matrix;
- no timers or tickers in the new 5.0 views;
- existing render-plan cache and O(n log n) conflict planning retained.

## Benchmark harness

`benchmark/timeline_engine_benchmark.dart` now reports:

- temporal-index construction;
- combined query;
- render-plan construction;
- render-plan cache hit;
- day layout;
- analytics;
- capacity analysis.

Run:

```bash
dart run benchmark/timeline_engine_benchmark.dart
```

## Required release measurements

- 10, 100, 500, 1,000, and 5,000 entries;
- static idle;
- scrolling;
- filtering;
- resource matrix;
- board;
- scenario comparison;
- web release;
- Android profile;
- memory and garbage collections;
- P90 and P99 UI/raster frame times.

The release must not publish invented values.

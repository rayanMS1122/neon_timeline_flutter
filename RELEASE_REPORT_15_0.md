# Neon Timeline Flutter 15.0 release report

## Scope

Version 15 adds a new public Ultra Adaptive Planner layer and preserves the
complete earlier API surface. It focuses on measurable interaction isolation
rather than percentage-based performance claims.

## Delivered capabilities

- responsive command-island workspace;
- six-level semantic zoom with continuous slider feedback;
- Ctrl/Cmd+wheel and trackpad zoom input;
- four-level magnetic snap control;
- accessible two-thumb time-range slider and direct time entry;
- blocked-range visualization;
- adaptive entry cards and dedicated drag feedback surfaces;
- pure-Dart coordinate map, interval index and snap engine;
- optional scheduler frame diagnostics;
- full gallery example and regression tests.

## Compatibility

- Package version: `15.0.0`.
- All v1–v14 libraries remain exported.
- Existing host persistence and mutation callbacks are retained.
- v15 is additive; applications can continue importing an older versioned
  entrypoint.

## Release honesty

Static validation parsed 266 Dart files with zero syntax-problem files and
found zero missing relative dependency targets. Archive and patch integrity are
checked during packaging. Flutter SDK commands cannot be run here because neither
`flutter` nor `dart` is installed. The archive must therefore be analyzed,
tested and built in a real Flutter environment before publication.

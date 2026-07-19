# Performance 9.0

## Implemented architecture

- Existing immutable day render plan and recurrence window reuse
- Existing viewport range tracking and controlled invalidation
- One lifecycle-aware clock for the all-in-one production widget
- No timer or animation controller per task card
- Public hybrid gap policy with synchronized visual and navigation extents
- Compact cards remove secondary layout work for short entries
- Existing per-entry mutation locks and incremental drag/resize previews
- No package-owned database, repository, Bloc, Provider, Firebase, or Hive

## Verification status

No frame-time, CPU, memory, web-LCP, or build-size values are claimed in this
document. Real measurements require Flutter profile/release builds on target
platforms. Run `tool/verify_release.sh` and the benchmark targets before public
release.

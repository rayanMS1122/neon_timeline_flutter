# Test Report 4.0

## Added or expanded coverage

### Engine

- conflict classification, invalid-range isolation, and O(1) lookup indexes;
- invalid and duplicate IDs;
- local/UTC day clipping and calendar-date boundaries;
- deterministic overlap-column reuse;
- analytics occupancy union, peak concurrency, and exclusion of entries outside
  the requested range;
- adaptive reduced-motion policy;
- capacity resolution only for real resource assignments;
- entry revision changes when application values change;
- render-plan cache reuse;
- dependency ordering, duplicate-ID rejection, earliest/latest starts, slack,
  exact critical entries, exact critical dependencies, non-critical branches,
  and cycles;
- command history, late async completion after disposal, data sources, and
  plugin guards.

### Widgets

- `CalendarDayView` overlap rendering;
- `ResourceTimelineView` resource assignment rendering;
- `DependencyTimelineView` graph layers;
- `TimelineWorkspace` destination switching;
- host-supplied localization for advanced empty states;
- neutral timeline and planner adapters;
- complete example navigation, including all 4.0 studio destinations;
- reduced-motion settings and retained legacy showcases.

## Automated release commands

Linux/macOS:

```bash
./tool/verify_release.sh
```

Windows:

```powershell
./tool/verify_release.ps1
```

Both scripts require formatting, analyzer, package tests with coverage, the
engine benchmark harness, publish dry-run, example analyzer/tests, an Android
release build, and a web release build. CI additionally runs stable Flutter on Linux, Windows, and macOS
and validates the declared minimum Flutter 3.22.0.

## Validation status in this environment

The execution environment does not contain `flutter` or `dart` in `PATH`.
Therefore formatter, analyzer, Flutter tests, platform builds, web build, and
publish dry-run were not executed here and are not reported as passing.

Executed static checks found no delimiter, relative import/export, YAML, tracked
artifact, or public v4 export-coverage error. These checks are useful evidence,
but they are not a substitute for the Flutter toolchain.
